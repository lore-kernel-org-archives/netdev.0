From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 6/8] amd-xgbe: Remove unused variable
Date: Thu, 20 Nov 2014 11:03:56 -0600
Message-ID: <20141120170356.15397.43120.stgit@tlendack-t1.amdoffice.net>
References: <20141120170320.15397.10583.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0114.outbound.protection.outlook.com ([157.56.110.114]:60544
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932175AbaKTREC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 12:04:02 -0500
In-Reply-To: <20141120170320.15397.10583.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tso_header variable in the xgbe_tx_ring_data structure is not used,
remove it.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c |    1 -
 drivers/net/ethernet/amd/xgbe/xgbe.h      |    1 -
 2 files changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
index 3c7c386..62cb4d3 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
@@ -532,7 +532,6 @@ static int xgbe_map_tx_skb(struct xgbe_channel *channel, struct sk_buff *skb)
 		}
 		rdata->skb_dma = skb_dma;
 		rdata->skb_dma_len = packet->header_len;
-		rdata->tx.tso_header = 1;
 
 		offset = packet->header_len;
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 98504f1..ec0d37a 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -276,7 +276,6 @@ struct xgbe_buffer_data {
 
 /* Tx-related ring data */
 struct xgbe_tx_ring_data {
-	unsigned int tso_header;	/* TSO header indicator */
 	unsigned int packets;		/* BQL packet count */
 	unsigned int bytes;		/* BQL byte count */
 };
