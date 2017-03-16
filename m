From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 1/2] net/sched: act_ife: Staticfy find_decode_metaid()
Date: Thu, 16 Mar 2017 10:49:04 +0200
Message-ID: <1489654145-20532-2-git-send-email-ogerlitz@mellanox.com>
References: <1489654145-20532-1-git-send-email-ogerlitz@mellanox.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52397 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751583AbdCPItQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 04:49:16 -0400
In-Reply-To: <1489654145-20532-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As it's used only on that file.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 net/sched/act_ife.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index 71e7ff22..c75ea5c 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -603,8 +603,8 @@ static int tcf_ife_dump(struct sk_buff *skb, struct tc_action *a, int bind,
 	return -1;
 }
 
-int find_decode_metaid(struct sk_buff *skb, struct tcf_ife_info *ife,
-		       u16 metaid, u16 mlen, void *mdata)
+static int find_decode_metaid(struct sk_buff *skb, struct tcf_ife_info *ife,
+			      u16 metaid, u16 mlen, void *mdata)
 {
 	struct tcf_meta_info *e;
 
-- 
2.3.7
