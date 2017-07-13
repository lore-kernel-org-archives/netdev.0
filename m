From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH net 1/1] net sched actions: rename act_get_notify() to tcf_get_notify()
Date: Thu, 13 Jul 2017 13:12:18 -0400
Message-ID: <1499965938-29679-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, Roman Mashak <mrv@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33683 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751384AbdGMRMd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 13:12:33 -0400
Received: by mail-it0-f65.google.com with SMTP id 188so8258048itx.0
        for <netdev@vger.kernel.org>; Thu, 13 Jul 2017 10:12:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make name consistent with other TC event notification routines, such as
tcf_add_notify() and tcf_del_notify()

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
---
 net/sched/act_api.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index aed6cf2..f2e9ed3 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -835,7 +835,7 @@ static int tca_get_fill(struct sk_buff *skb, struct list_head *actions,
 }
 
 static int
-act_get_notify(struct net *net, u32 portid, struct nlmsghdr *n,
+tcf_get_notify(struct net *net, u32 portid, struct nlmsghdr *n,
 	       struct list_head *actions, int event)
 {
 	struct sk_buff *skb;
@@ -1018,7 +1018,7 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 	}
 
 	if (event == RTM_GETACTION)
-		ret = act_get_notify(net, portid, n, &actions, event);
+		ret = tcf_get_notify(net, portid, n, &actions, event);
 	else { /* delete */
 		ret = tcf_del_notify(net, n, &actions, portid);
 		if (ret)
-- 
1.9.1
