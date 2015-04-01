From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2015-04-01
Date: Wed, 01 Apr 2015 12:04:48 +0200
Message-ID: <551BC2C0.5000408@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="AnJEjDAQfeHkare0CO32VAudSG0hM1sQc"
Cc: David Miller <davem@davemloft.net>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--AnJEjDAQfeHkare0CO32VAudSG0hM1sQc
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 5 patches for net-next/master.

There are two patches for the ems_usb driver by Gerhard Uttenthaler and
me, which fix sparse endianess warnings. Oliver Hartkopp adds two
patches to improve and extend the CAN-ID filter handling on RAW CAN
sockets. The last patch is by me, it silences an uninitialized variable
warning in the peak_usb driver.

Marc

---

The following changes since commit 9911674fcf1f239ff3c87e56177c4826e33dfd=
95:

  Merge branch 'ptp-ns_to_timespec64' (2015-03-31 17:19:19 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-4.1-20150401

for you to fetch changes up to 79d5eeddd7d23bd4588e370072977928b7075911:

  can: pcan_usb: pcan_usb_fd_send_cmd(): silence compiler warning about u=
ninitialized var (2015-04-01 11:49:59 +0200)

----------------------------------------------------------------
linux-can-next-for-4.1-20150401

----------------------------------------------------------------
Gerhard Uttenthaler (1):
      can: ems_usb: fix endianess of CAN ID

Marc Kleine-Budde (2):
      can: ems_usb: mark timestamp as little endian
      can: pcan_usb: pcan_usb_fd_send_cmd(): silence compiler warning abo=
ut uninitialized var

Oliver Hartkopp (2):
      can: fix multiple delivery of a single CAN frame for overlapping CA=
N filters
      can: introduce new raw socket option to join the given CAN filters

 Documentation/networking/can.txt           | 20 ++++++++++--
 drivers/net/can/usb/ems_usb.c              | 11 +++----
 drivers/net/can/usb/peak_usb/pcan_usb_fd.c |  2 +-
 include/uapi/linux/can/raw.h               |  1 +
 net/can/raw.c                              | 50 ++++++++++++++++++++++++=
++++++
 5 files changed, 74 insertions(+), 10 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--AnJEjDAQfeHkare0CO32VAudSG0hM1sQc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJVG8LEAAoJECte4hHFiupU6wMP+wUNP9dbMYBdjxgfH1UeDW5x
dtCF8W5s43JEywuZsa8xvNQsvPLlNun893G7ckJe0JdCTx2uae1gFNEda3AD3u22
vTDy0xYR0tjLUdVOyWQZUeUuOoryaHohO74PbL9fkhDSOHelHgqpAQAS6ZRn1nG7
vFbJgXUVzp/VEJtxb13PdpTG9F8fR0gH3YtiEuEVWLc7Tt44uPhieXM/J/Gsjpes
yF2KPNLvYz1JARKfebo/QbkzNXOECagsonEgyoIGyeZlt5XWlkKob90E+SLVHlOf
bgwRCUIBwsuW7KX5q7BBYQknLz0Rfdan+l/TfzNHarvCY5OdioxrxFjUx+GUeXij
Q9e7M8xkEidd4vLV6b9YISUCi8yasPSl36HJego8Ixgzvul/rob5ntL0Y44ar75A
GXutLzxXg8bbJb4vpwgfTP/ZNtcGoSrBEG9RQpQDcB0gWx7Ja/T2EmgXoamLV2xt
xrL37ZUYLiCqn/nTaQ3+xVsUiaEAY8MRXoPXmjKHnGpjmo+2OyG6LHPgWt6Vcgdu
vJlI7EniIhpV23JOBkRzrQ1JzWFU5Ry6vNxFLTn0WgoJV/G+RS+x4K81RE+gFuSs
ZqkQZ5r4JBtBvBx2YEGLcTqExlxkqoCHwSBfu4/6qbqRB3MX7ks1UWG6Q8nZWVrL
hChouBiBUPKfzalT9qLi
=oHvJ
-----END PGP SIGNATURE-----

--AnJEjDAQfeHkare0CO32VAudSG0hM1sQc--
