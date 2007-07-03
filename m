From: olof@lixom.net (Olof Johansson)
Subject: [PATCH] [2/2] phylib: Add Marvell 88E1112 phy id
Date: Tue, 3 Jul 2007 16:24:32 -0500
Message-ID: <20070703212432.GC26181@lixom.net>
References: <20070703212346.GB26181@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: afleming@freescale.com, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:54874 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751465AbXGCVOD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2007 17:14:03 -0400
Content-Disposition: inline
In-Reply-To: <20070703212346.GB26181@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add 88E1112 PHY ID to the marvell driver. Seems to do fine with the
88E1111 inits.

Signed-off-by: Olof Johansson <olof@lixom.net>


Index: mainline/drivers/net/phy/marvell.c
===================================================================
--- mainline.orig/drivers/net/phy/marvell.c
+++ mainline/drivers/net/phy/marvell.c
@@ -252,6 +252,19 @@ static struct phy_driver marvell_drivers
 		.driver = {.owner = THIS_MODULE,},
 	},
 	{
+		.phy_id = 0x01410c90,
+		.phy_id_mask = 0xfffffff0,
+		.name = "Marvell 88E1112",
+		.features = PHY_GBIT_FEATURES,
+		.flags = PHY_HAS_INTERRUPT,
+		.config_init = &m88e1111_config_init,
+		.config_aneg = &marvell_config_aneg,
+		.read_status = &genphy_read_status,
+		.ack_interrupt = &marvell_ack_interrupt,
+		.config_intr = &marvell_config_intr,
+		.driver = {.owner = THIS_MODULE,},
+	},
+	{
 		.phy_id = 0x01410cc0,
 		.phy_id_mask = 0xfffffff0,
 		.name = "Marvell 88E1111",
