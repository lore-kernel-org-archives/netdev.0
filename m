From: Sven Schuster <schuster.sven@gmx.de>
Subject: [PATCH][iproute2] make lnstat default count '1'
Date: Wed, 8 Dec 2004 00:13:36 +0100
Message-ID: <20041207231336.GA29839@zion.homelinux.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="s2ZSL+KKDSLx8OML"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--s2ZSL+KKDSLx8OML
Content-Type: multipart/mixed; boundary="X1bOJ3K7DJ5YkBrT"
Content-Disposition: inline


--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Hi,

I just compiled the latest iproute2 (from the bk repository) and tested
Harald's lnstat utility. It found it quite annoying that when I just
called rtstat it displayed nothing. The reason is that without the
parameter '-c 1' the default count for viewing the information is
0. Wouldn't 1 be a better default value?? If yes, tiny patch
attached :-)


Sven

--=20
Linux zion 2.6.10-rc3 #1 Mon Dec 6 22:51:51 CET 2004 i686 athlon i386 GNU/L=
inux
 00:08:17 up 1 day, 2 min,  2 users,  load average: 0.00, 0.03, 0.05

--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: attachment; filename="iproute2-count.patch"
Content-Transfer-Encoding: quoted-printable

--- iproute2-20041207/misc/lnstat.c.orig	2004-12-08 00:04:21.960353599 +0100
+++ iproute2-20041207/misc/lnstat.c	2004-12-08 00:02:32.425889013 +0100
@@ -218,7 +218,7 @@
 		MODE_NORMAL,
 	} mode =3D MODE_NORMAL;
=20
-	unsigned long count =3D 0;
+	unsigned long count =3D 1;
 	static struct field_params fp;
 	int num_req_files =3D 0;
 	char *req_files[LNSTAT_MAX_FILES];

--X1bOJ3K7DJ5YkBrT--

--s2ZSL+KKDSLx8OML
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFBtjkgo4FAdB2PneQRAuNzAJ9XW0u3dyn+1TtytHlef8TmKAHX0wCdFYBy
gB2MV8RVbfayglONP01p7MU=
=/jMn
-----END PGP SIGNATURE-----

--s2ZSL+KKDSLx8OML--
