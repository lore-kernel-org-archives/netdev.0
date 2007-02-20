From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 11/12] spidernet: janitorial, typos
Date: Tue, 20 Feb 2007 16:42:59 -0600
Message-ID: <20070220224259.GK28895@austin.ibm.com>
References: <20070220221314.GU923@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	kou.ishizaki@toshiba.co.jp, arnd@arndb.de,
	Jens Osterkamp <jens@de.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:33025 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161016AbXBTWnC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 17:43:02 -0500
Content-Disposition: inline
In-Reply-To: <20070220221314.GU923@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Janitorial patch. Undo long lines, fix typo in err msg.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
Cc: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>

----
 drivers/net/spider_net.c |   13 +++++++------
 drivers/net/spider_net.h |    2 +-
 2 files changed, 8 insertions(+), 7 deletions(-)

Index: linux-2.6.20-git16/drivers/net/spider_net.c
===================================================================
--- linux-2.6.20-git16.orig/drivers/net/spider_net.c	2007-02-20 15:02:48.000000000 -0600
+++ linux-2.6.20-git16/drivers/net/spider_net.c	2007-02-20 15:02:50.000000000 -0600
@@ -1053,14 +1053,15 @@ static void show_rx_chain(struct spider_
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
@@ -1097,7 +1098,7 @@ spider_net_decode_one_descr(struct spide
 	if ( (status != SPIDER_NET_DESCR_COMPLETE) &&
 	     (status != SPIDER_NET_DESCR_FRAME_END) ) {
 		if (netif_msg_rx_err(card))
-			pr_err("%s: RX descriptor with unkown state %d\n",
+			pr_err("%s: RX descriptor with unknown state %d\n",
 			       card->netdev->name, status);
 		card->spider_stats.rx_desc_unk_state++;
 		goto bad_desc;
Index: linux-2.6.20-git16/drivers/net/spider_net.h
===================================================================
--- linux-2.6.20-git16.orig/drivers/net/spider_net.h	2007-02-20 15:02:44.000000000 -0600
+++ linux-2.6.20-git16/drivers/net/spider_net.h	2007-02-20 15:02:50.000000000 -0600
@@ -25,7 +25,7 @@
 #ifndef _SPIDER_NET_H
 #define _SPIDER_NET_H
 
-#define VERSION "1.6 C"
+#define VERSION "2.0 A"
 
 #include "sungem_phy.h"
 
