From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH net-next 1/3] ipv6: White-space cleansing : Line Layouts
Date: Sun, 24 Aug 2014 21:53:10 +0100
Message-ID: <1408913592-10630-2-git-send-email-ipm@chirality.org.uk>
References: <1408913592-10630-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:46110 "EHLO
	oak.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753321AbaHXUxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 16:53:19 -0400
In-Reply-To: <1408913592-10630-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes no changes to the logic of the code but simply addresses
coding style issues as detected by checkpatch.

Both objdump and diff -w show no differences.

A number of items are addressed in this patch:
* Multiple spaces converted to tabs
* Spaces before tabs removed.
* Spaces in pointer typing cleansed (char *)foo etc.
* Remove space after sizeof
* Ensure spacing around comparators such as if statements.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv6/addrconf.c              |   12 ++---
 net/ipv6/af_inet6.c              |   12 ++---
 net/ipv6/ah6.c                   |   16 +++---
 net/ipv6/datagram.c              |    8 +--
 net/ipv6/esp6.c                  |    8 +--
 net/ipv6/exthdrs.c               |    2 +-
 net/ipv6/icmp.c                  |   10 ++--
 net/ipv6/inet6_connection_sock.c |    2 +-
 net/ipv6/inet6_hashtables.c      |    2 +-
 net/ipv6/ip6_flowlabel.c         |   18 +++----
 net/ipv6/ip6_icmp.c              |    2 +-
 net/ipv6/ip6_input.c             |    6 +--
 net/ipv6/ip6_offload.c           |    2 +-
 net/ipv6/ip6_output.c            |   20 ++++----
 net/ipv6/ip6_tunnel.c            |   32 ++++++------
 net/ipv6/ip6mr.c                 |    4 +-
 net/ipv6/ipv6_sockglue.c         |   22 ++++-----
 net/ipv6/mcast.c                 |  100 +++++++++++++++++++-------------------
 net/ipv6/ndisc.c                 |   16 +++---
 net/ipv6/output_core.c           |    2 +-
 net/ipv6/proc.c                  |    2 +-
 net/ipv6/raw.c                   |    8 +--
 net/ipv6/reassembly.c            |    6 +--
 net/ipv6/route.c                 |   20 ++++----
 net/ipv6/sit.c                   |   12 ++---
 net/ipv6/tunnel6.c               |    2 +-
 net/ipv6/udp.c                   |   18 +++----
 net/ipv6/xfrm6_input.c           |    4 +-
 net/ipv6/xfrm6_policy.c          |   22 ++++-----
 net/ipv6/xfrm6_state.c           |   14 +++---
 net/ipv6/xfrm6_tunnel.c          |    2 +-
 31 files changed, 203 insertions(+), 203 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 0b239fc..267ce3c 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -180,7 +180,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.rtr_solicits		= MAX_RTR_SOLICITATIONS,
 	.rtr_solicit_interval	= RTR_SOLICITATION_INTERVAL,
 	.rtr_solicit_delay	= MAX_RTR_SOLICITATION_DELAY,
-	.use_tempaddr 		= 0,
+	.use_tempaddr		= 0,
 	.temp_valid_lft		= TEMP_VALID_LIFETIME,
 	.temp_prefered_lft	= TEMP_PREFERRED_LIFETIME,
 	.regen_max_retry	= REGEN_MAX_RETRY,
@@ -1105,8 +1105,8 @@ retry:
 	spin_unlock_bh(&ifp->lock);
 
 	regen_advance = idev->cnf.regen_max_retry *
-	                idev->cnf.dad_transmits *
-	                NEIGH_VAR(idev->nd_parms, RETRANS_TIME) / HZ;
+			idev->cnf.dad_transmits *
+			NEIGH_VAR(idev->nd_parms, RETRANS_TIME) / HZ;
 	write_unlock_bh(&idev->lock);
 
 	/* A temporary address is created only if this calculated Preferred
@@ -3035,7 +3035,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 		struct hlist_head *h = &inet6_addr_lst[i];
 
 		spin_lock_bh(&addrconf_hash_lock);
-	restart:
+restart:
 		hlist_for_each_entry_rcu(ifa, h, addr_lst) {
 			if (ifa->idev == idev) {
 				hlist_del_init_rcu(&ifa->addr_lst);
@@ -3547,8 +3547,8 @@ static void __net_exit if6_proc_net_exit(struct net *net)
 }
 
 static struct pernet_operations if6_proc_net_ops = {
-       .init = if6_proc_net_init,
-       .exit = if6_proc_net_exit,
+	.init = if6_proc_net_init,
+	.exit = if6_proc_net_exit,
 };
 
 int __init if6_proc_init(void)
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 2daa3a1..b9393e6 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -7,15 +7,15 @@
  *
  *	Adapted from linux/net/ipv4/af_inet.c
  *
- * 	Fixes:
+ *	Fixes:
  *	piggy, Karl Knutson	:	Socket protocol table
- * 	Hideaki YOSHIFUJI	:	sin6_scope_id support
- * 	Arnaldo Melo		: 	check proc_net_create return, cleanups
+ *	Hideaki YOSHIFUJI	:	sin6_scope_id support
+ *	Arnaldo Melo		:	check proc_net_create return, cleanups
  *
  *	This program is free software; you can redistribute it and/or
- *      modify it under the terms of the GNU General Public License
- *      as published by the Free Software Foundation; either version
- *      2 of the License, or (at your option) any later version.
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
  */
 
 #define pr_fmt(fmt) "IPv6: " fmt
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 72a4930..ac71d9e 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -17,10 +17,10 @@
  * Authors
  *
  *	Mitsuru KANDA @USAGI       : IPv6 Support
- * 	Kazunori MIYAZAWA @USAGI   :
- * 	Kunihiro Ishiguro <kunihiro@ipinfusion.com>
+ *	Kazunori MIYAZAWA @USAGI   :
+ *	Kunihiro Ishiguro <kunihiro@ipinfusion.com>
  *
- * 	This file is derived from net/ipv4/ah.c.
+ *	This file is derived from net/ipv4/ah.c.
  */
 
 #define pr_fmt(fmt) "IPv6: " fmt
@@ -284,7 +284,7 @@ static int ipv6_clear_mutable_options(struct ipv6hdr *iph, int len, int dir)
 			ipv6_rearrange_rthdr(iph, exthdr.rth);
 			break;
 
-		default :
+		default:
 			return 0;
 		}
 
@@ -478,7 +478,7 @@ static void ah6_input_done(struct crypto_async_request *base, int err)
 	auth_data = ah_tmp_auth(work_iph, hdr_len);
 	icv = ah_tmp_icv(ahp->ahash, auth_data, ahp->icv_trunc_len);
 
-	err = memcmp(icv, auth_data, ahp->icv_trunc_len) ? -EBADMSG: 0;
+	err = memcmp(icv, auth_data, ahp->icv_trunc_len) ? -EBADMSG : 0;
 	if (err)
 		goto out;
 
@@ -622,7 +622,7 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 		goto out_free;
 	}
 
-	err = memcmp(icv, auth_data, ahp->icv_trunc_len) ? -EBADMSG: 0;
+	err = memcmp(icv, auth_data, ahp->icv_trunc_len) ? -EBADMSG : 0;
 	if (err)
 		goto out_free;
 
