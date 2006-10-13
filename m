From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH wireless-dev] adm8211: small cleanups in adm8211_probe
Date: Fri, 13 Oct 2006 13:55:23 -0400
Message-ID: <200610131355.29179.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1412259.57gRb0rDjH";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:8957 "EHLO annwn14.rutgers.edu")
	by vger.kernel.org with ESMTP id S1751784AbWJMSKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2006 14:10:21 -0400
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1412259.57gRb0rDjH
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

adm8211: small cleanups in adm8211_probe

This patch adds a KERN_INFO to a printk that didn't have anything, and=20
shortens another line.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>

=2D--

 drivers/net/wireless/d80211/adm8211/adm8211.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/d80211/adm8211/adm8211.c=20
b/drivers/net/wireless/d80211/adm8211/adm8211.c
index dcabeab..5522e15 100644
=2D-- a/drivers/net/wireless/d80211/adm8211/adm8211.c
+++ b/drivers/net/wireless/d80211/adm8211/adm8211.c
@@ -2072,13 +2072,13 @@ #endif
=20
 	priv->channel =3D priv->modes[0].channels[0].chan;
=20
=2D	err =3D ieee80211_register_hw(dev, &priv->hw);
+	err =3D ieee80211_register_hw(dev, hw);
 	if (err) {
 		printk(KERN_ERR "%s (adm8211): Cannot register netdevice\n",=20
pci_name(pdev));
 		goto err_free_desc;
 	}
=20
=2D	printk("%s: hwaddr " MAC_FMT ", Rev 0x%02x\n",
+	printk(KERN_INFO "%s: hwaddr " MAC_FMT ", Rev 0x%02x\n",
 	       dev->name, MAC_ARG(dev->dev_addr), priv->revid);
=20
 	return 0;

--nextPart1412259.57gRb0rDjH
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFL9MQT3Oqt9AH4aERAmK0AJ0X3emyeES6MF14SfJprYlFw/Vh6ACfeZ4j
701JMvXexdNGDPK6tdU0574=
=Sn9+
-----END PGP SIGNATURE-----

--nextPart1412259.57gRb0rDjH--
