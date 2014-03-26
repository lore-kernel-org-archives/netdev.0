From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH net-next v2 3/3] ipv6: fix checkpatch errors of foo
Date: Wed, 26 Mar 2014 10:37:26 +0800
Message-ID: <1395801446-8700-4-git-send-email-wangyufen@huawei.com>
References: <1395801446-8700-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wang Yufen <wangyufen@huawei.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:49610 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbaCZCko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 22:40:44 -0400
In-Reply-To: <1395801446-8700-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Yufen <wangyufen@huawei.com>

ERROR: "(foo*)" should be "(foo *)"
ERROR: "foo * bar" should be "foo *bar"

Suggested-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: Wang Yufen <wangyufen@huawei.com>
---
 net/ipv6/ip6_fib.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 8cb6949..aafc5bd 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -44,7 +44,7 @@
 #define RT6_TRACE(x...) do { ; } while (0)
 #endif
 
-static struct kmem_cache * fib6_node_kmem __read_mostly;
+static struct kmem_cache *fib6_node_kmem __read_mostly;
 
 enum fib_walk_state_t {
 #ifdef CONFIG_IPV6_SUBTREES
@@ -143,7 +143,7 @@ static __inline__ __be32 addr_bit_set(const void *token, int fn_bit)
 	       addr[fn_bit >> 5];
 }
 
-static __inline__ struct fib6_node * node_alloc(void)
+static __inline__ struct fib6_node *node_alloc(void)
 {
 	struct fib6_node *fn;
 
@@ -152,7 +152,7 @@ static __inline__ struct fib6_node * node_alloc(void)
 	return fn;
 }
 
-static __inline__ void node_free(struct fib6_node * fn)
+static __inline__ void node_free(struct fib6_node *fn)
 {
 	kmem_cache_free(fib6_node_kmem, fn);
 }
@@ -288,7 +288,7 @@ static int fib6_dump_node(struct fib6_walker_t *w)
 
 static void fib6_dump_end(struct netlink_callback *cb)
 {
-	struct fib6_walker_t *w = (void*)cb->args[2];
+	struct fib6_walker_t *w = (void *)cb->args[2];
 
 	if (w) {
 		if (cb->args[4]) {
@@ -298,7 +298,7 @@ static void fib6_dump_end(struct netlink_callback *cb)
 		cb->args[2] = 0;
 		kfree(w);
 	}
-	cb->done = (void*)cb->args[3];
+	cb->done = (void *)cb->args[3];
 	cb->args[1] = 3;
 }
 
@@ -951,8 +951,8 @@ struct lookup_args {
 	const struct in6_addr	*addr;		/* search key			*/
 };
 
-static struct fib6_node * fib6_lookup_1(struct fib6_node *root,
-					struct lookup_args *args)
+static struct fib6_node *fib6_lookup_1(struct fib6_node *root,
+				       struct lookup_args *args)
 {
 	struct fib6_node *fn;
 	__be32 dir;
@@ -1014,8 +1014,8 @@ backtrack:
 	return NULL;
 }
 
-struct fib6_node * fib6_lookup(struct fib6_node *root, const struct in6_addr *daddr,
-			       const struct in6_addr *saddr)
+struct fib6_node *fib6_lookup(struct fib6_node *root, const struct in6_addr *daddr,
+			      const struct in6_addr *saddr)
 {
 	struct fib6_node *fn;
 	struct lookup_args args[] = {
@@ -1047,9 +1047,9 @@ struct fib6_node * fib6_lookup(struct fib6_node *root, const struct in6_addr *da
  */
 
 
-static struct fib6_node * fib6_locate_1(struct fib6_node *root,
-					const struct in6_addr *addr,
-					int plen, int offset)
+static struct fib6_node *fib6_locate_1(struct fib6_node *root,
+				       const struct in6_addr *addr,
+				       int plen, int offset)
 {
 	struct fib6_node *fn;
 
@@ -1077,9 +1077,9 @@ static struct fib6_node * fib6_locate_1(struct fib6_node *root,
 	return NULL;
 }
 
-struct fib6_node * fib6_locate(struct fib6_node *root,
-			       const struct in6_addr *daddr, int dst_len,
-			       const struct in6_addr *saddr, int src_len)
+struct fib6_node *fib6_locate(struct fib6_node *root,
+			      const struct in6_addr *daddr, int dst_len,
+			      const struct in6_addr *saddr, int src_len)
 {
 	struct fib6_node *fn;
 
-- 
1.7.12
