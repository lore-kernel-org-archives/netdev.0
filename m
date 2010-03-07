From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6] netfilter: Remove stale declaration for ip6_masked_addrcmp().
Date: Sun, 7 Mar 2010 17:39:13 +0900
Message-ID: <201003070918.o279IfCk029612@94.43.138.210.xn.2iij.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: kaber@trash.net, davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit f2ffd9ee... ("[NETFILTER]: Move ip6_masked_addrcmp to
include/net/ipv6.h") replaced ip6_masked_addrcmp() with
ipv6_masked_addr_cmp().  Function definition went away.

Let's remove its declaration as well in header file.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
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
1.5.6.5

