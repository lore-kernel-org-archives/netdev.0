From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 20/21] ARCNET: com20020-pci: reformat structs to C99 format
Date: Fri, 24 Apr 2015 19:20:54 +0200
Message-ID: <1429896055-31680-21-git-send-email-m.grzeschik@pengutronix.de>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch changes the macro definitions to match the C99
formating. This improves the readability.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com20020-pci.c | 35 +++++++++++++++++++++++++++++------
 1 file changed, 29 insertions(+), 6 deletions(-)

diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index 18c0b1f..de8c894 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -191,7 +191,11 @@ static struct com20020_pci_card_info card_info_10mbit = {
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
@@ -200,7 +204,11 @@ static struct com20020_pci_card_info card_info_5mbit = {
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
@@ -210,7 +218,11 @@ static struct com20020_pci_card_info card_info_sohard = {
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
@@ -219,7 +231,11 @@ static struct com20020_pci_card_info card_info_eae_arc1 = {
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
@@ -228,8 +244,15 @@ static struct com20020_pci_card_info card_info_eae_ma1 = {
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
2.1.4
