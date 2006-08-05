From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] fix alloc_skb comment typo
Date: Sat, 5 Aug 2006 14:59:06 +0200
Message-ID: <20060805125906.GA24121@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:38533 "EHLO mail.lst.de")
	by vger.kernel.org with ESMTP id S1161418AbWHEM7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2006 08:59:11 -0400
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/include/linux/skbuff.h
===================================================================
--- linux-2.6.orig/include/linux/skbuff.h	2006-08-04 19:06:36.000000000 +0200
+++ linux-2.6/include/linux/skbuff.h	2006-08-05 14:57:17.000000000 +0200
@@ -1081,7 +1081,7 @@
  *	the headroom they think they need without accounting for the
  *	built in space. The built in space is used for optimisations.
  *
- *	%NULL is returned in there is no free memory.
+ *	%NULL is returned if there is no free memory.
  */
 static inline struct sk_buff *__dev_alloc_skb(unsigned int length,
 					      gfp_t gfp_mask)
@@ -1101,7 +1101,7 @@
  *	the headroom they think they need without accounting for the
  *	built in space. The built in space is used for optimisations.
  *
- *	%NULL is returned in there is no free memory. Although this function
+ *	%NULL is returned if there is no free memory. Although this function
  *	allocates memory it can be called from an interrupt.
  */
 static inline struct sk_buff *dev_alloc_skb(unsigned int length)
