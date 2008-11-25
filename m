From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 51/53] netns xfrm: per-netns MIBs
Date: Tue, 25 Nov 2008 20:27:23 +0300
Message-ID: <1227634045-27534-51-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-7-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-8-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-9-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-10-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-11-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-12-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-13-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-14-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-15-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-16-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-17-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-18-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-19-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-20-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-21-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-22-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-23-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-24-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-25-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-26-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-27-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-28-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-29-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-30-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-31-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-32-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-33-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-34-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-35-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-36-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-37-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-38-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-39-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-40-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-41-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-42-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-43-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-44-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-45-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-46-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-47-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-48-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-49-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-50-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:29237 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783AbYKYRZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:25:46 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1144716ugf.37
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:25:45 -0800 (PST)
In-Reply-To: <1227634045-27534-50-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/netns/mib.h |    3 ++
 include/net/xfrm.h      |   13 +++----
 net/ipv6/xfrm6_input.c  |    9 +++--
 net/xfrm/xfrm_input.c   |   22 ++++++------
 net/xfrm/xfrm_output.c  |   15 ++++----
 net/xfrm/xfrm_policy.c  |   82 +++++++++++++++++++++++++++--------------------
 net/xfrm/xfrm_proc.c    |    2 +-
 7 files changed, 81 insertions(+), 65 deletions(-)

diff --git a/include/net/netns/mib.h b/include/net/netns/mib.h
index 10cb7c3..0b44112 100644
--- a/include/net/netns/mib.h
+++ b/include/net/netns/mib.h
@@ -20,6 +20,9 @@ struct netns_mib {
 	DEFINE_SNMP_STAT(struct icmpv6_mib, icmpv6_statistics);
 	DEFINE_SNMP_STAT(struct icmpv6msg_mib, icmpv6msg_statistics);
 #endif
+#ifdef CONFIG_XFRM_STATISTICS
+	DEFINE_SNMP_STAT(struct linux_xfrm_mib, xfrm_statistics);
+#endif
 };
 
 #endif
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index d076f3d..78ec3e8 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -38,14 +38,13 @@
 	MODULE_ALIAS("xfrm-type-" __stringify(family) "-" __stringify(proto))
 
 #ifdef CONFIG_XFRM_STATISTICS
-DECLARE_SNMP_STAT(struct linux_xfrm_mib, xfrm_statistics);
-#define XFRM_INC_STATS(field)		SNMP_INC_STATS(xfrm_statistics, field)
-#define XFRM_INC_STATS_BH(field)	SNMP_INC_STATS_BH(xfrm_statistics, field)
-#define XFRM_INC_STATS_USER(field) 	SNMP_INC_STATS_USER(xfrm_statistics, field)
+#define XFRM_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.xfrm_statistics, field)
+#define XFRM_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.xfrm_statistics, field)
+#define XFRM_INC_STATS_USER(net, field)	SNMP_INC_STATS_USER((net)-mib.xfrm_statistics, field)
 #else
-#define XFRM_INC_STATS(field)
-#define XFRM_INC_STATS_BH(field)
-#define XFRM_INC_STATS_USER(field)
+#define XFRM_INC_STATS(net, field)	((void)(net))
+#define XFRM_INC_STATS_BH(net, field)	((void)(net))
+#define XFRM_INC_STATS_USER(net, field)	((void)(net))
 #endif
 
 extern u32 sysctl_xfrm_aevent_etime;
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index b69766a..9084582 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -58,6 +58,7 @@ EXPORT_SYMBOL(xfrm6_rcv);
 int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 		     xfrm_address_t *saddr, u8 proto)
 {
+	struct net *net = dev_net(skb->dev);
 	struct xfrm_state *x = NULL;
 	int i = 0;
 
@@ -67,7 +68,7 @@ int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 
 		sp = secpath_dup(skb->sp);
 		if (!sp) {
-			XFRM_INC_STATS(LINUX_MIB_XFRMINERROR);
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMINERROR);
 			goto drop;
 		}
 		if (skb->sp)
