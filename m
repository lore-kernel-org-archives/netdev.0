From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 05/15] xfrm: checkpatch erros with inline keyword position
Date: Tue, 14 Jan 2014 07:49:09 +0100
Message-ID: <1389682159-3260-6-git-send-email-steffen.klassert@secunet.com>
References: <1389682159-3260-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60084 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751566AbaANGti (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 01:49:38 -0500
In-Reply-To: <1389682159-3260-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c |    6 +++---
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
1.7.9.5
