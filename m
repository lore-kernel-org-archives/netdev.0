From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2015-09-17
Date: Tue, 13 Oct 2015 18:08:01 +0200
Message-ID: <561D2C61.1050201@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="q5vXpcpgL1o7eWKRXcduOFhPhhJ4pveB2"
Cc: David Miller <davem@davemloft.net>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--q5vXpcpgL1o7eWKRXcduOFhPhhJ4pveB2
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 4 patches for net-next/master.

Two patches are by Gerhard Bertelsmann, fixing some problems in the
sun4i driver. The patch by Arnd Bergmann stops using timeval for the
CAN broadcast manager. The last patch by Alexandre Belloni removes the
otherwise unused struct at91_can_data from the driver.

Marc

---

The following changes since commit bbb300eb976b613a8e4e666d3af39f5ab1031d=
22:

  Merge branch 'bridge-vlan' (2015-10-13 04:58:04 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-4.4-20151013

for you to fetch changes up to 42160a041db89807691b2a3fbf42e36a98b6019e:

  can: at91: remove at91_can_data (2015-10-13 17:42:35 +0200)

----------------------------------------------------------------
linux-can-next-for-4.4-20151013

----------------------------------------------------------------
Alexandre Belloni (1):
      can: at91: remove at91_can_data

Arnd Bergmann (1):
      can: avoid using timeval for uapi

Gerhard Bertelsmann (2):
      can: sun4i: fix arbitration lost error reporting
      can: sun4i: fix MODULE_DESCRIPTION

 drivers/net/can/at91_can.c          | 21 ---------------------
 drivers/net/can/sun4i_can.c         |  4 ++--
 include/linux/platform_data/atmel.h |  5 -----
 include/uapi/linux/can/bcm.h        |  7 ++++++-
 net/can/bcm.c                       | 15 ++++++++++-----
 5 files changed, 18 insertions(+), 34 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--q5vXpcpgL1o7eWKRXcduOFhPhhJ4pveB2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWHSxhAAoJEP5prqPJtc/HR2QIAJ7txv49xwSSlsVBxmr3CFRn
gO+0E+8yo82kPihbs/ya3urVN+l4IHF9Y22fz7hjhYie2WJgeg9Xbd5SQ2D9rKms
sEqSUgR1Pv2GgORAATsXiNGKw6TFfFQbOdzsbUy5ws7o5G/0vuseRxJgCX0W1KFC
wHYjFcXif1JbB40sehxrNyUV80fkJuQqOalE3sFm5P+pUWxt54GKCAOAHDiH7rpl
cQ0W1+Nql8TXbo8fGxF7ItOw+ImhAp+BuV/skndHtcuvOVpLftAtupIF0/A2dbo7
G2XoCZ69B5ZIoKbP1YFXlg53Bg+yyFW3gIlv/0r0UI9TgudP7mH0M31O7k7y5V8=
=mHQE
-----END PGP SIGNATURE-----

--q5vXpcpgL1o7eWKRXcduOFhPhhJ4pveB2--
