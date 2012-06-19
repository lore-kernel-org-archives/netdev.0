From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2012-06-19
Date: Tue, 19 Jun 2012 22:01:56 +0200
Message-ID: <4FE0DAB4.6080400@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig3730D6B992A1AE3C1375DB01"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig3730D6B992A1AE3C1375DB01
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello David,

here is our second pull request for net-next. In this series Federico
Vaga adds a pci driver for c_can/d_can hardware using the existing
generic c_can driver. The remaining 6 patches are by Oliver Hartkopp.
He adds CANFD support to the CAN stack while keeping binary
compatibility for existing applications. CANFD is an extension to the
existing CAN standard, it allows longer CAN frames and/or higher data
rates. There's no real hardware available yet, but this series adds
CANFD support to the vcan driver.

regards,
Marc

---

The following changes since commit b31525d16b50fe0eb33545afbc0be1a03f2896=
e3:

  net: lpc_eth: Driver cleanup (2012-06-19 00:27:03 -0700)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can-next.git master

for you to fetch changes up to ea53fe0c667ad3cae61d4d71d2be41908ac5c0a4:

  canfd: update documentation according to CAN FD extensions (2012-06-19 =
21:40:26 +0200)

----------------------------------------------------------------
Federico Vaga (1):
      c_can_pci: generic module for C_CAN/D_CAN on PCI

Oliver Hartkopp (6):
      canfd: add new data structures and constants
      canfd: add support for CAN FD in PF_CAN core
      canfd: add support for CAN FD in CAN_RAW sockets
      candev: add/update helpers for CAN FD
      vcan: add CAN FD support
      canfd: update documentation according to CAN FD extensions

 Documentation/networking/can.txt  |  154 ++++++++++++++++++++++++++++--
 drivers/net/can/c_can/Kconfig     |    7 ++
 drivers/net/can/c_can/Makefile    |    1 +
 drivers/net/can/c_can/c_can_pci.c |  236 +++++++++++++++++++++++++++++++=
+++++++++++++++
 drivers/net/can/dev.c             |   35 ++++++-
 drivers/net/can/vcan.c            |   27 ++++--
 include/linux/can.h               |   59 +++++++++++-
 include/linux/can/core.h          |    4 +-
 include/linux/can/dev.h           |   33 +++++--
 include/linux/can/raw.h           |    3 +-
 include/linux/if_ether.h          |    3 +-
 net/can/af_can.c                  |  116 +++++++++++++++++------
 net/can/raw.c                     |   50 +++++++++-
 13 files changed, 664 insertions(+), 64 deletions(-)
 create mode 100644 drivers/net/can/c_can/c_can_pci.c


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig3730D6B992A1AE3C1375DB01
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk/g2rkACgkQjTAFq1RaXHOc6gCcCaSORY83vo4jPoy+ng9EPR2l
UsUAn2+KSxyyIySIonsJBM1fD1CqOPIx
=hNB4
-----END PGP SIGNATURE-----

--------------enig3730D6B992A1AE3C1375DB01--
