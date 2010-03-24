From: Frans Pop <elendil@planet.nl>
Subject: [PATCH 1/9] net: remove trailing space in messages
Date: Wed, 24 Mar 2010 18:57:28 +0100
Message-ID: <1269453456-13599-1-git-send-email-elendil@planet.nl>
References: <201003241840.18701.elendil@planet.nl>
Cc: Frans Pop <elendil@planet.nl>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201003241840.18701.elendil@planet.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Frans Pop <elendil@planet.nl>
---
 net/dccp/ccids/ccid3.c                |    2 +-
 net/dccp/input.c                      |    2 +-
 net/ipv4/ipconfig.c                   |    2 +-
 net/ipv4/tcp_input.c                  |    2 +-
 net/ipv6/netfilter/ip6t_hbh.c         |    4 ++--
 net/irda/ircomm/ircomm_param.c        |    2 +-
 net/sched/cls_u32.c                   |    4 ++--
 net/sunrpc/auth_gss/gss_spkm3_token.c |    2 +-
 net/sunrpc/bc_svc.c                   |    2 +-
 9 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index bcd7632..d323589 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -208,7 +208,7 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 		goto restart_timer;
 	}
 
-	ccid3_pr_debug("%s(%p, state=%s) - entry \n", dccp_role(sk), sk,
+	ccid3_pr_debug("%s(%p, state=%s) - entry\n", dccp_role(sk), sk,
 		       ccid3_tx_state_name(hc->tx_state));
 
 	if (hc->tx_state == TFRC_SSTATE_FBACK)
diff --git a/net/dccp/input.c b/net/dccp/input.c
index 7648f31..5daa4bd 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -414,7 +414,7 @@ static int dccp_rcv_request_sent_state_process(struct sock *sk,
 		if (!between48(DCCP_SKB_CB(skb)->dccpd_ack_seq,
 			       dp->dccps_awl, dp->dccps_awh)) {
 			dccp_pr_debug("invalid ackno: S.AWL=%llu, "
-				      "P.ackno=%llu, S.AWH=%llu \n",
+				      "P.ackno=%llu, S.AWH=%llu\n",
 				      (unsigned long long)dp->dccps_awl,
 			   (unsigned long long)DCCP_SKB_CB(skb)->dccpd_ack_seq,
 				      (unsigned long long)dp->dccps_awh);
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 6789092..bf12d2a 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -975,7 +975,7 @@ static int __init ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, str
 	/* Is it a reply for the device we are configuring? */
 	if (b->xid != ic_dev_xid) {
 		if (net_ratelimit())
-			printk(KERN_ERR "DHCP/BOOTP: Ignoring delayed packet \n");
+			printk(KERN_ERR "DHCP/BOOTP: Ignoring delayed packet\n");
 		goto drop_unlock;
 	}
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c096a42..7b31476 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4318,7 +4318,7 @@ static void tcp_ofo_queue(struct sock *sk)
 		}
 
 		if (!after(TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt)) {
-			SOCK_DEBUG(sk, "ofo packet was already received \n");
+			SOCK_DEBUG(sk, "ofo packet was already received\n");
 			__skb_unlink(skb, &tp->out_of_order_queue);
 			__kfree_skb(skb);
 			continue;
diff --git a/net/ipv6/netfilter/ip6t_hbh.c b/net/ipv6/netfilter/ip6t_hbh.c
index cbe8dec..e606775 100644
--- a/net/ipv6/netfilter/ip6t_hbh.c
+++ b/net/ipv6/netfilter/ip6t_hbh.c
@@ -141,11 +141,11 @@ hbh_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
 			}
 
 			/* Step to the next */
-			pr_debug("len%04X \n", optlen);
+			pr_debug("len%04X\n", optlen);
 
 			if ((ptr > skb->len - optlen || hdrlen < optlen) &&
 			    temp < optinfo->optsnr - 1) {
-				pr_debug("new pointer is too large! \n");
+				pr_debug("new pointer is too large!\n");
 				break;
 			}
 			ptr += optlen;
diff --git a/net/irda/ircomm/ircomm_param.c b/net/irda/ircomm/ircomm_param.c
index d57aefd..0804532 100644
--- a/net/irda/ircomm/ircomm_param.c
+++ b/net/irda/ircomm/ircomm_param.c
@@ -474,7 +474,7 @@ static int ircomm_param_dce(void *instance, irda_param_t *param, int get)
 	/* Check if any of the settings have changed */
 	if (dce & 0x0f) {
 		if (dce & IRCOMM_DELTA_CTS) {
-			IRDA_DEBUG(2, "%s(), CTS \n", __func__ );
+			IRDA_DEBUG(2, "%s(), CTS\n", __func__ );
 		}
 	}
 
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 07372f6..1ef7687 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -772,10 +772,10 @@ static int __init init_u32(void)
 	printk("    Performance counters on\n");
 #endif
 #ifdef CONFIG_NET_CLS_IND
-	printk("    input device check on \n");
+	printk("    input device check on\n");
 #endif
 #ifdef CONFIG_NET_CLS_ACT
-	printk("    Actions configured \n");
+	printk("    Actions configured\n");
 #endif
 	return register_tcf_proto_ops(&cls_u32_ops);
 }
diff --git a/net/sunrpc/auth_gss/gss_spkm3_token.c b/net/sunrpc/auth_gss/gss_spkm3_token.c
index 3308157..a99825d 100644
--- a/net/sunrpc/auth_gss/gss_spkm3_token.c
+++ b/net/sunrpc/auth_gss/gss_spkm3_token.c
@@ -223,7 +223,7 @@ spkm3_verify_mic_token(unsigned char **tokp, int *mic_hdrlen, unsigned char **ck
 
 	/* only support SPKM_MIC_TOK */
 	if((ptr[6] != 0x01) || (ptr[7] != 0x01)) {
-		dprintk("RPC:       ERROR unsupported SPKM3 token \n");
+		dprintk("RPC:       ERROR unsupported SPKM3 token\n");
 		goto out;
 	}
 
diff --git a/net/sunrpc/bc_svc.c b/net/sunrpc/bc_svc.c
index 13f214f..8a610fb 100644
--- a/net/sunrpc/bc_svc.c
+++ b/net/sunrpc/bc_svc.c
@@ -75,7 +75,7 @@ int bc_send(struct rpc_rqst *req)
 		rpc_put_task(task);
 	}
 	return ret;
-	dprintk("RPC:       bc_send ret= %d \n", ret);
+	dprintk("RPC:       bc_send ret= %d\n", ret);
 }
 
 #endif /* CONFIG_NFS_V4_1 */
-- 
1.6.6.1
