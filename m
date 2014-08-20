From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2014-08-20
Date: Wed, 20 Aug 2014 16:49:36 +0200
Message-ID: <53F4B580.3030802@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="DQq4Vjdal6xTgT3kxTltECCU71ToW9TK2"
Cc: David Miller <davem@davemloft.net>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34180 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683AbaHTOtz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2014 10:49:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--DQq4Vjdal6xTgT3kxTltECCU71ToW9TK2
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 10 patches for net-next/master.

There is one patch by Wolfram Sang to clean up the build system.
Two patches by Stefan Agner that add vf610 support to the flexcan
driver. Dong Aisheng add support for bosch's m_can core, which is found
in the new freescale ARM SoCs. Sergei Shtylyov improves the rcar_can
driver by supporting all input clocks and adding device tree support.
The next patch is a small cleanup for the bit rate calculation function
by Lad, Prabhakar. And finally a patch by Himangi Saraogi, which
converts the mcp251x driver to use dmam_alloc_coherent.

Marc

---
The following changes since commit c9d26423e56ce1ab4d786f92aebecf859d4192=
93:

  Merge tag 'pm+acpi-3.17-rc1-2' of git://git.kernel.org/pub/scm/linux/ke=
rnel/git/rafael/linux-pm (2014-08-14 18:13:46 -0600)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can-next.git tags/linux-can-next-fo=
r-3.18-20140820

for you to fetch changes up to 3a73aeff37c2e425b11d19c19e42e8269d58d417:

  can: mcp251x: Use dmam_alloc_coherent (2014-08-18 01:03:43 +0200)

----------------------------------------------------------------
linux-can-next-for-3.18-20140820

----------------------------------------------------------------
Dong Aisheng (2):
      can: m_can: add device tree binding documentation
      can: m_can: add Bosch M_CAN controller support

Himangi Saraogi (1):
      can: mcp251x: Use dmam_alloc_coherent

Lad, Prabhakar (1):
      can: dev: remove unused variable from can_calc_bittiming() function=


Sergei Shtylyov (3):
      can: rcar_can: support all input clocks
      can: rcar_can: document device tree bindings
      can: rcar_can: add device tree support

Stefan Agner (2):
      can: flexcan: flexcan_get_berr_counter(): switch on clocks before a=
ccessing ecr register
      can: flexcan: add vf610 support for FlexCAN

Wolfram Sang (1):
      net: can: use kbuild magic to inherit debug settings

 .../devicetree/bindings/net/can/m_can.txt          |   67 ++
 .../devicetree/bindings/net/can/rcar_can.txt       |   43 +
 drivers/net/can/Kconfig                            |    2 +
 drivers/net/can/Makefile                           |    3 +-
 drivers/net/can/c_can/Makefile                     |    2 -
 drivers/net/can/cc770/Makefile                     |    2 -
 drivers/net/can/dev.c                              |    3 +-
 drivers/net/can/flexcan.c                          |  111 +-
 drivers/net/can/m_can/Kconfig                      |    4 +
 drivers/net/can/m_can/Makefile                     |    5 +
 drivers/net/can/m_can/m_can.c                      | 1202 ++++++++++++++=
++++++
 drivers/net/can/mscan/Makefile                     |    2 -
 drivers/net/can/rcar_can.c                         |   66 +-
 drivers/net/can/sja1000/Makefile                   |    2 -
 drivers/net/can/softing/Makefile                   |    2 -
 drivers/net/can/spi/Makefile                       |    2 -
 drivers/net/can/spi/mcp251x.c                      |   16 +-
 drivers/net/can/usb/Makefile                       |    2 -
 18 files changed, 1484 insertions(+), 52 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/can/m_can.txt
 create mode 100644 Documentation/devicetree/bindings/net/can/rcar_can.tx=
t
 create mode 100644 drivers/net/can/m_can/Kconfig
 create mode 100644 drivers/net/can/m_can/Makefile
 create mode 100644 drivers/net/can/m_can/m_can.c

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |
















--DQq4Vjdal6xTgT3kxTltECCU71ToW9TK2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlP0tYAACgkQjTAFq1RaXHNCcQCgjwfyjF4+Btf/Juy0d8bk6j+H
whwAnjygVsJZH0hj0Cx+0IYYGpewnS2X
=CtzF
-----END PGP SIGNATURE-----

--DQq4Vjdal6xTgT3kxTltECCU71ToW9TK2--
