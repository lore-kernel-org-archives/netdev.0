From: Aristeu Sergio Rozanski Filho <aris@cathedrallabs.org>
Subject: [PATCH] 4/5: eepro: fix return value in init_module()
Date: Thu, 18 Nov 2004 21:40:59 -0200
Message-ID: <20041118234059.GI24080@cathedrallabs.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="A1VS04HCCjrR2aaM"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--A1VS04HCCjrR2aaM
Content-Type: multipart/mixed; boundary="hIO1AjEoFJ7b3ahE"
Content-Disposition: inline


--hIO1AjEoFJ7b3ahE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


--=20
Aristeu


--hIO1AjEoFJ7b3ahE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="04-eepro-fix_return_value_in_init.patch"

eepro: fix return value in init_module()

Signed-off-by: Aristeu Sergio Rozanski Filho <aris@cathedrallabs.org>

--- 2.6/drivers/net/eepro.c.orig	2004-10-05 22:26:48.000000000 -0300
+++ 2.6/drivers/net/eepro.c	2004-10-05 22:27:00.000000000 -0300
@@ -1811,7 +1811,7 @@ init_module(void)
 	if (io[0] == 0 && autodetect == 0) {
 		printk(KERN_WARNING "eepro_init_module: Probe is very dangerous in ISA boards!\n");
 		printk(KERN_WARNING "eepro_init_module: Please add \"autodetect=1\" to force probe\n");
-		return 1;
+		return -ENODEV;
 	}
 	else if (autodetect) {
 		/* if autodetect is set then we must force detection */

--hIO1AjEoFJ7b3ahE--

--A1VS04HCCjrR2aaM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBnTMLRRJOudsVYbMRAhH0AKCXtxiehjz/ceMitrB0LIZzzyG+bgCggVQc
oxBQYi0RWbpO23Eow6NUk2I=
=0pom
-----END PGP SIGNATURE-----

--A1VS04HCCjrR2aaM--
