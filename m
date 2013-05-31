From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH v2 2/5] phy: Add Vitesse 8211 phy ID
Date: Fri, 31 May 2013 08:08:24 +0200
Message-ID: <804de6a875a407fb0379a437f83915e7158f2f2a.1369980470.git.michal.simek@xilinx.com>
References: <cover.1369980470.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-1692-1369980515-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Michal Simek <monstr@monstr.eu>,
	Michal Simek <michal.simek@xilinx.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Christian Hohnstaedt <chohnstaedt@innominate.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:41763 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752264Ab3EaGIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 02:08:40 -0400
Received: by mail-ea0-f175.google.com with SMTP id h14so1142001eaj.34
        for <netdev@vger.kernel.org>; Thu, 30 May 2013 23:08:37 -0700 (PDT)
In-Reply-To: <cover.1369980470.git.michal.simek@xilinx.com>
In-Reply-To: <cover.1369980470.git.michal.simek@xilinx.com>
References: <cover.1369980470.git.michal.simek@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-1692-1369980515-0001

Phy is compatible with Vitesse 8221.

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---
Changes in v2: None

 drivers/net/phy/vitesse.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index d6e988f..69b482b 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -56,6 +56,7 @@

 #define PHY_ID_VSC8244			0x000fc6c0
 #define PHY_ID_VSC8221			0x000fc550
+#define PHY_ID_VSC8211			0x000fc4b0

 MODULE_DESCRIPTION("Vitesse PHY driver");
 MODULE_AUTHOR("Kriston Carson");
@@ -175,6 +176,19 @@ static struct phy_driver vsc82xx_driver[] = {
 	.ack_interrupt	= &vsc824x_ack_interrupt,
 	.config_intr	= &vsc82xx_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
+}, {
+	/* Vitesse 8211 */
+	.phy_id		= PHY_ID_VSC8211,
+	.phy_id_mask	= 0x000ffff0,
+	.name		= "Vitesse VSC8211",
+	.features	= PHY_GBIT_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.config_init	= &vsc8221_config_init,
+	.config_aneg	= &genphy_config_aneg,
+	.read_status	= &genphy_read_status,
+	.ack_interrupt	= &vsc824x_ack_interrupt,
+	.config_intr	= &vsc82xx_config_intr,
+	.driver		= { .owner = THIS_MODULE,},
 } };

 static int __init vsc82xx_init(void)
@@ -195,6 +209,7 @@ module_exit(vsc82xx_exit);
 static struct mdio_device_id __maybe_unused vitesse_tbl[] = {
 	{ PHY_ID_VSC8244, 0x000fffc0 },
 	{ PHY_ID_VSC8221, 0x000ffff0 },
+	{ PHY_ID_VSC8211, 0x000ffff0 },
 	{ }
 };

--
1.8.2.3


--=_mimegpg-monstr-desktop-1692-1369980515-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlGoPmMACgkQykllyylKDCF1dQCdGvXQs4SIdzaVSz1XS7LEJcyk
OPcAn04Jylzt209h9d+V5TwhhE2Dro9+
=eTR7
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-1692-1369980515-0001--
