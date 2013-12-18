From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 2/2] sch_htb: use /* comments
Date: Wed, 18 Dec 2013 20:04:52 +0800
Message-ID: <1387368292-18120-3-git-send-email-yangyingliang@huawei.com>
References: <1387368292-18120-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:23325 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751474Ab3LRMFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 07:05:01 -0500
In-Reply-To: <1387368292-18120-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not use C99 // comments and correct a spelling typo.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_htb.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 5c5f01c..542a750 100644
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
