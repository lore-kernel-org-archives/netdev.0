From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] phylib: Add ID for Marvell 88E1240
Date: Sun, 4 Nov 2007 16:08:51 -0600
Message-ID: <20071104220851.GA13657@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, afleming@freescale.com
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:48472 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753139AbXKDV7w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Nov 2007 16:59:52 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add PHY IDs for Marvell 88E1240. It seems to have close enough programming
models to 1111/1112 for basic support at least.

Also clean up whitespace in the ID list a bit.


Signed-off-by: Olof Johansson <olof@lixom.net>

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index d2ede5f..035fd41 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -265,7 +265,7 @@ static struct phy_driver marvell_drivers[] = {
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
-		.driver = {.owner = THIS_MODULE,},
+		.driver = { .owner = THIS_MODULE },
 	},
 	{
 		.phy_id = 0x01410c90,
@@ -278,7 +278,7 @@ static struct phy_driver marvell_drivers[] = {
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
-		.driver = {.owner = THIS_MODULE,},
+		.driver = { .owner = THIS_MODULE },
 	},
 	{
 		.phy_id = 0x01410cc0,
@@ -291,7 +291,7 @@ static struct phy_driver marvell_drivers[] = {
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
-		.driver = {.owner = THIS_MODULE,},
+		.driver = { .owner = THIS_MODULE },
 	},
 	{
 		.phy_id = 0x01410cd0,
@@ -304,8 +304,21 @@ static struct phy_driver marvell_drivers[] = {
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
-		.driver = {.owner = THIS_MODULE,},
-	}
+		.driver = { .owner = THIS_MODULE },
+	},
+	{
+		.phy_id = 0x01410e30,
+		.phy_id_mask = 0xfffffff0,
+		.name = "Marvell 88E1240",
+		.features = PHY_GBIT_FEATURES,
+		.flags = PHY_HAS_INTERRUPT,
+		.config_init = &m88e1111_config_init,
+		.config_aneg = &marvell_config_aneg,
+		.read_status = &genphy_read_status,
+		.ack_interrupt = &marvell_ack_interrupt,
+		.config_intr = &marvell_config_intr,
+		.driver = { .owner = THIS_MODULE },
+	},
 };
 
 static int __init marvell_init(void)
