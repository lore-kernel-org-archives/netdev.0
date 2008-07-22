From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: [PATCH] fs_enet: Remove unused fields in the fs_mii_bb_platform_info structure.
Date: Tue, 22 Jul 2008 17:43:42 +0200
Message-ID: <200807221743.47807.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart43458818.Il0IBT7YsP";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: vbordug@ru.mvista.com, jgarzik@pobox.com
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:56728 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750906AbYGVPnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 11:43:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart43458818.Il0IBT7YsP
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

The mdio_port, mdio_bit, mdc_port and mdc_bit fields in the
fs_mii_bb_platform_info structure are left-overs from the move to the Phy
Abstraction Layer subsystem. They are not used anymore and can be safely
removed.

Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
=2D--
 include/linux/fs_enet_pd.h    |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/include/linux/fs_enet_pd.h b/include/linux/fs_enet_pd.h
index 9bc045b..decc4b5 100644
=2D-- a/include/linux/fs_enet_pd.h
+++ b/include/linux/fs_enet_pd.h
@@ -103,10 +103,6 @@ struct fs_mii_bb_platform_info {
 	struct fs_mii_bit 	mdio_dir;
 	struct fs_mii_bit 	mdio_dat;
 	struct fs_mii_bit	mdc_dat;
=2D	int mdio_port;	/* port & bit for MDIO */
=2D	int mdio_bit;
=2D	int mdc_port;	/* port & bit for MDC  */
=2D	int mdc_bit;
 	int delay;	/* delay in us         */
 	int irq[32]; 	/* irqs per phy's */
 };
=2D-=20
1.5.0


=2D-=20
Laurent Pinchart
CSE Semaphore Belgium

Chaussee de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75

--nextPart43458818.Il0IBT7YsP
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)

iEYEABECAAYFAkiGADMACgkQ8y9gWxC9vpdugACeMZWMv0IFETZxVd7/xxhR8E7D
wdkAoMsvS0a+lEDni7CL8GZtd6BuII7m
=haH6
-----END PGP SIGNATURE-----

--nextPart43458818.Il0IBT7YsP--
