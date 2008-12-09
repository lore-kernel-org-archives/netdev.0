From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH 28/31] net: Make static
Date: Tue, 09 Dec 2008 23:20:24 +0100
Message-ID: <493EEF28.1040007@gmail.com>
References: <493EA286.7080500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755479AbYLIWUk@vger.kernel.org>
In-Reply-To: <493EA286.7080500@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sparse asked whether these could be static.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 net/decnet/dn_dev.c                      |    2 +-
 net/decnet/dn_route.c                    |    4 ++--
 net/dsa/mv88e6060.c                      |    4 ++--
 net/dsa/mv88e6123_61_65.c                |    4 ++--
 net/dsa/mv88e6131.c                      |    4 ++--
 net/irda/irttp.c                         |   14 +++++++-------
 net/irda/timer.c                         |    2 +-
 net/mac80211/rc80211_minstrel.c          |    8 ++++----
 net/phonet/sysctl.c                      |    2 +-
 net/rxrpc/ar-connection.c                |    2 +-
 net/rxrpc/ar-connevent.c                 |    2 +-
 net/rxrpc/ar-security.c                  |    2 +-
 net/sched/sch_api.c                      |    2 +-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |    2 +-
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 +-
 net/wireless/reg.c                       |    2 +-
 16 files changed, 29 insertions(+), 29 deletions(-)

diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 28e26bd..5b066f7 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -1106,7 +1106,7 @@ static void dn_dev_set_timer(struct net_device *dev)
 	add_timer(&dn_db->timer);
 }
 
