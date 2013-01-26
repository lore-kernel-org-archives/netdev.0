From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2013-01-26
Date: Sat, 26 Jan 2013 17:09:07 +0100
Message-ID: <5103FFA3.5020507@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2ACQLJIANNAKVKSKWMLRH"
To: netdev@vger.kernel.org,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2ACQLJIANNAKVKSKWMLRH
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull-request for net-next/master. There is are 9 patches by=20
Fabio Baltieri and Kurt Van Dijck which add LED infrastructure and
support for CAN devices. Bernd Krumboeck adds a driver for the USB CAN
adapter from 8 devices. Oliver Hartkopp improves the CAN gateway
functionality. There are 4 patches by me, which clean up the CAN's
Kconfig.

regards,
Marc
---

The following changes since commit 93b9c1ddd3fb4a5b67d512e534b30070f9ecec=
28:

  Merge branch 'testing' of git://git.kernel.org/pub/scm/linux/kernel/git=
/klassert/ipsec-next (2013-01-23 14:00:16 -0500)

are available in the git repository at:


  git://gitorious.org/linux-can/linux-can-next.git for-davem

for you to fetch changes up to e6afa00a1409bc3bceed9ccb33111519463dfe7b:

  can: gw: indicate and count deleted frames due to misconfiguration (201=
3-01-26 16:59:02 +0100)

----------------------------------------------------------------
Bernd Krumboeck (2):
      can: usb_8dev: Add support for USB2CAN interface from 8 devices
      can: usb_8dev: add LED trigger support

Fabio Baltieri (7):
      can: add tx/rx LED trigger support
      can: flexcan: add LED trigger support
      can: at91_can: add LED trigger support
      can: ti_hecc: add LED trigger support
      can: c_can: add LED trigger support
      can: mcp251x: add LED trigger support
      can: sja1000: add LED trigger support

Kurt Van Dijck (2):
      can: export a safe netdev_priv wrapper for candev
      can: rename LED trigger name on netdev renames

Marc Kleine-Budde (4):
      can: Kconfig: convert 'depends on CAN' into 'if CAN...endif' block
      can: Kconfig: convert 'depends on CAN_DEV' into 'if CAN_DEV...endif=
' block
      can: Kconfig: switch on all CAN protocolls by default
      can: sja1000: correct indention of Kconfig help text

Oliver Hartkopp (4):
      can: add private data space for CAN sk_buffs
      can: gw: make routing to the incoming CAN interface configurable
      can: gw: add a variable limit for CAN frame routings
      can: gw: indicate and count deleted frames due to misconfiguration

 drivers/net/can/Kconfig           |   37 +-
 drivers/net/can/Makefile          |    2 +
 drivers/net/can/at91_can.c        |   10 +
 drivers/net/can/c_can/Kconfig     |    2 +-
 drivers/net/can/c_can/c_can.c     |   10 +
 drivers/net/can/cc770/Kconfig     |    2 +-
 drivers/net/can/dev.c             |   26 +-
 drivers/net/can/flexcan.c         |   11 +
 drivers/net/can/led.c             |  124 +++++
 drivers/net/can/mcp251x.c         |   23 +-
 drivers/net/can/mscan/Kconfig     |    2 +-
 drivers/net/can/sja1000/Kconfig   |   14 +-
 drivers/net/can/sja1000/sja1000.c |   17 +-
 drivers/net/can/slcan.c           |    8 +-
 drivers/net/can/softing/Kconfig   |    2 +-
 drivers/net/can/ti_hecc.c         |   10 +
 drivers/net/can/usb/Kconfig       |    8 +-
 drivers/net/can/usb/Makefile      |    1 +
 drivers/net/can/usb/usb_8dev.c    | 1033 +++++++++++++++++++++++++++++++=
++++++
 include/linux/can/dev.h           |   11 +
 include/linux/can/led.h           |   51 ++
 include/linux/can/skb.h           |   35 ++
 include/uapi/linux/can/gw.h       |    2 +
 net/can/Kconfig                   |   13 +-
 net/can/bcm.c                     |   12 +-
 net/can/gw.c                      |   74 ++-
 net/can/raw.c                     |    8 +-
 27 files changed, 1488 insertions(+), 60 deletions(-)
 create mode 100644 drivers/net/can/led.c
 create mode 100644 drivers/net/can/usb/usb_8dev.c
 create mode 100644 include/linux/can/led.h
 create mode 100644 include/linux/can/skb.h

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


------enig2ACQLJIANNAKVKSKWMLRH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlED/6cACgkQjTAFq1RaXHMgjgCeLwBZLKdyHQQGCHzjyO+oKxyU
9SEAnRpsjtydAL/0C9gLlgUD31k4ZJa8
=48sa
-----END PGP SIGNATURE-----

------enig2ACQLJIANNAKVKSKWMLRH--
