From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/6] net_sched: cls_flow: remove duplicate assignments
Date: Tue,  2 Dec 2014 18:00:35 +0100
Message-ID: <1417539636-12710-6-git-send-email-jiri@resnulli.us>
References: <1417539636-12710-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:42613 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754121AbaLBRH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 12:07:57 -0500
Received: by mail-wg0-f51.google.com with SMTP id k14so17363852wgh.24
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 09:07:56 -0800 (PST)
In-Reply-To: <1417539636-12710-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/cls_flow.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index a605739..819c230 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -426,10 +426,7 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 			goto err2;
 
 		/* Copy fold into fnew */
-		fnew->handle = fold->handle;
-		fnew->keymask = fold->keymask;
 		fnew->tp = fold->tp;
-
 		fnew->handle = fold->handle;
 		fnew->nkeys = fold->nkeys;
 		fnew->keymask = fold->keymask;
-- 
1.9.3
