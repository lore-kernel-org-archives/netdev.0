From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2015-03-23
Date: Mon, 23 Mar 2015 14:01:28 +0100
Message-ID: <55100EA8.5010505@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="Ra2hoE5BFECvIJ9690wAilSbeOohKPldA"
Cc: David Miller <davem@davemloft.net>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Ra2hoE5BFECvIJ9690wAilSbeOohKPldA
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 6 patches for net-next/master.

A patch by Florian Westphal, converts the skb->destructor to use
sock_efree() instead of own destructor. Ahmed S. Darwish's patch
converts the kvaser_usb driver to use unregister_candev(). A patch by
me removes a return from a void function in the m_can driver. Yegor
Yefremov contributes a patch for combined rx/tx LED trigger support. A
sparse warning in the esd_usb2 driver was fixes by Thomas K=C3=B6rper. Be=
n
Dooks converts the at91_can driver to use endian agnostic IO accessors.

Marc

---

The following changes since commit 8f2ddaac302a8ca364cb04efb19cd3b5cd0589=
10:

  netlink: Remove netlink_compare_arg.trailer (2015-03-21 00:16:39 -0400)=


are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-4.1-20150323

for you to fetch changes up to af9bfbdab8f1c5a4b51a45aaab4cfbcc318b8ae2:

  can: at91_can: use endian agnostic IO accessors (2015-03-22 23:50:12 +0=
100)

----------------------------------------------------------------
linux-can-next-for-4.1-20150323

----------------------------------------------------------------
Ahmed S. Darwish (1):
      can: kvaser_usb: Use can-dev unregistration mechanism

Ben Dooks (1):
      can: at91_can: use endian agnostic IO accessors

Florian Westphal (1):
      can: use sock_efree instead of own destructor

Marc Kleine-Budde (1):
      can: m_cam: m_can_fifo_write(): remove return from void function

Thomas K=C3=B6rper (1):
      can: esd_usb2: Fix sparse warnings

Yegor Yefremov (1):
      can: add combined rx/tx LED trigger support

 drivers/net/can/at91_can.c       |  4 ++--
 drivers/net/can/led.c            | 22 +++++++++++++++++++---
 drivers/net/can/m_can/m_can.c    |  4 ++--
 drivers/net/can/usb/esd_usb2.c   |  4 ++--
 drivers/net/can/usb/kvaser_usb.c |  2 +-
 include/linux/can/dev.h          |  2 ++
 include/linux/can/led.h          |  6 ++++--
 include/linux/can/skb.h          |  7 +------
 8 files changed, 33 insertions(+), 18 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |




--Ra2hoE5BFECvIJ9690wAilSbeOohKPldA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJVEA6rAAoJECte4hHFiupUyIMP+wWJUn6jsP5o/6Y8T8g4Hthz
r9l/O/59nPq60t6dalS7s0kV3Gl/oMBAw5Ftx0AQMrigQ7fpRhfi+g5TryG8DOfm
66Cw5pI94bwlNhlKGd3VneU6Mn6UBLaGRtLC+tOsEYDzVfK5OsH9q93tU2+RwC04
hM5a125DoE2QjA5svzsJR0wC/5DZdGe0jQCs4ICKJzKTMmPKU/aQ9aaZf+dhvhGr
wgumnCIbsEQT4RTXIDHNtjkjE+GpHPyweieeemLX3QvpkQ+k20ee0EJF2SFp78jR
rimuTXNWkOex/lKNU+ip9snVcVT3FAsE+Af+VSV5O88CuUHYKq2cAFF2CiuUnRXm
spaXLl7PZtLmnIIarL3mSax56P18x0NoLLcmcvFZrpejiOJceGdWG/jzFzEY3QGK
nGfqBKzS+otajjmn2FjSxMdN7zmzCm9x603r8w0ZjlwHvQM8TGNvIdGpzOiH1DhV
RfQOxunRjl63YAst2JffdPB3rP+iav7X94z5zyXdYNqM49JxqdSKkvALDaPDs9V2
o+I90hcvw2NAZoHSP3ehNwOSzxwKtZ5gJjGs6M2XWf7dCZ/1IvyZoX0dV3j+Fdh4
eXphCaXhTSiuBRnd9xaiE78nWEM6DfHzB7qpfiNLJHJn4pVCaQAghMlgTH5i6g1X
SxxWDMY4k71jngx7+AV1
=y1zl
-----END PGP SIGNATURE-----

--Ra2hoE5BFECvIJ9690wAilSbeOohKPldA--
