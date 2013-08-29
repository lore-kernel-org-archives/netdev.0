From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2013-08-29
Date: Thu, 29 Aug 2013 23:13:54 +0200
Message-ID: <521FB992.5080002@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="fH37pgSEblgWr5gnkXM5NQFTU32Ce32eo"
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--fH37pgSEblgWr5gnkXM5NQFTU32Ce32eo
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request for net-next. There are two patches from Gerhard
Sittig, which improves the clock handling on mpc5121. Oliver Hartkopp
provides a patch that adds a per rule limitation of frame hops.

regards,
Marc

---

The following changes since commit 7ec06da81d2b98859b558d8d551a0c4e3d9516=
a3:

  net: packet: document available fanout policies (2013-08-29 16:43:29 -0=
400)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can-next.git for-davem

for you to fetch changes up to 391ac1282dd7ff1cb8245cccc5262e8e4173edc4:

  can: gw: add a per rule limitation of frame hops (2013-08-29 22:58:24 +=
0200)

----------------------------------------------------------------
Gerhard Sittig (2):
      can: mscan: add a comment on reg to idx mapping
      can: mscan: improve clock API use

Oliver Hartkopp (1):
      can: gw: add a per rule limitation of frame hops

 drivers/net/can/mscan/mpc5xxx_can.c | 23 ++++++++++++++++-------
 drivers/net/can/mscan/mscan.c       | 25 ++++++++++++++++++++++++-
 drivers/net/can/mscan/mscan.h       |  3 +++
 include/uapi/linux/can/gw.h         |  9 ++++++++-
 net/can/gw.c                        | 35 +++++++++++++++++++++++++++++++=
----
 5 files changed, 82 insertions(+), 13 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--fH37pgSEblgWr5gnkXM5NQFTU32Ce32eo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlIfuZkACgkQjTAFq1RaXHO7HACgiWVcSOg8sKjdocp+59o5Qjcv
CMcAnj/Iu/CrdewuDQXzyFllAAiZu7C7
=2SML
-----END PGP SIGNATURE-----

--fH37pgSEblgWr5gnkXM5NQFTU32Ce32eo--