@@ -647,8 +647,8 @@ static int ah6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		   u8 type, u8 code, int offset, __be32 info)
 {
 	struct net *net = dev_net(skb->dev);
-	struct ipv6hdr *iph = (struct ipv6hdr*)skb->data;
-	struct ip_auth_hdr *ah = (struct ip_auth_hdr*)(skb->data+offset);
+	struct ipv6hdr *iph = (struct ipv6hdr *)skb->data;
+	struct ip_auth_hdr *ah = (struct ip_auth_hdr *)(skb->data+offset);
 	struct xfrm_state *x;
 
 	if (type != ICMPV6_PKT_TOOBIG &&
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 2753319..1844e87 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -43,13 +43,13 @@ static bool ipv6_mapped_addr_any(const struct in6_addr *a)
 int ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
 	struct sockaddr_in6	*usin = (struct sockaddr_in6 *) uaddr;
-	struct inet_sock      	*inet = inet_sk(sk);
-	struct ipv6_pinfo      	*np = inet6_sk(sk);
-	struct in6_addr		*daddr, *final_p, final;
+	struct inet_sock	*inet = inet_sk(sk);
+	struct ipv6_pinfo	*np = inet6_sk(sk);
+	struct in6_addr	*daddr, *final_p, final;
 	struct dst_entry	*dst;
 	struct flowi6		fl6;
 	struct ip6_flowlabel	*flowlabel = NULL;
-	struct ipv6_txoptions   *opt;
+	struct ipv6_txoptions	*opt;
 	int			addr_type;
 	int			err;
 
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index d15da13..7b6e830 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -17,10 +17,10 @@
  * Authors
  *
  *	Mitsuru KANDA @USAGI       : IPv6 Support
- * 	Kazunori MIYAZAWA @USAGI   :
- * 	Kunihiro Ishiguro <kunihiro@ipinfusion.com>
+ *	Kazunori MIYAZAWA @USAGI   :
+ *	Kunihiro Ishiguro <kunihiro@ipinfusion.com>
  *
- * 	This file is derived from net/ipv4/esp.c
+ *	This file is derived from net/ipv4/esp.c
  */
 
 #define pr_fmt(fmt) "IPv6: " fmt
@@ -598,7 +598,7 @@ static int esp6_init_state(struct xfrm_state *x)
 	case XFRM_MODE_BEET:
 		if (x->sel.family != AF_INET6)
 			x->props.header_len += IPV4_BEET_PHMAXLEN +
-				               (sizeof(struct ipv6hdr) - sizeof(struct iphdr));
+					       (sizeof(struct ipv6hdr) - sizeof(struct iphdr));
 		break;
 	case XFRM_MODE_TRANSPORT:
 		break;
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 8d67900..bfde361 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -142,7 +142,7 @@ static bool ip6_parse_tlv(const struct tlvtype_proc *procs, struct sk_buff *skb)
 		default: /* Other TLV code so scan list */
 			if (optlen > len)
 				goto bad;
-			for (curr=procs; curr->type >= 0; curr++) {
+			for (curr = procs; curr->type >= 0; curr++) {
 				if (curr->type == nh[off]) {
 					/* type specific length/alignment
 					   checks will be performed in the
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 06ba3e5..394bb82 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -503,7 +503,7 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	msg.type = type;
 
 	len = skb->len - msg.offset;
-	len = min_t(unsigned int, len, IPV6_MIN_MTU - sizeof(struct ipv6hdr) -sizeof(struct icmp6hdr));
+	len = min_t(unsigned int, len, IPV6_MIN_MTU - sizeof(struct ipv6hdr) - sizeof(struct icmp6hdr));
 	if (len < 0) {
 		LIMIT_NETDEBUG(KERN_DEBUG "icmp: len problem\n");
 		goto out_dst_release;
@@ -636,7 +636,7 @@ void icmpv6_notify(struct sk_buff *skb, u8 type, u8 code, __be32 info)
 		/* now skip over extension headers */
 		inner_offset = ipv6_skip_exthdr(skb, sizeof(struct ipv6hdr),
 						&nexthdr, &frag_off);
-		if (inner_offset<0)
+		if (inner_offset < 0)
 			goto out;
 	} else {
 		inner_offset = sizeof(struct ipv6hdr);
@@ -808,7 +808,7 @@ void icmpv6_flow_init(struct sock *sk, struct flowi6 *fl6,
 	memset(fl6, 0, sizeof(*fl6));
 	fl6->saddr = *saddr;
 	fl6->daddr = *daddr;
-	fl6->flowi6_proto 	= IPPROTO_ICMPV6;
+	fl6->flowi6_proto	= IPPROTO_ICMPV6;
 	fl6->fl6_icmp_type	= type;
 	fl6->fl6_icmp_code	= 0;
 	fl6->flowi6_oif		= oif;
@@ -875,8 +875,8 @@ static void __net_exit icmpv6_sk_exit(struct net *net)
 }
 
 static struct pernet_operations icmpv6_sk_ops = {
-       .init = icmpv6_sk_init,
-       .exit = icmpv6_sk_exit,
+	.init = icmpv6_sk_init,
+	.exit = icmpv6_sk_exit,
 };
 
 int __init icmpv6_init(void)
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index a245e5d..8c33a0b 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -163,7 +163,7 @@ void inet6_csk_reqsk_queue_hash_add(struct sock *sk,
 
 EXPORT_SYMBOL_GPL(inet6_csk_reqsk_queue_hash_add);
 
-void inet6_csk_addr2sockaddr(struct sock *sk, struct sockaddr * uaddr)
+void inet6_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr)
 {
 	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *) uaddr;
 
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 8260190..5f7927c 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -6,7 +6,7 @@
  *		Generic INET6 transport hashtables
  *
  * Authors:	Lotsa people, from code originally in tcp, generalised here
- * 		by Arnaldo Carvalho de Melo <acme@mandriva.com>
+ *		by Arnaldo Carvalho de Melo <acme@mandriva.com>
  *
  *	This program is free software; you can redistribute it and/or
  *      modify it under the terms of the GNU General Public License
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 4052694..2ace474 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -136,7 +136,7 @@ static void ip6_fl_gc(unsigned long dummy)
 
 	spin_lock(&ip6_fl_lock);
 
-	for (i=0; i<=FL_HASH_MASK; i++) {
+	for (i = 0; i <= FL_HASH_MASK; i++) {
 		struct ip6_flowlabel *fl;
 		struct ip6_flowlabel __rcu **flp;
 
@@ -239,7 +239,7 @@ static struct ip6_flowlabel *fl_intern(struct net *net,
 
 /* Socket flowlabel lists */
 
-struct ip6_flowlabel * fl6_sock_lookup(struct sock *sk, __be32 label)
+struct ip6_flowlabel *fl6_sock_lookup(struct sock *sk, __be32 label)
 {
 	struct ipv6_fl_socklist *sfl;
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -293,11 +293,11 @@ void fl6_free_socklist(struct sock *sk)
    following rthdr.
  */
 
-struct ipv6_txoptions *fl6_merge_options(struct ipv6_txoptions * opt_space,
-					 struct ip6_flowlabel * fl,
-					 struct ipv6_txoptions * fopt)
+struct ipv6_txoptions *fl6_merge_options(struct ipv6_txoptions *opt_space,
+					 struct ip6_flowlabel *fl,
+					 struct ipv6_txoptions *fopt)
 {
-	struct ipv6_txoptions * fl_opt = fl->opt;
+	struct ipv6_txoptions *fl_opt = fl->opt;
 
 	if (fopt == NULL || fopt->opt_flen == 0)
 		return fl_opt;
@@ -388,7 +388,7 @@ fl_create(struct net *net, struct sock *sk, struct in6_flowlabel_req *freq,
 			goto done;
 
 		msg.msg_controllen = olen;
-		msg.msg_control = (void*)(fl->opt+1);
+		msg.msg_control = (void *)(fl->opt+1);
 		memset(&flowi6, 0, sizeof(flowi6));
 
 		err = ip6_datagram_send_ctl(net, sk, &msg, &flowi6, fl->opt,
@@ -517,7 +517,7 @@ int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
 	struct net *net = sock_net(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct in6_flowlabel_req freq;
-	struct ipv6_fl_socklist *sfl1=NULL;
+	struct ipv6_fl_socklist *sfl1 = NULL;
 	struct ipv6_fl_socklist *sfl;
 	struct ipv6_fl_socklist __rcu **sflp;
 	struct ip6_flowlabel *fl, *fl1 = NULL;
@@ -542,7 +542,7 @@ int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
 		}
 		spin_lock_bh(&ip6_sk_fl_lock);
 		for (sflp = &np->ipv6_fl_list;
-		     (sfl = rcu_dereference(*sflp))!=NULL;
+		     (sfl = rcu_dereference(*sflp)) != NULL;
 		     sflp = &sfl->next) {
 			if (sfl->fl->label == freq.flr_label) {
 				if (freq.flr_label == (np->flow_label&IPV6_FLOWLABEL_MASK))
diff --git a/net/ipv6/ip6_icmp.c b/net/ipv6/ip6_icmp.c
index 4578e23..14dacc5 100644
--- a/net/ipv6/ip6_icmp.c
+++ b/net/ipv6/ip6_icmp.c
@@ -13,7 +13,7 @@ static ip6_icmp_send_t __rcu *ip6_icmp_send;
 int inet6_register_icmp_sender(ip6_icmp_send_t *fn)
 {
 	return (cmpxchg((ip6_icmp_send_t **)&ip6_icmp_send, NULL, fn) == NULL) ?
-	        0 : -EBUSY;
+		0 : -EBUSY;
 }
 EXPORT_SYMBOL(inet6_register_icmp_sender);
 
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 51d54dc..a3084ab 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -15,8 +15,8 @@
  */
 /* Changes
  *
- * 	Mitsuru KANDA @USAGI and
- * 	YOSHIFUJI Hideaki @USAGI: Remove ipv6_parse_exthdrs().
+ *	Mitsuru KANDA @USAGI and
+ *	YOSHIFUJI Hideaki @USAGI: Remove ipv6_parse_exthdrs().
  */
 
 #include <linux/errno.h>
@@ -65,7 +65,7 @@ int ip6_rcv_finish(struct sk_buff *skb)
 int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)
 {
 	const struct ipv6hdr *hdr;
-	u32 		pkt_len;
+	u32 pkt_len;
 	struct inet6_dev *idev;
 	struct net *net = dev_net(skb->dev);
 
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 65eda2a..5bcda33 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -244,7 +244,7 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 			continue;
 
 		iph2 = (struct ipv6hdr *)(p->data + off);
-		first_word = *(__be32 *)iph ^ *(__be32 *)iph2 ;
+		first_word = *(__be32 *)iph ^ *(__be32 *)iph2;
 
 		/* All fields must match except length and Traffic Class.
 		 * XXX skbs on the gro_list have all been parsed and pulled
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 315a55d..4ead554 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -20,7 +20,7 @@
  *				etc.
  *
  *      H. von Brand    :       Added missing #include <linux/string.h>
- *	Imran Patel	: 	frag id should be in NBO
+ *	Imran Patel	:	frag id should be in NBO
  *      Kazunori MIYAZAWA @USAGI
  *			:       add ip6_append_data and related functions
  *				for datagram xmit
@@ -555,14 +555,14 @@ static void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
 int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 {
 	struct sk_buff *frag;
-	struct rt6_info *rt = (struct rt6_info*)skb_dst(skb);
+	struct rt6_info *rt = (struct rt6_info *)skb_dst(skb);
 	struct ipv6_pinfo *np = skb->sk ? inet6_sk(skb->sk) : NULL;
 	struct ipv6hdr *tmp_hdr;
 	struct frag_hdr *fh;
 	unsigned int mtu, hlen, left, len;
 	int hroom, troom;
 	__be32 frag_id = 0;
-	int ptr, offset = 0, err=0;
+	int ptr, offset = 0, err = 0;
 	u8 *prevhdr, nexthdr = 0;
 	struct net *net = dev_net(skb_dst(skb)->dev);
 
@@ -637,7 +637,7 @@ int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 		}
 
 		__skb_pull(skb, hlen);
-		fh = (struct frag_hdr*)__skb_push(skb, sizeof(struct frag_hdr));
+		fh = (struct frag_hdr *)__skb_push(skb, sizeof(struct frag_hdr));
 		__skb_push(skb, hlen);
 		skb_reset_network_header(skb);
 		memcpy(skb_network_header(skb), tmp_hdr, hlen);
@@ -662,7 +662,7 @@ int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 			if (frag) {
 				frag->ip_summed = CHECKSUM_NONE;
 				skb_reset_transport_header(frag);
-				fh = (struct frag_hdr*)__skb_push(frag, sizeof(struct frag_hdr));
+				fh = (struct frag_hdr *)__skb_push(frag, sizeof(struct frag_hdr));
 				__skb_push(frag, hlen);
 				skb_reset_network_header(frag);
 				memcpy(skb_network_header(frag), tmp_hdr,
@@ -681,7 +681,7 @@ int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 			}
 
 			err = output(skb);
-			if(!err)
+			if (!err)
 				IP6_INC_STATS(net, ip6_dst_idev(&rt->dst),
 					      IPSTATS_MIB_FRAGCREATES);
 
@@ -742,7 +742,7 @@ slow_path:
 	/*
 	 *	Keep copying data until we run out.
 	 */
-	while(left > 0)	{
+	while (left > 0)	{
 		len = left;
 		/* IF: it doesn't fit, use 'mtu' - the data space left */
 		if (len > mtu)
@@ -865,7 +865,7 @@ static struct dst_entry *ip6_sk_dst_check(struct sock *sk,
 	/* Yes, checking route validity in not connected
 	 * case is not very simple. Take into account,
 	 * that we do not support routing by source, TOS,
-	 * and MSG_DONTROUTE 		--ANK (980726)
+	 * and MSG_DONTROUTE		--ANK (980726)
 	 *
 	 * 1. ip6_rt_check(): If route was host route,
 	 *    check that cached destination is current.
@@ -1049,7 +1049,7 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 			int getfrag(void *from, char *to, int offset, int len,
 			int odd, struct sk_buff *skb),
 			void *from, int length, int hh_len, int fragheaderlen,
-			int transhdrlen, int mtu,unsigned int flags,
+			int transhdrlen, int mtu, unsigned int flags,
 			struct rt6_info *rt)
 
 {
@@ -1072,7 +1072,7 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 		skb_reserve(skb, hh_len);
 
 		/* create space for UDP/IP header */
-		skb_put(skb,fragheaderlen + transhdrlen);
+		skb_put(skb, fragheaderlen + transhdrlen);
 
 		/* initialize network header pointer */
 		skb_reset_network_header(skb);
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index f9de5a6..e01bd03 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -408,12 +408,12 @@ __u16 ip6_tnl_parse_tlv_enc_lim(struct sk_buff *skb, __u8 *raw)
 {
 	const struct ipv6hdr *ipv6h = (const struct ipv6hdr *) raw;
 	__u8 nexthdr = ipv6h->nexthdr;
-	__u16 off = sizeof (*ipv6h);
+	__u16 off = sizeof(*ipv6h);
 
 	while (ipv6_ext_hdr(nexthdr) && nexthdr != NEXTHDR_NONE) {
 		__u16 optlen = 0;
 		struct ipv6_opt_hdr *hdr;
-		if (raw + off + sizeof (*hdr) > skb->data &&
+		if (raw + off + sizeof(*hdr) > skb->data &&
 		    !pskb_may_pull(skb, raw - skb->data + off + sizeof (*hdr)))
 			break;
 
@@ -530,7 +530,7 @@ ip6_tnl_err(struct sk_buff *skb, __u8 ipproto, struct inet6_skb_parm *opt,
 			mtu = IPV6_MIN_MTU;
 		t->dev->mtu = mtu;
 
-		if ((len = sizeof (*ipv6h) + ntohs(ipv6h->payload_len)) > mtu) {
+		if ((len = sizeof(*ipv6h) + ntohs(ipv6h->payload_len)) > mtu) {
 			rel_type = ICMPV6_PKT_TOOBIG;
 			rel_code = 0;
 			rel_info = mtu;
@@ -991,7 +991,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 				     t->parms.name);
 		goto tx_err_dst_release;
 	}
-	mtu = dst_mtu(dst) - sizeof (*ipv6h);
+	mtu = dst_mtu(dst) - sizeof(*ipv6h);
 	if (encap_limit >= 0) {
 		max_headroom += 8;
 		mtu -= 8;
@@ -1083,7 +1083,7 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
 		encap_limit = t->parms.encap_limit;
 
-	memcpy(&fl6, &t->fl.u.ip6, sizeof (fl6));
+	memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
 	fl6.flowi6_proto = IPPROTO_IPIP;
 
 	dsfield = ipv4_get_dsfield(iph);
@@ -1135,7 +1135,7 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	} else if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
 		encap_limit = t->parms.encap_limit;
 
-	memcpy(&fl6, &t->fl.u.ip6, sizeof (fl6));
+	memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
 	fl6.flowi6_proto = IPPROTO_IPV6;
 
 	dsfield = ipv6_get_dsfield(ipv6h);
@@ -1229,11 +1229,11 @@ static void ip6_tnl_link_config(struct ip6_tnl *t)
 
 		if (rt->dst.dev) {
 			dev->hard_header_len = rt->dst.dev->hard_header_len +
-				sizeof (struct ipv6hdr);
+				sizeof(struct ipv6hdr);
 
-			dev->mtu = rt->dst.dev->mtu - sizeof (struct ipv6hdr);
+			dev->mtu = rt->dst.dev->mtu - sizeof(struct ipv6hdr);
 			if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
-				dev->mtu-=8;
+				dev->mtu -= 8;
 
 			if (dev->mtu < IPV6_MIN_MTU)
 				dev->mtu = IPV6_MIN_MTU;
@@ -1350,7 +1350,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	switch (cmd) {
 	case SIOCGETTUNNEL:
 		if (dev == ip6n->fb_tnl_dev) {
-			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof (p))) {
+			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p))) {
 				err = -EFAULT;
 				break;
 			}
@@ -1362,7 +1362,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			memset(&p, 0, sizeof(p));
 		}
 		ip6_tnl_parm_to_user(&p, &t->parms);
-		if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof (p))) {
+		if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof(p))) {
 			err = -EFAULT;
 		}
 		break;
@@ -1372,7 +1372,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			break;
 		err = -EFAULT;
-		if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof (p)))
+		if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
 			break;
 		err = -EINVAL;
 		if (p.proto != IPPROTO_IPV6 && p.proto != IPPROTO_IPIP &&
@@ -1407,7 +1407,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 		if (dev == ip6n->fb_tnl_dev) {
 			err = -EFAULT;
-			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof (p)))
+			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
 				break;
 			err = -ENOENT;
 			ip6_tnl_parm_from_user(&p1, &p);
@@ -1482,11 +1482,11 @@ static void ip6_tnl_dev_setup(struct net_device *dev)
 	dev->destructor = ip6_dev_free;
 
 	dev->type = ARPHRD_TUNNEL6;
-	dev->hard_header_len = LL_MAX_HEADER + sizeof (struct ipv6hdr);
-	dev->mtu = ETH_DATA_LEN - sizeof (struct ipv6hdr);
+	dev->hard_header_len = LL_MAX_HEADER + sizeof(struct ipv6hdr);
+	dev->mtu = ETH_DATA_LEN - sizeof(struct ipv6hdr);
 	t = netdev_priv(dev);
 	if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
-		dev->mtu-=8;
+		dev->mtu -= 8;
 	dev->flags |= IFF_NOARP;
 	dev->addr_len = sizeof(struct in6_addr);
 	dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index f9a3fd3..0171f08 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -845,7 +845,7 @@ static void ip6mr_destroy_unres(struct mr6_table *mrt, struct mfc6_cache *c)
 
 	atomic_dec(&mrt->cache_resolve_queue_len);
 
-	while((skb = skb_dequeue(&c->mfc_un.unres.unresolved)) != NULL) {
+	while ((skb = skb_dequeue(&c->mfc_un.unres.unresolved)) != NULL) {
 		if (ipv6_hdr(skb)->version == 0) {
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct ipv6hdr));
 			nlh->nlmsg_type = NLMSG_ERROR;
@@ -1103,7 +1103,7 @@ static void ip6mr_cache_resolve(struct net *net, struct mr6_table *mrt,
 	 *	Play the pending entries through our router
 	 */
 
-	while((skb = __skb_dequeue(&uc->mfc_un.unres.unresolved))) {
+	while ((skb = __skb_dequeue(&uc->mfc_un.unres.unresolved))) {
 		if (ipv6_hdr(skb)->version == 0) {
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct ipv6hdr));
 
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 0c28998..64177ef 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -66,12 +66,12 @@ int ip6_ra_control(struct sock *sk, int sel)
 	if (sk->sk_type != SOCK_RAW || inet_sk(sk)->inet_num != IPPROTO_RAW)
 		return -ENOPROTOOPT;
 
-	new_ra = (sel>=0) ? kmalloc(sizeof(*new_ra), GFP_KERNEL) : NULL;
+	new_ra = (sel >= 0) ? kmalloc(sizeof(*new_ra), GFP_KERNEL) : NULL;
 
 	write_lock_bh(&ip6_ra_lock);
-	for (rap = &ip6_ra_chain; (ra=*rap) != NULL; rap = &ra->next) {
+	for (rap = &ip6_ra_chain; (ra = *rap) != NULL; rap = &ra->next) {
 		if (ra->sk == sk) {
-			if (sel>=0) {
+			if (sel >= 0) {
 				write_unlock_bh(&ip6_ra_lock);
 				kfree(new_ra);
 				return -EADDRINUSE;
@@ -130,7 +130,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 	int retv = -ENOPROTOOPT;
 
 	if (optval == NULL)
-		val=0;
+		val = 0;
 	else {
 		if (optlen >= sizeof(int)) {
 			if (get_user(val, (int __user *) optval))
@@ -139,7 +139,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 			val = 0;
 	}
 
-	valbool = (val!=0);
+	valbool = (val != 0);
 
 	if (ip6_mroute_opt(optname))
 		return ip6_mroute_setsockopt(sk, optname, optval, optlen);
@@ -474,7 +474,7 @@ sticky_done:
 			goto done;
 
 		msg.msg_controllen = optlen;
-		msg.msg_control = (void*)(opt+1);
+		msg.msg_control = (void *)(opt+1);
 
 		retv = ip6_datagram_send_ctl(net, sk, &msg, &fl6, opt, &junk,
 					     &junk, &junk);
@@ -687,7 +687,7 @@ done:
 			retv = -ENOBUFS;
 			break;
 		}
-		gsf = kmalloc(optlen,GFP_KERNEL);
+		gsf = kmalloc(optlen, GFP_KERNEL);
 		if (!gsf) {
 			retv = -ENOBUFS;
 			break;
@@ -921,7 +921,7 @@ static int ipv6_getsockopt_sticky(struct sock *sk, struct ipv6_txoptions *opt,
 	if (!opt)
 		return 0;
 
-	switch(optname) {
+	switch (optname) {
 	case IPV6_HOPOPTS:
 		hdr = opt->hopopt;
 		break;
@@ -1284,9 +1284,9 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		return -ENOPROTOOPT;
 	}
 	len = min_t(unsigned int, sizeof(int), len);
-	if(put_user(len, optlen))
+	if (put_user(len, optlen))
 		return -EFAULT;
-	if(copy_to_user(optval,&val,len))
+	if (copy_to_user(optval, &val, len))
 		return -EFAULT;
 	return 0;
 }
@@ -1299,7 +1299,7 @@ int ipv6_getsockopt(struct sock *sk, int level, int optname,
 	if (level == SOL_IP && sk->sk_type != SOCK_RAW)
 		return udp_prot.getsockopt(sk, level, optname, optval, optlen);
 
-	if(level != SOL_IPV6)
+	if (level != SOL_IPV6)
 		return -ENOPROTOOPT;
 
 	err = do_ipv6_getsockopt(sk, level, optname, optval, optlen, 0);
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 617f095..7088179 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -232,7 +232,7 @@ int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	spin_lock(&ipv6_sk_mc_lock);
 	for (lnk = &np->ipv6_mc_list;
 	     (mc_lst = rcu_dereference_protected(*lnk,
-			lockdep_is_held(&ipv6_sk_mc_lock))) !=NULL ;
+			lockdep_is_held(&ipv6_sk_mc_lock))) != NULL;
 	      lnk = &mc_lst->next) {
 		if ((ifindex == 0 || mc_lst->ifindex == ifindex) &&
 		    ipv6_addr_equal(&mc_lst->addr, addr)) {
@@ -390,7 +390,7 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 		if (!psl)
 			goto done;	/* err = -EADDRNOTAVAIL */
 		rv = !0;
-		for (i=0; i<psl->sl_count; i++) {
+		for (i = 0; i < psl->sl_count; i++) {
 			rv = !ipv6_addr_equal(&psl->sl_addr[i], source);
 			if (rv == 0)
 				break;
@@ -407,7 +407,7 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 		/* update the interface filter */
 		ip6_mc_del_src(idev, group, omode, 1, source, 1);
 
-		for (j=i+1; j<psl->sl_count; j++)
+		for (j = i+1; j < psl->sl_count; j++)
 			psl->sl_addr[j-1] = psl->sl_addr[j];
 		psl->sl_count--;
 		err = 0;
@@ -433,19 +433,19 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 		newpsl->sl_max = count;
 		newpsl->sl_count = count - IP6_SFBLOCK;
 		if (psl) {
-			for (i=0; i<psl->sl_count; i++)
+			for (i = 0; i < psl->sl_count; i++)
 				newpsl->sl_addr[i] = psl->sl_addr[i];
 			sock_kfree_s(sk, psl, IP6_SFLSIZE(psl->sl_max));
 		}
 		pmc->sflist = psl = newpsl;
 	}
 	rv = 1;	/* > 0 for insert logic below if sl_count is 0 */
-	for (i=0; i<psl->sl_count; i++) {
+	for (i = 0; i < psl->sl_count; i++) {
 		rv = !ipv6_addr_equal(&psl->sl_addr[i], source);
 		if (rv == 0) /* There is an error in the address. */
 			goto done;
 	}
-	for (j=psl->sl_count-1; j>=i; j--)
+	for (j = psl->sl_count-1; j >= i; j--)
 		psl->sl_addr[j+1] = psl->sl_addr[j];
 	psl->sl_addr[i] = *source;
 	psl->sl_count++;
@@ -514,7 +514,7 @@ int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf)
 			goto done;
 		}
 		newpsl->sl_max = newpsl->sl_count = gsf->gf_numsrc;
-		for (i=0; i<newpsl->sl_count; ++i) {
+		for (i = 0; i < newpsl->sl_count; ++i) {
 			struct sockaddr_in6 *psin6;
 
 			psin6 = (struct sockaddr_in6 *)&gsf->gf_slist[i];
@@ -606,7 +606,7 @@ int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
 	 * on ipv6_sk_mc_lock and a write lock on pmc->sflock. We
 	 * have the socket lock, so reading here is safe.
 	 */
-	for (i=0; i<copycount; i++) {
+	for (i = 0; i < copycount; i++) {
 		struct sockaddr_in6 *psin6;
 		struct sockaddr_storage ss;
 
@@ -648,7 +648,7 @@ bool inet6_mc_check(struct sock *sk, const struct in6_addr *mc_addr,
 	} else {
 		int i;
 
-		for (i=0; i<psl->sl_count; i++) {
+		for (i = 0; i < psl->sl_count; i++) {
 			if (ipv6_addr_equal(&psl->sl_addr[i], src_addr))
 				break;
 		}
@@ -762,7 +762,7 @@ static void mld_add_delrec(struct inet6_dev *idev, struct ifmcaddr6 *im)
 		pmc->mca_tomb = im->mca_tomb;
 		pmc->mca_sources = im->mca_sources;
 		im->mca_tomb = im->mca_sources = NULL;
-		for (psf=pmc->mca_sources; psf; psf=psf->sf_next)
+		for (psf = pmc->mca_sources; psf; psf = psf->sf_next)
 			psf->sf_crcount = pmc->mca_crcount;
 	}
 	spin_unlock_bh(&im->mca_lock);
@@ -780,7 +780,7 @@ static void mld_del_delrec(struct inet6_dev *idev, const struct in6_addr *pmca)
 
 	spin_lock_bh(&idev->mc_lock);
 	pmc_prev = NULL;
-	for (pmc=idev->mc_tomb; pmc; pmc=pmc->next) {
+	for (pmc = idev->mc_tomb; pmc; pmc = pmc->next) {
 		if (ipv6_addr_equal(&pmc->mca_addr, pmca))
 			break;
 		pmc_prev = pmc;
@@ -794,7 +794,7 @@ static void mld_del_delrec(struct inet6_dev *idev, const struct in6_addr *pmca)
 	spin_unlock_bh(&idev->mc_lock);
 
 	if (pmc) {
-		for (psf=pmc->mca_tomb; psf; psf=psf_next) {
+		for (psf = pmc->mca_tomb; psf; psf = psf_next) {
 			psf_next = psf->sf_next;
 			kfree(psf);
 		}
@@ -821,14 +821,14 @@ static void mld_clear_delrec(struct inet6_dev *idev)
 
 	/* clear dead sources, too */
 	read_lock_bh(&idev->lock);
-	for (pmc=idev->mc_list; pmc; pmc=pmc->next) {
+	for (pmc = idev->mc_list; pmc; pmc = pmc->next) {
 		struct ip6_sf_list *psf, *psf_next;
 
 		spin_lock_bh(&pmc->mca_lock);
 		psf = pmc->mca_tomb;
 		pmc->mca_tomb = NULL;
 		spin_unlock_bh(&pmc->mca_lock);
-		for (; psf; psf=psf_next) {
+		for (; psf; psf = psf_next) {
 			psf_next = psf->sf_next;
 			kfree(psf);
 		}
@@ -917,7 +917,7 @@ int __ipv6_dev_mc_dec(struct inet6_dev *idev, const struct in6_addr *addr)
 	struct ifmcaddr6 *ma, **map;
 
 	write_lock_bh(&idev->lock);
-	for (map = &idev->mc_list; (ma=*map) != NULL; map = &ma->next) {
+	for (map = &idev->mc_list; (ma = *map) != NULL; map = &ma->next) {
 		if (ipv6_addr_equal(&ma->mca_addr, addr)) {
 			if (--ma->mca_users == 0) {
 				*map = ma->next;
@@ -968,7 +968,7 @@ bool ipv6_chk_mcast_addr(struct net_device *dev, const struct in6_addr *group,
 	idev = __in6_dev_get(dev);
 	if (idev) {
 		read_lock_bh(&idev->lock);
-		for (mc = idev->mc_list; mc; mc=mc->next) {
+		for (mc = idev->mc_list; mc; mc = mc->next) {
 			if (ipv6_addr_equal(&mc->mca_addr, group))
 				break;
 		}
@@ -977,7 +977,7 @@ bool ipv6_chk_mcast_addr(struct net_device *dev, const struct in6_addr *group,
 				struct ip6_sf_list *psf;
 
 				spin_lock_bh(&mc->mca_lock);
-				for (psf=mc->mca_sources;psf;psf=psf->sf_next) {
+				for (psf = mc->mca_sources; psf; psf = psf->sf_next) {
 					if (ipv6_addr_equal(&psf->sf_addr, src_addr))
 						break;
 				}
@@ -986,7 +986,7 @@ bool ipv6_chk_mcast_addr(struct net_device *dev, const struct in6_addr *group,
 						psf->sf_count[MCAST_EXCLUDE] !=
 						mc->mca_sfcount[MCAST_EXCLUDE];
 				else
-					rv = mc->mca_sfcount[MCAST_EXCLUDE] !=0;
+					rv = mc->mca_sfcount[MCAST_EXCLUDE] != 0;
 				spin_unlock_bh(&mc->mca_lock);
 			} else
 				rv = true; /* don't filter unspecified source */
@@ -1077,10 +1077,10 @@ static bool mld_xmarksources(struct ifmcaddr6 *pmc, int nsrcs,
 	int i, scount;
 
 	scount = 0;
-	for (psf=pmc->mca_sources; psf; psf=psf->sf_next) {
+	for (psf = pmc->mca_sources; psf; psf = psf->sf_next) {
 		if (scount == nsrcs)
 			break;
-		for (i=0; i<nsrcs; i++) {
+		for (i = 0; i < nsrcs; i++) {
 			/* skip inactive filters */
 			if (psf->sf_count[MCAST_INCLUDE] ||
 			    pmc->mca_sfcount[MCAST_EXCLUDE] !=
@@ -1110,10 +1110,10 @@ static bool mld_marksources(struct ifmcaddr6 *pmc, int nsrcs,
 	/* mark INCLUDE-mode sources */
 
 	scount = 0;
-	for (psf=pmc->mca_sources; psf; psf=psf->sf_next) {
+	for (psf = pmc->mca_sources; psf; psf = psf->sf_next) {
 		if (scount == nsrcs)
 			break;
-		for (i=0; i<nsrcs; i++) {
+		for (i = 0; i < nsrcs; i++) {
 			if (ipv6_addr_equal(&srcs[i], &psf->sf_addr)) {
 				psf->sf_gsresp = 1;
 				scount++;
@@ -1364,13 +1364,13 @@ int igmp6_event_query(struct sk_buff *skb)
 
 	read_lock_bh(&idev->lock);
 	if (group_type == IPV6_ADDR_ANY) {
-		for (ma = idev->mc_list; ma; ma=ma->next) {
+		for (ma = idev->mc_list; ma; ma = ma->next) {
 			spin_lock_bh(&ma->mca_lock);
 			igmp6_group_queried(ma, max_delay);
 			spin_unlock_bh(&ma->mca_lock);
 		}
 	} else {
-		for (ma = idev->mc_list; ma; ma=ma->next) {
+		for (ma = idev->mc_list; ma; ma = ma->next) {
 			if (!ipv6_addr_equal(group, &ma->mca_addr))
 				continue;
 			spin_lock_bh(&ma->mca_lock);
@@ -1434,7 +1434,7 @@ int igmp6_event_report(struct sk_buff *skb)
 	 */
 
 	read_lock_bh(&idev->lock);
-	for (ma = idev->mc_list; ma; ma=ma->next) {
+	for (ma = idev->mc_list; ma; ma = ma->next) {
 		if (ipv6_addr_equal(&ma->mca_addr, &mld->mld_mca)) {
 			spin_lock(&ma->mca_lock);
 			if (del_timer(&ma->mca_timer))
@@ -1498,7 +1498,7 @@ mld_scount(struct ifmcaddr6 *pmc, int type, int gdeleted, int sdeleted)
 	struct ip6_sf_list *psf;
 	int scount = 0;
 
-	for (psf=pmc->mca_sources; psf; psf=psf->sf_next) {
+	for (psf = pmc->mca_sources; psf; psf = psf->sf_next) {
 		if (!is_in(pmc, psf, type, gdeleted, sdeleted))
 			continue;
 		scount++;
@@ -1712,7 +1712,7 @@ static struct sk_buff *add_grec(struct sk_buff *skb, struct ifmcaddr6 *pmc,
 	}
 	first = 1;
 	psf_prev = NULL;
-	for (psf=*psf_list; psf; psf=psf_next) {
+	for (psf = *psf_list; psf; psf = psf_next) {
 		struct in6_addr *psrc;
 
 		psf_next = psf->sf_next;
@@ -1791,7 +1791,7 @@ static void mld_send_report(struct inet6_dev *idev, struct ifmcaddr6 *pmc)
 
 	read_lock_bh(&idev->lock);
 	if (!pmc) {
-		for (pmc=idev->mc_list; pmc; pmc=pmc->next) {
+		for (pmc = idev->mc_list; pmc; pmc = pmc->next) {
 			if (pmc->mca_flags & MAF_NOREPORT)
 				continue;
 			spin_lock_bh(&pmc->mca_lock);
@@ -1824,7 +1824,7 @@ static void mld_clear_zeros(struct ip6_sf_list **ppsf)
 	struct ip6_sf_list *psf_prev, *psf_next, *psf;
 
 	psf_prev = NULL;
-	for (psf=*ppsf; psf; psf = psf_next) {
+	for (psf = *ppsf; psf; psf = psf_next) {
 		psf_next = psf->sf_next;
 		if (psf->sf_crcount == 0) {
 			if (psf_prev)
@@ -1848,7 +1848,7 @@ static void mld_send_cr(struct inet6_dev *idev)
 
 	/* deleted MCA's */
 	pmc_prev = NULL;
-	for (pmc=idev->mc_tomb; pmc; pmc=pmc_next) {
+	for (pmc = idev->mc_tomb; pmc; pmc = pmc_next) {
 		pmc_next = pmc->next;
 		if (pmc->mca_sfmode == MCAST_INCLUDE) {
 			type = MLD2_BLOCK_OLD_SOURCES;
@@ -1881,7 +1881,7 @@ static void mld_send_cr(struct inet6_dev *idev)
 	spin_unlock(&idev->mc_lock);
 
 	/* change recs */
-	for (pmc=idev->mc_list; pmc; pmc=pmc->next) {
+	for (pmc = idev->mc_list; pmc; pmc = pmc->next) {
 		spin_lock_bh(&pmc->mca_lock);
 		if (pmc->mca_sfcount[MCAST_EXCLUDE]) {
 			type = MLD2_BLOCK_OLD_SOURCES;
@@ -2018,7 +2018,7 @@ static void mld_send_initial_cr(struct inet6_dev *idev)
 
 	skb = NULL;
 	read_lock_bh(&idev->lock);
-	for (pmc=idev->mc_list; pmc; pmc=pmc->next) {
+	for (pmc = idev->mc_list; pmc; pmc = pmc->next) {
 		spin_lock_bh(&pmc->mca_lock);
 		if (pmc->mca_sfcount[MCAST_EXCLUDE])
 			type = MLD2_CHANGE_TO_EXCLUDE;
@@ -2063,7 +2063,7 @@ static int ip6_mc_del1_src(struct ifmcaddr6 *pmc, int sfmode,
 	int rv = 0;
 
 	psf_prev = NULL;
-	for (psf=pmc->mca_sources; psf; psf=psf->sf_next) {
+	for (psf = pmc->mca_sources; psf; psf = psf->sf_next) {
 		if (ipv6_addr_equal(&psf->sf_addr, psfsrc))
 			break;
 		psf_prev = psf;
@@ -2104,7 +2104,7 @@ static int ip6_mc_del_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 	if (!idev)
 		return -ENODEV;
 	read_lock_bh(&idev->lock);
-	for (pmc=idev->mc_list; pmc; pmc=pmc->next) {
+	for (pmc = idev->mc_list; pmc; pmc = pmc->next) {
 		if (ipv6_addr_equal(pmca, &pmc->mca_addr))
 			break;
 	}
@@ -2124,7 +2124,7 @@ static int ip6_mc_del_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 		pmc->mca_sfcount[sfmode]--;
 	}
 	err = 0;
-	for (i=0; i<sfcount; i++) {
+	for (i = 0; i < sfcount; i++) {
 		int rv = ip6_mc_del1_src(pmc, sfmode, &psfsrc[i]);
 
 		changerec |= rv > 0;
@@ -2140,7 +2140,7 @@ static int ip6_mc_del_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 		pmc->mca_sfmode = MCAST_INCLUDE;
 		pmc->mca_crcount = idev->mc_qrv;
 		idev->mc_ifc_count = pmc->mca_crcount;
-		for (psf=pmc->mca_sources; psf; psf = psf->sf_next)
+		for (psf = pmc->mca_sources; psf; psf = psf->sf_next)
 			psf->sf_crcount = 0;
 		mld_ifc_event(pmc->idev);
 	} else if (sf_setstate(pmc) || changerec)
@@ -2159,7 +2159,7 @@ static int ip6_mc_add1_src(struct ifmcaddr6 *pmc, int sfmode,
 	struct ip6_sf_list *psf, *psf_prev;
 
 	psf_prev = NULL;
-	for (psf=pmc->mca_sources; psf; psf=psf->sf_next) {
+	for (psf = pmc->mca_sources; psf; psf = psf->sf_next) {
 		if (ipv6_addr_equal(&psf->sf_addr, psfsrc))
 			break;
 		psf_prev = psf;
@@ -2184,7 +2184,7 @@ static void sf_markstate(struct ifmcaddr6 *pmc)
 	struct ip6_sf_list *psf;
 	int mca_xcount = pmc->mca_sfcount[MCAST_EXCLUDE];
 
-	for (psf=pmc->mca_sources; psf; psf=psf->sf_next)
+	for (psf = pmc->mca_sources; psf; psf = psf->sf_next)
 		if (pmc->mca_sfcount[MCAST_EXCLUDE]) {
 			psf->sf_oldin = mca_xcount ==
 				psf->sf_count[MCAST_EXCLUDE] &&
@@ -2201,7 +2201,7 @@ static int sf_setstate(struct ifmcaddr6 *pmc)
 	int new_in, rv;
 
 	rv = 0;
-	for (psf=pmc->mca_sources; psf; psf=psf->sf_next) {
+	for (psf = pmc->mca_sources; psf; psf = psf->sf_next) {
 		if (pmc->mca_sfcount[MCAST_EXCLUDE]) {
 			new_in = mca_xcount == psf->sf_count[MCAST_EXCLUDE] &&
 				!psf->sf_count[MCAST_INCLUDE];
@@ -2211,8 +2211,8 @@ static int sf_setstate(struct ifmcaddr6 *pmc)
 			if (!psf->sf_oldin) {
 				struct ip6_sf_list *prev = NULL;
 
-				for (dpsf=pmc->mca_tomb; dpsf;
-				     dpsf=dpsf->sf_next) {
+				for (dpsf = pmc->mca_tomb; dpsf;
+				     dpsf = dpsf->sf_next) {
 					if (ipv6_addr_equal(&dpsf->sf_addr,
 					    &psf->sf_addr))
 						break;
@@ -2234,7 +2234,7 @@ static int sf_setstate(struct ifmcaddr6 *pmc)
 			 * add or update "delete" records if an active filter
 			 * is now inactive
 			 */
-			for (dpsf=pmc->mca_tomb; dpsf; dpsf=dpsf->sf_next)
+			for (dpsf = pmc->mca_tomb; dpsf; dpsf = dpsf->sf_next)
 				if (ipv6_addr_equal(&dpsf->sf_addr,
 				    &psf->sf_addr))
 					break;
@@ -2268,7 +2268,7 @@ static int ip6_mc_add_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 	if (!idev)
 		return -ENODEV;
 	read_lock_bh(&idev->lock);
-	for (pmc=idev->mc_list; pmc; pmc=pmc->next) {
+	for (pmc = idev->mc_list; pmc; pmc = pmc->next) {
 		if (ipv6_addr_equal(pmca, &pmc->mca_addr))
 			break;
 	}
@@ -2284,7 +2284,7 @@ static int ip6_mc_add_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 	if (!delta)
 		pmc->mca_sfcount[sfmode]++;
 	err = 0;
-	for (i=0; i<sfcount; i++) {
+	for (i = 0; i < sfcount; i++) {
 		err = ip6_mc_add1_src(pmc, sfmode, &psfsrc[i]);
 		if (err)
 			break;
@@ -2294,7 +2294,7 @@ static int ip6_mc_add_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 
 		if (!delta)
 			pmc->mca_sfcount[sfmode]--;
-		for (j=0; j<i; j++)
+		for (j = 0; j < i; j++)
 			ip6_mc_del1_src(pmc, sfmode, &psfsrc[j]);
 	} else if (isexclude != (pmc->mca_sfcount[MCAST_EXCLUDE] != 0)) {
 		struct ip6_sf_list *psf;
@@ -2308,7 +2308,7 @@ static int ip6_mc_add_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 
 		pmc->mca_crcount = idev->mc_qrv;
 		idev->mc_ifc_count = pmc->mca_crcount;
-		for (psf=pmc->mca_sources; psf; psf = psf->sf_next)
+		for (psf = pmc->mca_sources; psf; psf = psf->sf_next)
 			psf->sf_crcount = 0;
 		mld_ifc_event(idev);
 	} else if (sf_setstate(pmc))
@@ -2322,12 +2322,12 @@ static void ip6_mc_clear_src(struct ifmcaddr6 *pmc)
 {
 	struct ip6_sf_list *psf, *nextpsf;
 
-	for (psf=pmc->mca_tomb; psf; psf=nextpsf) {
+	for (psf = pmc->mca_tomb; psf; psf = nextpsf) {
 		nextpsf = psf->sf_next;
 		kfree(psf);
 	}
 	pmc->mca_tomb = NULL;
-	for (psf=pmc->mca_sources; psf; psf=nextpsf) {
+	for (psf = pmc->mca_sources; psf; psf = nextpsf) {
 		nextpsf = psf->sf_next;
 		kfree(psf);
 	}
@@ -2471,7 +2471,7 @@ void ipv6_mc_down(struct inet6_dev *idev)
 	mld_gq_stop_timer(idev);
 	mld_dad_stop_timer(idev);
 
-	for (i = idev->mc_list; i; i=i->next)
+	for (i = idev->mc_list; i; i = i->next)
 		igmp6_group_dropped(i);
 	read_unlock_bh(&idev->lock);
 
@@ -2488,7 +2488,7 @@ void ipv6_mc_up(struct inet6_dev *idev)
 	/* Install multicast list, except for all-nodes (already installed) */
 
 	read_lock_bh(&idev->lock);
-	for (i = idev->mc_list; i; i=i->next)
+	for (i = idev->mc_list; i; i = i->next)
 		igmp6_group_added(i);
 	read_unlock_bh(&idev->lock);
 }
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 339078f..995a829 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -175,7 +175,7 @@ static struct nd_opt_hdr *ndisc_next_option(struct nd_opt_hdr *cur,
 	type = cur->nd_opt_type;
 	do {
 		cur = ((void *)cur) + (cur->nd_opt_len << 3);
-	} while(cur < end && cur->nd_opt_type != type);
+	} while (cur < end && cur->nd_opt_type != type);
 	return cur <= end && cur->nd_opt_type == type ? cur : NULL;
 }
 
@@ -192,7 +192,7 @@ static struct nd_opt_hdr *ndisc_next_useropt(struct nd_opt_hdr *cur,
 		return NULL;
 	do {
 		cur = ((void *)cur) + (cur->nd_opt_len << 3);
-	} while(cur < end && !ndisc_is_useropt(cur));
+	} while (cur < end && !ndisc_is_useropt(cur));
 	return cur <= end && ndisc_is_useropt(cur) ? cur : NULL;
 }
 
@@ -296,7 +296,7 @@ static u32 ndisc_hash(const void *pkey,
 
 static int ndisc_constructor(struct neighbour *neigh)
 {
-	struct in6_addr *addr = (struct in6_addr*)&neigh->primary_key;
+	struct in6_addr *addr = (struct in6_addr *)&neigh->primary_key;
 	struct net_device *dev = neigh->dev;
 	struct inet6_dev *in6_dev;
 	struct neigh_parms *parms;
@@ -344,7 +344,7 @@ static int ndisc_constructor(struct neighbour *neigh)
 
 static int pndisc_constructor(struct pneigh_entry *n)
 {
-	struct in6_addr *addr = (struct in6_addr*)&n->key;
+	struct in6_addr *addr = (struct in6_addr *)&n->key;
 	struct in6_addr maddr;
 	struct net_device *dev = n->dev;
 
@@ -357,7 +357,7 @@ static int pndisc_constructor(struct pneigh_entry *n)
 
 static void pndisc_destructor(struct pneigh_entry *n)
 {
-	struct in6_addr *addr = (struct in6_addr*)&n->key;
+	struct in6_addr *addr = (struct in6_addr *)&n->key;
 	struct in6_addr maddr;
 	struct net_device *dev = n->dev;
 
@@ -1065,7 +1065,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	int optlen;
 	unsigned int pref = 0;
 
-	__u8 * opt = (__u8 *)(ra_msg + 1);
+	__u8 *opt = (__u8 *)(ra_msg + 1);
 
 	optlen = (skb_tail_pointer(skb) - skb_transport_header(skb)) -
 		sizeof(struct ra_msg);
@@ -1319,7 +1319,7 @@ skip_linkparms:
 				continue;
 			if (ri->prefix_len > in6_dev->cnf.accept_ra_rt_info_max_plen)
 				continue;
-			rt6_route_rcv(skb->dev, (u8*)p, (p->nd_opt_len) << 3,
+			rt6_route_rcv(skb->dev, (u8 *)p, (p->nd_opt_len) << 3,
 				      &ipv6_hdr(skb)->saddr);
 		}
 	}
@@ -1352,7 +1352,7 @@ skip_routeinfo:
 		__be32 n;
 		u32 mtu;
 
-		memcpy(&n, ((u8*)(ndopts.nd_opts_mtu+1))+2, sizeof(mtu));
+		memcpy(&n, ((u8 *)(ndopts.nd_opts_mtu+1))+2, sizeof(mtu));
 		mtu = ntohl(n);
 
 		if (mtu < IPV6_MIN_MTU || mtu > skb->dev->mtu) {
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index 5ec867e..fc24c39 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -35,7 +35,7 @@ int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr)
 			if (found_rhdr)
 				return offset;
 			break;
-		default :
+		default:
 			return offset;
 		}
 
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 2d6f860..1752cd0 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -8,7 +8,7 @@
  *		except it reports the sockets in the INET6 address family.
  *
  * Authors:	David S. Miller (davem@caip.rutgers.edu)
- * 		YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
+ *		YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
  *
  *		This program is free software; you can redistribute it and/or
  *		modify it under the terms of the GNU General Public License
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 39d4422..896af88 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -889,7 +889,7 @@ back_from_confirm:
 	else {
 		lock_sock(sk);
 		err = ip6_append_data(sk, ip_generic_getfrag, msg->msg_iov,
-			len, 0, hlimit, tclass, opt, &fl6, (struct rt6_info*)dst,
+			len, 0, hlimit, tclass, opt, &fl6, (struct rt6_info *)dst,
 			msg->msg_flags, dontfrag);
 
 		if (err)
@@ -902,7 +902,7 @@ done:
 	dst_release(dst);
 out:
 	fl6_sock_release(flowlabel);
-	return err<0?err:len;
+	return err < 0 ? err : len;
 do_confirm:
 	dst_confirm(dst);
 	if (!(msg->msg_flags & MSG_PROBE) || len)
@@ -1045,7 +1045,7 @@ static int do_rawv6_getsockopt(struct sock *sk, int level, int optname,
 	struct raw6_sock *rp = raw6_sk(sk);
 	int val, len;
 
-	if (get_user(len,optlen))
+	if (get_user(len, optlen))
 		return -EFAULT;
 
 	switch (optname) {
@@ -1069,7 +1069,7 @@ static int do_rawv6_getsockopt(struct sock *sk, int level, int optname,
 
 	if (put_user(len, optlen))
 		return -EFAULT;
-	if (copy_to_user(optval,&val,len))
+	if (copy_to_user(optval, &val, len))
 		return -EFAULT;
 	return 0;
 }
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index c6557d9..fe156d9 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -68,7 +68,7 @@ struct ip6frag_skb_cb
 	int			offset;
 };
 
-#define FRAG6_CB(skb)	((struct ip6frag_skb_cb*)((skb)->cb))
+#define FRAG6_CB(skb)	((struct ip6frag_skb_cb *)((skb)->cb))
 
 static inline u8 ip6_frag_ecn(const struct ipv6hdr *ipv6h)
 {
@@ -289,7 +289,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 		goto found;
 	}
 	prev = NULL;
-	for(next = fq->q.fragments; next != NULL; next = next->next) {
+	for (next = fq->q.fragments; next != NULL; next = next->next) {
 		if (FRAG6_CB(next)->offset >= offset)
 			break;	/* bingo! */
 		prev = next;
@@ -529,7 +529,7 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 	IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_REASMREQDS);
 
 	/* Jumbo payload inhibits frag. header */
-	if (hdr->payload_len==0)
+	if (hdr->payload_len == 0)
 		goto fail_hdr;
 
 	if (!pskb_may_pull(skb, (skb_transport_offset(skb) +
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f23fbd2..76c7930 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -813,7 +813,7 @@ out:
 
 }
 
-struct dst_entry * ip6_route_lookup(struct net *net, struct flowi6 *fl6,
+struct dst_entry *ip6_route_lookup(struct net *net, struct flowi6 *fl6,
 				    int flags)
 {
 	return fib6_rule_lookup(net, fl6, flags, ip6_pol_route_lookup);
@@ -1024,7 +1024,7 @@ static struct rt6_info *ip6_pol_route_output(struct net *net, struct fib6_table
 	return ip6_pol_route(net, table, fl6->flowi6_oif, fl6, flags);
 }
 
-struct dst_entry * ip6_route_output(struct net *net, const struct sock *sk,
+struct dst_entry *ip6_route_output(struct net *net, const struct sock *sk,
 				    struct flowi6 *fl6)
 {
 	int flags = 0;
@@ -1149,7 +1149,7 @@ static void ip6_link_failure(struct sk_buff *skb)
 static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 			       struct sk_buff *skb, u32 mtu)
 {
-	struct rt6_info *rt6 = (struct rt6_info*)dst;
+	struct rt6_info *rt6 = (struct rt6_info *)dst;
 
 	dst_confirm(dst);
 	if (mtu < dst_mtu(dst) && rt6->rt6i_dst.plen == 128) {
@@ -1924,7 +1924,7 @@ static struct rt6_info *rt6_get_route_info(struct net *net,
 		return NULL;
 
 	read_lock_bh(&table->tb6_lock);
-	fn = fib6_locate(&table->tb6_root, prefix ,prefixlen, NULL, 0);
+	fn = fib6_locate(&table->tb6_root, prefix, prefixlen, NULL, 0);
 	if (!fn)
 		goto out;
 
@@ -1983,7 +1983,7 @@ struct rt6_info *rt6_get_dflt_router(const struct in6_addr *addr, struct net_dev
 		return NULL;
 
 	read_lock_bh(&table->tb6_lock);
-	for (rt = table->tb6_root.leaf; rt; rt=rt->dst.rt6_next) {
+	for (rt = table->tb6_root.leaf; rt; rt = rt->dst.rt6_next) {
 		if (dev == rt->dst.dev &&
 		    ((rt->rt6i_flags & (RTF_ADDRCONF | RTF_DEFAULT)) == (RTF_ADDRCONF | RTF_DEFAULT)) &&
 		    ipv6_addr_equal(&rt->rt6i_gateway, addr))
@@ -2068,7 +2068,7 @@ int ipv6_route_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	struct in6_rtmsg rtmsg;
 	int err;
 
-	switch(cmd) {
+	switch (cmd) {
 	case SIOCADDRT:		/* Add a route */
 	case SIOCDELRT:		/* Delete a route */
 		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
@@ -2191,7 +2191,7 @@ int ip6_route_get_saddr(struct net *net,
 			unsigned int prefs,
 			struct in6_addr *saddr)
 {
-	struct inet6_dev *idev = ip6_dst_idev((struct dst_entry*)rt);
+	struct inet6_dev *idev = ip6_dst_idev((struct dst_entry *)rt);
 	int err = 0;
 	if (rt->rt6i_prefsrc.plen)
 		*saddr = rt->rt6i_prefsrc.addr;
@@ -2486,7 +2486,7 @@ beginning:
 	return last_err;
 }
 
-static int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh)
+static int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct fib6_config cfg;
 	int err;
@@ -2501,7 +2501,7 @@ static int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh)
 		return ip6_route_del(&cfg);
 }
 
-static int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh)
+static int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct fib6_config cfg;
 	int err;
@@ -2693,7 +2693,7 @@ int rt6_dump_route(struct rt6_info *rt, void *p_arg)
 		     prefix, 0, NLM_F_MULTI);
 }
 
-static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh)
+static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct nlattr *tb[RTA_MAX+1];
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 6163f85..86e3fa8 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -812,9 +812,9 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	const struct ipv6hdr *iph6 = ipv6_hdr(skb);
 	u8     tos = tunnel->parms.iph.tos;
 	__be16 df = tiph->frag_off;
-	struct rtable *rt;     			/* Route to the other host */
-	struct net_device *tdev;		/* Device to other host */
-	unsigned int max_headroom;		/* The extra header space needed */
+	struct rtable *rt;		/* Route to the other host */
+	struct net_device *tdev;	/* Device to other host */
+	unsigned int max_headroom;	/* The extra header space needed */
 	__be32 dst = tiph->daddr;
 	struct flowi4 fl4;
 	int    mtu;
@@ -1123,7 +1123,7 @@ static int ipip6_tunnel_update_6rd(struct ip_tunnel *t,
 #endif
 
 static int
-ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
+ipip6_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	int err = 0;
 	struct ip_tunnel_parm p;
@@ -1339,10 +1339,10 @@ static void ipip6_dev_free(struct net_device *dev)
 static void ipip6_tunnel_setup(struct net_device *dev)
 {
 	dev->netdev_ops		= &ipip6_netdev_ops;
-	dev->destructor 	= ipip6_dev_free;
+	dev->destructor		= ipip6_dev_free;
 
 	dev->type		= ARPHRD_SIT;
-	dev->hard_header_len 	= LL_MAX_HEADER + sizeof(struct iphdr);
+	dev->hard_header_len	= LL_MAX_HEADER + sizeof(struct iphdr);
 	dev->mtu		= ETH_DATA_LEN - sizeof(struct iphdr);
 	dev->flags		= IFF_NOARP;
 	dev->priv_flags	       &= ~IFF_XMIT_DST_RELEASE;
diff --git a/net/ipv6/tunnel6.c b/net/ipv6/tunnel6.c
index 2c4e4c5..7a53d39 100644
--- a/net/ipv6/tunnel6.c
+++ b/net/ipv6/tunnel6.c
@@ -15,7 +15,7 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * Authors	Mitsuru KANDA  <mk@linux-ipv6.org>
- * 		YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
+ *		YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
  */
 
 #define pr_fmt(fmt) "IPv6: " fmt
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 25ffe73..12fcce8f 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -373,8 +373,8 @@ EXPORT_SYMBOL_GPL(udp6_lib_lookup);
 
 
 /*
- * 	This should be easy, if there is something there we
- * 	return it, otherwise we block.
+ *	This should be easy, if there is something there we
+ *	return it, otherwise we block.
  */
 
 int udpv6_recvmsg(struct kiocb *iocb, struct sock *sk,
@@ -530,7 +530,7 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	const struct ipv6hdr *hdr = (const struct ipv6hdr *)skb->data;
 	const struct in6_addr *saddr = &hdr->saddr;
 	const struct in6_addr *daddr = &hdr->daddr;
-	struct udphdr *uh = (struct udphdr*)(skb->data+offset);
+	struct udphdr *uh = (struct udphdr *)(skb->data+offset);
 	struct sock *sk;
 	int err;
 	struct net *net = dev_net(skb->dev);
@@ -596,7 +596,7 @@ static int __udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 static __inline__ void udpv6_err(struct sk_buff *skb,
 				 struct inet6_skb_parm *opt, u8 type,
-				 u8 code, int offset, __be32 info     )
+				 u8 code, int offset, __be32 info)
 {
 	__udp6_lib_err(skb, opt, type, code, offset, info, &udp_table);
 }
@@ -960,10 +960,10 @@ static void udp_v6_flush_pending_frames(struct sock *sk)
 }
 
 /**
- * 	udp6_hwcsum_outgoing  -  handle outgoing HW checksumming
- * 	@sk: 	socket we are sending on
- * 	@skb: 	sk_buff containing the filled-in UDP header
- * 	        (checksum field must be zeroed out)
+ *	udp6_hwcsum_outgoing  -  handle outgoing HW checksumming
+ *	@sk:	socket we are sending on
+ *	@skb:	sk_buff containing the filled-in UDP header
+ *		(checksum field must be zeroed out)
  */
 static void udp6_hwcsum_outgoing(struct sock *sk, struct sk_buff *skb,
 				 const struct in6_addr *saddr,
@@ -1294,7 +1294,7 @@ do_append_data:
 	getfrag  =  is_udplite ?  udplite_getfrag : ip_generic_getfrag;
 	err = ip6_append_data(sk, getfrag, msg->msg_iov, ulen,
 		sizeof(struct udphdr), hlimit, tclass, opt, &fl6,
-		(struct rt6_info*)dst,
+		(struct rt6_info *)dst,
 		corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags, dontfrag);
 	if (err)
 		udp_v6_flush_pending_frames(sk);
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index f8c3cf8..cd4c98c 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -3,8 +3,8 @@
  *
  * Authors:
  *	Mitsuru KANDA @USAGI
- * 	Kazunori MIYAZAWA @USAGI
- * 	Kunihiro Ishiguro <kunihiro@ipinfusion.com>
+ *	Kazunori MIYAZAWA @USAGI
+ *	Kunihiro Ishiguro <kunihiro@ipinfusion.com>
  *	YOSHIFUJI Hideaki @USAGI
  *		IPv6 support
  */
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 2a0bbda..ac49f84 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -3,11 +3,11 @@
  *
  * Authors:
  *	Mitsuru KANDA @USAGI
- * 	Kazunori MIYAZAWA @USAGI
- * 	Kunihiro Ishiguro <kunihiro@ipinfusion.com>
- * 		IPv6 support
- * 	YOSHIFUJI Hideaki
- * 		Split up af-specific portion
+ *	Kazunori MIYAZAWA @USAGI
+ *	Kunihiro Ishiguro <kunihiro@ipinfusion.com>
+ *		IPv6 support
+ *	YOSHIFUJI Hideaki
+ *		Split up af-specific portion
  *
  */
 
@@ -84,7 +84,7 @@ static int xfrm6_init_path(struct xfrm_dst *path, struct dst_entry *dst,
 			   int nfheader_len)
 {
 	if (dst->ops->family == AF_INET6) {
-		struct rt6_info *rt = (struct rt6_info*)dst;
+		struct rt6_info *rt = (struct rt6_info *)dst;
 		if (rt->rt6i_node)
 			path->path_cookie = rt->rt6i_node->fn_sernum;
 	}
@@ -97,7 +97,7 @@ static int xfrm6_init_path(struct xfrm_dst *path, struct dst_entry *dst,
 static int xfrm6_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 			  const struct flowi *fl)
 {
-	struct rt6_info *rt = (struct rt6_info*)xdst->route;
+	struct rt6_info *rt = (struct rt6_info *)xdst->route;
 
 	xdst->u.dst.dev = dev;
 	dev_hold(dev);
@@ -296,7 +296,7 @@ static struct xfrm_policy_afinfo xfrm6_policy_afinfo = {
 	.family =		AF_INET6,
 	.dst_ops =		&xfrm6_dst_ops,
 	.dst_lookup =		xfrm6_dst_lookup,
-	.get_saddr = 		xfrm6_get_saddr,
+	.get_saddr =		xfrm6_get_saddr,
 	.decode_session =	_decode_session6,
 	.get_tos =		xfrm6_get_tos,
 	.init_dst =		xfrm6_init_dst,
@@ -319,9 +319,9 @@ static void xfrm6_policy_fini(void)
 static struct ctl_table xfrm6_policy_table[] = {
 	{
 		.procname       = "xfrm6_gc_thresh",
-		.data	   	= &init_net.xfrm.xfrm6_dst_ops.gc_thresh,
-		.maxlen	 	= sizeof(int),
-		.mode	   	= 0644,
+		.data		= &init_net.xfrm.xfrm6_dst_ops.gc_thresh,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
 		.proc_handler   = proc_dointvec,
 	},
 	{ }
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index 3fc9701..8a1f9c0 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -3,11 +3,11 @@
  *
  * Authors:
  *	Mitsuru KANDA @USAGI
- * 	Kazunori MIYAZAWA @USAGI
- * 	Kunihiro Ishiguro <kunihiro@ipinfusion.com>
- * 		IPv6 support
- * 	YOSHIFUJI Hideaki @USAGI
- * 		Split up af-specific portion
+ *	Kazunori MIYAZAWA @USAGI
+ *	Kunihiro Ishiguro <kunihiro@ipinfusion.com>
+ *		IPv6 support
+ *	YOSHIFUJI Hideaki @USAGI
+ *		Split up af-specific portion
  *
  */
 
@@ -45,10 +45,10 @@ xfrm6_init_temprop(struct xfrm_state *x, const struct xfrm_tmpl *tmpl,
 		   const xfrm_address_t *daddr, const xfrm_address_t *saddr)
 {
 	x->id = tmpl->id;
-	if (ipv6_addr_any((struct in6_addr*)&x->id.daddr))
+	if (ipv6_addr_any((struct in6_addr *)&x->id.daddr))
 		memcpy(&x->id.daddr, daddr, sizeof(x->sel.daddr));
 	memcpy(&x->props.saddr, &tmpl->saddr, sizeof(x->props.saddr));
-	if (ipv6_addr_any((struct in6_addr*)&x->props.saddr))
+	if (ipv6_addr_any((struct in6_addr *)&x->props.saddr))
 		memcpy(&x->props.saddr, saddr, sizeof(x->props.saddr));
 	x->props.mode = tmpl->mode;
 	x->props.reqid = tmpl->reqid;
diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index 1c66465..7b2508b 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -15,7 +15,7 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * Authors	Mitsuru KANDA  <mk@linux-ipv6.org>
- * 		YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
+ *		YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
  *
  * Based on net/ipv4/xfrm4_tunnel.c
  *
-- 
1.7.9.5
