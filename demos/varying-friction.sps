
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(import (rnrs)
	(gl)
	(glut)
        (dharmalab misc limit-call-rate)
	(agave glamour misc)
	(agave glamour window)
	(box2d-lite util math)
	(box2d-lite vec)
	(box2d-lite mat)
	(box2d-lite body)
	(box2d-lite world)
        (surfage s27 random-bits))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(initialize-glut)

(window (size 800 800)
	(title "Box2d Lite - Varying Friction")
	(reshape (width height)
		 (lambda (w h)
		   (glMatrixMode GL_PROJECTION)
		   (glLoadIdentity)
		   (glOrtho -20.0 20.0 -20.0 20.0 -1000.0 1000.0))))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(random-source-randomize! default-random-source)

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define bodies '())

(define time-step 0.008)

(define world (make-world #f #f #f (make-vec 0.0 -10.0) 10))

(is-world world)

(define bomb #f)

(is-body bomb)

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (launch-bomb)

  (if (not bomb)
      
      (begin

	(set! bomb (create-body))

	(bomb.set (make-vec 1.0 1.0) 50.0)

	(bomb.friction! 0.2)

	(world.add-body bomb)

	(set! bodies (cons bomb bodies))

	))

  (bomb.position! (make-vec (+ -15.0 (* (random-real) 30.0))
			    15.0))

  (bomb.rotation! (+ -1.5 (* (random-real) 3.0)))

  (bomb.velocity! (n*v -1.5 bomb.position))

  (bomb.angular-velocity! (+ -20.0 (* (random-real) 40.0))))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define draw-body-print-data? #f)

(define (draw-body body)

  (is-body body)

  (let ((R (angle->mat body.rotation))
	(x body.position)
	(h (n*v 0.5 body.width)))

    (is-vec h)

    (let ((v1 (v+ x (m*v R (make-vec (- h.x) (- h.y)))))
	  (v2 (v+ x (m*v R (make-vec    h.x  (- h.y)))))
	  (v3 (v+ x (m*v R (make-vec    h.x     h.y ))))
	  (v4 (v+ x (m*v R (make-vec (- h.x)    h.y )))))

      (is-vec v1)
      (is-vec v2)
      (is-vec v3)
      (is-vec v4)

      (if (eq? body bomb)
	  (glColor3f 0.4 0.9 0.4)
	  (glColor3f 0.8 0.8 0.9))

      (gl-begin GL_LINE_LOOP
	(glVertex2d v1.x v1.y)
	(glVertex2d v2.x v2.y)
	(glVertex2d v3.x v3.y)
	(glVertex2d v4.x v4.y)))))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(world.clear)

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(let ((b (create-body)))
  (is-body b)
  (is-vec b.width)
  (b.set (make-vec 100.0 20.0) FLT-MAX)
  (b.friction! 0.2)
  (b.position! (make-vec 0.0 (* -0.5 b.width.y)))
  (b.rotation! 0.0)
  (world.add-body b)
  (set! bodies (cons b bodies)))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(let ((b (create-body)))
  (is-body b)
  (b.set (make-vec 13.0 0.25) FLT-MAX)
  (b.position! (make-vec -2.0 11.0))
  (b.rotation! -0.25)
  (world.add-body b)
  (set! bodies (cons b bodies)))

(let ((b (create-body)))
  (is-body b)
  (b.set (make-vec 0.25 1.0) FLT-MAX)
  (b.position! (make-vec 5.25 0.5))
  (b.rotation! 0.0)
  (world.add-body b)
  (set! bodies (cons b bodies)))

(let ((b (create-body)))
  (is-body b)
  (b.set (make-vec 13.0 0.25) FLT-MAX)
  (b.position! (make-vec 2.0 7.0))
  (b.rotation! 0.25)
  (world.add-body b)
  (set! bodies (cons b bodies)))

(let ((b (create-body)))
  (is-body b)
  (b.set (make-vec 0.25 1.0) FLT-MAX)
  (b.position! (make-vec -5.25 5.5))
  (b.rotation! 0.0)
  (world.add-body b)
  (set! bodies (cons b bodies)))

(let ((b (create-body)))
  (is-body b)
  (b.set (make-vec 13.0 0.25) FLT-MAX)
  (b.position! (make-vec -2.0 3.0))
  (b.rotation! -0.25)
  (world.add-body b)
  (set! bodies (cons b bodies)))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(for-each
 (lambda (i friction)
   (let ((b (create-body)))
     (is-body b)
     (b.set (make-vec 0.5 0.5) 25.0)
     (b.position! (make-vec (+ -7.5 (* 2.0 i)) 14.0))
     (b.friction! friction)
     (b.rotation! 0.0)
     (world.add-body b)
     (set! bodies (cons b bodies))))
 '(0 1 2 3 4)
 '(0.75 0.5 0.35 0.1 0.0))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(buffered-display-procedure
 (lambda ()
   (background 0.0)
   (world.step time-step)
   (for-each draw-body bodies)))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(glutIdleFunc (limit-call-rate 60 (glutPostRedisplay)))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(glutKeyboardFunc
 (lambda (key x y)
   (case (integer->char key)
     ((#\space) (launch-bomb)))))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(display "Press <space> to throw the bomb\n")

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(glutMainLoop)
