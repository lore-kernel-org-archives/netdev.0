From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 18/62: nfnetlink_queue: simplify warning message
Date: Tue, 16 Feb 2010 15:55:44 +0100 (MET)
Message-ID: <20100216145542.2796.22840.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51997 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932344Ab0BPOzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:55:46 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit a5d896adf019143adf72d08826fe5359b6a8762c
Author: Eric Leblond <eric@inl.fr>
Date:   Mon Jan 18 09:44:39 2010 +0100

    netfilter: nfnetlink_queue: simplify warning message
    
    This patch remove variable part from a debug message to have
    message concatenation from syslog.
    
    Signed-off-by: Eric Leblond <eric@inl.fr>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 5c589b2..90cf36d 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -414,8 +414,8 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 		queue->queue_dropped++;
 		if (net_ratelimit())
 			  printk(KERN_WARNING "nf_queue: full at %d entries, "
-				 "dropping packets(s). Dropped: %d\n",
-				 queue->queue_total, queue->queue_dropped);
+				 "dropping packets(s).\n",
+				 queue->queue_total);
 		goto err_out_free_nskb;
 	}
 
