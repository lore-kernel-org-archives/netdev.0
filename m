From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH 1/1] net_sched: Improve readability of filter processing
Date: Thu, 18 Feb 2016 08:04:43 -0500
Message-ID: <1455800683-17456-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:33455 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946061AbcBRNEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 08:04:54 -0500
Received: by mail-ig0-f174.google.com with SMTP id y8so13042441igp.0
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 05:04:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/sch_api.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index af1acf0..de1e176 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1841,7 +1841,7 @@ reclassify:
 			return err;
 	}
 
-	return -1;
+	return TC_ACT_UNSPEC; /* signal: continue lookup */
 #ifdef CONFIG_NET_CLS_ACT
 reset:
 	if (unlikely(limit++ >= MAX_REC_LOOP)) {
-- 
1.9.1
