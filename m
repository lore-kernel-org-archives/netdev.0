From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2012-11-27
Date: Tue, 27 Nov 2012 09:57:34 +0100
Message-ID: <50B4807E.8010607@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig07297DF6009613D8384EFCE1"
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig07297DF6009613D8384EFCE1
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello David,

this is pull request is for net-next. Contains a patch by Andreas
Larsson, which enables the sja1000 of driver to work under sparc.
AnilKumar Ch contributed a patch to improve the c_can support under
omap, Olivier Sobrie's patch brings support for the CAN/USB dongles
from Kvaser. In a bunch of patches by me missing MODULE_ALIAS and/or
MODULE_DEVICE_TABLE entries were added to the CAN drivers.

regards,
Marc

---

The following changes since commit 03f52a0a554210d5049eeed9f1bb29047dc807=
cb:

  ip6mr: Add sizeof verification to MRT6_ASSERT and MT6_PIM (2012-11-26 1=
7:35:58 -0500)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can-next.git for-davem

for you to fetch changes up to fc8f40b10e58f37ec07e7b0cf85d19e899bdf23f:

  can: mpc5xxx_can: add MODULE_DEVICE_TABLE (2012-11-27 09:49:36 +0100)

----------------------------------------------------------------
Andreas Larsson (1):
      can: sja1000: Make sja1000_of_platform selectable and compilable on=
 SPARC

AnilKumar Ch (1):
      can: c_can: Add d_can raminit support

Marc Kleine-Budde (8):
      can: bfin_can: add MODULE_ALIAS
      can: ti_hecc: add MODULE_ALIAS
      can: sja1000_platform: add MODULE_ALIAS
      can: cc770_platform: add MODULE_ALIAS and MODULE_DEVICE_TABLE
      can: flexcan: add MODULE_DEVICE_TABLE
      can: at91_can: add MODULE_DEVICE_TABLE
      can: c_can_platform: add MODULE_DEVICE_TABLE
      can: mpc5xxx_can: add MODULE_DEVICE_TABLE

Olivier Sobrie (1):
      can: kvaser_usb: Add support for Kvaser CAN/USB devices

 drivers/net/can/at91_can.c                    |    1 +
 drivers/net/can/bfin_can.c                    |    1 +
 drivers/net/can/c_can/c_can.c                 |   12 +
 drivers/net/can/c_can/c_can.h                 |    3 +
 drivers/net/can/c_can/c_can_platform.c        |   30 +-
 drivers/net/can/cc770/cc770_platform.c        |    2 +
 drivers/net/can/flexcan.c                     |    2 +
 drivers/net/can/mscan/mpc5xxx_can.c           |    1 +
 drivers/net/can/sja1000/Kconfig               |    2 +-
 drivers/net/can/sja1000/sja1000_of_platform.c |    6 +-
 drivers/net/can/sja1000/sja1000_platform.c    |    1 +
 drivers/net/can/ti_hecc.c                     |    1 +
 drivers/net/can/usb/Kconfig                   |   29 +
 drivers/net/can/usb/Makefile                  |    1 +
 drivers/net/can/usb/kvaser_usb.c              | 1627 +++++++++++++++++++=
++++++
 15 files changed, 1715 insertions(+), 4 deletions(-)
 create mode 100644 drivers/net/can/usb/kvaser_usb.c

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig07297DF6009613D8384EFCE1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iEYEARECAAYFAlC0gIEACgkQjTAFq1RaXHMsKACgik0OOUBPZfapVhopr4FsJWwY
nOcAn3wDYru5MXmEmq+KXYxepztIikpq
=Fois
-----END PGP SIGNATURE-----

--------------enig07297DF6009613D8384EFCE1--
