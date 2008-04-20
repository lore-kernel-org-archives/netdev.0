From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] skbuff: fix missing kernel-doc notation
Date: Sun, 20 Apr 2008 10:51:01 -0700
Message-ID: <20080420105101.d07438f8.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, torvalds <torvalds@linux-foundation.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:36122 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754795AbYDTRv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 13:51:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Add kernel-doc notation for ndisc_nodetype:

Warning(linux-2.6.25-git2//include/linux/skbuff.h:340): No description found for parameter 'ndisc_nodetype'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 include/linux/skbuff.h |    1 +
 1 file changed, 1 insertion(+)

--- linux-2.6.25-git2.orig/include/linux/skbuff.h
+++ linux-2.6.25-git2/include/linux/skbuff.h
@@ -242,6 +242,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@queue_mapping: Queue mapping for multiqueue devices
  *	@tc_index: Traffic control index
  *	@tc_verd: traffic control verdict
+ *	@ndisc_nodetype: router type (from link layer)
  *	@dma_cookie: a cookie to one of several possible DMA operations
  *		done by skb DMA functions
  *	@secmark: security marking
