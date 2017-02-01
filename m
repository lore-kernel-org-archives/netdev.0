From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 01/15] xfrm: trivial typos
Date: Wed, 1 Feb 2017 09:17:43 +0100
Message-ID: <1485937077-612-2-git-send-email-steffen.klassert@secunet.com>
References: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:37032 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751687AbdBAISI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Feb 2017 03:18:08 -0500
In-Reply-To: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Alemayhu <alexander@alemayhu.com>

o s/descentant/descendant
o s/workarbound/workaround

Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c | 2 +-
 net/xfrm/xfrm_state.c  | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 177e208..99ad1af2 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -330,7 +330,7 @@ void xfrm_policy_destroy(struct xfrm_policy *policy)
 }
 EXPORT_SYMBOL(xfrm_policy_destroy);
 
-/* Rule must be locked. Release descentant resources, announce
+/* Rule must be locked. Release descendant resources, announce
  * entry dead. The rule must be unlinked from lists to the moment.
  */
 
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 64e3c82..c5cf4d6 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -409,7 +409,7 @@ static enum hrtimer_restart xfrm_timer_handler(struct hrtimer *me)
 			if (x->xflags & XFRM_SOFT_EXPIRE) {
 				/* enter hard expire without soft expire first?!
 				 * setting a new date could trigger this.
-				 * workarbound: fix x->curflt.add_time by below:
+				 * workaround: fix x->curflt.add_time by below:
 				 */
 				x->curlft.add_time = now - x->saved_tmo - 1;
 				tmo = x->lft.hard_add_expires_seconds - x->saved_tmo;
-- 
1.9.1
