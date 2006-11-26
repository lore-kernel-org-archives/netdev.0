From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/sched/: remove unused exports
Date: Sun, 26 Nov 2006 07:29:31 +0100
Message-ID: <20061126062931.GL15364@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:35856 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S967304AbWKZG31 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Nov 2006 01:29:27 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes the following unused EXPORT_SYMBOL's:
- sch_api.c: qdisc_lookup
- sch_generic.c: __netdev_watchdog_up
- sch_generic.c: noop_qdisc_ops
- sch_generic.c: qdisc_alloc

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 net/sched/sch_api.c     |    1 -
 net/sched/sch_generic.c |    3 ---
 2 files changed, 4 deletions(-)

--- linux-2.6.19-rc6-mm1/net/sched/sch_api.c.old	2006-11-26 06:58:02.000000000 +0100
+++ linux-2.6.19-rc6-mm1/net/sched/sch_api.c	2006-11-26 06:58:16.000000000 +0100
@@ -1277,7 +1277,6 @@
 
 subsys_initcall(pktsched_init);
 
-EXPORT_SYMBOL(qdisc_lookup);
 EXPORT_SYMBOL(qdisc_get_rtab);
 EXPORT_SYMBOL(qdisc_put_rtab);
 EXPORT_SYMBOL(register_qdisc);
--- linux-2.6.19-rc6-mm1/net/sched/sch_generic.c.old	2006-11-26 07:02:22.000000000 +0100
+++ linux-2.6.19-rc6-mm1/net/sched/sch_generic.c	2006-11-26 07:03:40.000000000 +0100
@@ -606,13 +606,10 @@
 	qdisc_unlock_tree(dev);
 }
 
-EXPORT_SYMBOL(__netdev_watchdog_up);
 EXPORT_SYMBOL(netif_carrier_on);
 EXPORT_SYMBOL(netif_carrier_off);
 EXPORT_SYMBOL(noop_qdisc);
-EXPORT_SYMBOL(noop_qdisc_ops);
 EXPORT_SYMBOL(qdisc_create_dflt);
-EXPORT_SYMBOL(qdisc_alloc);
 EXPORT_SYMBOL(qdisc_destroy);
 EXPORT_SYMBOL(qdisc_reset);
 EXPORT_SYMBOL(qdisc_lock_tree);

