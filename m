From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] make qdisc_class_hash_alloc() static
Date: Tue, 22 Jul 2008 20:20:41 +0300
Message-ID: <20080722172041.GS14846@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:34777 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754791AbYGVRUw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 13:20:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the needlessly global qdisc_class_hash_alloc() static.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
0fe6b0fa7332eaeeaacbfae2052dfd46e3ef66ab 
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 5219d5f..b060164 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -447,7 +447,7 @@ void qdisc_watchdog_cancel(struct qdisc_watchdog *wd)
 }
 EXPORT_SYMBOL(qdisc_watchdog_cancel);
 
-struct hlist_head *qdisc_class_hash_alloc(unsigned int n)
+static struct hlist_head *qdisc_class_hash_alloc(unsigned int n)
 {
 	unsigned int size = n * sizeof(struct hlist_head), i;
 	struct hlist_head *h;

