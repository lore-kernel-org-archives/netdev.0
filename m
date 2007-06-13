From: Shani Moideen <shani.moideen@wipro.com>
Subject: [KJ PATCH] Replacing alloc_pages(gfp,0) with alloc_page(gfp) in
	net/core/skbuff.c
Date: Wed, 13 Jun 2007 08:07:50 +0530
Message-ID: <1181702270.2282.6.camel@shani-win>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@lists.osdl.org
To: jgarzik@pobox.com, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wip-cdc-wd.wipro.com ([203.91.201.26]:44619 "EHLO
	wip-cdc-wd.wipro.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752153AbXFMCpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 22:45:08 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Replacing alloc_pages(gfp,0) with alloc_page(gfp) 
in net/core/skbuff.c

Signed-off-by: Shani Moideen <shani.moideen@wipro.com>
----

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 1422573..b923181 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1805,7 +1805,7 @@ int skb_append_datato_frags(struct sock *sk, struct sk_buff *skb,
 			return -EFAULT;
 
 		/* allocate a new page for next frag */
-		page = alloc_pages(sk->sk_allocation, 0);
+		page = alloc_page(sk->sk_allocation);
 
 		/* If alloc_page fails just return failure and caller will
 		 * free previous allocated pages by doing kfree_skb()

-- 
Shani
