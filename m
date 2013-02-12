From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v5 03/11] htb: remove pointless first initialization of buffer and cbuffer
Date: Tue, 12 Feb 2013 11:12:01 +0100
Message-ID: <1360663929-1023-4-git-send-email-jiri@resnulli.us>
References: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:47462 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932782Ab3BLKMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 05:12:25 -0500
Received: by mail-ea0-f174.google.com with SMTP id 1so76065eaa.5
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 02:12:24 -0800 (PST)
In-Reply-To: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
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
