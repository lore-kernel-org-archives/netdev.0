From: Chen Weilong <chenweilong@huawei.com>
Subject: [patch ipsec-next 5/5] xfrm: checkpatch erros with inline keyword position
Date: Fri, 20 Dec 2013 18:49:37 +0800
Message-ID: <1387536577-11480-6-git-send-email-chenweilong@huawei.com>
References: <1387536577-11480-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:25238 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932293Ab3LTKuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 05:50:05 -0500
In-Reply-To: <1387536577-11480-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>


Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/xfrm/xfrm_policy.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 0ed4770..26cbbab 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1640,7 +1640,7 @@ free_dst:
 	goto out;
 }
 
-static int inline
+static inline int
 xfrm_dst_alloc_copy(void **target, const void *src, int size)
 {
 	if (!*target) {
@@ -1652,7 +1652,7 @@ xfrm_dst_alloc_copy(void **target, const void *src, int size)
 	return 0;
 }
 
-static int inline
+static inline int
 xfrm_dst_update_parent(struct dst_entry *dst, const struct xfrm_selector *sel)
 {
 #ifdef CONFIG_XFRM_SUB_POLICY
@@ -1664,7 +1664,7 @@ xfrm_dst_update_parent(struct dst_entry *dst, const struct xfrm_selector *sel)
 #endif
 }
 
-static int inline
+static inline int
 xfrm_dst_update_origin(struct dst_entry *dst, const struct flowi *fl)
 {
 #ifdef CONFIG_XFRM_SUB_POLICY
-- 
1.7.12
