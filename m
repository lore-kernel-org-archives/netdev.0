From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH] xfrm: remove unused helper
Date: Thu, 1 Dec 2016 12:48:05 +0100
Message-ID: <1480592885-3903-2-git-send-email-steffen.klassert@secunet.com>
References: <1480592885-3903-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:50124 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754358AbcLALsX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Dec 2016 06:48:23 -0500
In-Reply-To: <1480592885-3903-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Not used anymore since 2009 (9e0d57fd6dad37,
'xfrm: SAD entries do not expire correctly after suspend-resume').

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 419bf5d..45cb7c6 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -388,14 +388,6 @@ static void xfrm_state_gc_task(struct work_struct *work)
 		xfrm_state_gc_destroy(x);
 }
 
-static inline unsigned long make_jiffies(long secs)
-{
-	if (secs >= (MAX_SCHEDULE_TIMEOUT-1)/HZ)
-		return MAX_SCHEDULE_TIMEOUT-1;
-	else
-		return secs*HZ;
-}
-
 static enum hrtimer_restart xfrm_timer_handler(struct hrtimer *me)
 {
 	struct tasklet_hrtimer *thr = container_of(me, struct tasklet_hrtimer, timer);
-- 
1.9.1
