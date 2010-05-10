From: kaber@trash.net
Subject: [PATCH 03/84] netfilter: remove stale declaration for ip6_masked_addrcmp()
Date: Mon, 10 May 2010 22:17:34 +0200
Message-ID: <1273522735-24672-4-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54501 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756568Ab0EJUS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:18:58 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Commit f2ffd9ee... ("[NETFILTER]: Move ip6_masked_addrcmp to
include/net/ipv6.h") replaced ip6_masked_addrcmp() with
ipv6_masked_addr_cmp().  Function definition went away.

Let's remove its declaration as well in header file.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter_ipv6/ip6_tables.h |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
index e5ba03d..18442ff 100644
--- a/include/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/linux/netfilter_ipv6/ip6_tables.h
@@ -316,10 +316,6 @@ extern int ip6t_ext_hdr(u8 nexthdr);
 extern int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
 			 int target, unsigned short *fragoff);
 
-extern int ip6_masked_addrcmp(const struct in6_addr *addr1,
-			      const struct in6_addr *mask,
-			      const struct in6_addr *addr2);
-
 #define IP6T_ALIGN(s) XT_ALIGN(s)
 
 #ifdef CONFIG_COMPAT
-- 
1.7.0.4

