From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2016-02-20
Date: Sat, 20 Feb 2016 15:09:42 +0100
Message-ID: <56C873A6.2000102@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="bueBTDQdtRqjlIhIma75nWBSct5qWS8Vk"
Cc: David Miller <davem@davemloft.net>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--bueBTDQdtRqjlIhIma75nWBSct5qWS8Vk
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 9 patch for net-next/master.

The first 3 patches are from Damien Riegel, they add support for
Technologic Systems IP core to tje sja100 driver. The next patches 6 by
Marek Vasut (including one my me) first clean sort the CAN driver's
Kconfig and Makefiles and then add support for the IFI CANFD IP core.

Marc

---

The following changes since commit 80c804bfc487c6df783c258b9034b9d81c34f7=
a0:

  Merge branch 'bpf-get-stackid' (2016-02-20 00:21:44 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-4.6-20160220

for you to fetch changes up to 0c4d9c94a1303008b32079991360cea7ab849ef3:

  can: ifi: Add IFI CANFD IP support (2016-02-20 14:56:15 +0100)

----------------------------------------------------------------
linux-can-next-for-4.6-20160220

----------------------------------------------------------------
Damien Riegel (3):
      can: sja1000: of: add per-compatible init hook
      can: sja1000: add documentation for Technologic Systems version
      can: sja1000: of: add compatibility with Technologic Systems versio=
n

Marc Kleine-Budde (1):
      can: Kconfig: sort drivers alphabetically

Marek Vasut (5):
      can: Kconfig: Sort the Kconfig includes
      can: Makefile: Sort the Makefile
      of: Add vendor prefix for I/F/I
      can: ifi: Add DT bindings for ifi,canfd
      can: ifi: Add IFI CANFD IP support

 .../devicetree/bindings/net/can/ifi_canfd.txt      |  15 +
 .../devicetree/bindings/net/can/sja1000.txt        |   3 +-
 .../devicetree/bindings/vendor-prefixes.txt        |   1 +
 drivers/net/can/Kconfig                            |  64 +-
 drivers/net/can/Makefile                           |  17 +-
 drivers/net/can/ifi_canfd/Kconfig                  |   8 +
 drivers/net/can/ifi_canfd/Makefile                 |   5 +
 drivers/net/can/ifi_canfd/ifi_canfd.c              | 917 +++++++++++++++=
++++++
 drivers/net/can/sja1000/sja1000_platform.c         |  87 +-
 9 files changed, 1064 insertions(+), 53 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/can/ifi_canfd.t=
xt
 create mode 100644 drivers/net/can/ifi_canfd/Kconfig
 create mode 100644 drivers/net/can/ifi_canfd/Makefile
 create mode 100644 drivers/net/can/ifi_canfd/ifi_canfd.c

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--bueBTDQdtRqjlIhIma75nWBSct5qWS8Vk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWyHOpAAoJED07qiWsqSVq9HoIAIHNYFgFyolZM+V/a9Ixu+Ip
9naoJyhh7pRUBulZ5c4gnhkE4PMit7MkQn7XH27Eb8lrHNVlOJjDG2ecoNAjefaU
nAVrSCpbx+ZUN3TlP3Yj95OrsdG6nltODe1++8cqz/JR7mfWSaOdCgOqOO5c743u
rSC1ltLgAXwld7UlfJ6Yqbkct4kkdfK5OUW6GvsNEwo6BvF3Zdk85NjeSp/DVNJb
rR6fMP5+sERM+qRUb2mXXF32nLS79eZgS3SUghx/jqn8E11+f86j0s8QA1GnlP/X
XUvwESY9e/Nzw+lyPYwXA+3Cw4je5prAKOU0+5pBSjGIliOY/xfqR8avslYwOn4=
=sI89
-----END PGP SIGNATURE-----

--bueBTDQdtRqjlIhIma75nWBSct5qWS8Vk--
