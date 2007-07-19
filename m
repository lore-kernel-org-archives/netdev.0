From: "Steven J. Hill" <sjhill@realitydiluted.com>
Subject: [PATCH] Merge GT/MV642xx Support into MV643xx Driver [6/8]
Date: Wed, 18 Jul 2007 23:55:36 -0500
Message-ID: <469EEEC8.5040805@realitydiluted.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigB153A808913B1B7A749261DA"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from real.realitydiluted.com ([66.43.201.61]:34025 "EHLO
	real.realitydiluted.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265AbXGSEzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 00:55:38 -0400
Received: from atlas.inter.net ([10.0.0.3])
	by real.realitydiluted.com with esmtp (Exim 4.67)
	(envelope-from <sjhill@realitydiluted.com>)
	id 1IBO5G-000675-Gx
	for netdev@vger.kernel.org; Wed, 18 Jul 2007 23:57:51 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigB153A808913B1B7A749261DA
Content-Type: multipart/mixed;
 boundary="------------050104030606060302000405"

This is a multi-part message in MIME format.
--------------050104030606060302000405
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Fix the TX bytes statistics counter to, um, actually count.

Signed-off-by: Steven J. Hill <sjhill1@rockwellcollins.com>
---

--------------050104030606060302000405
Content-Type: text/x-patch;
 name="06-mv643xx-fix-tx-statistics.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
 filename="06-mv643xx-fix-tx-statistics.patch"

--- linux-2.6.22.1/drivers/net/mv643xx_eth.c	2007-07-18 21:51:49.00000000=
0 -0500
+++ linux-2.6.22.1-rci/drivers/net/mv643xx_eth.c	2007-07-18 21:44:07.0000=
00000 -0500
@@ -1506,7 +1511,7 @@
 	spin_lock_irqsave(&mp->lock, flags);
=20
 	eth_tx_submit_descs_for_skb(mp, skb);
-	stats->tx_bytes =3D skb->len;
+	stats->tx_bytes +=3D skb->len;
 	stats->tx_packets++;
 	dev->trans_start =3D jiffies;
=20

--------------050104030606060302000405--

--------------enigB153A808913B1B7A749261DA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFGnu7IgyK5H2Ic36cRAu8sAJ9yG2TGuxRsglMSYF1wfy/DGtgx8wCfcti2
mPFjvkf8f81IAD1uE0SgCiI=
=BEol
-----END PGP SIGNATURE-----

--------------enigB153A808913B1B7A749261DA--
