From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH 3/4] IPV6: checkpatch corrections
Date: Sat, 16 Aug 2014 13:04:46 +0100
Message-ID: <1408190687-28941-3-git-send-email-ipm@chirality.org.uk>
References: <1408190687-28941-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:43162 "EHLO
	oak.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751531AbaHPME7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Aug 2014 08:04:59 -0400
In-Reply-To: <1408190687-28941-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

removing blank lines between function close brace and EXPORT_SYMBOL
no differences according to objdump

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv6/inet6_connection_sock.c |    4 ----
 net/ipv6/inet6_hashtables.c      |    3 ---
 net/ipv6/ip6_flowlabel.c         |    1 -
 net/ipv6/ip6_output.c            |    1 -
 net/ipv6/ipv6_sockglue.c         |    4 ----
 net/ipv6/ndisc.c                 |    1 -
 net/ipv6/route.c                 |    2 --
 net/ipv6/tunnel6.c               |    2 --
 net/ipv6/xfrm6_input.c           |    2 --
 net/ipv6/xfrm6_output.c          |    1 -
 net/ipv6/xfrm6_tunnel.c          |    2 --
 11 files changed, 23 deletions(-)

diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 8c33a0b..29b3220 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -63,7 +63,6 @@ int inet6_csk_bind_conflict(const struct sock *sk,
 
 	return sk2 != NULL;
 }
-
 EXPORT_SYMBOL_GPL(inet6_csk_bind_conflict);
 
 struct dst_entry *inet6_csk_route_req(struct sock *sk,
@@ -144,7 +143,6 @@ struct request_sock *inet6_csk_search_req(const struct sock *sk,
 
 	return NULL;
 }
-
 EXPORT_SYMBOL_GPL(inet6_csk_search_req);
 
 void inet6_csk_reqsk_queue_hash_add(struct sock *sk,
@@ -160,7 +158,6 @@ void inet6_csk_reqsk_queue_hash_add(struct sock *sk,
 	reqsk_queue_hash_req(&icsk->icsk_accept_queue, h, req, timeout);
 	inet_csk_reqsk_queue_added(sk, timeout);
 }
-
 EXPORT_SYMBOL_GPL(inet6_csk_reqsk_queue_hash_add);
 
 void inet6_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr)
@@ -175,7 +172,6 @@ void inet6_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr)
 	sin6->sin6_scope_id = ipv6_iface_scope_id(&sin6->sin6_addr,
 						  sk->sk_bound_dev_if);
 }
-
 EXPORT_SYMBOL_GPL(inet6_csk_addr2sockaddr);
 
 static inline
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index f172907..22dfc36 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -222,7 +222,6 @@ begin:
 	rcu_read_unlock();
 	return result;
 }
-
 EXPORT_SYMBOL_GPL(inet6_lookup_listener);
 
 struct sock *inet6_lookup(struct net *net, struct inet_hashinfo *hashinfo,
@@ -238,7 +237,6 @@ struct sock *inet6_lookup(struct net *net, struct inet_hashinfo *hashinfo,
 
 	return sk;
 }
-
 EXPORT_SYMBOL_GPL(inet6_lookup);
 
 static int __inet6_check_established(struct inet_timewait_death_row *death_row,
@@ -324,5 +322,4 @@ int inet6_hash_connect(struct inet_timewait_death_row *death_row,
 	return __inet_hash_connect(death_row, sk, inet6_sk_port_offset(sk),
 			__inet6_check_established, __inet6_hash);
 }
-
 EXPORT_SYMBOL_GPL(inet6_hash_connect);
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 2ace474..3dd7d4e 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -259,7 +259,6 @@ struct ip6_flowlabel *fl6_sock_lookup(struct sock *sk, __be32 label)
 	rcu_read_unlock_bh();
 	return NULL;
 }
-
 EXPORT_SYMBOL_GPL(fl6_sock_lookup);
 
 void fl6_free_socklist(struct sock *sk)
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 4ead554..b7a3e7b 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -233,7 +233,6 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 	kfree_skb(skb);
 	return -EMSGSIZE;
 }
-
 EXPORT_SYMBOL(ip6_xmit);
 
 static int ip6_call_ra_chain(struct sk_buff *skb, int sel)
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 64177ef..e1a9583 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -873,7 +873,6 @@ int ipv6_setsockopt(struct sock *sk, int level, int optname,
 #endif
 	return err;
 }
