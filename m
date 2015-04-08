From: Sheng Yong <shengyong1@huawei.com>
Subject: [RFC PATCH 2/2] net: remove extra newlines
Date: Wed, 8 Apr 2015 01:26:18 +0000
Message-ID: <1428456378-122783-2-git-send-email-shengyong1@huawei.com>
References: <1428456378-122783-1-git-send-email-shengyong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <yoshfuji@linux-ipv6.org>,
	<kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>, <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:11438 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753184AbbDHB0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 21:26:37 -0400
In-Reply-To: <1428456378-122783-1-git-send-email-shengyong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sheng Yong <shengyong1@huawei.com>
---
 include/net/ipv6.h   | 2 --
 net/core/skbuff.c    | 1 -
 net/ipv4/ip_output.c | 3 ---
 net/ipv4/udp.c       | 5 -----
 net/ipv6/udp.c       | 3 ---
 5 files changed, 14 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 679c5e2..70e9585 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -47,8 +47,6 @@
 
 #define NEXTHDR_MAX		255
 
-
-
 #define IPV6_DEFAULT_HOPLIMIT   64
 #define IPV6_DEFAULT_MCASTHOPS	1
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 10995a4..4dc2f99 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3750,7 +3750,6 @@ void skb_complete_wifi_ack(struct sk_buff *skb, bool acked)
 }
 EXPORT_SYMBOL_GPL(skb_complete_wifi_ack);
 
-
 /**
  * skb_partial_csum_set - set up and verify partial csum values for packet
  * @skb: the skb to set
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index d5c5955..48d6684 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -449,7 +449,6 @@ no_route:
 }
 EXPORT_SYMBOL(ip_queue_xmit);
 
-
 static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 {
 	to->pkt_type = from->pkt_type;
@@ -812,7 +811,6 @@ static inline int ip_ufo_append_data(struct sock *sk,
 
 		skb->csum = 0;
 
-
 		__skb_queue_tail(queue, skb);
 	} else if (skb_is_gso(skb)) {
 		goto append;
@@ -1208,7 +1206,6 @@ ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
 		skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
 	}
 
-
 	while (size > 0) {
 		int i;
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index d1fc362..6263737 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -433,7 +433,6 @@ static u32 udp_ehashfn(const struct net *net, const __be32 laddr,
 			      udp_ehash_secret + net_hash_mix(net));
 }
 
-
 /* called with read_rcu_lock() */
 static struct sock *udp4_lib_lookup2(struct net *net,
 		__be32 saddr, __be16 sport,
@@ -1171,7 +1170,6 @@ out:
 	return ret;
 }
 
-
 /**
  *	first_packet_length	- return length of first packet in receive queue
  *	@sk: socket
@@ -1355,7 +1353,6 @@ csum_copy_err:
 	goto try_again;
 }
 
-
 int udp_disconnect(struct sock *sk, int flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
@@ -1579,7 +1576,6 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	    udp_lib_checksum_complete(skb))
 		goto csum_error;
 
-
 	if (sk_rcvqueues_full(sk, sk->sk_rcvbuf)) {
 		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_RCVBUFERRORS,
 				 is_udplite);
@@ -1609,7 +1605,6 @@ drop:
 	return -1;
 }
 
-
 static void flush_stack(struct sock **stack, unsigned int count,
 			struct sk_buff *skb, unsigned int final)
 {
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 5f0f05f..06839a9 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -120,7 +120,6 @@ static u32 udp6_portaddr_hash(const struct net *net,
 	return hash ^ port;
 }
 
-
 int udp_v6_get_port(struct sock *sk, unsigned short snum)
 {
 	unsigned int hash2_nulladdr =
@@ -385,7 +384,6 @@ struct sock *udp6_lib_lookup(struct net *net, const struct in6_addr *saddr, __be
 }
 EXPORT_SYMBOL_GPL(udp6_lib_lookup);
 
-
 /*
  *	This should be easy, if there is something there we
  *	return it, otherwise we block.
@@ -1555,7 +1553,6 @@ static struct inet_protosw udpv6_protosw = {
 	.flags =     INET_PROTOSW_PERMANENT,
 };
 
-
 int __init udpv6_init(void)
 {
 	int ret;
-- 
1.8.3.4
