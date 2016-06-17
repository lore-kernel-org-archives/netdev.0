From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2016-06-17
Date: Fri, 17 Jun 2016 16:31:46 +0200
Message-ID: <7075a8b3-562d-3de2-80f7-b593c665adef@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="64Lb1pP9oUX6fh4avVQHjTHvLGdB8aRd0"
Cc: David Miller <davem@davemloft.net>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--64Lb1pP9oUX6fh4avVQHjTHvLGdB8aRd0
Content-Type: multipart/mixed; boundary="QOHlRGIbHQMg06e0Id6nuu1V4wXNh5PuI"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Cc: David Miller <davem@davemloft.net>,
 "kernel@pengutronix.de" <kernel@pengutronix.de>,
 "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Message-ID: <7075a8b3-562d-3de2-80f7-b593c665adef@pengutronix.de>
Subject: pull-request: can-next 2016-06-17

--QOHlRGIbHQMg06e0Id6nuu1V4wXNh5PuI
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 14 patches for net-next/master.

Geert Uytterhoeven contributes a patch that adds a file patterns for
CAN device tree bindings to MAINTAINERS. A patch by Alexander Aring
fixes warnings when building without proc support. A patch by me=20
improves the sample point calculation. Marek Vasut's patch converts
the slcan driver to use CAN_MTU. A patch by William Breathitt Gray
converts the tscan1 driver to use module_isa_driver.

Two patches by Maximilian Schneider for the gs_usb driver fix coding
style and add support for set_phys_id callback. 5 patches by Oliver
Hartkopp add support for CANFD to the bcm. And finally two patches
by Ramesh Shanmugasundaram, which add support for the rcar_canfd
driver.

regards,
Marc

---

The following changes since commit 9f6ed032cd951d2427995578c51af1b50c054e=
fa:

  net, cls: also reject deleting all filters when TCA_KIND present (2016-=
06-16 22:50:16 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-4.8-20160617

for you to fetch changes up to a23b97e6255b83babd28345e43a29508981f931e:

  can: rcar_can: Move Renesas CAN driver to rcar dir (2016-06-17 15:39:48=
 +0200)

----------------------------------------------------------------
linux-can-next-for-4.8-20160617

----------------------------------------------------------------
Alexander Aring (1):
      can: build proc support only if CONFIG_PROC_FS is activated

Geert Uytterhoeven (1):
      MAINTAINERS: Add file patterns for can device tree bindings

Marc Kleine-Budde (1):
      can: dev: can-calc-bit-timing(): better sample point calculation

Marek Vasut (1):
      can: slcan: Replace sizeof struct can_frame with CAN_MTU

Maximilian Schneider (2):
      can: gs_usb: codingstyle: introduce use of BIT() + fix indention
      can: gs_usb: add ethtool set_phys_id callback to locate physical de=
vice

Oliver Hartkopp (5):
      can: bcm: fix indention and other minor style issues
      can: bcm: use CAN frame instead of can_frame in comments
      can: bcm: unify bcm_msg_head handling and prepare function paramete=
rs
      can: bcm: add support for CAN FD frames
      can: bcm: add documentation for CAN FD support

Ramesh Shanmugasundaram (2):
      can: rcar_canfd: Add Renesas R-Car CAN FD driver
      can: rcar_can: Move Renesas CAN driver to rcar dir

William Breathitt Gray (1):
      can: tscan1: Utilize the module_isa_driver macro

 .../devicetree/bindings/net/can/rcar_canfd.txt     |   89 +
 Documentation/networking/can.txt                   |   25 +-
 MAINTAINERS                                        |    1 +
 drivers/net/can/Kconfig                            |   11 +-
 drivers/net/can/Makefile                           |    2 +-
 drivers/net/can/dev.c                              |  140 +-
 drivers/net/can/rcar/Kconfig                       |   21 +
 drivers/net/can/rcar/Makefile                      |    6 +
 drivers/net/can/{ =3D> rcar}/rcar_can.c              |    0
 drivers/net/can/rcar/rcar_canfd.c                  | 1695 ++++++++++++++=
++++++
 drivers/net/can/sja1000/tscan1.c                   |   12 +-
 drivers/net/can/slcan.c                            |    4 +-
 drivers/net/can/usb/gs_usb.c                       |  141 +-
 include/uapi/linux/can/bcm.h                       |    1 +
 net/can/Makefile                                   |    3 +-
 net/can/af_can.h                                   |   11 +
 net/can/bcm.c                                      |  309 ++--
 net/can/proc.c                                     |    3 +-
 18 files changed, 2219 insertions(+), 255 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/can/rcar_canfd.=
txt
 create mode 100644 drivers/net/can/rcar/Kconfig
 create mode 100644 drivers/net/can/rcar/Makefile
 rename drivers/net/can/{ =3D> rcar}/rcar_can.c (100%)
 create mode 100644 drivers/net/can/rcar/rcar_canfd.c

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--QOHlRGIbHQMg06e0Id6nuu1V4wXNh5PuI--

--64Lb1pP9oUX6fh4avVQHjTHvLGdB8aRd0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJXZAnSAAoJED07qiWsqSVqOWoH/2s7/0Eye2KbC1wMlM/jeWHD
wMsHUG5wqhDhcl/uOcI89dmOKoANCqwi9VcSH1R7l2+nntKQNvxteGbx1vRTjXqH
2dAgys4SpR/SJagIx8fFCknHd8kH0g30tgLk6zMoNTH/Z97Kzl8Rb0+mGeBeUbH1
otekmTFMUsGCGcllpJ6gTD1QrAQW2HbsiNsSLzrTo2IKzDqn2Q3uZKl3Vse55naC
rNDBf8XqhyEXiKfrnPcXgkI3PcR+tHm25yKa3HJIcNlsy2CVfvQMf9BU3Z7uAMKW
NJmzoMzmvgRYUlTjnONI5FCZkwtiziM0b5E19Awu8LddiEa4A2zyvIYydC8Xpt0=
=f+3X
-----END PGP SIGNATURE-----

--64Lb1pP9oUX6fh4avVQHjTHvLGdB8aRd0--
