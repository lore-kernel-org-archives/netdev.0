From: Chen Weilong <chenweilong@huawei.com>
Subject: [resend patch net-next v3 2/7] ipv4: fix checkpatch error "space prohibited"
Date: Mon, 23 Dec 2013 14:37:27 +0800
Message-ID: <1387780652-16232-3-git-send-email-chenweilong@huawei.com>
References: <1387780652-16232-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>,
	<netfilter@vger.kernel.org>
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:34618 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509Ab3LWGiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 01:38:25 -0500
In-Reply-To: <1387780652-16232-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/ipv4/inetpeer.c                    |  4 ++--
 net/ipv4/netfilter/nf_nat_snmp_basic.c | 12 ++++++------
 net/ipv4/syncookies.c                  |  2 +-
 net/ipv4/tcp_yeah.c                    |  4 ++--
 4 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 33d5537..d047c88 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -227,7 +227,7 @@ static int addr_compare(const struct inetpeer_addr *a,
 	stackptr = _stack;					\
 	*stackptr++ = &_base->root;				\
 	for (u = rcu_deref_locked(_base->root, _base);		\
-	     u != peer_avl_empty; ) {				\
+	     u != peer_avl_empty;) {				\
 		int cmp = addr_compare(_daddr, &u->daddr);	\
 		if (cmp == 0)					\
 			break;					\
@@ -282,7 +282,7 @@ static struct inet_peer *lookup_rcu(const struct inetpeer_addr *daddr,
 	*stackptr++ = &start->avl_left;				\
 	v = &start->avl_left;					\
 	for (u = rcu_deref_locked(*v, base);			\
-	     u->avl_right != peer_avl_empty_rcu; ) {		\
+	     u->avl_right != peer_avl_empty_rcu;) {		\
 		v = &u->avl_right;				\
 		*stackptr++ = v;				\
 		u = rcu_deref_locked(*v, base);			\
diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index 61a9422..d551e31 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -461,14 +461,14 @@ static unsigned char asn1_oid_decode(struct asn1_ctx *ctx,
 	}
 
 	if (subid < 40) {
-		optr [0] = 0;
-		optr [1] = subid;
+		optr[0] = 0;
+		optr[1] = subid;
 	} else if (subid < 80) {
-		optr [0] = 1;
-		optr [1] = subid - 40;
+		optr[0] = 1;
+		optr[1] = subid - 40;
 	} else {
-		optr [0] = 2;
-		optr [1] = subid - 80;
+		optr[0] = 2;
+		optr[1] = subid - 80;
 	}
 
 	*len = 2;
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index b95331e..f2ed13c 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -121,7 +121,7 @@ static __u32 check_tcp_syn_cookie(__u32 cookie, __be32 saddr, __be32 daddr,
 	cookie -= cookie_hash(saddr, daddr, sport, dport, 0, 0) + sseq;
 
 	/* Cookie is now reduced to (count * 2^24) ^ (hash % 2^24) */
-	diff = (count - (cookie >> COOKIEBITS)) & ((__u32) - 1 >> COOKIEBITS);
+	diff = (count - (cookie >> COOKIEBITS)) & ((__u32) -1 >> COOKIEBITS);
 	if (diff >= MAX_SYNCOOKIE_AGE)
 		return (__u32)-1;
 
diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
index a347a07..20cfaab 100644
--- a/net/ipv4/tcp_yeah.c
+++ b/net/ipv4/tcp_yeah.c
@@ -214,9 +214,9 @@ static u32 tcp_yeah_ssthresh(struct sock *sk) {
 	if (yeah->doing_reno_now < TCP_YEAH_RHO) {
 		reduction = yeah->lastQ;
 
-		reduction = min( reduction, max(tp->snd_cwnd>>1, 2U) );
+		reduction = min(reduction, max(tp->snd_cwnd>>1, 2U));
 
-		reduction = max( reduction, tp->snd_cwnd >> TCP_YEAH_DELTA);
+		reduction = max(reduction, tp->snd_cwnd >> TCP_YEAH_DELTA);
 	} else
 		reduction = max(tp->snd_cwnd>>1, 2U);
 
-- 
1.7.12
