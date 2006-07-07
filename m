From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 2/2] correct dev_alloc_skb kerneldoc
Date: Fri, 7 Jul 2006 11:09:57 +0200
Message-ID: <20060707090956.GA2543@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:32946 "EHLO mail.lst.de")
	by vger.kernel.org with ESMTP id S1750777AbWGGJKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 05:10:10 -0400
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dev_alloc_skb is designated for RX descriptors, not TX.  (Some drivers
use it for the latter anyway, but that's a different story)


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/include/linux/skbuff.h
===================================================================
--- linux-2.6.orig/include/linux/skbuff.h	2006-07-07 11:05:30.000000000 +0200
+++ linux-2.6/include/linux/skbuff.h	2006-07-07 11:06:31.000000000 +0200
@@ -1067,7 +1067,7 @@
 }
 
 /**
- *	__dev_alloc_skb - allocate an skbuff for sending
+ *	__dev_alloc_skb - allocate an skbuff for receiving
  *	@length: length to allocate
  *	@gfp_mask: get_free_pages mask, passed to alloc_skb
  *
@@ -1088,7 +1088,7 @@
 }
 
 /**
- *	dev_alloc_skb - allocate an skbuff for sending
+ *	dev_alloc_skb - allocate an skbuff for receiving
  *	@length: length to allocate
  *
  *	Allocate a new &sk_buff and assign it a usage count of one. The
