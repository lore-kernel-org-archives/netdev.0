From: Colin King <colin.king@canonical.com>
Subject: [PATCH] ethernet: xircom: fix spelling mistakes on "excessive collisions"
Date: Wed, 22 Jun 2016 18:35:05 +0100
Message-ID: <1466616905-24424-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
	Antonio Quartulli <a@unstable.cc>,
	Felipe Balbi <felipe.balbi@linux.intel.com>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:46711 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242AbcFVRfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 13:35:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

trivial fixes to spelling mistakes of the words "excessive collisions"

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/xircom/xirc2ps_cs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/xircom/xirc2ps_cs.c b/drivers/net/ethernet/xircom/xirc2ps_cs.c
index 7b44968..ddced28 100644
--- a/drivers/net/ethernet/xircom/xirc2ps_cs.c
+++ b/drivers/net/ethernet/xircom/xirc2ps_cs.c
@@ -1144,8 +1144,8 @@ xirc2ps_interrupt(int irq, void *dev_id)
 	    dev->stats.tx_packets += lp->last_ptr_value - n;
 	netif_wake_queue(dev);
     }
-    if (tx_status & 0x0002) {	/* Execessive collissions */
-	pr_debug("tx restarted due to execssive collissions\n");
+    if (tx_status & 0x0002) {	/* Excessive collisions */
+	pr_debug("tx restarted due to excessive collisions\n");
 	PutByte(XIRCREG_CR, RestartTx);  /* restart transmitter process */
     }
     if (tx_status & 0x0040)
-- 
2.8.1
