From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: [PATCH] skbuff: add missing kernel-doc for do_not_encrypt
Date: Thu, 31 Jul 2008 11:53:24 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0807311152140.3067@shark.he.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:36455 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754108AbYGaSxa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2008 14:53:30 -0400
Received: from shark.he.net ([66.160.160.2]) by xenotime.net for <netdev@vger.kernel.org>; Thu, 31 Jul 2008 11:53:24 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Add missing kernel-doc notation to sk_buff:

Warning(linux-2.6.27-rc1-git2//include/linux/skbuff.h:345): No description found for parameter 'do_not_encrypt'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 include/linux/skbuff.h |    1 +
 1 file changed, 1 insertion(+)

--- linux-2.6.27-rc1-git2.orig/include/linux/skbuff.h
+++ linux-2.6.27-rc1-git2/include/linux/skbuff.h
@@ -243,6 +243,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@tc_index: Traffic control index
  *	@tc_verd: traffic control verdict
  *	@ndisc_nodetype: router type (from link layer)
+ *	@do_not_encrypt: set to prevent encryption of this frame
  *	@dma_cookie: a cookie to one of several possible DMA operations
  *		done by skb DMA functions
  *	@secmark: security marking
