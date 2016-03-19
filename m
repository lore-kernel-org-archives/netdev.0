From: Luis de Bethencourt <luisbg@osg.samsung.com>
Subject: [PATCH] net: sched: Add description for cpu_bstats argument
Date: Sat, 19 Mar 2016 21:31:38 +0000
Message-ID: <1458423098-3399-1-git-send-email-luisbg@osg.samsung.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org, edumazet@google.com,
	ast@plumgrid.com, Luis de Bethencourt <luisbg@osg.samsung.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 22e0f8b9322c ("net: sched: make bstats per cpu and estimator RCU safe")
added the argument cpu_bstats to functions gen_new_estimator and
gen_replace_estimator and now the descriptions of these are missing for the
documentation. Adding them.

Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>
---
Hi,

Noticed these missing descriptions when running make htmldocs.

Got the following warnings:
.//net/core/gen_estimator.c:212: warning: No description found for parameter 'cpu_bstats'
.//net/core/gen_estimator.c:303: warning: No description found for parameter 'cpu_bstats'

Thanks :)
Luis

 net/core/gen_estimator.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 92d886f..4573d81 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -191,6 +191,7 @@ struct gen_estimator *gen_find_node(const struct gnet_stats_basic_packed *bstats
 /**
  * gen_new_estimator - create a new rate estimator
  * @bstats: basic statistics
+ * @cpu_bstats: bstats per cpu
  * @rate_est: rate estimator statistics
  * @stats_lock: statistics lock
  * @opt: rate estimator configuration TLV
@@ -287,6 +288,7 @@ EXPORT_SYMBOL(gen_kill_estimator);
 /**
  * gen_replace_estimator - replace rate estimator configuration
  * @bstats: basic statistics
+ * @cpu_bstats: bstats per cpu
  * @rate_est: rate estimator statistics
  * @stats_lock: statistics lock
  * @opt: rate estimator configuration TLV
-- 
2.5.1