-struct dn_dev *dn_dev_create(struct net_device *dev, int *err)
+static struct dn_dev *dn_dev_create(struct net_device *dev, int *err)
 {
 	int i;
 	struct dn_dev_parms *p = dn_dev_list;
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 821bd1c..5ab48d0 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -312,7 +312,7 @@ static int dn_insert_route(struct dn_route *rt, unsigned hash, struct dn_route *
 	return 0;
 }
 
-void dn_run_flush(unsigned long dummy)
+static void dn_run_flush(unsigned long dummy)
 {
 	int i;
 	struct dn_route *rt, *next;
@@ -1423,7 +1423,7 @@ e_neighbour:
 	goto done;
 }
 
-int dn_route_input(struct sk_buff *skb)
+static int dn_route_input(struct sk_buff *skb)
 {
 	struct dn_route *rt;
 	struct dn_skb_cb *cb = DN_SKB_CB(skb);
diff --git a/net/dsa/mv88e6060.c b/net/dsa/mv88e6060.c
index 54068ef..0f69224 100644
--- a/net/dsa/mv88e6060.c
+++ b/net/dsa/mv88e6060.c
@@ -273,14 +273,14 @@ static struct dsa_switch_driver mv88e6060_switch_driver = {
 	.poll_link	= mv88e6060_poll_link,
 };
 
-int __init mv88e6060_init(void)
+static int __init mv88e6060_init(void)
 {
 	register_switch_driver(&mv88e6060_switch_driver);
 	return 0;
 }
 module_init(mv88e6060_init);
 
-void __exit mv88e6060_cleanup(void)
+static void __exit mv88e6060_cleanup(void)
 {
 	unregister_switch_driver(&mv88e6060_switch_driver);
 }
diff --git a/net/dsa/mv88e6123_61_65.c b/net/dsa/mv88e6123_61_65.c
index 555b164..ec8c6a0 100644
--- a/net/dsa/mv88e6123_61_65.c
+++ b/net/dsa/mv88e6123_61_65.c
@@ -407,14 +407,14 @@ static struct dsa_switch_driver mv88e6123_61_65_switch_driver = {
 	.get_sset_count		= mv88e6123_61_65_get_sset_count,
 };
 
-int __init mv88e6123_61_65_init(void)
+static int __init mv88e6123_61_65_init(void)
 {
 	register_switch_driver(&mv88e6123_61_65_switch_driver);
 	return 0;
 }
 module_init(mv88e6123_61_65_init);
 
-void __exit mv88e6123_61_65_cleanup(void)
+static void __exit mv88e6123_61_65_cleanup(void)
 {
 	unregister_switch_driver(&mv88e6123_61_65_switch_driver);
 }
diff --git a/net/dsa/mv88e6131.c b/net/dsa/mv88e6131.c
index 36e01eb..374d46a 100644
--- a/net/dsa/mv88e6131.c
+++ b/net/dsa/mv88e6131.c
@@ -366,14 +366,14 @@ static struct dsa_switch_driver mv88e6131_switch_driver = {
 	.get_sset_count		= mv88e6131_get_sset_count,
 };
 
-int __init mv88e6131_init(void)
+static int __init mv88e6131_init(void)
 {
 	register_switch_driver(&mv88e6131_switch_driver);
 	return 0;
 }
 module_init(mv88e6131_init);
 
-void __exit mv88e6131_cleanup(void)
+static void __exit mv88e6131_cleanup(void)
 {
 	unregister_switch_driver(&mv88e6131_switch_driver);
 }
diff --git a/net/irda/irttp.c b/net/irda/irttp.c
index 74e439e..ecf4eb2 100644
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -201,7 +201,7 @@ static void irttp_todo_expired(unsigned long data)
  *
  *     Flushes (removes all frames) in transitt-buffer (tx_list)
  */
-void irttp_flush_queues(struct tsap_cb *self)
+static void irttp_flush_queues(struct tsap_cb *self)
 {
 	struct sk_buff* skb;
 
@@ -1266,9 +1266,9 @@ static void irttp_connect_confirm(void *instance, void *sap,
  *    Some other device is connecting to this TSAP
  *
  */
-void irttp_connect_indication(void *instance, void *sap, struct qos_info *qos,
-			      __u32 max_seg_size, __u8 max_header_size,
-			      struct sk_buff *skb)
+static void irttp_connect_indication(void *instance, void *sap,
+		struct qos_info *qos, __u32 max_seg_size, __u8 max_header_size,
+		struct sk_buff *skb)
 {
 	struct tsap_cb *self;
 	struct lsap_cb *lsap;
@@ -1579,8 +1579,8 @@ EXPORT_SYMBOL(irttp_disconnect_request);
  *    Disconnect indication, TSAP disconnected by peer?
  *
  */
-void irttp_disconnect_indication(void *instance, void *sap, LM_REASON reason,
-				 struct sk_buff *skb)
+static void irttp_disconnect_indication(void *instance, void *sap,
+		LM_REASON reason, struct sk_buff *skb)
 {
 	struct tsap_cb *self;
 
@@ -1664,7 +1664,7 @@ static void irttp_do_data_indication(struct tsap_cb *self, struct sk_buff *skb)
  *     Check if we have any frames to be transmitted, or if we have any
  *     available credit to give away.
  */
-void irttp_run_rx_queue(struct tsap_cb *self)
+static void irttp_run_rx_queue(struct tsap_cb *self)
 {
 	struct sk_buff *skb;
 	int more = 0;
diff --git a/net/irda/timer.c b/net/irda/timer.c
index d730099..0335ba0 100644
--- a/net/irda/timer.c
+++ b/net/irda/timer.c
@@ -219,7 +219,7 @@ static void irlap_backoff_timer_expired(void *data)
  *
  *
  */
-void irlap_media_busy_expired(void* data)
+static void irlap_media_busy_expired(void *data)
 {
 	struct irlap_cb *self = (struct irlap_cb *) data;
 
diff --git a/net/mac80211/rc80211_minstrel.c b/net/mac80211/rc80211_minstrel.c
index f6d69da..7639bcc 100644
--- a/net/mac80211/rc80211_minstrel.c
+++ b/net/mac80211/rc80211_minstrel.c
@@ -233,10 +233,10 @@ minstrel_get_next_sample(struct minstrel_sta_info *mi)
 	return sample_ndx;
 }
 
-void
-minstrel_get_rate(void *priv, struct ieee80211_supported_band *sband,
-                  struct ieee80211_sta *sta, void *priv_sta,
-                  struct sk_buff *skb, struct rate_selection *sel)
+static void minstrel_get_rate(void *priv,
+		struct ieee80211_supported_band *sband,
+		struct ieee80211_sta *sta, void *priv_sta,
+		struct sk_buff *skb, struct rate_selection *sel)
 {
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 	struct minstrel_sta_info *mi = priv_sta;
diff --git a/net/phonet/sysctl.c b/net/phonet/sysctl.c
index 600a430..1532042 100644
--- a/net/phonet/sysctl.c
+++ b/net/phonet/sysctl.c
@@ -95,7 +95,7 @@ static struct ctl_table phonet_table[] = {
 	{ .ctl_name = 0 }
 };
 
-struct ctl_path phonet_ctl_path[] = {
+static struct ctl_path phonet_ctl_path[] = {
 	{ .procname = "net", .ctl_name = CTL_NET, },
 	{ .procname = "phonet", .ctl_name = CTL_UNNUMBERED, },
 	{ },
diff --git a/net/rxrpc/ar-connection.c b/net/rxrpc/ar-connection.c
index 3869a58..0f1218b 100644
--- a/net/rxrpc/ar-connection.c
+++ b/net/rxrpc/ar-connection.c
@@ -826,7 +826,7 @@ static void rxrpc_destroy_connection(struct rxrpc_connection *conn)
 /*
  * reap dead connections
  */
-void rxrpc_connection_reaper(struct work_struct *work)
+static void rxrpc_connection_reaper(struct work_struct *work)
 {
 	struct rxrpc_connection *conn, *_p;
 	unsigned long now, earliest, reap_time;
diff --git a/net/rxrpc/ar-connevent.c b/net/rxrpc/ar-connevent.c
index 1ada43d..dc5cb1e 100644
--- a/net/rxrpc/ar-connevent.c
+++ b/net/rxrpc/ar-connevent.c
@@ -126,7 +126,7 @@ static int rxrpc_abort_connection(struct rxrpc_connection *conn,
  * mark a call as being on a now-secured channel
  * - must be called with softirqs disabled
  */
-void rxrpc_call_is_secure(struct rxrpc_call *call)
+static void rxrpc_call_is_secure(struct rxrpc_call *call)
 {
 	_enter("%p", call);
 	if (call) {
diff --git a/net/rxrpc/ar-security.c b/net/rxrpc/ar-security.c
index 60d1d36..dc62920 100644
--- a/net/rxrpc/ar-security.c
+++ b/net/rxrpc/ar-security.c
@@ -40,7 +40,7 @@ static void rxrpc_security_put(struct rxrpc_security *sec)
 /*
  * look up an rxrpc security module
  */
-struct rxrpc_security *rxrpc_security_lookup(u8 security_index)
+static struct rxrpc_security *rxrpc_security_lookup(u8 security_index)
 {
 	struct rxrpc_security *sec = NULL;
 
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 6ab4a2f..2ce3f34 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -184,7 +184,7 @@ EXPORT_SYMBOL(unregister_qdisc);
    (root qdisc, all its children, children of children etc.)
  */
 
-struct Qdisc *qdisc_match_from_root(struct Qdisc *root, u32 handle)
+static struct Qdisc *qdisc_match_from_root(struct Qdisc *root, u32 handle)
 {
 	struct Qdisc *q;
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 9a7a8e7..a3334e3 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -69,7 +69,7 @@
  * array is only concerned with the reply we are assured that we have
  * on extra page for the RPCRMDA header.
  */
-int fast_reg_xdr(struct svcxprt_rdma *xprt,
+static int fast_reg_xdr(struct svcxprt_rdma *xprt,
 		 struct xdr_buf *xdr,
 		 struct svc_rdma_req_map *vec)
 {
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 6fb493c..95a5955 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -61,7 +61,7 @@ static int svc_rdma_has_wspace(struct svc_xprt *xprt);
 static void rq_cq_reap(struct svcxprt_rdma *xprt);
 static void sq_cq_reap(struct svcxprt_rdma *xprt);
 
-DECLARE_TASKLET(dto_tasklet, dto_tasklet_func, 0UL);
+static DECLARE_TASKLET(dto_tasklet, dto_tasklet_func, 0UL);
 static DEFINE_SPINLOCK(dto_lock);
 static LIST_HEAD(dto_xprt_q);
 
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index eb3b1a9..080906c 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -705,7 +705,7 @@ static void print_regdomain(const struct ieee80211_regdomain *rd)
 	print_rd_rules(rd);
 }
 
-void print_regdomain_info(const struct ieee80211_regdomain *rd)
+static void print_regdomain_info(const struct ieee80211_regdomain *rd)
 {
 	printk(KERN_INFO "cfg80211: Regulatory domain: %c%c\n",
 		rd->alpha2[0], rd->alpha2[1]);
