From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2017-04-25
Date: Tue, 25 Apr 2017 10:44:26 +0200
Message-ID: <5a2d15d7-eb0f-f423-5814-df0babe5b749@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="C4cDn891Ux5bGEb5xamugNWvIDGG8xu2g"
Cc: David Miller <davem@davemloft.net>,
        "kernel@pengutronix.de" <kernel@pengutronix.de>,
        "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--C4cDn891Ux5bGEb5xamugNWvIDGG8xu2g
Content-Type: multipart/mixed; boundary="E4dadL66ikTK2bSGajP1UIaSNDe0mb95c";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Cc: David Miller <davem@davemloft.net>,
 "kernel@pengutronix.de" <kernel@pengutronix.de>,
 "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Message-ID: <5a2d15d7-eb0f-f423-5814-df0babe5b749@pengutronix.de>
Subject: pull-request: can-next 2017-04-25

--E4dadL66ikTK2bSGajP1UIaSNDe0mb95c
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 21 patches for net-next/master.

There are 4 patches by Stephane Grosjean for the PEAK PCAN-PCIe FD
CAN-FD boards. The next 7 patches are by Mario Huettel, which add
support for M_CAN IP version >=3D v3.1.x to the m_can driver. A patch by
Remigiusz Ko=C5=82=C5=82=C4=85taj adds support for the Microchip CAN BUS =
Analyzer. 8
patches by Oliver Hartkopp complete the initial CAN network namespace
support. Wei Yongjun's patch for the ti_hecc driver fixes the return
value check in the probe function.

Marc

---

The following changes since commit 14933dc8d9964e46f1d5bd2a4dfe3d3be8e420=
e0:

  sparc64: Improve 64-bit constant loading in eBPF JIT. (2017-04-24 20:32=
:15 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-4.12-20170425

for you to fetch changes up to b655f0e96d4061eac42dea2dccd37a3348d1f3f3:

  can: ti_hecc: fix return value check in ti_hecc_probe() (2017-04-25 10:=
03:40 +0200)

----------------------------------------------------------------
linux-can-next-for-4.12-20170425

----------------------------------------------------------------
Mario Huettel (7):
      can: m_can: Disabled Interrupt Line 1
      can: m_can: Removed initialization of FIFO water marks
      can: m_can: Removed virtual address from print
      can: m_can: Updated register defines to newest version
      can: m_can: Enable M_CAN version dependent initialization
      can: m_can: Configuration for TX and TX event FIFOs
      can: m_can: Enable TX FIFO Handling for M_CAN IP version >=3D v3.1.=
x

Oliver Hartkopp (8):
      can: fix memory leak in initial namespace support
      can: remove obsolete pernet_operations definitions
      can: remove obsolete definitions
      can: complete initial namespace support
      can: network namespace support for CAN_BCM protocol
      can: network namespace support for CAN gateway
      can: add Virtual CAN Tunnel driver (vxcan)
      can: enable module auto loading for virtual CAN interfaces

Remigiusz Ko=C5=82=C5=82=C4=85taj (1):
      can: mcba_usb: Add support for Microchip CAN BUS Analyzer

Stephane Grosjean (4):
      can: peak: fix usage of usb specific data type
      can: peak: fix usage of const qualifier in pointers args
      can: peak: move header file to new can common subdir
      can: peak: add support for PEAK PCAN-PCIe FD CAN-FD boards

Wei Yongjun (1):
      can: ti_hecc: fix return value check in ti_hecc_probe()

 drivers/net/can/Kconfig                            |  19 +
 drivers/net/can/Makefile                           |   2 +
 drivers/net/can/m_can/m_can.c                      | 752 +++++++++++++--=
--
 drivers/net/can/peak_canfd/Kconfig                 |  13 +
 drivers/net/can/peak_canfd/Makefile                |   5 +
 drivers/net/can/peak_canfd/peak_canfd.c            | 801 +++++++++++++++=
+++
 drivers/net/can/peak_canfd/peak_canfd_user.h       |  55 ++
 drivers/net/can/peak_canfd/peak_pciefd_main.c      | 842 +++++++++++++++=
++++
 drivers/net/can/ti_hecc.c                          |  12 +-
 drivers/net/can/usb/Kconfig                        |   6 +
 drivers/net/can/usb/Makefile                       |   1 +
 drivers/net/can/usb/mcba_usb.c                     | 904 +++++++++++++++=
++++++
 drivers/net/can/usb/peak_usb/pcan_usb_fd.c         |  25 +-
 drivers/net/can/vcan.c                             |   7 +-
 drivers/net/can/vxcan.c                            | 316 +++++++
 include/linux/can/core.h                           |   4 +-
 .../linux/can/dev/peak_canfd.h                     |  86 +-
 include/net/netns/can.h                            |   9 +
 include/uapi/linux/can/vxcan.h                     |  12 +
 net/can/af_can.c                                   |  77 +-
 net/can/af_can.h                                   |   9 -
 net/can/bcm.c                                      |  90 +-
 net/can/gw.c                                       |  72 +-
 net/can/proc.c                                     | 141 ++--
 24 files changed, 3888 insertions(+), 372 deletions(-)
 create mode 100644 drivers/net/can/peak_canfd/Kconfig
 create mode 100644 drivers/net/can/peak_canfd/Makefile
 create mode 100644 drivers/net/can/peak_canfd/peak_canfd.c
 create mode 100644 drivers/net/can/peak_canfd/peak_canfd_user.h
 create mode 100644 drivers/net/can/peak_canfd/peak_pciefd_main.c
 create mode 100644 drivers/net/can/usb/mcba_usb.c
 create mode 100644 drivers/net/can/vxcan.c
 rename drivers/net/can/usb/peak_usb/pcan_ucan.h =3D> include/linux/can/d=
ev/peak_canfd.h (73%)
 create mode 100644 include/uapi/linux/can/vxcan.h

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |




--E4dadL66ikTK2bSGajP1UIaSNDe0mb95c--

--C4cDn891Ux5bGEb5xamugNWvIDGG8xu2g
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlj/DGoACgkQHv7KIOw4
HPbBGQgAxThBE8y1jzC4Ohy9ky8pdXRXAEipqiFmEeGbjG3WJ5JoAJzZ2w8pAhzi
5i+SG8WDyIJw2ErJTm/l47su8lHDnQYrIi1XIY1zi8/ySk+7g1tY1D9l2ifHCv/4
UABzjmBiV/j5XwAdVN6g/Qx7z1yPBoMZc9qH1/HXHGy6b/cNd6vExqUQgOLV4vdj
rJURorNrtxx9HOirpCMx8OYpXOk7bli+c5MTeCDKpAfw1IMyq3789cSk7EDCtHUf
YUA3IFo+Xi/tPP+f7GeNSwI40shrIZsULneud46LNfdVBrY3TvSX+zMaMBvnNXBP
aNDiwfEIc95sjN7TUtgeRMyEb0OXww==
=8kin
-----END PGP SIGNATURE-----

--C4cDn891Ux5bGEb5xamugNWvIDGG8xu2g--