@@ -76,7 +77,7 @@ int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 	}
 
 	if (1 + skb->sp->len == XFRM_MAX_DEPTH) {
-		XFRM_INC_STATS(LINUX_MIB_XFRMINBUFFERERROR);
+		XFRM_INC_STATS(net, LINUX_MIB_XFRMINBUFFERERROR);
 		goto drop;
 	}
 
@@ -100,7 +101,7 @@ int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 			break;
 		}
 
-		x = xfrm_state_lookup_byaddr(&init_net, dst, src, proto, AF_INET6);
+		x = xfrm_state_lookup_byaddr(net, dst, src, proto, AF_INET6);
 		if (!x)
 			continue;
 
@@ -122,7 +123,7 @@ int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 	}
 
 	if (!x) {
-		XFRM_INC_STATS(LINUX_MIB_XFRMINNOSTATES);
+		XFRM_INC_STATS(net, LINUX_MIB_XFRMINNOSTATES);
 		xfrm_audit_state_notfound_simple(skb, AF_INET6);
 		goto drop;
 	}
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index a714dce..b4a1317 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -128,7 +128,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 		sp = secpath_dup(skb->sp);
 		if (!sp) {
-			XFRM_INC_STATS(LINUX_MIB_XFRMINERROR);
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMINERROR);
 			goto drop;
 		}
 		if (skb->sp)
@@ -142,19 +142,19 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 	seq = 0;
 	if (!spi && (err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) != 0) {
-		XFRM_INC_STATS(LINUX_MIB_XFRMINHDRERROR);
+		XFRM_INC_STATS(net, LINUX_MIB_XFRMINHDRERROR);
 		goto drop;
 	}
 
 	do {
 		if (skb->sp->len == XFRM_MAX_DEPTH) {
-			XFRM_INC_STATS(LINUX_MIB_XFRMINBUFFERERROR);
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMINBUFFERERROR);
 			goto drop;
 		}
 
 		x = xfrm_state_lookup(net, daddr, spi, nexthdr, family);
 		if (x == NULL) {
-			XFRM_INC_STATS(LINUX_MIB_XFRMINNOSTATES);
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMINNOSTATES);
 			xfrm_audit_state_notfound(skb, family, spi, seq);
 			goto drop;
 		}
@@ -163,22 +163,22 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 		spin_lock(&x->lock);
 		if (unlikely(x->km.state != XFRM_STATE_VALID)) {
-			XFRM_INC_STATS(LINUX_MIB_XFRMINSTATEINVALID);
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEINVALID);
 			goto drop_unlock;
 		}
 
 		if ((x->encap ? x->encap->encap_type : 0) != encap_type) {
-			XFRM_INC_STATS(LINUX_MIB_XFRMINSTATEMISMATCH);
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEMISMATCH);
 			goto drop_unlock;
 		}
 
 		if (x->props.replay_window && xfrm_replay_check(x, skb, seq)) {
-			XFRM_INC_STATS(LINUX_MIB_XFRMINSTATESEQERROR);
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATESEQERROR);
 			goto drop_unlock;
 		}
 
 		if (xfrm_state_check_expire(x)) {
-			XFRM_INC_STATS(LINUX_MIB_XFRMINSTATEEXPIRED);
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEEXPIRED);
 			goto drop_unlock;
 		}
 
@@ -199,7 +199,7 @@ resume:
 							 x->type->proto);
 				x->stats.integrity_failed++;
 			}
-			XFRM_INC_STATS(LINUX_MIB_XFRMINSTATEPROTOERROR);
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEPROTOERROR);
 			goto drop_unlock;
 		}
 
@@ -225,7 +225,7 @@ resume:
 		}
 
 		if (inner_mode->input(x, skb)) {
-			XFRM_INC_STATS(LINUX_MIB_XFRMINSTATEMODEERROR);
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEMODEERROR);
 			goto drop;
 		}
 
