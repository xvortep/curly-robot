using ControlSystems, Plots

function sistem(p)
  G1 = tf(2, [0.2, 1])
  G2 = tf([1.2, 1], [1, 2, 0.1])
  G3 = tf(4, [1, 3, 2])
  G4 = tf(1, [0.1, 1])
  K1 = tf(p[1])
  K2 = tf(p[2])
  # W11 -> U1, Y
  G12 = minreal(series(G1, G2))
  G32 = minreal(feedback(G3, K2))
  G324 = minreal(series(G32, G4))
  G3241 = minreal(series(K1, -G324))
  Gp = minreal(parallel(tf(1), -G3241))
  W11 = minreal(series(G12, Gp))
  # W12 -> U2, Y
  G32 = minreal(feedback(G3, K2))
  W12 = minreal(series(G32, -G4))
  return (W11, W12)
end

k1 = [0.1, 0.3, 0.7]
k2 = [0.2, 0.5]
pairs = vec([(i, j) for i in k1, j in k2])

t = 0:0.01:10

u1 = sin.(t)
u2 = cos.(t)

wa = @. sistem(pairs)
w11 = [w[1] for w in wa]
w22 = [w[2] for w in wa]

y1o = [lsim(w, u1', t) for w in w11]
y2o = [lsim(w, u2', t) for w in w22]
yy1 = [yy[1] for yy in y1o]
yy2 = [yy[1] for yy in y2o]

yp = @. yy1 + yy2
y = [vec(h) for h in yp]

plot(t, y, lw=2, xticks=0:2:10, xlabel="t")

