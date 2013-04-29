From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH net 1/3] cxgb4: Fix pci_device_id structure initialization with correct PF number
Date: Mon, 29 Apr 2013 19:34:39 +0530
Message-ID: <1367244281-23043-2-git-send-email-vipul@chelsio.com>
References: <1367244281-23043-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, divy@chelsio.com, dm@chelsio.com,
	abhishek@chelsio.com, leedom@chelsio.com,
	swise@opengridcomputing.com, Vipul Pandya <vipul@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:27087 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757698Ab3D2OK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 10:10:59 -0400
In-Reply-To: <1367244281-23043-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 76 ++++++++++++-------------
 1 file changed, 38 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 6a6a01a..656f934 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -229,44 +229,44 @@ static DEFINE_PCI_DEVICE_TABLE(cxgb4_pci_tbl) = {
 	CH_DEVICE(0x440a, 4),
 	CH_DEVICE(0x440d, 4),
 	CH_DEVICE(0x440e, 4),
-	CH_DEVICE(0x5001, 5),
-	CH_DEVICE(0x5002, 5),
-	CH_DEVICE(0x5003, 5),
-	CH_DEVICE(0x5004, 5),
-	CH_DEVICE(0x5005, 5),
-	CH_DEVICE(0x5006, 5),
-	CH_DEVICE(0x5007, 5),
-	CH_DEVICE(0x5008, 5),
-	CH_DEVICE(0x5009, 5),
-	CH_DEVICE(0x500A, 5),
-	CH_DEVICE(0x500B, 5),
-	CH_DEVICE(0x500C, 5),
-	CH_DEVICE(0x500D, 5),
-	CH_DEVICE(0x500E, 5),
-	CH_DEVICE(0x500F, 5),
-	CH_DEVICE(0x5010, 5),
-	CH_DEVICE(0x5011, 5),
-	CH_DEVICE(0x5012, 5),
-	CH_DEVICE(0x5013, 5),
-	CH_DEVICE(0x5401, 5),
-	CH_DEVICE(0x5402, 5),
-	CH_DEVICE(0x5403, 5),
-	CH_DEVICE(0x5404, 5),
-	CH_DEVICE(0x5405, 5),
-	CH_DEVICE(0x5406, 5),
-	CH_DEVICE(0x5407, 5),
-	CH_DEVICE(0x5408, 5),
-	CH_DEVICE(0x5409, 5),
-	CH_DEVICE(0x540A, 5),
-	CH_DEVICE(0x540B, 5),
-	CH_DEVICE(0x540C, 5),
-	CH_DEVICE(0x540D, 5),
-	CH_DEVICE(0x540E, 5),
-	CH_DEVICE(0x540F, 5),
-	CH_DEVICE(0x5410, 5),
-	CH_DEVICE(0x5411, 5),
-	CH_DEVICE(0x5412, 5),
-	CH_DEVICE(0x5413, 5),
+	CH_DEVICE(0x5001, 4),
+	CH_DEVICE(0x5002, 4),
+	CH_DEVICE(0x5003, 4),
+	CH_DEVICE(0x5004, 4),
+	CH_DEVICE(0x5005, 4),
+	CH_DEVICE(0x5006, 4),
+	CH_DEVICE(0x5007, 4),
+	CH_DEVICE(0x5008, 4),
+	CH_DEVICE(0x5009, 4),
+	CH_DEVICE(0x500A, 4),
+	CH_DEVICE(0x500B, 4),
+	CH_DEVICE(0x500C, 4),
+	CH_DEVICE(0x500D, 4),
+	CH_DEVICE(0x500E, 4),
+	CH_DEVICE(0x500F, 4),
+	CH_DEVICE(0x5010, 4),
+	CH_DEVICE(0x5011, 4),
+	CH_DEVICE(0x5012, 4),
+	CH_DEVICE(0x5013, 4),
+	CH_DEVICE(0x5401, 4),
+	CH_DEVICE(0x5402, 4),
+	CH_DEVICE(0x5403, 4),
+	CH_DEVICE(0x5404, 4),
+	CH_DEVICE(0x5405, 4),
+	CH_DEVICE(0x5406, 4),
+	CH_DEVICE(0x5407, 4),
+	CH_DEVICE(0x5408, 4),
+	CH_DEVICE(0x5409, 4),
+	CH_DEVICE(0x540A, 4),
+	CH_DEVICE(0x540B, 4),
+	CH_DEVICE(0x540C, 4),
+	CH_DEVICE(0x540D, 4),
+	CH_DEVICE(0x540E, 4),
+	CH_DEVICE(0x540F, 4),
+	CH_DEVICE(0x5410, 4),
+	CH_DEVICE(0x5411, 4),
+	CH_DEVICE(0x5412, 4),
+	CH_DEVICE(0x5413, 4),
 	{ 0, }
 };
 
-- 
1.8.0
