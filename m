From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 6/11] PKT_SCHED: Transform prototypes to be extern
Date: Wed, 27 Oct 2004 00:26:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026222626.GG12289@postel.suug.ch>
References: <20041026222148.GA12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041026222148.GA12289@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-rc1-bk1.orig/include/net/pkt_sched.h	2004-10-26 23:19:32.000000000 +0200
+++ linux-2.6.10-rc1-bk1/include/net/pkt_sched.h	2004-10-26 23:30:36.000000000 +0200
@@ -211,21 +211,24 @@
 extern struct Qdisc_ops pfifo_qdisc_ops;
 extern struct Qdisc_ops bfifo_qdisc_ops;
 
-int register_qdisc(struct Qdisc_ops *qops);
-int unregister_qdisc(struct Qdisc_ops *qops);
-struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle);
-struct Qdisc *qdisc_lookup_class(struct net_device *dev, u32 handle);
-void dev_init_scheduler(struct net_device *dev);
-void dev_shutdown(struct net_device *dev);
-void dev_activate(struct net_device *dev);
-void dev_deactivate(struct net_device *dev);
-void qdisc_reset(struct Qdisc *qdisc);
-void qdisc_destroy(struct Qdisc *qdisc);
-struct Qdisc * qdisc_create_dflt(struct net_device *dev, struct Qdisc_ops *ops);
-int qdisc_new_estimator(struct tc_stats *stats, spinlock_t *stats_lock, struct rtattr *opt);
-void qdisc_kill_estimator(struct tc_stats *stats);
-struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r, struct rtattr *tab);
-void qdisc_put_rtab(struct qdisc_rate_table *tab);
+extern int register_qdisc(struct Qdisc_ops *qops);
+extern int unregister_qdisc(struct Qdisc_ops *qops);
+extern struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle);
+extern struct Qdisc *qdisc_lookup_class(struct net_device *dev, u32 handle);
+extern void dev_init_scheduler(struct net_device *dev);
+extern void dev_shutdown(struct net_device *dev);
+extern void dev_activate(struct net_device *dev);
+extern void dev_deactivate(struct net_device *dev);
+extern void qdisc_reset(struct Qdisc *qdisc);
+extern void qdisc_destroy(struct Qdisc *qdisc);
+extern struct Qdisc * qdisc_create_dflt(struct net_device *dev,
+	struct Qdisc_ops *ops);
+extern int qdisc_new_estimator(struct tc_stats *stats, spinlock_t *stats_lock,
+	struct rtattr *opt);
+extern void qdisc_kill_estimator(struct tc_stats *stats);
+extern struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r,
+		struct rtattr *tab);
+extern void qdisc_put_rtab(struct qdisc_rate_table *tab);
 
 extern int qdisc_restart(struct net_device *dev);
 
