From: David Miller <davem@davemloft.net>
Subject: [PATCH 10/10]: llc: Kill outdated and incorrect comment.
Date: Fri, 29 May 2009 01:40:27 -0700 (PDT)
Message-ID: <20090529.014027.254773257.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56932
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757378AbZE2Ik1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 04:40:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This comment suggested storing two pieces of state in the
LLC skb control block, and in fact we do.  Someone did
the implementation but never killed this todo comment :-)

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/llc/llc_conn.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/llc/llc_conn.c b/net/llc/llc_conn.c
index 3477624..c6bab39 100644
--- a/net/llc/llc_conn.c
+++ b/net/llc/llc_conn.c
@@ -79,10 +79,6 @@ int llc_conn_state_process(struct sock *sk, struct sk_buff *skb)
 
 	if (unlikely(!ev->ind_prim && !ev->cfm_prim)) {
 		/* indicate or confirm not required */
-		/* XXX this is not very pretty, perhaps we should store
-		 * XXX indicate/confirm-needed state in the llc_conn_state_ev
-		 * XXX control block of the SKB instead? -DaveM
-		 */
 		if (!skb->next)
 			goto out_kfree_skb;
 		goto out_skb_put;
-- 
1.6.3

