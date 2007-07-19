From: "Steven J. Hill" <sjhill@realitydiluted.com>
Subject: [PATCH] Merge GT/MV642xx Support into MV643xx Driver [5/8]
Date: Wed, 18 Jul 2007 23:54:45 -0500
Message-ID: <469EEE95.8050500@realitydiluted.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig573E9313E93976E665452136"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from real.realitydiluted.com ([66.43.201.61]:34006 "EHLO
	real.realitydiluted.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969AbXGSEyq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 00:54:46 -0400
Received: from atlas.inter.net ([10.0.0.3])
	by real.realitydiluted.com with esmtp (Exim 4.67)
	(envelope-from <sjhill@realitydiluted.com>)
	id 1IBO4R-000671-2q
	for netdev@vger.kernel.org; Wed, 18 Jul 2007 23:57:00 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig573E9313E93976E665452136
Content-Type: multipart/mixed;
 boundary="------------080400010706030901030004"

This is a multi-part message in MIME format.
--------------080400010706030901030004
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Fix 'mv643xx_eth_tx_timeout_task' function prototype.

Signed-off-by: Steven J. Hill <sjhill1@rockwellcollins.com>
---

--------------080400010706030901030004
Content-Type: text/x-patch;
 name="05-mv643xx-fix-function-prototype.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
 filename="05-mv643xx-fix-function-prototype.patch"

--- linux-2.6.22.1/drivers/net/mv643xx_eth.c	2007-07-18 21:45:13.00000000=
0 -0500
+++ linux-2.6.22.1-rci/drivers/net/mv643xx_eth.c	2007-07-18 21:44:07.0000=
00000 -0500
@@ -317,11 +315,9 @@
  *
  * Actual routine to reset the adapter when a timeout on Tx has occurred=

  */
-static void mv643xx_eth_tx_timeout_task(struct work_struct *ugly)
+static void mv643xx_eth_tx_timeout_task(struct net_device *dev)
 {
-	struct mv643xx_private *mp =3D container_of(ugly, struct mv643xx_privat=
e,
-						  tx_timeout_task);
-	struct net_device *dev =3D mp->mii.dev; /* yuck */
+	struct mv643xx_private *mp =3D netdev_priv(dev);
=20
 	if (!netif_running(dev))
 		return;

--------------080400010706030901030004--

--------------enig573E9313E93976E665452136
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFGnu6VgyK5H2Ic36cRAhUmAJwMGwmLCKgMKAcp4/ysZEKNpNiFeQCdGSf5
fA9s8x6cBiPBrgM8IcdhYGc=
=antd
-----END PGP SIGNATURE-----

--------------enig573E9313E93976E665452136--
