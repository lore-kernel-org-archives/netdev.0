From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH net-next] net/sched: pkt_cls: change tc actions order to be as the user sets
Date: Sun, 25 Sep 2016 17:08:44 +0300
Message-ID: <1474812524-29089-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49154 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S934881AbcIYOJF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 10:09:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the created tc actions list is reversed against the order
set by the user.
Change the actions list order to be the same as was set by the user.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
---
 include/net/pkt_cls.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 5ccaa4b..767b03a 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -123,7 +123,7 @@ static inline void tcf_exts_to_list(const struct tcf_exts *exts,
 	for (i = 0; i < exts->nr_actions; i++) {
 		struct tc_action *a = exts->actions[i];
 
-		list_add(&a->list, actions);
+		list_add_tail(&a->list, actions);
 	}
 #endif
 }
-- 
1.8.3.1
