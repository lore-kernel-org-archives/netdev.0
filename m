From: Shani Moideen <shani.moideen@wipro.com>
Subject: [KJ PATCH] Replacing alloc_pages(gfp,0) with alloc_page(gfp) in
	net/ipv6/ip6_output.c
Date: Tue, 12 Jun 2007 10:28:44 +0530
Message-ID: <1181624324.2282.29.camel@shani-win>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@lists.osdl.org
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wip-cdc-wd.wipro.com ([203.91.201.26]:39099 "EHLO
	wip-cdc-wd.wipro.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752831AbXFLFFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 01:05:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
Replacing alloc_pages(gfp,0) with alloc_page(gfp) in net/ipv6/ip6_output.c

Signed-off-by: Shani Moideen <shani.moideen@wipro.com>
----

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index f508171..1d27779 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1291,7 +1291,7 @@ alloc_new_skb:
 			} else if(i < MAX_SKB_FRAGS) {
 				if (copy > PAGE_SIZE)
 					copy = PAGE_SIZE;
-				page = alloc_pages(sk->sk_allocation, 0);
+				page = alloc_page(sk->sk_allocation);
 				if (page == NULL) {
 					err = -ENOMEM;
 					goto error;


Regards,
Shani 
