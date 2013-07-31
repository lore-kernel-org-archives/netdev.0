From: Joe Perches <joe@perches.com>
Subject: [PATCH] net: Remove extern from include/net/ scheduling prototypes
Date: Tue, 30 Jul 2013 22:47:13 -0700
Message-ID: <470a8782ea89cee979eca82c7847748129de6bd0.1375249605.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:55318 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750839Ab3GaFrR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 01:47:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Reflow modified prototypes to 80 columns.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/act_api.h     | 60 +++++++++++++++++++++++------------------------
 include/net/pkt_cls.h     | 42 ++++++++++++++++-----------------
 include/net/pkt_sched.h   | 50 +++++++++++++++++++--------------------
 include/net/sch_generic.h | 53 +++++++++++++++++++++--------------------
 4 files changed, 104 insertions(+), 101 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index b8ffac7..9e90fdf 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -82,36 +82,36 @@ struct tc_action_ops {
 	int     (*walk)(struct sk_buff *, struct netlink_callback *, int, struct tc_action *);
 };
 
-extern struct tcf_common *tcf_hash_lookup(u32 index,
-					  struct tcf_hashinfo *hinfo);
-extern void tcf_hash_destroy(struct tcf_common *p, struct tcf_hashinfo *hinfo);
-extern int tcf_hash_release(struct tcf_common *p, int bind,
-			    struct tcf_hashinfo *hinfo);
-extern int tcf_generic_walker(struct sk_buff *skb, struct netlink_callback *cb,
-			      int type, struct tc_action *a);
-extern u32 tcf_hash_new_index(u32 *idx_gen, struct tcf_hashinfo *hinfo);
-extern int tcf_hash_search(struct tc_action *a, u32 index);
-extern struct tcf_common *tcf_hash_check(u32 index, struct tc_action *a,
-					 int bind, struct tcf_hashinfo *hinfo);
-extern struct tcf_common *tcf_hash_create(u32 index, struct nlattr *est,
-					  struct tc_action *a, int size,
-					  int bind, u32 *idx_gen,
-					  struct tcf_hashinfo *hinfo);
-extern void tcf_hash_insert(struct tcf_common *p, struct tcf_hashinfo *hinfo);
+struct tcf_common *tcf_hash_lookup(u32 index, struct tcf_hashinfo *hinfo);
+void tcf_hash_destroy(struct tcf_common *p, struct tcf_hashinfo *hinfo);
+int tcf_hash_release(struct tcf_common *p, int bind,
+		     struct tcf_hashinfo *hinfo);
+int tcf_generic_walker(struct sk_buff *skb, struct netlink_callback *cb,
+		       int type, struct tc_action *a);
+u32 tcf_hash_new_index(u32 *idx_gen, struct tcf_hashinfo *hinfo);
+int tcf_hash_search(struct tc_action *a, u32 index);
+struct tcf_common *tcf_hash_check(u32 index, struct tc_action *a,
+				  int bind, struct tcf_hashinfo *hinfo);
+struct tcf_common *tcf_hash_create(u32 index, struct nlattr *est,
+				   struct tc_action *a, int size,
+				   int bind, u32 *idx_gen,
+				   struct tcf_hashinfo *hinfo);
+void tcf_hash_insert(struct tcf_common *p, struct tcf_hashinfo *hinfo);
 
