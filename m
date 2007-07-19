From: "Steven J. Hill" <sjhill@realitydiluted.com>
Subject: [PATCH] Merge GT/MV642xx Support into MV643xx Driver [2/8]
Date: Wed, 18 Jul 2007 23:49:33 -0500
Message-ID: <469EED5D.60905@realitydiluted.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigC3EC1FC2895F61335839D959"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from real.realitydiluted.com ([66.43.201.61]:49738 "EHLO
	real.realitydiluted.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753338AbXGSFYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 01:24:38 -0400
Received: from atlas.inter.net ([10.0.0.3])
	by real.realitydiluted.com with esmtp (Exim 4.67)
	(envelope-from <sjhill@realitydiluted.com>)
	id 1IBNzP-00066J-53
	for netdev@vger.kernel.org; Wed, 18 Jul 2007 23:51:48 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC3EC1FC2895F61335839D959
Content-Type: multipart/mixed;
 boundary="------------080903020204010603010303"

This is a multi-part message in MIME format.
--------------080903020204010603010303
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Add #defines for RGMII Discovery II/III in 'include/linux/mv643xx.h' file=
=2E

Signed-off-by: Steven J. Hill <sjhill1@rockwellcollins.com>
---

--------------080903020204010603010303
Content-Type: text/x-patch;
 name="02-mv643xx-add-rgmii-defines.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
 filename="02-mv643xx-add-rgmii-defines.patch"

--- linux-2.6.22.1/include/linux/mv643xx.h	2007-05-10 15:16:24.000000000 =
-0500
+++ linux-2.6.22.1-rci/include/linux/mv643xx.h	2007-07-18 15:50:44.000000=
000 -0500
@@ -1243,6 +1379,8 @@
 #define MV643XX_ETH_SET_GMII_SPEED_TO_1000		(1<<23)
 #define MV643XX_ETH_SET_MII_SPEED_TO_10			0
 #define MV643XX_ETH_SET_MII_SPEED_TO_100		(1<<24)
+#define MV643XX_ETH_SET_RGMII_TX_DELAY			(1<<26)
+#define MV643XX_ETH_SET_RGMII_RX_DELAY			(1<<27)
=20
 #define MV643XX_ETH_MAX_RX_PACKET_MASK			(0x7<<17)
=20

--------------080903020204010603010303--

--------------enigC3EC1FC2895F61335839D959
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFGnu1dgyK5H2Ic36cRAmRKAJ97E6ah9O83SEnwkKCZ8Uxou78LpgCdE6Kl
fIcvsmmsfYqCKZe9g1scCJ0=
=4ICQ
-----END PGP SIGNATURE-----

--------------enigC3EC1FC2895F61335839D959--
