From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2016-03-10
Date: Thu, 10 Mar 2016 10:33:28 +0100
Message-ID: <56E13F68.900@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="WbiXQ0Mv69rR9DidxBdaEc6hSmxOmq1D0"
Cc: David Miller <davem@davemloft.net>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--WbiXQ0Mv69rR9DidxBdaEc6hSmxOmq1D0
Content-Type: multipart/mixed; boundary="rCNeAkd5EcLri0qU1Kbo7NgSIR4HagQpP"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Cc: David Miller <davem@davemloft.net>,
 "kernel@pengutronix.de" <kernel@pengutronix.de>,
 "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Message-ID: <56E13F68.900@pengutronix.de>
Subject: pull-request: can-next 2016-03-10

--rCNeAkd5EcLri0qU1Kbo7NgSIR4HagQpP
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 5 patch for net-next/master.

Marek Vasut contributes 4 patches for the ifi CAN driver, which makes
it work on real hardware. There is one patch by Ramesh Shanmugasundaram
for the rcar_can driver that adds support for the 3rd generation IP
core.

Marc

---

The following changes since commit 3b8377dca1fd1974d245b2a04a708fc434761c=
65:

  Merge branch 'variable-length-ll-headers' (2016-03-09 22:13:01 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-4.6-20160310

for you to fetch changes up to e481ab23c57b37c989fa27e0a6b3e941a908775a:

  can: rcar_can: Add r8a7795 support (2016-03-10 10:30:21 +0100)

----------------------------------------------------------------
linux-can-next-for-4.6-20160310

----------------------------------------------------------------
Marek Vasut (4):
      can: ifi: Fix clock generator configuration
      can: ifi: Fix TX DLC configuration
      can: ifi: Fix RX and TX ID mask
      can: ifi: Add obscure bit swap for EFF frame IDs

Ramesh Shanmugasundaram (1):
      can: rcar_can: Add r8a7795 support

 .../devicetree/bindings/net/can/rcar_can.txt       | 11 +++
 drivers/net/can/Kconfig                            |  2 +-
 drivers/net/can/ifi_canfd/ifi_canfd.c              | 97 ++++++++++++++--=
------
 drivers/net/can/rcar_can.c                         |  1 +
 4 files changed, 75 insertions(+), 36 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--rCNeAkd5EcLri0qU1Kbo7NgSIR4HagQpP--

--WbiXQ0Mv69rR9DidxBdaEc6hSmxOmq1D0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJW4T9oAAoJED07qiWsqSVqsFMH/i+VKG8wetSxI8snz7dR7glj
V0JVSmVM0mhq+249v56lRwZ2pEIb8Rk2gRj8wOEJAA1v4L3bJ09RGNDNVGlSAfF3
ZHi7i26w3H7EaxHjliTrl+yC9ftGC7vl+4qb8R4wLvg2E1RmMfva2TvyIV9ofYKL
0Ji6vUPP4hGskiPzEKQ4xES0Mb6mGzPamn6CJvzTInHwYsBKDLXzku0uzbsJMhS8
S+ip8bQ37s2VNBkF3S4QlMNUnZl4ZaAMCaQLrfiyL/hBW5E2465Dt+eHn+p4dxyA
GHW6yMhXk/3XVHhxejDi9hjvIpB4ZqFdvTml5IziQja2Lu+DTdLwvRWc50+uJis=
=pEdz
-----END PGP SIGNATURE-----

--WbiXQ0Mv69rR9DidxBdaEc6hSmxOmq1D0--
