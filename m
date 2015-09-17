From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2015-09-17
Date: Thu, 17 Sep 2015 23:07:44 +0200
Message-ID: <55FB2BA0.6070300@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="gf2o5fIoGjAqg1QoRBoLqIGqJVWIhB7S4"
Cc: David Miller <davem@davemloft.net>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--gf2o5fIoGjAqg1QoRBoLqIGqJVWIhB7S4
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of two patches for net-next/master.

Gerhard Bertelsmann adds support for the CAN controller found on the
Allwinner A10/A20 SoC.

Marc

---

The following changes since commit 37d2dbcdcca88e392009d7cbe8617d5af0ebcb=
32:

  net: fix cdc-phonet.c dependency and build error (2015-09-16 11:51:19 -=
0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-4.4-20150917

for you to fetch changes up to 0738eff14d817a02ab082c392c96a1613006f158:

  can: Allwinner A10/A20 CAN Controller support - Kernel module (2015-09-=
17 22:39:08 +0200)

----------------------------------------------------------------
linux-can-next-for-4.4-20150917

----------------------------------------------------------------
Gerhard Bertelsmann (2):
      can: Allwinner A10/A20 CAN Controller support - Devicetree bindings=

      can: Allwinner A10/A20 CAN Controller support - Kernel module

 .../devicetree/bindings/net/can/sun4i_can.txt      |  36 +
 drivers/net/can/Kconfig                            |  10 +
 drivers/net/can/Makefile                           |   1 +
 drivers/net/can/sun4i_can.c                        | 857 +++++++++++++++=
++++++
 4 files changed, 904 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/can/sun4i_can.t=
xt
 create mode 100644 drivers/net/can/sun4i_can.c

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--gf2o5fIoGjAqg1QoRBoLqIGqJVWIhB7S4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJV+yugAAoJEP5prqPJtc/H250H/A2nXI87wCqU3XU7egKXFze5
Gk9pX8jIHoN5K4CAURVrYvdny2E3wKilDDhkVusGdaEz2Bpc+7fvvduD+UVL2pkm
fOK3xEr9LgZT6HFhD3s5CrWlnn4yyRNrAALmM9eKD+zarCyDn4TnYWjGq8syUfFh
y0Snnx3SYzP8sK2D5NGUl++N/G2/qG7iM7R4QF+BbaN7T4T0gnzsJ/4B1sveyb9a
QFWyKRZlXeZO26Epi5/zbMm2tZJGTomiEhQ6/9MmFoZZnFY8Icu/7wztEP7TBBeJ
C5alp4V6tLFmekcWzsOIXLgJk3XhLDA8K4JhPlXmGY6KZ6ISwM6fqy2A7o0RokM=
=ZsFB
-----END PGP SIGNATURE-----

--gf2o5fIoGjAqg1QoRBoLqIGqJVWIhB7S4--
