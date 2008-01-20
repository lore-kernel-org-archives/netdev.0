From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 3/3][NET] gen_estimator: gen_replace_estimator() cosmetic
	changes
Date: Mon, 21 Jan 2008 00:51:15 +0100
Message-ID: <20080120235115.GC2691@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:40063 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756188AbYATXsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 18:48:51 -0500
Received: by ug-out-1314.google.com with SMTP id z38so798177ugc.16
        for <netdev@vger.kernel.org>; Sun, 20 Jan 2008 15:48:49 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

White spaces etc. are changed in gen_replace_estimator() to make it similar
to others in a file.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

diff -Nurp 2.6.24-rc8-mm1-p2-/net/core/gen_estimator.c 2.6.24-rc8-mm1-p2+/net/core/gen_estimator.c
--- 2.6.24-rc8-mm1-p2-/net/core/gen_estimator.c	2008-01-20 21:07:42.000000000 +0100
+++ 2.6.24-rc8-mm1-p2+/net/core/gen_estimator.c	2008-01-20 21:15:36.000000000 +0100
@@ -275,7 +275,7 @@ static void gen_kill_estimator_find(stru
 }
 
 /**
- * gen_replace_estimator - replace rate estimator configruation
+ * gen_replace_estimator - replace rate estimator configuration
  * @bstats: basic statistics
  * @rate_est: rate estimator statistics
  * @stats_lock: statistics lock
@@ -286,13 +286,12 @@ static void gen_kill_estimator_find(stru
  *
  * Returns 0 on success or a negative error code.
  */
-int
-gen_replace_estimator(struct gnet_stats_basic *bstats,
-	struct gnet_stats_rate_est *rate_est, spinlock_t *stats_lock,
-	struct rtattr *opt)
+int gen_replace_estimator(struct gnet_stats_basic *bstats,
+			  struct gnet_stats_rate_est *rate_est,
+			  spinlock_t *stats_lock, struct rtattr *opt)
 {
-    gen_kill_estimator(bstats, rate_est);
-    return gen_new_estimator(bstats, rate_est, stats_lock, opt);
+	gen_kill_estimator(bstats, rate_est);
+	return gen_new_estimator(bstats, rate_est, stats_lock, opt);
 }
 
 
