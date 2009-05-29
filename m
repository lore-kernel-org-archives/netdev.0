From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/10]: wavelan: Remove bogus debugging on skb->next being
 non-NULL.
Date: Fri, 29 May 2009 01:40:02 -0700 (PDT)
Message-ID: <20090529.014002.66716606.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56916
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757282AbZE2IkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 04:40:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Fcc: +backup
X-Mailer: Mew version 6.2.51 on Emacs 22.1 / Mule 5.0 (SAKAKI)
----

This eliminates explicit references to the SKB list handling
implementation.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/wireless/wavelan.c    |    4 ----
 drivers/net/wireless/wavelan_cs.c |    5 -----
 2 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/wavelan.c b/drivers/net/wireless/wavelan.c
index 3ab3eb9..25d27b6 100644
--- a/drivers/net/wireless/wavelan.c
+++ b/drivers/net/wireless/wavelan.c
@@ -2869,10 +2869,6 @@ static int wavelan_packet_xmit(struct sk_buff *skb, struct net_device * dev)
 		if (lp->tx_n_in_use == (NTXBLOCKS - 1))
 			return 1;
 	}
-#ifdef DEBUG_TX_ERROR
-	if (skb->next)
-		printk(KERN_INFO "skb has next\n");
-#endif
 
 	/* Do we need some padding? */
 	/* Note : on wireless the propagation time is in the order of 1us,
diff --git a/drivers/net/wireless/wavelan_cs.c b/drivers/net/wireless/wavelan_cs.c
index e55b339..1a90d69 100644
--- a/drivers/net/wireless/wavelan_cs.c
+++ b/drivers/net/wireless/wavelan_cs.c
@@ -3107,11 +3107,6 @@ wavelan_packet_xmit(struct sk_buff *	skb,
        * so the Tx buffer is now free */
     }
 
-#ifdef DEBUG_TX_ERROR
-	if (skb->next)
-		printk(KERN_INFO "skb has next\n");
-#endif
-
 	/* Check if we need some padding */
 	/* Note : on wireless the propagation time is in the order of 1us,
 	 * and we don't have the Ethernet specific requirement of beeing
-- 
1.6.3