@@ -243,7 +243,7 @@ resume:
 
 		err = xfrm_parse_spi(skb, nexthdr, &spi, &seq);
 		if (err < 0) {
-			XFRM_INC_STATS(LINUX_MIB_XFRMINHDRERROR);
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMINHDRERROR);
 			goto drop;
 		}
 	} while (!err);
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index ba90e5e..c235597 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -49,27 +49,27 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 	do {
 		err = xfrm_state_check_space(x, skb);
 		if (err) {
-			XFRM_INC_STATS(LINUX_MIB_XFRMOUTERROR);
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTERROR);
 			goto error_nolock;
 		}
 
 		err = x->outer_mode->output(x, skb);
 		if (err) {
-			XFRM_INC_STATS(LINUX_MIB_XFRMOUTSTATEMODEERROR);
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTSTATEMODEERROR);
 			goto error_nolock;
 		}
 
 		spin_lock_bh(&x->lock);
 		err = xfrm_state_check_expire(x);
 		if (err) {
-			XFRM_INC_STATS(LINUX_MIB_XFRMOUTSTATEEXPIRED);
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTSTATEEXPIRED);
 			goto error;
 		}
 
 		if (x->type->flags & XFRM_TYPE_REPLAY_PROT) {
 			XFRM_SKB_CB(skb)->seq.output = ++x->replay.oseq;
 			if (unlikely(x->replay.oseq == 0)) {
-				XFRM_INC_STATS(LINUX_MIB_XFRMOUTSTATESEQERROR);
+				XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTSTATESEQERROR);
 				x->replay.oseq--;
 				xfrm_audit_state_replay_overflow(x, skb);
 				err = -EOVERFLOW;
@@ -90,12 +90,12 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 
 resume:
 		if (err) {
-			XFRM_INC_STATS(LINUX_MIB_XFRMOUTSTATEPROTOERROR);
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTSTATEPROTOERROR);
 			goto error_nolock;
 		}
 
 		if (!(skb->dst = dst_pop(dst))) {
-			XFRM_INC_STATS(LINUX_MIB_XFRMOUTERROR);
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTERROR);
 			err = -EHOSTUNREACH;
 			goto error_nolock;
 		}
@@ -179,6 +179,7 @@ static int xfrm_output_gso(struct sk_buff *skb)
 
 int xfrm_output(struct sk_buff *skb)
 {
+	struct net *net = dev_net(skb->dst->dev);
 	int err;
 
 	if (skb_is_gso(skb))
@@ -187,7 +188,7 @@ int xfrm_output(struct sk_buff *skb)
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		err = skb_checksum_help(skb);
 		if (err) {
-			XFRM_INC_STATS(LINUX_MIB_XFRMOUTERROR);
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTERROR);
 			kfree_skb(skb);
 			return err;
 		}
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index fcf8c92..e239a25 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -36,11 +36,6 @@
 
 int sysctl_xfrm_larval_drop __read_mostly = 1;
 
-#ifdef CONFIG_XFRM_STATISTICS
-DEFINE_SNMP_STAT(struct linux_xfrm_mib, xfrm_statistics) __read_mostly;
-EXPORT_SYMBOL(xfrm_statistics);
-#endif
-
 DEFINE_MUTEX(xfrm_cfg_mutex);
 EXPORT_SYMBOL(xfrm_cfg_mutex);
 
@@ -1570,7 +1565,7 @@ restart:
 		policy = xfrm_sk_policy_lookup(sk, XFRM_POLICY_OUT, fl);
 		err = PTR_ERR(policy);
 		if (IS_ERR(policy)) {
-			XFRM_INC_STATS(LINUX_MIB_XFRMOUTPOLERROR);
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTPOLERROR);
 			goto dropdst;
 		}
 	}
