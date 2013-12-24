From: Chen Weilong <chenweilong@huawei.com>
Subject: [resend patch ipsec-next v2 5/5] xfrm: checkpatch erros with inline keyword position
Date: Tue, 24 Dec 2013 09:43:50 +0800
Message-ID: <1387849430-17860-6-git-send-email-chenweilong@huawei.com>
References: <1387849430-17860-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:41752 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757926Ab3LXBoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 20:44:07 -0500
In-Reply-To: <1387849430-17860-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/xfrm/xfrm_policy.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index b5c315e..fe8942b 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1641,7 +1641,7 @@ free_dst:
 	goto out;
 }
 
-static int inline
+static inline int
 xfrm_dst_alloc_copy(void **target, const void *src, int size)
 {
 	if (!*target) {
@@ -1653,7 +1653,7 @@ xfrm_dst_alloc_copy(void **target, const void *src, int size)
 	return 0;
 }
 
-static int inline
+static inline int
 xfrm_dst_update_parent(struct dst_entry *dst, const struct xfrm_selector *sel)
 {
 #ifdef CONFIG_XFRM_SUB_POLICY
@@ -1665,7 +1665,7 @@ xfrm_dst_update_parent(struct dst_entry *dst, const struct xfrm_selector *sel)
 #endif
 }
 
-static int inline
+static inline int
 xfrm_dst_update_origin(struct dst_entry *dst, const struct flowi *fl)
 {
 #ifdef CONFIG_XFRM_SUB_POLICY
-- 
1.7.12
