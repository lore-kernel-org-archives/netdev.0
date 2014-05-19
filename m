From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2014-05-19
Date: Mon, 19 May 2014 09:46:22 +0200
Message-ID: <5379B6CE.60004@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="oramG9CR3IlvUJ1t2KBqdvnSFwbstFn9F"
Cc: David Miller <davem@davemloft.net>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--oramG9CR3IlvUJ1t2KBqdvnSFwbstFn9F
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 13 patches for net-next/master.

A patch by Dan Carpenter fixes a coccinelle warning in the mcp251x
driver. Jean Delvare contributes three patches to tightening the
Kconfig dependencies for some drivers. Then come three patches by Pavel
Machek that improve the c_can driver support on the socfpga platform.
Sergei Shtylyov's patch brings support for the CAN hardware found on
Renesas R-Car CAN controllers. Four patches by Oliver Hartkopp, the
first cleans up the guard macros in the CAN headers the other three
improve the EFF frame filtering. Maximilian Schneider's patch adds
support for the GS_USB CAN devices.

Marc

---
The following changes since commit b6052af61a9e0dee236bcf4c69843126c0d28e=
4f:

  Merge tag 'batman-adv-for-davem' of git://git.open-mesh.org/linux-merge=
 (2014-05-18 21:27:09 -0400)

are available in the git repository at:


  git://gitorious.org/linux-can/linux-can-next.git linux-can-next-for-3.1=
6-20140519

for you to fetch changes up to d08e973a77d128b25e01a08c34d89593fdf222da:

  can: gs_usb: Added support for the GS_USB CAN devices (2014-05-19 09:38=
:25 +0200)

----------------------------------------------------------------
linux-can-next-for-3.16-20140519

----------------------------------------------------------------
Dan Carpenter (1):
      can: mcp251x: fix coccinelle warnings

Jean Delvare (3):
      can: at91_can: Fix Kconfig dependencies
      can: mscan: Fix Kconfig dependencies
      can: pch_can: Fix Kconfig dependencies

Maximilian Schneider (1):
      can: gs_usb: Added support for the GS_USB CAN devices

Oliver Hartkopp (4):
      can: unify identifiers to ensure unique include processing
      can: proc: make array printing function indenpendent from sff frame=
s
      can: add hash based access to single EFF frame filters
      can: add documentation for CAN filter usage optimisation

Pavel Machek (3):
      can: c_can: make {read,write}_reg functions const
      can: c_can: Add and make use of 32-bit accesses functions
      can: c_can: add hwinit support for non-TI devices

Sergei Shtylyov (1):
      can: add Renesas R-Car CAN driver

 Documentation/networking/can.txt       |  35 ++
 drivers/net/can/Kconfig                |  14 +-
 drivers/net/can/Makefile               |   1 +
 drivers/net/can/c_can/c_can.c          |  15 +-
 drivers/net/can/c_can/c_can.h          |   8 +-
 drivers/net/can/c_can/c_can_pci.c      |  31 +-
 drivers/net/can/c_can/c_can_platform.c |  84 ++-
 drivers/net/can/mscan/Kconfig          |   2 +-
 drivers/net/can/rcar_can.c             | 876 +++++++++++++++++++++++++++=
++
 drivers/net/can/spi/mcp251x.c          |   2 +-
 drivers/net/can/usb/Kconfig            |   8 +
 drivers/net/can/usb/Makefile           |   1 +
 drivers/net/can/usb/gs_usb.c           | 971 +++++++++++++++++++++++++++=
++++++
 include/linux/can/core.h               |   6 +-
 include/linux/can/dev.h                |   6 +-
 include/linux/can/led.h                |   6 +-
 include/linux/can/platform/cc770.h     |   6 +-
 include/linux/can/platform/mcp251x.h   |   6 +-
 include/linux/can/platform/rcar_can.h  |  17 +
 include/linux/can/platform/sja1000.h   |   6 +-
 include/linux/can/platform/ti_hecc.h   |   6 +-
 include/linux/can/skb.h                |   6 +-
 include/uapi/linux/can.h               |   6 +-
 include/uapi/linux/can/bcm.h           |   6 +-
 include/uapi/linux/can/error.h         |   6 +-
 include/uapi/linux/can/gw.h            |   6 +-
 include/uapi/linux/can/netlink.h       |   6 +-
 include/uapi/linux/can/raw.h           |   6 +-
 net/can/af_can.c                       |  31 +-
 net/can/af_can.h                       |   9 +-
 net/can/proc.c                         |  76 ++-
 31 files changed, 2170 insertions(+), 95 deletions(-)
 create mode 100644 drivers/net/can/rcar_can.c
 create mode 100644 drivers/net/can/usb/gs_usb.c
 create mode 100644 include/linux/can/platform/rcar_can.h

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |












--oramG9CR3IlvUJ1t2KBqdvnSFwbstFn9F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlN5ts4ACgkQjTAFq1RaXHMPSgCdFFnO62SLL8R8AobXiqOvcmTm
5CMAnjJNDjEjskVlAcM1629r5AQvDe/r
=/645
-----END PGP SIGNATURE-----

--oramG9CR3IlvUJ1t2KBqdvnSFwbstFn9F--
