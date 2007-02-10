From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 5/5]: spidernet janitorial: typos
Date: Fri, 9 Feb 2007 18:25:28 -0600
Message-ID: <20070210002528.GF2396@austin.ibm.com>
References: <20070210000128.GJ5616@austin.ibm.com> <20070210002305.GE2396@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	James K Lewis <jklewis@us.ibm.com>,
	Jens Osterkamp <Jens.Osterkamp@de.ibm.com>,
	Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:54873 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946806AbXBJAZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 19:25:30 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1A0PT7A018561
	for <netdev@vger.kernel.org>; Fri, 9 Feb 2007 19:25:29 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1A0PT4E548694
	for <netdev@vger.kernel.org>; Fri, 9 Feb 2007 17:25:29 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1A0PS7D026260
	for <netdev@vger.kernel.org>; Fri, 9 Feb 2007 17:25:29 -0700
Content-Disposition: inline
In-Reply-To: <20070210002305.GE2396@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Resend, The subject line was wrong on the last one.
End-of-day tiredness.
--linas

Janitorial patch. Undo long lines, fix typo in err msg.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: James K Lewis <jklewis@us.ibm.com>
Cc: Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
Cc: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>

----
 drivers/net/spider_net.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

Index: linux-2.6.20-git4/drivers/net/spider_net.c
===================================================================
--- linux-2.6.20-git4.orig/drivers/net/spider_net.c	2007-02-09 17:37:41.000000000 -0600
+++ linux-2.6.20-git4/drivers/net/spider_net.c	2007-02-09 17:40:57.000000000 -0600
@@ -1017,14 +1017,15 @@ static void show_rx_chain(struct spider_
 #endif
 
 /**
- * spider_net_decode_one_descr - processes an rx descriptor
+ * spider_net_decode_one_descr - processes an RX descriptor
  * @card: card structure
  *
- * Returns 1 if a packet has been sent to the stack, otherwise 0
+ * Returns 1 if a packet has been sent to the stack, otherwise 0.
  *
- * Processes an rx descriptor by iommu-unmapping the data buffer and passing
- * the packet up to the stack. This function is called in softirq
- * context, e.g. either bottom half from interrupt or NAPI polling context
+ * Processes an RX descriptor by iommu-unmapping the data buffer
+ * and passing the packet up to the stack. This function is called
+ * in softirq context, e.g. either bottom half from interrupt or
+ * NAPI polling context.
  */
 static int
 spider_net_decode_one_descr(struct spider_net_card *card)
@@ -1061,7 +1062,7 @@ spider_net_decode_one_descr(struct spide
 	if ( (status != SPIDER_NET_DESCR_COMPLETE) &&
 	     (status != SPIDER_NET_DESCR_FRAME_END) ) {
 		if (netif_msg_rx_err(card))
-			pr_err("%s: RX descriptor with unkown state %d\n",
+			pr_err("%s: RX descriptor with unknown state %d\n",
 			       card->netdev->name, status);
 		card->spider_stats.rx_desc_unk_state++;
 		goto bad_desc;
