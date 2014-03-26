From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH net-next v2 2/3] ipv6: fix checkpatch errors of brace and trailing statements
Date: Wed, 26 Mar 2014 10:37:25 +0800
Message-ID: <1395801446-8700-3-git-send-email-wangyufen@huawei.com>
References: <1395801446-8700-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wang Yufen <wangyufen@huawei.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:55692 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbaCZCiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 22:38:13 -0400
In-Reply-To: <1395801446-8700-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Yufen <wangyufen@huawei.com>

ERROR: open brace '{' following enum go on the same line
ERROR: open brace '{' following struct go on the same line
ERROR: trailing statements should be on next line

Signed-off-by: Wang Yufen <wangyufen@huawei.com>
---
 net/ipv6/ip6_fib.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index c626a0f..8cb6949 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -46,8 +46,7 @@
 
 static struct kmem_cache * fib6_node_kmem __read_mostly;
 
-enum fib_walk_state_t
-{
+enum fib_walk_state_t {
 #ifdef CONFIG_IPV6_SUBTREES
 	FWS_S,
 #endif
@@ -57,8 +56,7 @@ enum fib_walk_state_t
 	FWS_U
 };
 
-struct fib6_cleaner_t
-{
+struct fib6_cleaner_t {
 	struct fib6_walker_t w;
 	struct net *net;
 	int (*func)(struct rt6_info *, void *arg);
@@ -1149,8 +1147,10 @@ static struct fib6_node *fib6_repair_tree(struct net *net,
 
 		children = 0;
 		child = NULL;
-		if (fn->right) child = fn->right, children |= 1;
-		if (fn->left) child = fn->left, children |= 2;
+		if (fn->right)
+			child = fn->right, children |= 1;
+		if (fn->left)
+			child = fn->left, children |= 2;
 
 		if (children == 3 || FIB6_SUBTREE(fn)
 #ifdef CONFIG_IPV6_SUBTREES
@@ -1178,8 +1178,10 @@ static struct fib6_node *fib6_repair_tree(struct net *net,
 		} else {
 			WARN_ON(fn->fn_flags & RTN_ROOT);
 #endif
-			if (pn->right == fn) pn->right = child;
-			else if (pn->left == fn) pn->left = child;
+			if (pn->right == fn)
+				pn->right = child;
+			else if (pn->left == fn)
+				pn->left = child;
 #if RT6_DEBUG >= 2
 			else
 				WARN_ON(1);
-- 
1.7.12