-
 EXPORT_SYMBOL(ipv6_setsockopt);
 
 #ifdef CONFIG_COMPAT
@@ -909,7 +908,6 @@ int compat_ipv6_setsockopt(struct sock *sk, int level, int optname,
 #endif
 	return err;
 }
-
 EXPORT_SYMBOL(compat_ipv6_setsockopt);
 #endif
 
@@ -1321,7 +1319,6 @@ int ipv6_getsockopt(struct sock *sk, int level, int optname,
 #endif
 	return err;
 }
-
 EXPORT_SYMBOL(ipv6_getsockopt);
 
 #ifdef CONFIG_COMPAT
@@ -1364,7 +1361,6 @@ int compat_ipv6_getsockopt(struct sock *sk, int level, int optname,
 #endif
 	return err;
 }
-
 EXPORT_SYMBOL(compat_ipv6_getsockopt);
 #endif
 
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 995a829..4cb45c1 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -284,7 +284,6 @@ int ndisc_mc_map(const struct in6_addr *addr, char *buf, struct net_device *dev,
 	}
 	return -EINVAL;
 }
-
 EXPORT_SYMBOL(ndisc_mc_map);
 
 static u32 ndisc_hash(const void *pkey,
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 76c7930..f74b041 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -843,7 +843,6 @@ struct rt6_info *rt6_lookup(struct net *net, const struct in6_addr *daddr,
 
 	return NULL;
 }
-
 EXPORT_SYMBOL(rt6_lookup);
 
 /* ip6_ins_rt is called with FREE table->tb6_lock.
@@ -1041,7 +1040,6 @@ struct dst_entry *ip6_route_output(struct net *net, const struct sock *sk,
 
 	return fib6_rule_lookup(net, fl6, flags, ip6_pol_route_output);
 }
-
 EXPORT_SYMBOL(ip6_route_output);
 
 struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_orig)
diff --git a/net/ipv6/tunnel6.c b/net/ipv6/tunnel6.c
index 7a53d39..3c75800 100644
--- a/net/ipv6/tunnel6.c
+++ b/net/ipv6/tunnel6.c
@@ -64,7 +64,6 @@ err:
 
 	return ret;
 }
-
 EXPORT_SYMBOL(xfrm6_tunnel_register);
 
 int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler, unsigned short family)
@@ -92,7 +91,6 @@ int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler, unsigned short family)
 
 	return ret;
 }
-
 EXPORT_SYMBOL(xfrm6_tunnel_deregister);
 
 #define for_each_tunnel_rcu(head, handler)		\
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index cd4c98c..f48fbe4 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -52,7 +52,6 @@ int xfrm6_rcv(struct sk_buff *skb)
 	return xfrm6_rcv_spi(skb, skb_network_header(skb)[IP6CB(skb)->nhoff],
 			     0);
 }
-
 EXPORT_SYMBOL(xfrm6_rcv);
 
 int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
@@ -142,5 +141,4 @@ int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 drop:
 	return -1;
 }
-
 EXPORT_SYMBOL(xfrm6_input_addr);
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 433672d..ca3f29b 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -25,7 +25,6 @@ int xfrm6_find_1stfragopt(struct xfrm_state *x, struct sk_buff *skb,
 {
 	return ip6_find_1stfragopt(skb, prevhdr);
 }
-
 EXPORT_SYMBOL(xfrm6_find_1stfragopt);
 
 static int xfrm6_local_dontfrag(struct sk_buff *skb)
diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index 7b2508b..5743044 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -110,7 +110,6 @@ __be32 xfrm6_tunnel_spi_lookup(struct net *net, const xfrm_address_t *saddr)
 	rcu_read_unlock_bh();
 	return htonl(spi);
 }
-
 EXPORT_SYMBOL(xfrm6_tunnel_spi_lookup);
 
 static int __xfrm6_tunnel_spi_check(struct net *net, u32 spi)
@@ -187,7 +186,6 @@ __be32 xfrm6_tunnel_alloc_spi(struct net *net, xfrm_address_t *saddr)
 
 	return htonl(spi);
 }
-
 EXPORT_SYMBOL(xfrm6_tunnel_alloc_spi);
 
 static void x6spi_destroy_rcu(struct rcu_head *head)
-- 
1.7.9.5
