From: Shani Moideen <shani.moideen@wipro.com>
Subject: [KJ PATCH] Replacing alloc_pages(gfp,0) with alloc_page(gfp) in
	net/ipv4/ip_output.c.
Date: Tue, 12 Jun 2007 09:28:17 +0530
Message-ID: <1181620697.2282.25.camel@shani-win>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@lists.osdl.org
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@coreworks.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from wip-cdc-wd.wipro.com ([203.91.201.26]:36687 "EHLO
	wip-cdc-wd.wipro.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698AbXFLEFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 00:05:37 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
Replacing alloc_pages(gfp,0) with alloc_page(gfp) in
net/ipv4/ip_output.c.

Signed-off-by: Shani Moideen <shani.moideen@wipro.com>
----

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index d6427d9..f9a87f6 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1003,7 +1003,7 @@ alloc_new_skb:
 			} else if (i < MAX_SKB_FRAGS) {
 				if (copy > PAGE_SIZE)
 					copy = PAGE_SIZE;
-				page = alloc_pages(sk->sk_allocation, 0);
+				page = alloc_page(sk->sk_allocation);
 				if (page == NULL)  {
 					err = -ENOMEM;
 					goto error;

Regards,
Shani

