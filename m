From: Denis Kirjanov <dkirjanov@hera.kernel.org>
Subject: [RESEND][PATCH] cxgb4: Use kfree_skb for skb pointers
Date: Thu, 1 Jul 2010 09:45:52 +0000
Message-ID: <20100701094552.GA6188@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:50015 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752037Ab0GAJp4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jul 2010 05:45:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use kfree_skb for skb pointers

Acked-by: Dimitris Michailidis <dm@chelsio.com> 
Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
drivers/net/cxgb4/l2t.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb4/l2t.c b/drivers/net/cxgb4/l2t.c
index 5b990d2..e8f0f55 100644
--- a/drivers/net/cxgb4/l2t.c
+++ b/drivers/net/cxgb4/l2t.c
@@ -314,7 +314,7 @@ static void t4_l2e_free(struct l2t_entry *e)
 			struct sk_buff *skb = e->arpq_head;
 
 			e->arpq_head = skb->next;
-			kfree(skb);
+			kfree_skb(skb);
 		}
 		e->arpq_tail = NULL;
 	}
