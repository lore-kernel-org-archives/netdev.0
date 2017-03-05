From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] net/sched: act_skbmod: remove unneeded rcu_read_unlock in tcf_skbmod_dump
Date: Sun,  5 Mar 2017 03:01:55 +0300
Message-ID: <1488672115-11057-1-git-send-email-khoroshilov@ispras.ru>
References: <f9a9b434-ea38-3f7f-6207-8c7bc7317bc4@mojatatu.com>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f9a9b434-ea38-3f7f-6207-8c7bc7317bc4@mojatatu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 net/sched/act_skbmod.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sched/act_skbmod.c b/net/sched/act_skbmod.c
index 3b7074e23024..c736627f8f4a 100644
--- a/net/sched/act_skbmod.c
+++ b/net/sched/act_skbmod.c
@@ -228,7 +228,6 @@ static int tcf_skbmod_dump(struct sk_buff *skb, struct tc_action *a,
 
 	return skb->len;
 nla_put_failure:
-	rcu_read_unlock();
 	nlmsg_trim(skb, b);
 	return -1;
 }
-- 
2.7.4
