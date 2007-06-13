From: Shani Moideen <shani.moideen@wipro.com>
Subject: [KJ PATCH] Replacing alloc_pages(gfp,0) with alloc_page(gfp) in
	net/core/sock.c
Date: Wed, 13 Jun 2007 08:16:42 +0530
Message-ID: <1181702802.2282.16.camel@shani-win>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@lists.osdl.org
To: jgarzik@pobox.com, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wip-cdc-wd.wipro.com ([203.91.201.26]:44761 "EHLO
	wip-cdc-wd.wipro.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752983AbXFMCz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 22:55:26 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Replacing alloc_pages(gfp,0) with alloc_page(gfp) 
in net/core/sock.c

Signed-off-by: Shani Moideen <shani.moideen@wipro.com>
----

diff --git a/net/core/sock.c b/net/core/sock.c
index 22183c2..25bb52b 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1193,7 +1193,7 @@ static struct sk_buff *sock_alloc_send_pskb(struct sock *sk,
 					struct page *page;
 					skb_frag_t *frag;
 
-					page = alloc_pages(sk->sk_allocation, 0);
+					page = alloc_page(sk->sk_allocation);
 					if (!page) {
 						err = -ENOBUFS;
 						skb_shinfo(skb)->nr_frags = i;

-- 
Shani 
