From: maximilian attems <janitor@sternwelten.at>
Subject: [patch] remove " ALLMULTI check " in plip.c
Date: Wed, 17 Sep 2003 20:45:04 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030917184504.GB15929@mail.sternwelten.at>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="uQr8t48UFsdbeI+V"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kj <kernel-janitors@osdl.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--uQr8t48UFsdbeI+V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


please check the following patch
maybe the comment is wrong and
then it should be changed ;)

it compiles, but no further checks
same patch applies to 2.4.22 with offset

thx for your feedback
a++ maks


--- linux-2.6.0-test5/drivers/net/plip.c	Mon Sep  8 21:50:40 2003
+++ linux/drivers/net/plip.c	Wed Sep 17 20:06:38 2003
@@ -567,14 +567,6 @@
 			skb->pkt_type=3DPACKET_MULTICAST;
 	}
 =09
-	/*
-	 *	This ALLMULTI check should be redundant by 1.4
-	 *	so don't forget to remove it.
-	 */
-	=20
-	if (ntohs(eth->h_proto) >=3D 1536)
-		return eth->h_proto;
-	=09
 	rawp =3D skb->data;
 =09
 	/*

--uQr8t48UFsdbeI+V
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQE/aKuv6//kSTNjoX0RAkuPAJ9mpMQRWu4i2hnt4+o16UqaT9x4fgCfbdCo
Iunk75jZtkN2EdbdUsedo9o=
=G9kW
-----END PGP SIGNATURE-----

--uQr8t48UFsdbeI+V--