-extern int tcf_register_action(struct tc_action_ops *a);
-extern int tcf_unregister_action(struct tc_action_ops *a);
-extern void tcf_action_destroy(struct tc_action *a, int bind);
-extern int tcf_action_exec(struct sk_buff *skb, const struct tc_action *a, struct tcf_result *res);
-extern struct tc_action *tcf_action_init(struct net *net, struct nlattr *nla,
-					 struct nlattr *est, char *n, int ovr,
-					 int bind);
-extern struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
-					   struct nlattr *est, char *n, int ovr,
-					   int bind);
-extern int tcf_action_dump(struct sk_buff *skb, struct tc_action *a, int, int);
-extern int tcf_action_dump_old(struct sk_buff *skb, struct tc_action *a, int, int);
-extern int tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int, int);
-extern int tcf_action_copy_stats (struct sk_buff *,struct tc_action *, int);
+int tcf_register_action(struct tc_action_ops *a);
+int tcf_unregister_action(struct tc_action_ops *a);
+void tcf_action_destroy(struct tc_action *a, int bind);
+int tcf_action_exec(struct sk_buff *skb, const struct tc_action *a,
+		    struct tcf_result *res);
+struct tc_action *tcf_action_init(struct net *net, struct nlattr *nla,
+				  struct nlattr *est, char *n, int ovr,
+				  int bind);
+struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
+				    struct nlattr *est, char *n, int ovr,
+				    int bind);
+int tcf_action_dump(struct sk_buff *skb, struct tc_action *a, int, int);
+int tcf_action_dump_old(struct sk_buff *skb, struct tc_action *a, int, int);
+int tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int, int);
+int tcf_action_copy_stats(struct sk_buff *, struct tc_action *, int);
 #endif /* CONFIG_NET_CLS_ACT */
 #endif
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 1317450..2ebef77 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -14,8 +14,8 @@ struct tcf_walker {
 	int	(*fn)(struct tcf_proto *, unsigned long node, struct tcf_walker *);
 };
 
-extern int register_tcf_proto_ops(struct tcf_proto_ops *ops);
-extern int unregister_tcf_proto_ops(struct tcf_proto_ops *ops);
+int register_tcf_proto_ops(struct tcf_proto_ops *ops);
+int unregister_tcf_proto_ops(struct tcf_proto_ops *ops);
 
 static inline unsigned long
 __cls_set_class(unsigned long *clp, unsigned long cl)
@@ -126,17 +126,17 @@ tcf_exts_exec(struct sk_buff *skb, struct tcf_exts *exts,
 	return 0;
 }
 