@@ -1585,7 +1580,7 @@ restart:
 					   dir, xfrm_policy_lookup);
 		err = PTR_ERR(policy);
 		if (IS_ERR(policy)) {
-			XFRM_INC_STATS(LINUX_MIB_XFRMOUTPOLERROR);
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTPOLERROR);
 			goto dropdst;
 		}
 	}
@@ -1608,7 +1603,7 @@ restart:
 	default:
 	case XFRM_POLICY_BLOCK:
 		/* Prohibit the flow */
-		XFRM_INC_STATS(LINUX_MIB_XFRMOUTPOLBLOCK);
+		XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTPOLBLOCK);
 		err = -EPERM;
 		goto error;
 
@@ -1628,7 +1623,7 @@ restart:
 		 */
 		dst = xfrm_find_bundle(fl, policy, family);
 		if (IS_ERR(dst)) {
-			XFRM_INC_STATS(LINUX_MIB_XFRMOUTBUNDLECHECKERROR);
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTBUNDLECHECKERROR);
 			err = PTR_ERR(dst);
 			goto error;
 		}
@@ -1644,12 +1639,12 @@ restart:
 							    XFRM_POLICY_OUT);
 			if (pols[1]) {
 				if (IS_ERR(pols[1])) {
-					XFRM_INC_STATS(LINUX_MIB_XFRMOUTPOLERROR);
+					XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTPOLERROR);
 					err = PTR_ERR(pols[1]);
 					goto error;
 				}
 				if (pols[1]->action == XFRM_POLICY_BLOCK) {
-					XFRM_INC_STATS(LINUX_MIB_XFRMOUTPOLBLOCK);
+					XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTPOLBLOCK);
 					err = -EPERM;
 					goto error;
 				}
@@ -1680,7 +1675,7 @@ restart:
 				/* EREMOTE tells the caller to generate
 				 * a one-shot blackhole route.
 				 */
-				XFRM_INC_STATS(LINUX_MIB_XFRMOUTNOSTATES);
+				XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTNOSTATES);
 				xfrm_pol_put(policy);
 				return -EREMOTE;
 			}
@@ -1696,7 +1691,7 @@ restart:
 				nx = xfrm_tmpl_resolve(pols, npols, fl, xfrm, family);
 
 				if (nx == -EAGAIN && signal_pending(current)) {
-					XFRM_INC_STATS(LINUX_MIB_XFRMOUTNOSTATES);
+					XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTNOSTATES);
 					err = -ERESTART;
 					goto error;
 				}
@@ -1708,7 +1703,7 @@ restart:
 				err = nx;
 			}
 			if (err < 0) {
-				XFRM_INC_STATS(LINUX_MIB_XFRMOUTNOSTATES);
+				XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTNOSTATES);
 				goto error;
 			}
 		}
@@ -1721,7 +1716,7 @@ restart:
 		dst = xfrm_bundle_create(policy, xfrm, nx, fl, dst_orig);
 		err = PTR_ERR(dst);
 		if (IS_ERR(dst)) {
-			XFRM_INC_STATS(LINUX_MIB_XFRMOUTBUNDLEGENERROR);
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTBUNDLEGENERROR);
 			goto error;
 		}
 
@@ -1742,9 +1737,9 @@ restart:
 			dst_free(dst);
 
 			if (pol_dead)
-				XFRM_INC_STATS(LINUX_MIB_XFRMOUTPOLDEAD);
+				XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTPOLDEAD);
 			else
-				XFRM_INC_STATS(LINUX_MIB_XFRMOUTBUNDLECHECKERROR);
+				XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTBUNDLECHECKERROR);
 			err = -EHOSTUNREACH;
 			goto error;
 		}
@@ -1756,7 +1751,7 @@ restart:
 		if (unlikely(err)) {
 			write_unlock_bh(&policy->lock);
 			dst_free(dst);
-			XFRM_INC_STATS(LINUX_MIB_XFRMOUTBUNDLECHECKERROR);
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTBUNDLECHECKERROR);
 			goto error;
 		}
 
