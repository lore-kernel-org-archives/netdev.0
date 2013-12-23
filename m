From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next v2 2/3] sch_htb: use /* comments
Date: Mon, 23 Dec 2013 17:38:59 +0800
Message-ID: <1387791540-27028-3-git-send-email-yangyingliang@huawei.com>
References: <1387791540-27028-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:18393 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190Ab3LWJj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 04:39:29 -0500
In-Reply-To: <1387791540-27028-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not use C99 // comments and correct a spelling typo.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_htb.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index e598810..0db5a6e 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1276,9 +1276,10 @@ static int htb_delete(struct Qdisc *sch, unsigned long arg)
 	struct Qdisc *new_q = NULL;
 	int last_child = 0;
 
-	// TODO: why don't allow to delete subtree ? references ? does
-	// tc subsys quarantee us that in htb_destroy it holds no class
-	// refs so that we can remove children safely there ?
+	/* TODO: why don't allow to delete subtree ? references ? does
+	 * tc subsys guarantee us that in htb_destroy it holds no class
+	 * refs so that we can remove children safely there ?
+	 */
 	if (cl->children || cl->filter_cnt)
 		return -EBUSY;
 
-- 
1.8.0
