From: Daniele Venzano <webvenza@libero.it>
Subject: [PATCH] Add Altimata PHY to sis900 driver
Date: Thu, 28 Oct 2004 12:21:02 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041028102102.GD3806@picchio.gall.it>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="p2kqVDKq5asng8Dg"
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, NetDev <netdev@oss.sgi.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--p2kqVDKq5asng8Dg
Content-Type: multipart/mixed; boundary="xXmbgvnjoT4axfJE"
Content-Disposition: inline


--xXmbgvnjoT4axfJE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

The attached patch fixes a long standing detection problem with the
sis900 driver.
This PHY chip is used on some Pentium 4  with SiS chipset and on the
Acer Aspire 1705SMi (at least) notebook.

The patch is made against kernel 2.6.9 and is available also on
http://teg.homeunix.org/sis900.html

Please, consider for inclusion.

Signed-Off-By: Daniele Venzano <webvenza@libero.it>

--=20
-----------------------------
Daniele Venzano
Web: http://teg.homeunix.org


--xXmbgvnjoT4axfJE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sis900-new-altimata-phy.diff"

Index: sis900.c
===================================================================
--- a/drivers/net/sis900.c	(revision 12)
+++ b/drivers/net/sis900.c	(working copy)
@@ -120,6 +120,7 @@
 } mii_chip_table[] = {
 	{ "SiS 900 Internal MII PHY", 		0x001d, 0x8000, LAN },
 	{ "SiS 7014 Physical Layer Solution", 	0x0016, 0xf830, LAN },
+	{ "Altimata AC101LF PHY",               0x0022, 0x5520, LAN },
 	{ "AMD 79C901 10BASE-T PHY",  		0x0000, 0x6B70, LAN },
 	{ "AMD 79C901 HomePNA PHY",		0x0000, 0x6B90, HOME},
 	{ "ICS LAN PHY",			0x0015, 0xF440, LAN },

--xXmbgvnjoT4axfJE--

--p2kqVDKq5asng8Dg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBgMgN2rmHZCWzV+0RAjCmAKCdIPKBXO5IQkW81RxFN7nA4/uRkgCfRHkP
vvGATLCvtCud6L5uk6gQ0Sg=
=Yjk4
-----END PGP SIGNATURE-----

--p2kqVDKq5asng8Dg--
