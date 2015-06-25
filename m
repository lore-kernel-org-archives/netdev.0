From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH 1/1] net: sched: flower fix typo
Date: Thu, 25 Jun 2015 06:55:27 -0400
Message-ID: <1435229727-3398-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <hadi@mojatatu.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:33932 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995AbbFYKzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 06:55:40 -0400
Received: by igcsj18 with SMTP id sj18so5450437igc.1
        for <netdev@vger.kernel.org>; Thu, 25 Jun 2015 03:55:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <hadi@mojatatu.com>

Fix typo in the validation rules for flower's attributes

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/cls_flower.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index b92d3f4..9d37ccd 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -216,8 +216,8 @@ static const struct nla_policy fl_policy[TCA_FLOWER_MAX + 1] = {
 	[TCA_FLOWER_KEY_IPV6_DST_MASK]	= { .len = sizeof(struct in6_addr) },
 	[TCA_FLOWER_KEY_TCP_SRC]	= { .type = NLA_U16 },
 	[TCA_FLOWER_KEY_TCP_DST]	= { .type = NLA_U16 },
-	[TCA_FLOWER_KEY_TCP_SRC]	= { .type = NLA_U16 },
-	[TCA_FLOWER_KEY_TCP_DST]	= { .type = NLA_U16 },
+	[TCA_FLOWER_KEY_UDP_SRC]	= { .type = NLA_U16 },
+	[TCA_FLOWER_KEY_UDP_DST]	= { .type = NLA_U16 },
 };
 
 static void fl_set_key_val(struct nlattr **tb,
-- 
1.7.9.5
