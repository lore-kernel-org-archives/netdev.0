From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH v2 net-next 08/22] cxgb4: Add T5 PCI ids
Date: Thu, 14 Mar 2013 20:38:54 +0530
Message-ID: <1363273748-25330-9-git-send-email-vipul@chelsio.com>
References: <1363273748-25330-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com,
	JBottomley@parallels.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	naresh@chelsio.com, divy@chelsio.com, santosh@chelsio.com,
	arvindb@chelsio.com, abhishek@chelsio.com, vipul@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:2190 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933533Ab3CNPPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 11:15:33 -0400
In-Reply-To: <1363273748-25330-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santosh Rastapur <santosh@chelsio.com>

Signed-off-by: Santosh Rastapur <santosh@chelsio.com>
Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
v2: Replaced #ifdef with portable interface wmb in ring_tx_db

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   38 +++++++++++++++++++++++
 1 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index ca88070..eceee44 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -229,6 +229,44 @@ static DEFINE_PCI_DEVICE_TABLE(cxgb4_pci_tbl) = {
 	CH_DEVICE(0x440a, 4),
 	CH_DEVICE(0x440d, 4),
 	CH_DEVICE(0x440e, 4),
+	CH_DEVICE(0x5001, 5),
+	CH_DEVICE(0x5002, 5),
+	CH_DEVICE(0x5003, 5),
+	CH_DEVICE(0x5004, 5),
+	CH_DEVICE(0x5005, 5),
+	CH_DEVICE(0x5006, 5),
+	CH_DEVICE(0x5007, 5),
+	CH_DEVICE(0x5008, 5),
+	CH_DEVICE(0x5009, 5),
+	CH_DEVICE(0x500A, 5),
+	CH_DEVICE(0x500B, 5),
+	CH_DEVICE(0x500C, 5),
+	CH_DEVICE(0x500D, 5),
+	CH_DEVICE(0x500E, 5),
+	CH_DEVICE(0x500F, 5),
+	CH_DEVICE(0x5010, 5),
+	CH_DEVICE(0x5011, 5),
+	CH_DEVICE(0x5012, 5),
+	CH_DEVICE(0x5013, 5),
+	CH_DEVICE(0x5401, 5),
+	CH_DEVICE(0x5402, 5),
+	CH_DEVICE(0x5403, 5),
+	CH_DEVICE(0x5404, 5),
+	CH_DEVICE(0x5405, 5),
+	CH_DEVICE(0x5406, 5),
+	CH_DEVICE(0x5407, 5),
+	CH_DEVICE(0x5408, 5),
+	CH_DEVICE(0x5409, 5),
+	CH_DEVICE(0x540A, 5),
+	CH_DEVICE(0x540B, 5),
+	CH_DEVICE(0x540C, 5),
+	CH_DEVICE(0x540D, 5),
+	CH_DEVICE(0x540E, 5),
+	CH_DEVICE(0x540F, 5),
+	CH_DEVICE(0x5410, 5),
+	CH_DEVICE(0x5411, 5),
+	CH_DEVICE(0x5412, 5),
+	CH_DEVICE(0x5413, 5),
 	{ 0, }
 };
 
-- 
1.7.1
