From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2014-11-17
Date: Mon, 17 Nov 2014 15:41:36 +0100
Message-ID: <546A0920.4060706@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="SGgi9AicbBVqnDoG9HvbfJXiRmp3ODc0v"
Cc: David Miller <davem@davemloft.net>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--SGgi9AicbBVqnDoG9HvbfJXiRmp3ODc0v
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 9 patches for net-next/master.

All 9 patches are by Roger Quadros and update the c_can platform
driver. First by improving the initialization sequence of the message
RAM, making use of syscon/regmap. In the later patches support for
various TI SoCs is added.

Marc

---
The following changes since commit 65622ed40eef5ce2732365077b22416593fec4=
c8:

  Merge branch 'rss_key_fill' (2014-11-16 15:59:19 -0500)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can-next.git tags/linux-can-next-fo=
r-3.19-20141117

for you to fetch changes up to f2bf2589834faec7af8c02c3949c90788d21b790:

  net: can: c_can: Add support for TI am4372 DCAN (2014-11-17 15:32:10 +0=
100)

----------------------------------------------------------------
linux-can-next-for-3.19-20141117

----------------------------------------------------------------
Roger Quadros (9):
      can: c_can: Add timeout to c_can_hw_raminit_ti()
      can: c_can: Introduce c_can_driver_data structure
      can: c_can: Add RAMINIT register information to driver data
      can: c_can: Add syscon/regmap RAMINIT mechanism
      can: c_can: Add support for START pulse in RAMINIT sequence
      can: c_can: Disable pins when CAN interface is down
      can: c_can: Add support for TI DRA7 DCAN
      can: c_can: Add support for TI am3352 DCAN
      net: can: c_can: Add support for TI am4372 DCAN

 .../devicetree/bindings/net/can/c_can.txt          |   5 +
 drivers/net/can/c_can/c_can.c                      |  13 ++
 drivers/net/can/c_can/c_can.h                      |  25 ++-
 drivers/net/can/c_can/c_can_platform.c             | 201 ++++++++++++++-=
------
 4 files changed, 181 insertions(+), 63 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


















--SGgi9AicbBVqnDoG9HvbfJXiRmp3ODc0v
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUagkgAAoJECte4hHFiupUM7QQAIt8H9L0nufxV1k9Bb/RhVui
tV/Y53AFqVYYpKSpxtUYsanFB93Snv4HgmhpFM4a7QDZkqLBZ9PwT+PTX4LO9zNK
n2ZU4NpSJRi72ToiHkqVnyLPJi8MhrDeKvvK49mkTeY5wBsWllcuN+RLW6D3hRSl
4OY9fPunh2VFUadg7JQIHUbUj8JGiw4OorcMEJvx9+IME4aLr2tuTSawpOC6J8mm
BRczJAlp8wesmeAmY48qjZOQNvtkz1FufjrgJpBSUOEZS6UNHfYlmYyhz4LfAoSx
Shodhj2qaGTyTQWuXlj8Fp+Z5wVTQ3oMlIqhk/pzGcASZ2JxPd3DUhTVhkeumVa/
TjiHdDBmlIf1LMzlPAiYvQYnRZIHsHwrq/VT6NLMrc8nMJUI7Km12zImvHhRT3fi
hmcWWR5wTo38UkOYuA+3s3a4L9SAUB7CywRRXWNXbbjLb4mODLOLJZNTWeDfnRRU
rrtkVmqp2DUHKDA69mOjrg9O1eTyDnV6o/6haFKVz/msYwiqINrKJjXDoYdIKdsI
5Egh/c3Cs/G+3eqQ1A9mPGTQYOEKlFSNS0/GcaA4tCfW8U99SG9J6FAPSLMxzuXP
8lkq8hHa8JMSjFbYe78wGaLEGaS/fg9+B97WtRar1LZppJLH/bZGjdtQ9qg4Sz4J
8q5v/nkdpER6XsrFWplz
=gyA3
-----END PGP SIGNATURE-----

--SGgi9AicbBVqnDoG9HvbfJXiRmp3ODc0v--