-extern int tcf_exts_validate(struct net *net, struct tcf_proto *tp,
-			     struct nlattr **tb, struct nlattr *rate_tlv,
-			     struct tcf_exts *exts,
-			     const struct tcf_ext_map *map);
-extern void tcf_exts_destroy(struct tcf_proto *tp, struct tcf_exts *exts);
-extern void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
-	                     struct tcf_exts *src);
-extern int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts,
-	                 const struct tcf_ext_map *map);
-extern int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts,
-	                       const struct tcf_ext_map *map);
+int tcf_exts_validate(struct net *net, struct tcf_proto *tp,
+		      struct nlattr **tb, struct nlattr *rate_tlv,
+		      struct tcf_exts *exts,
+		      const struct tcf_ext_map *map);
+void tcf_exts_destroy(struct tcf_proto *tp, struct tcf_exts *exts);
+void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
+		     struct tcf_exts *src);
+int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts,
+		  const struct tcf_ext_map *map);
+int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts,
+			const struct tcf_ext_map *map);
 
 /**
  * struct tcf_pkt_info - packet information
@@ -239,14 +239,14 @@ struct tcf_ematch_ops {
 	struct list_head	link;
 };
 
-extern int tcf_em_register(struct tcf_ematch_ops *);
-extern void tcf_em_unregister(struct tcf_ematch_ops *);
-extern int tcf_em_tree_validate(struct tcf_proto *, struct nlattr *,
-				struct tcf_ematch_tree *);
-extern void tcf_em_tree_destroy(struct tcf_proto *, struct tcf_ematch_tree *);
-extern int tcf_em_tree_dump(struct sk_buff *, struct tcf_ematch_tree *, int);
-extern int __tcf_em_tree_match(struct sk_buff *, struct tcf_ematch_tree *,
-			       struct tcf_pkt_info *);
+int tcf_em_register(struct tcf_ematch_ops *);
+void tcf_em_unregister(struct tcf_ematch_ops *);
+int tcf_em_tree_validate(struct tcf_proto *, struct nlattr *,
+			 struct tcf_ematch_tree *);
+void tcf_em_tree_destroy(struct tcf_proto *, struct tcf_ematch_tree *);
+int tcf_em_tree_dump(struct sk_buff *, struct tcf_ematch_tree *, int);
+int __tcf_em_tree_match(struct sk_buff *, struct tcf_ematch_tree *,
+			struct tcf_pkt_info *);
 
 /**
  * tcf_em_tree_change - replace ematch tree of a running classifier
diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 388bf8b..f7c24f8 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -64,8 +64,8 @@ struct qdisc_watchdog {
 	struct Qdisc	*qdisc;
 };
 
-extern void qdisc_watchdog_init(struct qdisc_watchdog *wd, struct Qdisc *qdisc);
-extern void qdisc_watchdog_schedule_ns(struct qdisc_watchdog *wd, u64 expires);
+void qdisc_watchdog_init(struct qdisc_watchdog *wd, struct Qdisc *qdisc);
+void qdisc_watchdog_schedule_ns(struct qdisc_watchdog *wd, u64 expires);
 
 static inline void qdisc_watchdog_schedule(struct qdisc_watchdog *wd,
 					   psched_time_t expires)
@@ -73,31 +73,31 @@ static inline void qdisc_watchdog_schedule(struct qdisc_watchdog *wd,
 	qdisc_watchdog_schedule_ns(wd, PSCHED_TICKS2NS(expires));
 }
 
-extern void qdisc_watchdog_cancel(struct qdisc_watchdog *wd);
+void qdisc_watchdog_cancel(struct qdisc_watchdog *wd);
 
 extern struct Qdisc_ops pfifo_qdisc_ops;
 extern struct Qdisc_ops bfifo_qdisc_ops;
 extern struct Qdisc_ops pfifo_head_drop_qdisc_ops;
 
-extern int fifo_set_limit(struct Qdisc *q, unsigned int limit);
-extern struct Qdisc *fifo_create_dflt(struct Qdisc *sch, struct Qdisc_ops *ops,
-				      unsigned int limit);
-
-extern int register_qdisc(struct Qdisc_ops *qops);
-extern int unregister_qdisc(struct Qdisc_ops *qops);
-extern void qdisc_list_del(struct Qdisc *q);
-extern struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle);
-extern struct Qdisc *qdisc_lookup_class(struct net_device *dev, u32 handle);
-extern struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r,
-		struct nlattr *tab);
-extern void qdisc_put_rtab(struct qdisc_rate_table *tab);
-extern void qdisc_put_stab(struct qdisc_size_table *tab);
-extern void qdisc_warn_nonwc(char *txt, struct Qdisc *qdisc);
-extern int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
-			   struct net_device *dev, struct netdev_queue *txq,
-			   spinlock_t *root_lock);
-
-extern void __qdisc_run(struct Qdisc *q);
+int fifo_set_limit(struct Qdisc *q, unsigned int limit);
+struct Qdisc *fifo_create_dflt(struct Qdisc *sch, struct Qdisc_ops *ops,
+			       unsigned int limit);
+
+int register_qdisc(struct Qdisc_ops *qops);
+int unregister_qdisc(struct Qdisc_ops *qops);
+void qdisc_list_del(struct Qdisc *q);
+struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle);
+struct Qdisc *qdisc_lookup_class(struct net_device *dev, u32 handle);
+struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r,
+					struct nlattr *tab);
+void qdisc_put_rtab(struct qdisc_rate_table *tab);
+void qdisc_put_stab(struct qdisc_size_table *tab);
+void qdisc_warn_nonwc(char *txt, struct Qdisc *qdisc);
+int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
+		    struct net_device *dev, struct netdev_queue *txq,
+		    spinlock_t *root_lock);
+
+void __qdisc_run(struct Qdisc *q);
 
 static inline void qdisc_run(struct Qdisc *q)
 {
@@ -105,10 +105,10 @@ static inline void qdisc_run(struct Qdisc *q)
 		__qdisc_run(q);
 }
 
-extern int tc_classify_compat(struct sk_buff *skb, const struct tcf_proto *tp,
-			      struct tcf_result *res);
-extern int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
+int tc_classify_compat(struct sk_buff *skb, const struct tcf_proto *tp,
 		       struct tcf_result *res);
+int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
+		struct tcf_result *res);
 
 /* Calculate maximal size of packet seen by hard_start_xmit
    routine of this device.
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 6eab6336..ffc9d88 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -350,30 +350,32 @@ qdisc_class_find(const struct Qdisc_class_hash *hash, u32 id)
 	return NULL;
 }
 
-extern int qdisc_class_hash_init(struct Qdisc_class_hash *);
-extern void qdisc_class_hash_insert(struct Qdisc_class_hash *, struct Qdisc_class_common *);
-extern void qdisc_class_hash_remove(struct Qdisc_class_hash *, struct Qdisc_class_common *);
-extern void qdisc_class_hash_grow(struct Qdisc *, struct Qdisc_class_hash *);
-extern void qdisc_class_hash_destroy(struct Qdisc_class_hash *);
-
-extern void dev_init_scheduler(struct net_device *dev);
-extern void dev_shutdown(struct net_device *dev);
-extern void dev_activate(struct net_device *dev);
-extern void dev_deactivate(struct net_device *dev);
-extern void dev_deactivate_many(struct list_head *head);
-extern struct Qdisc *dev_graft_qdisc(struct netdev_queue *dev_queue,
-				     struct Qdisc *qdisc);
-extern void qdisc_reset(struct Qdisc *qdisc);
-extern void qdisc_destroy(struct Qdisc *qdisc);
-extern void qdisc_tree_decrease_qlen(struct Qdisc *qdisc, unsigned int n);
-extern struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
-				 struct Qdisc_ops *ops);
-extern struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
-				       struct Qdisc_ops *ops, u32 parentid);
-extern void __qdisc_calculate_pkt_len(struct sk_buff *skb,
-				      const struct qdisc_size_table *stab);
-extern void tcf_destroy(struct tcf_proto *tp);
-extern void tcf_destroy_chain(struct tcf_proto **fl);
+int qdisc_class_hash_init(struct Qdisc_class_hash *);
+void qdisc_class_hash_insert(struct Qdisc_class_hash *,
+			     struct Qdisc_class_common *);
+void qdisc_class_hash_remove(struct Qdisc_class_hash *,
+			     struct Qdisc_class_common *);
+void qdisc_class_hash_grow(struct Qdisc *, struct Qdisc_class_hash *);
+void qdisc_class_hash_destroy(struct Qdisc_class_hash *);
+
+void dev_init_scheduler(struct net_device *dev);
+void dev_shutdown(struct net_device *dev);
+void dev_activate(struct net_device *dev);
+void dev_deactivate(struct net_device *dev);
+void dev_deactivate_many(struct list_head *head);
+struct Qdisc *dev_graft_qdisc(struct netdev_queue *dev_queue,
+			      struct Qdisc *qdisc);
+void qdisc_reset(struct Qdisc *qdisc);
+void qdisc_destroy(struct Qdisc *qdisc);
+void qdisc_tree_decrease_qlen(struct Qdisc *qdisc, unsigned int n);
+struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
+			  struct Qdisc_ops *ops);
+struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
+				struct Qdisc_ops *ops, u32 parentid);
+void __qdisc_calculate_pkt_len(struct sk_buff *skb,
+			       const struct qdisc_size_table *stab);
+void tcf_destroy(struct tcf_proto *tp);
+void tcf_destroy_chain(struct tcf_proto **fl);
 
 /* Reset all TX qdiscs greater then index of a device.  */
 static inline void qdisc_reset_all_tx_gt(struct net_device *dev, unsigned int i)
@@ -692,7 +694,8 @@ static inline u64 psched_l2t_ns(const struct psched_ratecfg *r,
 	return ((u64)(len + r->overhead) * r->mult) >> r->shift;
 }
 
-extern void psched_ratecfg_precompute(struct psched_ratecfg *r, const struct tc_ratespec *conf);
+void psched_ratecfg_precompute(struct psched_ratecfg *r,
+			       const struct tc_ratespec *conf);
 
 static inline void psched_ratecfg_getrate(struct tc_ratespec *res,
 					  const struct psched_ratecfg *r)
-- 
1.8.1.2.459.gbcd45b4.dirty
