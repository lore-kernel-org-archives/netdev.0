From: Daniele Venzano <webvenza@libero.it>
Subject: [PATCH] Add new PHY ID to sis900 driver
Date: Sun, 29 Aug 2004 12:32:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040829103226.GD5168@gateway.milesteg.arr>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ALfTUftag+2gvp1h"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--ALfTUftag+2gvp1h
Content-Type: multipart/mixed; boundary="oLBj+sq0vYjzfsbl"
Content-Disposition: inline


--oLBj+sq0vYjzfsbl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Add new PHY from National (83847).

=46rom: Laurent <laurent@gobio2.net>
Signed-off-by: Daniele Venzano <webvenza@libero.it>

This patch is also available at: http://teg.homeunix.org/sis900.html

--=20
-----------------------------
Daniele Venzano
Web: http://teg.homeunix.org


--oLBj+sq0vYjzfsbl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sis900-new-national-phy.diff"

Index: sis900.c
===================================================================
--- a/drivers/net/sis900.c	(revision 10)
+++ b/drivers/net/sis900.c	(revision 11)
@@ -124,6 +124,7 @@
 	{ "AMD 79C901 HomePNA PHY",		0x0000, 0x6B90, HOME},
 	{ "ICS LAN PHY",			0x0015, 0xF440, LAN },
 	{ "NS 83851 PHY",			0x2000, 0x5C20, MIX },
+	{ "NS 83847 PHY",                       0x2000, 0x5C30, MIX },
 	{ "Realtek RTL8201 PHY",		0x0000, 0x8200, LAN },
 	{ "VIA 6103 PHY",			0x0101, 0x8f20, LAN },
 	{NULL,},

--oLBj+sq0vYjzfsbl--

--ALfTUftag+2gvp1h
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBMbC62rmHZCWzV+0RAlo1AKCm98bU/2Aht8MHsbrNi/jgplhDcQCghopj
EJhoikQ0n/j+BJ3XC78VVfk=
=pCMx
-----END PGP SIGNATURE-----

--ALfTUftag+2gvp1h--
