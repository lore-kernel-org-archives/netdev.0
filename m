From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] act_mirred: fix a typo in get_dev
Date: Sat,  3 Dec 2016 10:36:01 -0800
Message-ID: <1480790161-8097-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35219 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750749AbcLCSiI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 13:38:08 -0500
Received: by mail-pg0-f65.google.com with SMTP id p66so11409695pga.2
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 10:38:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Hadar Hen Zion <hadarh@mellanox.com>
Cc: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_mirred.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index bb09ba3..2d9fa6e 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -321,7 +321,7 @@ static int tcf_mirred_device(const struct tc_action *a, struct net *net,
 	int ifindex = tcf_mirred_ifindex(a);
 
 	*mirred_dev = __dev_get_by_index(net, ifindex);
-	if (!mirred_dev)
+	if (!*mirred_dev)
 		return -EINVAL;
 	return 0;
 }
-- 
2.1.4
