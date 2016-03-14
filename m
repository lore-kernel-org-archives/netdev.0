From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH trivial] netfilter: xt_limit: Spelling s/maxmum/maximum/
Date: Mon, 14 Mar 2016 16:32:26 +0100
Message-ID: <1457969546-23971-1-git-send-email-geert+renesas@glider.be>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S. Miller" <davem@davemloft.net>,
	Jiri Kosina <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xavier.telenet-ops.be ([195.130.132.52]:34178 "EHLO
	xavier.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934521AbcCNPc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 11:32:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
 net/netfilter/xt_limit.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/xt_limit.c b/net/netfilter/xt_limit.c
index bef8505965589298..c1a4d5bf25d5bf9f 100644
--- a/net/netfilter/xt_limit.c
+++ b/net/netfilter/xt_limit.c
@@ -47,7 +47,7 @@ static DEFINE_SPINLOCK(limit_lock);
 
    See Alexey's formal explanation in net/sched/sch_tbf.c.
 
-   To get the maxmum range, we multiply by this factor (ie. you get N
+   To get the maximum range, we multiply by this factor (ie. you get N
    credits per jiffy).  We want to allow a rate as low as 1 per day
    (slowest userspace tool allows), which means
    CREDITS_PER_JIFFY*HZ*60*60*24 < 2^32. ie. */
-- 
1.9.1
