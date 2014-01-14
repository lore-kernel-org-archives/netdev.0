From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 01/15] xfrm: checkpatch errors with space
Date: Tue, 14 Jan 2014 07:49:05 +0100
Message-ID: <1389682159-3260-2-git-send-email-steffen.klassert@secunet.com>
References: <1389682159-3260-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60070 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750777AbaANGtg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 01:49:36 -0500
In-Reply-To: <1389682159-3260-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

This patch cleanup some space errors.

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c |   10 +++++-----
 net/xfrm/xfrm_proc.c   |    2 +-
 net/xfrm/xfrm_state.c  |   10 +++++-----
 net/xfrm/xfrm_user.c   |    4 ++--
 4 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index a7487f3..8a2b9d8 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1286,7 +1286,7 @@ xfrm_tmpl_resolve_one(struct xfrm_policy *policy, const struct flowi *fl,
 	xfrm_address_t *saddr = xfrm_flowi_saddr(fl, family);
 	xfrm_address_t tmp;
 
-	for (nx=0, i = 0; i < policy->xfrm_nr; i++) {
+	for (nx = 0, i = 0; i < policy->xfrm_nr; i++) {
 		struct xfrm_state *x;
 		xfrm_address_t *remote = daddr;
 		xfrm_address_t *local  = saddr;
@@ -1326,7 +1326,7 @@ xfrm_tmpl_resolve_one(struct xfrm_policy *policy, const struct flowi *fl,
 	return nx;
 
 fail:
-	for (nx--; nx>=0; nx--)
+	for (nx--; nx >= 0; nx--)
 		xfrm_state_put(xfrm[nx]);
 	return error;
 }
@@ -1363,7 +1363,7 @@ xfrm_tmpl_resolve(struct xfrm_policy **pols, int npols, const struct flowi *fl,
 	return cnx;
 
  fail:
-	for (cnx--; cnx>=0; cnx--)
+	for (cnx--; cnx >= 0; cnx--)
 		xfrm_state_put(tpp[cnx]);
 	return error;
 
@@ -2332,7 +2332,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 	if (skb->sp) {
 		int i;
 
-		for (i=skb->sp->len-1; i>=0; i--) {
+		for (i = skb->sp->len-1; i >= 0; i--) {
 			struct xfrm_state *x = skb->sp->xvec[i];
 			if (!xfrm_selector_match(&x->sel, &fl, family)) {
 				XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEMISMATCH);
@@ -2987,7 +2987,7 @@ static void xfrm_audit_common_policyinfo(struct xfrm_policy *xp,
 		audit_log_format(audit_buf, " sec_alg=%u sec_doi=%u sec_obj=%s",
 				 ctx->ctx_alg, ctx->ctx_doi, ctx->ctx_str);
 
-	switch(sel->family) {
+	switch (sel->family) {
 	case AF_INET:
 		audit_log_format(audit_buf, " src=%pI4", &sel->saddr.a4);
 		if (sel->prefixlen_s != 32)
diff --git a/net/xfrm/xfrm_proc.c b/net/xfrm/xfrm_proc.c
index 80cd1e5..fc5abd0 100644
--- a/net/xfrm/xfrm_proc.c
+++ b/net/xfrm/xfrm_proc.c
@@ -52,7 +52,7 @@ static int xfrm_statistics_seq_show(struct seq_file *seq, void *v)
 {
 	struct net *net = seq->private;
 	int i;
-	for (i=0; xfrm_mib_list[i].name; i++)
+	for (i = 0; xfrm_mib_list[i].name; i++)
 		seq_printf(seq, "%-24s\t%lu\n", xfrm_mib_list[i].name,
 			   snmp_fold_field((void __percpu **)
 					   net->mib.xfrm_statistics,
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index a62c25e..5fe79b4 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -448,7 +448,7 @@ static enum hrtimer_restart xfrm_timer_handler(struct hrtimer * me)
 	if (warn)
 		km_state_expired(x, 0, 0);
 resched:
-	if (next != LONG_MAX){
+	if (next != LONG_MAX) {
 		tasklet_hrtimer_start(&x->mtimer, ktime_set(next, 0), HRTIMER_MODE_REL);
 	}
 
@@ -1348,7 +1348,7 @@ int xfrm_state_check_expire(struct xfrm_state *x)
 	if (x->curlft.bytes >= x->lft.hard_byte_limit ||
 	    x->curlft.packets >= x->lft.hard_packet_limit) {
 		x->km.state = XFRM_STATE_EXPIRED;
-		tasklet_hrtimer_start(&x->mtimer, ktime_set(0,0), HRTIMER_MODE_REL);
+		tasklet_hrtimer_start(&x->mtimer, ktime_set(0, 0), HRTIMER_MODE_REL);
 		return -EINVAL;
 	}
 
@@ -1542,7 +1542,7 @@ int xfrm_alloc_spi(struct xfrm_state *x, u32 low, u32 high)
 		x->id.spi = minspi;
 	} else {
 		u32 spi = 0;
-		for (h=0; h<high-low+1; h++) {
+		for (h = 0; h < high-low+1; h++) {
 			spi = low + net_random()%(high-low+1);
 			x0 = xfrm_state_lookup(net, mark, &x->id.daddr, htonl(spi), x->id.proto, x->props.family);
 			if (x0 == NULL) {
@@ -2079,7 +2079,7 @@ static void xfrm_audit_helper_sainfo(struct xfrm_state *x,
 		audit_log_format(audit_buf, " sec_alg=%u sec_doi=%u sec_obj=%s",
 				 ctx->ctx_alg, ctx->ctx_doi, ctx->ctx_str);
 
-	switch(x->props.family) {
+	switch (x->props.family) {
 	case AF_INET:
 		audit_log_format(audit_buf, " src=%pI4 dst=%pI4",
 				 &x->props.saddr.a4, &x->id.daddr.a4);
@@ -2109,7 +2109,7 @@ static void xfrm_audit_helper_pktinfo(struct sk_buff *skb, u16 family,
 		iph6 = ipv6_hdr(skb);
 		audit_log_format(audit_buf,
 				 " src=%pI6 dst=%pI6 flowlbl=0x%x%02x%02x",
-				 &iph6->saddr,&iph6->daddr,
+				 &iph6->saddr, &iph6->daddr,
 				 iph6->flow_lbl[0] & 0x0f,
 				 iph6->flow_lbl[1],
 				 iph6->flow_lbl[2]);
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 97681a3..e50be42 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1731,11 +1731,11 @@ static int build_aevent(struct sk_buff *skb, struct xfrm_state *x, const struct
 		return -EMSGSIZE;
 
 	id = nlmsg_data(nlh);
-	memcpy(&id->sa_id.daddr, &x->id.daddr,sizeof(x->id.daddr));
+	memcpy(&id->sa_id.daddr, &x->id.daddr, sizeof(x->id.daddr));
 	id->sa_id.spi = x->id.spi;
 	id->sa_id.family = x->props.family;
 	id->sa_id.proto = x->id.proto;
-	memcpy(&id->saddr, &x->props.saddr,sizeof(x->props.saddr));
+	memcpy(&id->saddr, &x->props.saddr, sizeof(x->props.saddr));
 	id->reqid = x->props.reqid;
 	id->flags = c->data.aevent;
 
-- 
1.7.9.5
