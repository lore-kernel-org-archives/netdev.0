From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 30/33] arcnet: reformat structs to C99 format
Date: Tue, 22 Sep 2015 11:02:11 +0200
Message-ID: <1442912534-10821-31-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:51222 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932730AbbIVJCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:42 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the macro definitions to match the C99
formating. This improves the readability.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/capmode.c      | 14 ++++++--------
 drivers/net/arcnet/com20020-pci.c | 35 +++++++++++++++++++++++++++++------
 2 files changed, 35 insertions(+), 14 deletions(-)

diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index 2f2d0d9..8297e00 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -230,14 +230,12 @@ free_outskb:
 }
 
 static struct ArcProto capmode_proto = {
-	'r',
-	XMTU,
-	0,
-	rx,
-	build_header,
-	prepare_tx,
-	NULL,
-	ack_tx
+	.suffix		= 'r',
+	.mtu		= XMTU,
+	.rx		= rx,
+	.build_header	= build_header,
+	.prepare_tx	= prepare_tx,
+	.ack_tx		= ack_tx
 };
 
 static void arcnet_cap_init(void)
diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index 9b82126..a12bf83 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -188,7 +188,11 @@ static struct com20020_pci_card_info card_info_10mbit = {
 	.name = "ARC-PCI",
 	.devcount = 1,
 	.chan_map_tbl = {
-		{ 2, 0x00, 0x08 },
+		{
+			.bar = 2,
+			.offset = 0x00,
+			.size = 0x08,
+		},
 	},
 	.flags = ARC_CAN_10MBIT,
 };
@@ -197,7 +201,11 @@ static struct com20020_pci_card_info card_info_5mbit = {
 	.name = "ARC-PCI",
 	.devcount = 1,
 	.chan_map_tbl = {
-		{ 2, 0x00, 0x08 },
+		{
+			.bar = 2,
+			.offset = 0x00,
+			.size = 0x08,
+		},
 	},
 	.flags = ARC_IS_5MBIT,
 };
@@ -207,7 +215,11 @@ static struct com20020_pci_card_info card_info_sohard = {
 	.devcount = 1,
 	/* SOHARD needs PCI base addr 4 */
 	.chan_map_tbl = {
-		{4, 0x00, 0x08},
+		{
+			.bar = 4,
+			.offset = 0x00,
+			.size = 0x08
+		},
 	},
 	.flags = ARC_CAN_10MBIT,
 };
@@ -216,7 +228,11 @@ static struct com20020_pci_card_info card_info_eae_arc1 = {
 	.name = "EAE PLX-PCI ARC1",
 	.devcount = 1,
 	.chan_map_tbl = {
-		{ 2, 0x00, 0x08 },
+		{
+			.bar = 2,
+			.offset = 0x00,
+			.size = 0x08,
+		},
 	},
 	.flags = ARC_CAN_10MBIT,
 };
@@ -225,8 +241,15 @@ static struct com20020_pci_card_info card_info_eae_ma1 = {
 	.name = "EAE PLX-PCI MA1",
 	.devcount = 2,
 	.chan_map_tbl = {
-		{ 2, 0x00, 0x08 },
-		{ 2, 0x08, 0x08 }
+		{
+			.bar = 2,
+			.offset = 0x00,
+			.size = 0x08,
+		}, {
+			.bar = 2,
+			.offset = 0x08,
+			.size = 0x08,
+		}
 	},
 	.flags = ARC_CAN_10MBIT,
 };
-- 
2.5.1