@@ -1912,7 +1907,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 	fl_dir = policy_to_flow_dir(dir);
 
 	if (__xfrm_decode_session(skb, &fl, family, reverse) < 0) {
-		XFRM_INC_STATS(LINUX_MIB_XFRMINHDRERROR);
+		XFRM_INC_STATS(net, LINUX_MIB_XFRMINHDRERROR);
 		return 0;
 	}
 
@@ -1925,7 +1920,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 		for (i=skb->sp->len-1; i>=0; i--) {
 			struct xfrm_state *x = skb->sp->xvec[i];
 			if (!xfrm_selector_match(&x->sel, &fl, family)) {
-				XFRM_INC_STATS(LINUX_MIB_XFRMINSTATEMISMATCH);
+				XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEMISMATCH);
 				return 0;
 			}
 		}
@@ -1935,7 +1930,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 	if (sk && sk->sk_policy[dir]) {
 		pol = xfrm_sk_policy_lookup(sk, dir, &fl);
 		if (IS_ERR(pol)) {
-			XFRM_INC_STATS(LINUX_MIB_XFRMINPOLERROR);
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMINPOLERROR);
 			return 0;
 		}
 	}
@@ -1945,14 +1940,14 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 					xfrm_policy_lookup);
 
 	if (IS_ERR(pol)) {
-		XFRM_INC_STATS(LINUX_MIB_XFRMINPOLERROR);
+		XFRM_INC_STATS(net, LINUX_MIB_XFRMINPOLERROR);
 		return 0;
 	}
 
 	if (!pol) {
 		if (skb->sp && secpath_has_nontransport(skb->sp, 0, &xerr_idx)) {
 			xfrm_secpath_reject(xerr_idx, skb, &fl);
-			XFRM_INC_STATS(LINUX_MIB_XFRMINNOPOLS);
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMINNOPOLS);
 			return 0;
 		}
 		return 1;
@@ -1969,7 +1964,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 						    XFRM_POLICY_IN);
 		if (pols[1]) {
 			if (IS_ERR(pols[1])) {
-				XFRM_INC_STATS(LINUX_MIB_XFRMINPOLERROR);
+				XFRM_INC_STATS(net, LINUX_MIB_XFRMINPOLERROR);
 				return 0;
 			}
 			pols[1]->curlft.use_time = get_seconds();
@@ -1993,11 +1988,11 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 		for (pi = 0; pi < npols; pi++) {
 			if (pols[pi] != pol &&
 			    pols[pi]->action != XFRM_POLICY_ALLOW) {
-				XFRM_INC_STATS(LINUX_MIB_XFRMINPOLBLOCK);
+				XFRM_INC_STATS(net, LINUX_MIB_XFRMINPOLBLOCK);
 				goto reject;
 			}
 			if (ti + pols[pi]->xfrm_nr >= XFRM_MAX_DEPTH) {
-				XFRM_INC_STATS(LINUX_MIB_XFRMINBUFFERERROR);
+				XFRM_INC_STATS(net, LINUX_MIB_XFRMINBUFFERERROR);
 				goto reject_error;
 			}
 			for (i = 0; i < pols[pi]->xfrm_nr; i++)
@@ -2021,20 +2016,20 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 				if (k < -1)
 					/* "-2 - errored_index" returned */
 					xerr_idx = -(2+k);
-				XFRM_INC_STATS(LINUX_MIB_XFRMINTMPLMISMATCH);
+				XFRM_INC_STATS(net, LINUX_MIB_XFRMINTMPLMISMATCH);
 				goto reject;
 			}
 		}
 
 		if (secpath_has_nontransport(sp, k, &xerr_idx)) {
-			XFRM_INC_STATS(LINUX_MIB_XFRMINTMPLMISMATCH);
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMINTMPLMISMATCH);
 			goto reject;
 		}
 
 		xfrm_pols_put(pols, npols);
 		return 1;
 	}
