From: Alexander Alemayhu <alexander@alemayhu.com>
Subject: [PATCH ipsec] xfrm: trivial typos
Date: Tue,  3 Jan 2017 17:13:20 +0100
Message-ID: <20170103161320.1372-1-alexander@alemayhu.com>
Cc: steffen.klassert@secunet.com,
        Alexander Alemayhu <alexander@alemayhu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:33643 "EHLO
        mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759330AbdACQUW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 11:20:22 -0500
Received: by mail-lf0-f49.google.com with SMTP id c13so288493986lfg.0
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2017 08:20:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o s/descentant/descendant
o s/workarbound/workaround

Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>
---
 net/xfrm/xfrm_policy.c | 2 +-
 net/xfrm/xfrm_state.c  | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 177e208e8ff5..99ad1af2927f 100644
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
index 64e3c82eedf6..c5cf4d611aab 100644
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
2.11.0
