From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2012-09-22
Date: Sat, 22 Sep 2012 00:24:28 +0200
Message-ID: <505CE91C.1070504@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigCAE396B5F25D2CBDC791E97F"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigCAE396B5F25D2CBDC791E97F
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello David,

this pull request is intended for net-next (v3.7 cycle), it consist of
5 patches by AnilKumar bringing device tree support, runtime PM, suspend
resume and pinctrl support to the c_can/d_can driver.

Andreas Larsson improves the sja1000 driver (one-shot, listen only).
Randy Dunlap fixes a function name conflict in the peak driver.
Wei Yongjun fixes a return value check in the mscan-mpc5xxx driver.

regards, Marc
--

The following changes since commit abb17e6c0c7b27693201dc85f75dbb184279fd=
10:

  netlink: use <linux/export.h> instead of <linux/module.h> (2012-09-21 1=
5:43:58 -0400)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can-next.git for-davem

for you to fetch changes up to cb8db899a6b73334b41fd1a72252533afdf080dc:

  can: sja1000: Add support for listen-only mode and one-shot mode (2012-=
09-21 23:58:49 +0200)

----------------------------------------------------------------
Andreas Larsson (1):
      can: sja1000: Add support for listen-only mode and one-shot mode

AnilKumar Ch (5):
      can: c_can: Modify c_can device names
      can: c_can: Add device tree support to Bosch C_CAN/D_CAN controller=

      can: c_can: Add runtime PM support to Bosch C_CAN/D_CAN controller
      can: c_can: Add d_can suspend resume support
      can: c_can: Adopt pinctrl support

Randy Dunlap (1):
      can: usb: peak: rename peak_usb dump_mem function

Wei Yongjun (1):
      can: mscan-mpc5xxx: fix return value check in mpc512x_can_get_clock=
()

 .../devicetree/bindings/net/can/c_can.txt          |   49 ++++++++
 drivers/net/can/c_can/c_can.c                      |  127 ++++++++++++++=
+++++-
 drivers/net/can/c_can/c_can.h                      |   14 ++-
 drivers/net/can/c_can/c_can_pci.c                  |    6 +-
 drivers/net/can/c_can/c_can_platform.c             |  123 ++++++++++++++=
++---
 drivers/net/can/mscan/mpc5xxx_can.c                |    4 +-
 drivers/net/can/sja1000/sja1000.c                  |   31 +++--
 drivers/net/can/usb/peak_usb/pcan_usb_core.c       |    8 +-
 drivers/net/can/usb/peak_usb/pcan_usb_core.h       |    2 +-
 drivers/net/can/usb/peak_usb/pcan_usb_pro.c        |    8 +-
 10 files changed, 332 insertions(+), 40 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/can/c_can.txt

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigCAE396B5F25D2CBDC791E97F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://www.enigmail.net/

iEYEARECAAYFAlBc6SAACgkQjTAFq1RaXHOWNwCfXJOB3RS0kn2zc5LQ1GLagsG+
sqcAnRgDzbABNgIbAq4x6wCOr+8Lt4Qt
=subJ
-----END PGP SIGNATURE-----

--------------enigCAE396B5F25D2CBDC791E97F--
