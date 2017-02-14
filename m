From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH net-next] net_sched: nla_memdup_cookie() can be static
Date: Tue, 14 Feb 2017 14:19:32 +0000
Message-ID: <20170214141932.15115-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f194.google.com ([209.85.213.194]:32779 "EHLO
        mail-yb0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753912AbdBNOTk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 09:19:40 -0500
Received: by mail-yb0-f194.google.com with SMTP id 123so5512631ybe.0
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2017 06:19:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fixes the following sparse warning:

net/sched/act_api.c:532:5: warning:
 symbol 'nla_memdup_cookie' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 net/sched/act_api.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 3c5e29b..f219ff3 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -529,7 +529,7 @@ int tcf_action_dump(struct sk_buff *skb, struct list_head *actions,
 	return err;
 }
 
-int nla_memdup_cookie(struct tc_action *a, struct nlattr **tb)
+static int nla_memdup_cookie(struct tc_action *a, struct nlattr **tb)
 {
 	a->act_cookie = kzalloc(sizeof(*a->act_cookie), GFP_KERNEL);
 	if (!a->act_cookie)