-	XFRM_INC_STATS(LINUX_MIB_XFRMINPOLBLOCK);
+	XFRM_INC_STATS(net, LINUX_MIB_XFRMINPOLBLOCK);
 
 reject:
 	xfrm_secpath_reject(xerr_idx, skb, &fl);
@@ -2051,7 +2046,7 @@ int __xfrm_route_forward(struct sk_buff *skb, unsigned short family)
 
 	if (xfrm_decode_session(skb, &fl, family) < 0) {
 		/* XXX: we should have something like FWDHDRERROR here. */
-		XFRM_INC_STATS(LINUX_MIB_XFRMINHDRERROR);
+		XFRM_INC_STATS(net, LINUX_MIB_XFRMINHDRERROR);
 		return 0;
 	}
 
@@ -2380,13 +2375,27 @@ static struct notifier_block xfrm_dev_notifier = {
 };
 
 #ifdef CONFIG_XFRM_STATISTICS
-static int __init xfrm_statistics_init(void)
+static int __net_init xfrm_statistics_init(struct net *net)
 {
-	if (snmp_mib_init((void **)xfrm_statistics,
+	if (snmp_mib_init((void **)net->mib.xfrm_statistics,
 			  sizeof(struct linux_xfrm_mib)) < 0)
 		return -ENOMEM;
 	return 0;
 }
+
+static void xfrm_statistics_fini(struct net *net)
+{
+	snmp_mib_free((void **)net->mib.xfrm_statistics);
+}
+#else
+static int __net_init xfrm_statistics_init(struct net *net)
+{
+	return 0;
+}
+
+static void xfrm_statistics_fini(struct net *net)
+{
+}
 #endif
 
 static int __net_init xfrm_policy_init(struct net *net)
@@ -2480,6 +2489,9 @@ static int __net_init xfrm_net_init(struct net *net)
 {
 	int rv;
 
+	rv = xfrm_statistics_init(net);
+	if (rv < 0)
+		goto out_statistics;
 	rv = xfrm_state_init(net);
 	if (rv < 0)
 		goto out_state;
@@ -2491,6 +2503,8 @@ static int __net_init xfrm_net_init(struct net *net)
 out_policy:
 	xfrm_state_fini(net);
 out_state:
+	xfrm_statistics_fini(net);
+out_statistics:
 	return rv;
 }
 
@@ -2498,6 +2512,7 @@ static void __net_exit xfrm_net_exit(struct net *net)
 {
 	xfrm_policy_fini(net);
 	xfrm_state_fini(net);
+	xfrm_statistics_fini(net);
 }
 
 static struct pernet_operations __net_initdata xfrm_net_ops = {
@@ -2508,9 +2523,6 @@ static struct pernet_operations __net_initdata xfrm_net_ops = {
 void __init xfrm_init(void)
 {
 	register_pernet_subsys(&xfrm_net_ops);
-#ifdef CONFIG_XFRM_STATISTICS
-	xfrm_statistics_init();
-#endif
 	xfrm_input_init();
 #ifdef CONFIG_XFRM_STATISTICS
 	xfrm_proc_init();
diff --git a/net/xfrm/xfrm_proc.c b/net/xfrm/xfrm_proc.c
index 2b0db13..27a2ab9 100644
--- a/net/xfrm/xfrm_proc.c
+++ b/net/xfrm/xfrm_proc.c
@@ -62,7 +62,7 @@ static int xfrm_statistics_seq_show(struct seq_file *seq, void *v)
 	int i;
 	for (i=0; xfrm_mib_list[i].name; i++)
 		seq_printf(seq, "%-24s\t%lu\n", xfrm_mib_list[i].name,
-			   fold_field((void **)xfrm_statistics,
+			   fold_field((void **)init_net.mib.xfrm_statistics,
 				      xfrm_mib_list[i].entry));
 	return 0;
 }
-- 
1.5.6.5

