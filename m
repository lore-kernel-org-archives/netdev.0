From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] skbuff: size of hole is wrong in a comment
Date: Mon, 30 Sep 2013 14:16:41 +0200
Message-ID: <1380543401-29502-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, mgorman@suse.de,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:45877 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752848Ab3I3MQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 08:16:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit c93bdd0e03e8 ("netvm: allow skb allocation to use PFMEMALLOC
reserves"), hole size is one bit less than what is written in the comment.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/skbuff.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2ddb48d9312c..c2d89335f637 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -498,7 +498,7 @@ struct sk_buff {
 	 * headers if needed
 	 */
 	__u8			encapsulation:1;
-	/* 7/9 bit hole (depending on ndisc_nodetype presence) */
+	/* 6/8 bit hole (depending on ndisc_nodetype presence) */
 	kmemcheck_bitfield_end(flags2);
 
 #if defined CONFIG_NET_DMA || defined CONFIG_NET_RX_BUSY_POLL
-- 
1.8.2.1
