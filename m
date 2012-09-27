From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2012-09-27
Date: Thu, 27 Sep 2012 16:43:42 +0200
Message-ID: <5064661E.1000000@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig7E93F69A2BFD0B887EE5D1E2"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig7E93F69A2BFD0B887EE5D1E2
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello David,

this pull request is for net-next, for the v3.7 release cycle.
AnilKumar Ch contributed a fix for a segfault in the c_can driver,
which is triggered by an earlier commit [1] in net-next (so no backport
is needed).

Marc

[1] 4cdd34b can: c_can: Add runtime PM support to Bosch C_CAN/D_CAN contr=
oller

---

The following changes since commit 842b08bbee448b2069aaebb7f18b40942ad2a1=
bd:

  ipconfig: fix trivial build error (2012-09-25 13:22:30 -0400)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can-next.git for-davem

for you to fetch changes up to c523530ce17defe6b28ccfe622c506488f430866:

  can: c_can: fix segfault during rmmod (2012-09-27 16:34:02 +0200)

----------------------------------------------------------------
AnilKumar Ch (1):
      can: c_can: fix segfault during rmmod

 drivers/net/can/c_can/c_can.c |    3 ---
 1 file changed, 3 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig7E93F69A2BFD0B887EE5D1E2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://www.enigmail.net/

iEYEARECAAYFAlBkZh4ACgkQjTAFq1RaXHO3DACfUeHAPzlRsBwg/rW7TSIXvSsO
GuQAnRJkUHo7JQAYvvXfaI9bfW5Wkw40
=tGE2
-----END PGP SIGNATURE-----

--------------enig7E93F69A2BFD0B887EE5D1E2--
