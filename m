From: Daniele Venzano <webvenza@libero.it>
Subject: [PATCH] convert sis900 to new style parameters
Date: Fri, 12 Nov 2004 23:07:10 +0100
Message-ID: <20041112220710.GB29980@gateway.milesteg.arr>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="p4qYPpj5QlsIQJ0K"
Cc: NetDev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Rusty Russell <rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--p4qYPpj5QlsIQJ0K
Content-Type: multipart/mixed; boundary="zYM0uCDKw75PZbzx"
Content-Disposition: inline


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

The attached patch converts MODULE_PARM() calls in module_param() calls.
I've tested it and the expected files were created in sysfs.

For now all parameters are read-only. After some check I'll probably
change some of them to r/w.

The patch is against 2.6.9 and if no issues are raised, I propose it for
inclusion.

This patch is also available at http://teg.homeunix.org/sis900.html

--=20
-----------------------------
Daniele Venzano
Web: http://teg.homeunix.org


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sis900-module-param.diff"
Content-Transfer-Encoding: quoted-printable

--- a/drivers/net/sis900.c	2004-11-12 16:26:50.000000000 +0100
+++ b/drivers/net/sis900.c	2004-11-12 16:33:20.000000000 +0100
@@ -48,6 +48,7 @@
 */
=20
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/timer.h>
@@ -179,9 +180,9 @@
 MODULE_DESCRIPTION("SiS 900 PCI Fast Ethernet driver");
 MODULE_LICENSE("GPL");
=20
-MODULE_PARM(multicast_filter_limit, "i");
-MODULE_PARM(max_interrupt_work, "i");
-MODULE_PARM(debug, "i");
+module_param(multicast_filter_limit, int, 0444);
+module_param(max_interrupt_work, int, 0444);
+module_param(debug, int, 0444);
 MODULE_PARM_DESC(multicast_filter_limit, "SiS 900/7016 maximum number of f=
iltered multicast addresses");
 MODULE_PARM_DESC(max_interrupt_work, "SiS 900/7016 maximum events handled =
per interrupt");
 MODULE_PARM_DESC(debug, "SiS 900/7016 debug level (2-4)");

--zYM0uCDKw75PZbzx--

--p4qYPpj5QlsIQJ0K
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBlTQO2rmHZCWzV+0RAlLKAJwNBqPurX3dsKcEVm6WOE/muEVPBQCcDaEK
tpL36BohIy2G5AKUqsdHaFY=
=VeE/
-----END PGP SIGNATURE-----

--p4qYPpj5QlsIQJ0K--
