From: Shani Moideen <shani.moideen@wipro.com>
Subject: [KJ PATCH] Replacing alloc_pages(gfp,0) with alloc_page(gfp) in
	net/core/pktgen.c
Date: Wed, 13 Jun 2007 08:12:42 +0530
Message-ID: <1181702562.2282.12.camel@shani-win>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@lists.osdl.org
To: jgarzik@pobox.com, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wip-cdc-wd.wipro.com ([203.91.201.26]:44672 "EHLO
	wip-cdc-wd.wipro.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755433AbXFMCuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 22:50:00 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Replacing alloc_pages(gfp,0) with alloc_page(gfp) 
in net/core/pktgen.c

Signed-off-by: Shani Moideen <shani.moideen@wipro.com>
----

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index b92a322..2600c7f 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2414,7 +2414,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 
 		i = 0;
 		while (datalen > 0) {
-			struct page *page = alloc_pages(GFP_KERNEL, 0);
+			struct page *page = alloc_page(GFP_KERNEL);
 			skb_shinfo(skb)->frags[i].page = page;
 			skb_shinfo(skb)->frags[i].page_offset = 0;
 			skb_shinfo(skb)->frags[i].size =
@@ -2762,7 +2762,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 
 		i = 0;
 		while (datalen > 0) {
-			struct page *page = alloc_pages(GFP_KERNEL, 0);
+			struct page *page = alloc_page(GFP_KERNEL);
 			skb_shinfo(skb)->frags[i].page = page;
 			skb_shinfo(skb)->frags[i].page_offset = 0;
 			skb_shinfo(skb)->frags[i].size =

-- 
Shani 
