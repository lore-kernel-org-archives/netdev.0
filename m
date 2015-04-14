From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/5] cxgb4: Increased the value of MAX_IMM_TX_PKT_LEN from 128 to 256 bytes
Date: Wed, 15 Apr 2015 02:02:30 +0530
Message-ID: <1429043554-8744-2-git-send-email-hariprasad@chelsio.com>
References: <1429043554-8744-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:27607 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753915AbbDNPUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 11:20:38 -0400
In-Reply-To: <1429043554-8744-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows a significant latency drop for packets of sizes between 128 and 192
bytes

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index e622214..900c642 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -144,7 +144,7 @@
  * Max Tx descriptor space we allow for an Ethernet packet to be inlined
  * into a WR.
  */
-#define MAX_IMM_TX_PKT_LEN 128
+#define MAX_IMM_TX_PKT_LEN 256
 
 /*
  * Max size of a WR sent through a control Tx queue.
-- 
2.3.4
