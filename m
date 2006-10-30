From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] spidernet: user netdev_alloc_skb
Date: Mon, 30 Oct 2006 15:07:26 +0100
Message-ID: <20061030140726.GA7164@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:2006 "EHLO mail.lst.de")
	by vger.kernel.org with ESMTP id S1751476AbWJ3OHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2006 09:07:54 -0500
To: jim@jklewis.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/drivers/net/spider_net.c
===================================================================
--- linux-2.6.orig/drivers/net/spider_net.c	2006-10-23 17:20:14.000000000 +0200
+++ linux-2.6/drivers/net/spider_net.c	2006-10-30 13:27:48.000000000 +0100
@@ -395,7 +395,8 @@
 	/* and we need to have it 128 byte aligned, therefore we allocate a
 	 * bit more */
 	/* allocate an skb */
-	descr->skb = dev_alloc_skb(bufsize + SPIDER_NET_RXBUF_ALIGN - 1);
+	descr->skb = netdev_alloc_skb(card->netdev,
+				      bufsize + SPIDER_NET_RXBUF_ALIGN - 1);
 	if (!descr->skb) {
 		if (netif_msg_rx_err(card) && net_ratelimit())
 			pr_err("Not enough memory to allocate rx buffer\n");
