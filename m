From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 03/11] htb: remove pointless first initialization of buffer and cbuffer
Date: Sat,  9 Feb 2013 17:45:04 +0100
Message-ID: <1360428312-1277-4-git-send-email-jiri@resnulli.us>
References: <1360428312-1277-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:48565 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932409Ab3BIQp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2013 11:45:27 -0500
Received: by mail-ee0-f47.google.com with SMTP id e52so2537025eek.34
        for <netdev@vger.kernel.org>; Sat, 09 Feb 2013 08:45:26 -0800 (PST)
In-Reply-To: <1360428312-1277-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

these are initialized correctly couple of lines later in the function.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_htb.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 14a83dc..547912e9 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1503,9 +1503,6 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 			cl->prio = TC_HTB_NUMPRIO - 1;
 	}
 
-	cl->buffer = hopt->buffer;
-	cl->cbuffer = hopt->cbuffer;
-
 	cl->rate.rate_bps = (u64)hopt->rate.rate << 3;
 	cl->ceil.rate_bps = (u64)hopt->ceil.rate << 3;
 
-- 
1.8.1.2
