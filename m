From: Christian Engelmayer <cengelma@gmx.at>
Subject: [PATCH/RESEND] 3c59x: Remove unused pointer in
 vortex_eisa_cleanup()
Date: Sat, 8 Feb 2014 20:10:23 +0100
Message-ID: <20140208201023.731538cf@spike>
References: <20140208181117.6776b154@spike>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_//U2cwNAw6sHtmv/J7Hyx8HP"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org
To: steffen@klassert.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:63646 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751159AbaBHTKY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Feb 2014 14:10:24 -0500
Received: from spike ([81.217.122.98]) by mail.gmx.com (mrgmx002) with ESMTPSA
 (Nemesis) id 0LngNT-1VZKpV2ymV-00hrgi for <netdev@vger.kernel.org>; Sat, 08
 Feb 2014 20:10:22 +0100
In-Reply-To: <20140208181117.6776b154@spike>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_//U2cwNAw6sHtmv/J7Hyx8HP
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Remove unused network device private data pointer 'vp' in function
vortex_eisa_cleanup(). Detected by Coverity: CID 139826.

Signed-off-by: Christian Engelmayer <cengelma@gmx.at>
---
Resend using address steffen@klassert.de as retrieved from the mail delivery
fail notification by tu-chemnitz.de. Information in MAINTAINERS seems to be
outdated on that point.
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

--Sig_//U2cwNAw6sHtmv/J7Hyx8HP
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJS9oEfAAoJEKssnEpaPQKEGasP/iEMEaLXzEZt4aV2AtpS/yxx
G4Kra51I9eyAZXOBDdpDOAaPIp1n3CvtffbtghgLK5aLdiZn6GSemOk06p9X4jQs
5MWieXsPQA58gBldwgNhLhtHGQ7V435hgNKfVgaGUOLPf+AC1Vv4qQkBZ5s6AHRC
ZkvB8SZcfkEEKHjMvXBfVfwm3Lsjl3HvLSU+5gizp2Af0IIz4OEMwRVNJH/aS/4J
171Ma4pfT8bkKcEF3mvWiDxmGVq6mBuNnJbXrH4E5uoawzopso2pIBOJay4dlIf0
UiGJG2UFHjYEgAD+Iuge3Ukr3oxBr2AHIOLrEUr+KT54+VJnDGiE94mn3igOuVZI
S/u+HjbE6NPeaeYyt0Q892r0CVegvwnXlCMWDS4vLu6YQZJLJHlpOkyG7YbmV1Ts
BC2eMewzGZxtE182YegNUIv3FGDvp5MW8pRLIrNnpud0h+XTb6ZCg2W2X2P34DFk
SdYVcDeyoXiNXJa33AvypLFSUziJ9KLyOIG8SsDrHldFn4k5n09gx5X7/UtVJEYS
buW8kjdN7col6I3HLyYAGoPTL+CXJwV0UEgrAgwApzHyLtpU//H1yMmA7w/v3NlN
SLUs3PRHAvUKcZrGAUoDzobG03M05DdHoLWmWb/p6q0oPSom+YkYktrD1rbfkZ4V
FBIKzkEB82Ia6g1E8jbl
=Edi/
-----END PGP SIGNATURE-----

--Sig_//U2cwNAw6sHtmv/J7Hyx8HP--
