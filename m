From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V2 1/6] net/sched: cls_matchall: Dump skip flags
Date: Tue, 14 Feb 2017 16:30:35 +0200
Message-ID: <1487082640-24813-2-git-send-email-ogerlitz@mellanox.com>
References: <1487082640-24813-1-git-send-email-ogerlitz@mellanox.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Roi Dayan <roid@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54483 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754066AbdBNOay (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 09:30:54 -0500
In-Reply-To: <1487082640-24813-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The skip flags are not dumped to user-space, do that.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Yotam Gigi <yotamg@mellanox.com>
---
 net/sched/cls_matchall.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index f2141cb..ce2f7d4 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -244,6 +244,8 @@ static int mall_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 	    nla_put_u32(skb, TCA_MATCHALL_CLASSID, head->res.classid))
 		goto nla_put_failure;
 
+	nla_put_u32(skb, TCA_MATCHALL_FLAGS, head->flags);
+
 	if (tcf_exts_dump(skb, &head->exts))
 		goto nla_put_failure;
 
-- 
2.3.7
