From: Aristeu Sergio Rozanski Filho <aris@cathedrallabs.org>
Subject: [PATCH] 2/5: eepro: use module_param macros
Date: Thu, 18 Nov 2004 21:40:48 -0200
Message-ID: <20041118234048.GG24080@cathedrallabs.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ggdAeHltlv4tpqCr"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--ggdAeHltlv4tpqCr
Content-Type: multipart/mixed; boundary="oiL9LJXJsdjS5rzq"
Content-Disposition: inline


--oiL9LJXJsdjS5rzq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


--=20
Aristeu


--oiL9LJXJsdjS5rzq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="02-eepro-module_param.patch"
Content-Transfer-Encoding: quoted-printable

eepro: use module_param macros

Signed-off-by: Aristeu Sergio Rozanski Filho <aris@cathedrallabs.org>

--- 2.6-pre/drivers/net/eepro.c	2004-08-26 14:38:29.000000000 -0300
+++ 2.6-work/drivers/net/eepro.c	2004-09-13 13:37:20.000000000 -0300
@@ -1720,10 +1720,11 @@ MODULE_AUTHOR("Pascal Dupuis, and aris@c
 MODULE_DESCRIPTION("Intel i82595 ISA EtherExpressPro10/10+ driver");
 MODULE_LICENSE("GPL");
=20
-MODULE_PARM(io, "1-" __MODULE_STRING(MAX_EEPRO) "i");
-MODULE_PARM(irq, "1-" __MODULE_STRING(MAX_EEPRO) "i");
-MODULE_PARM(mem, "1-" __MODULE_STRING(MAX_EEPRO) "i");
-MODULE_PARM(autodetect, "1-" __MODULE_STRING(1) "i");
+static int num_params;
+module_param_array(io, int, num_params, 0);
+module_param_array(irq, int, num_params, 0);
+module_param_array(mem, int, num_params, 0);
+module_param(autodetect, int, 0);
 MODULE_PARM_DESC(io, "EtherExpress Pro/10 I/O base addres(es)");
 MODULE_PARM_DESC(irq, "EtherExpress Pro/10 IRQ number(s)");
 MODULE_PARM_DESC(mem, "EtherExpress Pro/10 Rx buffer size(es) in kB (3-29)=
");

--oiL9LJXJsdjS5rzq--

--ggdAeHltlv4tpqCr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBnTMARRJOudsVYbMRAj8zAJ4jFzTa3vI8YKTBiyqS7mG5uNTylwCfcG2q
cQd7mu3B56/V+rSAriCNwIk=
=GQF7
-----END PGP SIGNATURE-----

--ggdAeHltlv4tpqCr--
