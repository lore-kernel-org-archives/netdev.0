From: Christian Engelmayer <cengelma@gmx.at>
Subject: [PATCH] 3c59x: Remove unused pointer in vortex_eisa_cleanup()
Date: Sat, 8 Feb 2014 18:11:17 +0100
Message-ID: <20140208181117.6776b154@spike>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/YibhGRdI9RNzRiIM2LAzWCu"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org
To: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:59400 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751453AbaBHRLX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Feb 2014 12:11:23 -0500
Received: from spike ([81.217.122.98]) by mail.gmx.com (mrgmx003) with ESMTPSA
 (Nemesis) id 0MEnjW-1W0cy32OKI-00FyHB for <netdev@vger.kernel.org>; Sat, 08
 Feb 2014 18:11:21 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/YibhGRdI9RNzRiIM2LAzWCu
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Remove unused network device private data pointer 'vp' in function
vortex_eisa_cleanup(). Detected by Coverity: CID 139826.

Signed-off-by: Christian Engelmayer <cengelma@gmx.at>
---
 drivers/net/ethernet/3com/3c59x.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/=
3c59x.c
index 0f4241c..238ccea 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -3294,7 +3294,6 @@ static int __init vortex_init(void)
=20
 static void __exit vortex_eisa_cleanup(void)
 {
-	struct vortex_private *vp;
 	void __iomem *ioaddr;
=20
 #ifdef CONFIG_EISA
@@ -3303,7 +3302,6 @@ static void __exit vortex_eisa_cleanup(void)
 #endif
=20
 	if (compaq_net_device) {
-		vp =3D netdev_priv(compaq_net_device);
 		ioaddr =3D ioport_map(compaq_net_device->base_addr,
 		                    VORTEX_TOTAL_SIZE);
=20
--=20
1.8.3.2

--Sig_/YibhGRdI9RNzRiIM2LAzWCu
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJS9mU1AAoJEKssnEpaPQKE8gUQALGJZoEOSKAYc9jlesc4XmP7
Um9k0/tfIQbd11XI61tvE1XK/PSqXZR3uYEhqneP7VJoSbYrLph8rckVsAEp9EFw
0nb37ZkOVzYjLb6vFonVBcA/RxrtOAB5rynQkmQ61sI3HeBzIE6mOlIEtTJQHs4K
McXIbv1WVm9gDr/evTNlnJxvv+vhlM+l34TLjINVaJJq6c08faQlWSccR8UaX6Hh
l4GgS41VHkwOKAuPmzi7IP2dBLlOTTUnEhHH9zyr/rR+0Q/cjSG2kyRQyuMSkj6D
zmWRjyKgctlEfYksWhEFMUM5agpbCudVDYIU1esA/zrO1jNcscDZM4zFg9Yd39Hi
f0kXO5txTeS69LQM+XkGLYeie1mBr8Ibqg3rDuIQ3UgT9VQjJGMDs7OsKD7xamgH
O0I967S8x+SYzsODfPiEgCUcp6RLs4+Ozd9ZA5sMICXcsrMyd3UQrG/ph35kQ8Pg
W5VurQeRAFrY3u/3GLiwF259j3cT4Cfmv9Ug3JM1XC1+k7W6kuW6HVVligsiCytT
hRWgdPlAeaz68eTAovsrVTX4S9QlXbANBDvQttJaeJUksdOsmuW0DKl74ve+t6Ke
KcM0CkUwWBv2IPxjYkrSd5kVQnk75XMPRve2FFiTT5sJ5m5MKDstpFh1PvXvzgL5
X+uQQABe88nQAqtokB0x
=ZWH8
-----END PGP SIGNATURE-----

--Sig_/YibhGRdI9RNzRiIM2LAzWCu--
