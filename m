From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 1/6] net_sched: remove unnecessary parentheses while return
Date: Tue, 10 Dec 2013 20:55:29 +0800
Message-ID: <1386680134-85452-2-git-send-email-yangyingliang@huawei.com>
References: <1386680134-85452-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:4231 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954Ab3LJMzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 07:55:42 -0500
In-Reply-To: <1386680134-85452-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

return is not a function, parentheses are not required.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/act_api.c    | 3 ++-
 net/sched/sch_dsmark.c | 2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index fd70728..92a3c31 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -191,7 +191,8 @@ u32 tcf_hash_new_index(u32 *idx_gen, struct tcf_hashinfo *hinfo)
 			val = 1;
 	} while (tcf_hash_lookup(val, hinfo));
 
-	return (*idx_gen = val);
+	*idx_gen = val;
+	return val;
 }
 EXPORT_SYMBOL(tcf_hash_new_index);
 
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 3886365..0952fd2 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -47,7 +47,7 @@ struct dsmark_qdisc_data {
 
 static inline int dsmark_valid_index(struct dsmark_qdisc_data *p, u16 index)
 {
-	return (index <= p->indices && index > 0);
+	return index <= p->indices && index > 0;
 }
 
 /* ------------------------- Class/flow operations ------------------------- */
-- 
1.8.0
