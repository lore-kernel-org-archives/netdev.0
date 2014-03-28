From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH net-next v2 1/3] ipv6: fix checkpatch errors comments and space
Date: Fri, 28 Mar 2014 12:07:02 +0800
Message-ID: <1395979624-8544-2-git-send-email-wangyufen@huawei.com>
References: <1395979624-8544-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wang Yufen <wangyufen@huawei.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:65270 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbaC1EHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 00:07:30 -0400
In-Reply-To: <1395979624-8544-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Yufen <wangyufen@huawei.com>

WARNING: please, no space before tabs
WARNING: please, no spaces at the start of a line
ERROR: spaces required around that ':' (ctx:VxW)
ERROR: spaces required around that '>' (ctx:VxV)
ERROR: spaces required around that '>=' (ctx:VxV)

Signed-off-by: Wang Yufen <wangyufen@huawei.com>
---
 net/ipv6/ip6_fib.c | 26 ++++++++++++--------------
 1 file changed, 12 insertions(+), 14 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 075602f..c626a0f 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -9,14 +9,12 @@
  *      modify it under the terms of the GNU General Public License
  *      as published by the Free Software Foundation; either version
  *      2 of the License, or (at your option) any later version.
- */
-
-/*
- * 	Changes:
- * 	Yuji SEKIYA @USAGI:	Support default route on router node;
- * 				remove ip6_null_entry from the top of
- * 				routing table.
- * 	Ville Nuorvala:		Fixed routing subtrees.
+ *
+ *	Changes:
+ *	Yuji SEKIYA @USAGI:	Support default route on router node;
+ *				remove ip6_null_entry from the top of
+ *				routing table.
+ *	Ville Nuorvala:		Fixed routing subtrees.
  */
 
 #define pr_fmt(fmt) "IPv6: " fmt
@@ -138,7 +136,7 @@ static __inline__ __be32 addr_bit_set(const void *token, int fn_bit)
 	const __be32 *addr = token;
 	/*
 	 * Here,
-	 * 	1 << ((~fn_bit ^ BITOP_BE32_SWIZZLE) & 0x1f)
+	 *	1 << ((~fn_bit ^ BITOP_BE32_SWIZZLE) & 0x1f)
 	 * is optimized version of
 	 *	htonl(1 << ((~fn_bit)&0x1F))
 	 * See include/asm-generic/bitops/le.h.
@@ -485,7 +483,7 @@ static struct fib6_node *fib6_add_1(struct fib6_node *root,
 		fn->fn_sernum = sernum;
 		dir = addr_bit_set(addr, fn->fn_bit);
 		pn = fn;
-		fn = dir ? fn->right: fn->left;
+		fn = dir ? fn->right : fn->left;
 	} while (fn);
 
 	if (!allow_create) {
@@ -1213,10 +1211,10 @@ static struct fib6_node *fib6_repair_tree(struct net *net,
 					w->node = child;
 					if (children&2) {
 						RT6_TRACE("W %p adjusted by delnode 2, s=%d\n", w, w->state);
-						w->state = w->state>=FWS_R ? FWS_U : FWS_INIT;
+						w->state = w->state >= FWS_R ? FWS_U : FWS_INIT;
 					} else {
 						RT6_TRACE("W %p adjusted by delnode 2, s=%d\n", w, w->state);
-						w->state = w->state>=FWS_C ? FWS_U : FWS_INIT;
+						w->state = w->state >= FWS_C ? FWS_U : FWS_INIT;
 					}
 				}
 			}
@@ -1314,7 +1312,7 @@ int fib6_del(struct rt6_info *rt, struct nl_info *info)
 	struct rt6_info **rtp;
 
 #if RT6_DEBUG >= 2
-	if (rt->dst.obsolete>0) {
+	if (rt->dst.obsolete > 0) {
 		WARN_ON(fn != NULL);
 		return -ENOENT;
 	}
@@ -1707,7 +1705,7 @@ out_rt6_stats:
 	kfree(net->ipv6.rt6_stats);
 out_timer:
 	return -ENOMEM;
- }
+}
 
 static void fib6_net_exit(struct net *net)
 {
-- 
1.7.12
