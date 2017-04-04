From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2017-03-03
Date: Tue, 4 Apr 2017 17:47:28 +0200
Message-ID: <f4c403dd-50c0-be1a-90eb-1d45d3bc1afd@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="HTdrFOGG1PXTpTPHtD8iHONuON8rQp8G6"
Cc: David Miller <davem@davemloft.net>,
        "kernel@pengutronix.de" <kernel@pengutronix.de>,
        "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--HTdrFOGG1PXTpTPHtD8iHONuON8rQp8G6
Content-Type: multipart/mixed; boundary="fh1cpQriiAMq1LXb7P575bG196n5qLO4E";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Cc: David Miller <davem@davemloft.net>,
 "kernel@pengutronix.de" <kernel@pengutronix.de>,
 "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Message-ID: <f4c403dd-50c0-be1a-90eb-1d45d3bc1afd@pengutronix.de>
Subject: pull-request: can-next 2017-03-03

--fh1cpQriiAMq1LXb7P575bG196n5qLO4E
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 5 patches for net-next/master.

There are two patches by Yegor Yefremov which convert the ti_hecc
driver into a DT only driver, as there is no in-tree user of the old
platform driver interface anymore. The next patch by Mario Kicherer
adds network namespace support to the can subsystem. The last two
patches by Akshay Bhat add support for the holt_hi311x SPI CAN driver.

regards,
Marc

---

The following changes since commit 822f9bb104c9d1d2dea3669f1941558c6304cf=
92:

  soreuseport: use "unsigned int" in __reuseport_alloc() (2017-04-03 19:0=
6:38 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-4.13-20170404

for you to fetch changes up to 57e83fb9b7468c75cb65cde1d23043553c346c6d:

  can: hi311x: Add Holt HI-311x CAN driver (2017-04-04 17:35:59 +0200)

----------------------------------------------------------------
linux-can-next-for-4.13-20170404

----------------------------------------------------------------
Akshay Bhat (2):
      can: holt_hi311x: document device tree bindings
      can: hi311x: Add Holt HI-311x CAN driver

Mario Kicherer (1):
      can: initial support for network namespaces

Yegor Yefremov (2):
      can: ti_hecc: Add TI HECC DT binding documentation
      can: ti_hecc: Convert TI HECC driver to DT only driver

 .../devicetree/bindings/net/can/holt_hi311x.txt    |   24 +
 .../devicetree/bindings/net/can/ti_hecc.txt        |   32 +
 drivers/net/can/spi/Kconfig                        |    6 +
 drivers/net/can/spi/Makefile                       |    1 +
 drivers/net/can/spi/hi311x.c                       | 1076 ++++++++++++++=
++++++
 drivers/net/can/ti_hecc.c                          |  170 ++--
 include/linux/can/core.h                           |    7 +-
 include/linux/can/platform/ti_hecc.h               |   44 -
 include/net/net_namespace.h                        |    4 +
 include/net/netns/can.h                            |   31 +
 net/can/af_can.c                                   |  122 ++-
 net/can/af_can.h                                   |    4 +-
 net/can/bcm.c                                      |   13 +-
 net/can/gw.c                                       |    4 +-
 net/can/proc.c                                     |  144 ++-
 net/can/raw.c                                      |   92 +-
 16 files changed, 1469 insertions(+), 305 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/can/holt_hi311x=
=2Etxt
 create mode 100644 Documentation/devicetree/bindings/net/can/ti_hecc.txt=

 create mode 100644 drivers/net/can/spi/hi311x.c
 delete mode 100644 include/linux/can/platform/ti_hecc.h
 create mode 100644 include/net/netns/can.h

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--fh1cpQriiAMq1LXb7P575bG196n5qLO4E--

--HTdrFOGG1PXTpTPHtD8iHONuON8rQp8G6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAljjwBAACgkQHv7KIOw4
HPYoFwf/dFKhwau59FEPC9H/veC4Xb62lWeXgrKpovC4yr2cw1m2R571JYa/KW3y
7mZ2nBwUqOtTL91oTvDX31edb1k203Pv4xAZu4EBIZ8mJjVCC6I6GEtYdKhqt5q+
J5ugHxPTBNCA/B9ZRI4RSMxnsjpOsQBev5nvb3g6nsouSjepGlLdibPO6P7BM3mH
GvP9IVQ+JxWpMv/WnsflWkM28n8oheq5irICewuSRynXrrVffirUcQB7ZQULOY1V
3ZFH2/yb65Zhzyjc5iUtDWcCNedN4QtZVuJuJvPSlC13Yp+R8OHo9iqPnrYoVodf
SWa63IBW8FUAZKqlVNgDKCcjqOGaAQ==
=3wGp
-----END PGP SIGNATURE-----

--HTdrFOGG1PXTpTPHtD8iHONuON8rQp8G6--
