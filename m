From: Chen Weilong <chenweilong@huawei.com>
Subject: [patch net-next 5/5] xfrm: checkpatch erros with inline keyword position
Date: Thu, 19 Dec 2013 20:22:14 +0800
Message-ID: <1387455734-7624-6-git-send-email-chenweilong@huawei.com>
References: <1387455734-7624-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:5858 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755704Ab3LSMWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 07:22:39 -0500
In-Reply-To: <1387455734-7624-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

inline keyword should sit between storage class and type.

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/xfrm/xfrm_policy.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 8be5abb..7a55437 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1635,7 +1635,7 @@ free_dst:
 	goto out;
 }
 
-static int inline
+static inline int
 xfrm_dst_alloc_copy(void **target, const void *src, int size)
 {
 	if (!*target) {
@@ -1647,7 +1647,7 @@ xfrm_dst_alloc_copy(void **target, const void *src, int size)
 	return 0;
 }
 
-static int inline
+static inline int
 xfrm_dst_update_parent(struct dst_entry *dst, const struct xfrm_selector *sel)
 {
 #ifdef CONFIG_XFRM_SUB_POLICY
@@ -1659,7 +1659,7 @@ xfrm_dst_update_parent(struct dst_entry *dst, const struct xfrm_selector *sel)
 #endif
 }
 
-static int inline
+static inline int
 xfrm_dst_update_origin(struct dst_entry *dst, const struct flowi *fl)
 {
 #ifdef CONFIG_XFRM_SUB_POLICY
-- 
1.7.12
