From: Florian Westphal <fw@strlen.de>
Subject: [PATCH ipsec-next] xfrm: remove unused helper
Date: Tue, 27 Sep 2016 17:53:58 +0200
Message-ID: <1474991638-10666-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:53264 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932181AbcI0Pxt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 11:53:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not used anymore since 2009 (9e0d57fd6dad37,
'xfrm: SAD entries do not expire correctly after suspend-resume').

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/xfrm/xfrm_state.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index bf5969aa7dc2..9ca9a30c3fcf 100644
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
2.7.3
