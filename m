From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2016-06-17
Date: Thu, 23 Jun 2016 11:30:30 +0200
Message-ID: <0c371efc-6afa-130a-6752-50c3d5a0694c@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="wmJsXVQrSjhxX6GdtLuavrM2AGKl9BKr9"
Cc: David Miller <davem@davemloft.net>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--wmJsXVQrSjhxX6GdtLuavrM2AGKl9BKr9
Content-Type: multipart/mixed; boundary="079sod0RbOqEUETPlju00qW1p5Le2DWLU"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Cc: David Miller <davem@davemloft.net>,
 "kernel@pengutronix.de" <kernel@pengutronix.de>,
 "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Message-ID: <0c371efc-6afa-130a-6752-50c3d5a0694c@pengutronix.de>
Subject: pull-request: can-next 2016-06-17

--079sod0RbOqEUETPlju00qW1p5Le2DWLU
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 4 patches for net-next/master.

Arnd Bergmann's patch fixes a regresseion in af_can introduced in
linux-can-next-for-4.8-20160617. There are two patches by Ramesh
Shanmugasundaram, which add CAN-2.0 support to the rcar_canfd driver.
And a patch by Ed Spiridonov that adds better error diagnoses messages
to the Ed Spiridonov driver.

regards,
Marc

---

The following changes since commit b95e5928fcc76d156352570858abdea7b2628e=
fd:

  openvswitch: Add packet len info to upcall. (2016-06-22 16:34:39 -0400)=


are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-4.8-20160623

for you to fetch changes up to b63f69d0fc1fa1e25842a2266633862d523c380f:

  can: mcp251x: add message about sucessful/unsuccessful probe (2016-06-2=
3 11:23:49 +0200)

----------------------------------------------------------------
linux-can-next-for-4.8-20160623

----------------------------------------------------------------
Arnd Bergmann (1):
      can: only call can_stat_update with procfs

Ed Spiridonov (1):
      can: mcp251x: add message about sucessful/unsuccessful probe

Ramesh Shanmugasundaram (2):
      can: rcar_canfd: Add Classical CAN only mode support
      can: rcar_canfd: Add back-to-error-active support

 .../devicetree/bindings/net/can/rcar_canfd.txt     |  21 +-
 drivers/net/can/rcar/rcar_canfd.c                  | 429 ++++++++++++++-=
------
 drivers/net/can/spi/mcp251x.c                      |   7 +-
 net/can/af_can.c                                   |  22 +-
 net/can/af_can.h                                   |  11 -
 5 files changed, 328 insertions(+), 162 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--079sod0RbOqEUETPlju00qW1p5Le2DWLU--

--wmJsXVQrSjhxX6GdtLuavrM2AGKl9BKr9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJXa6w2AAoJED07qiWsqSVq87oIAKtBeB1B8vRayZ5NN/Gxzz09
5MGzi372vzlhpEMz9YpyU0o3U8s24ijjuVnL3q6VMXhBkye/1l9i0N+EJ31nZ8mV
AiIUsQG2/8mMkzD4KJ4uHVfUDCvvifABjDGy0jSS0I6pjGAA5D4eJYXdOMtzxc2e
R/JfWPxYG4u0bscLO8m4xAjGta9taEBN7MrZcuuO846Mxeh+BAxjbYa1bsuoj2DB
ZndigAbRJdKggNzteKlGIrnfPYukEE9AdF5eOCih5fq13z34OkSb1dTyPKTiD6JF
JZgSYzi7eZ0dR9TIR1NVMExfq3VHXwmvfCk4hAQ3XgpDZ1bOYJwAihwvbKZasQ0=
=+5XK
-----END PGP SIGNATURE-----

--wmJsXVQrSjhxX6GdtLuavrM2AGKl9BKr9--
