From: Chen Weilong <chenweilong@huawei.com>
Subject: [patch net-next v2 1/7] ipv4: do clean up with spaces
Date: Mon, 23 Dec 2013 10:14:10 +0800
Message-ID: <1387764856-13948-2-git-send-email-chenweilong@huawei.com>
References: <1387764856-13948-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<pablo@netfilter.org>, <kadlec@blackhole.kfki.hu>,
	<steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:27420 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755949Ab3LWCOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 21:14:52 -0500
In-Reply-To: <1387764856-13948-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

Fix checkpatch errors like:
ERROR: spaces required around that XXX

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/ipv4/ip_options.c | 12 ++++++------
 net/ipv4/tcp_input.c  |  4 ++--
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index ec72645..dd9d90b 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -167,7 +167,7 @@ int ip_options_echo(struct ip_options *dopt, struct sk_buff *skb)
 		soffset -= 4;
 		if (soffset > 3) {
 			memcpy(&faddr, &start[soffset-1], 4);
-			for (soffset-=4, doffset=4; soffset > 3; soffset-=4, doffset+=4)
+			for (soffset -= 4, doffset = 4; soffset > 3; soffset -= 4, doffset += 4)
 				memcpy(&dptr[doffset-1], &start[soffset-1], 4);
 			/*
 			 * RFC1812 requires to fix illegal source routes.
@@ -227,7 +227,7 @@ void ip_options_fragment(struct sk_buff *skb)
 			continue;
 		}
 		optlen = optptr[1];
-		if (optlen<2 || optlen>l)
+		if (optlen < 2 || optlen > l)
 		  return;
 		if (!IPOPT_COPIED(*optptr))
 			memset(optptr, IPOPT_NOOP, optlen);
@@ -276,7 +276,7 @@ int ip_options_compile(struct net *net,
 	for (l = opt->optlen; l > 0; ) {
 		switch (*optptr) {
 		      case IPOPT_END:
-			for (optptr++, l--; l>0; optptr++, l--) {
+			for (optptr++, l--; l > 0; optptr++, l--) {
 				if (*optptr != IPOPT_END) {
 					*optptr = IPOPT_END;
 					opt->is_changed = 1;
@@ -289,7 +289,7 @@ int ip_options_compile(struct net *net,
 			continue;
 		}
 		optlen = optptr[1];
-		if (optlen<2 || optlen>l) {
+		if (optlen < 2 || optlen > l) {
 			pp_ptr = optptr;
 			goto error;
 		}
@@ -572,7 +572,7 @@ void ip_forward_options(struct sk_buff *skb)
 
 		optptr = raw + opt->srr;
 
-		for ( srrptr=optptr[2], srrspace = optptr[1];
+		for ( srrptr = optptr[2], srrspace = optptr[1];
 		     srrptr <= srrspace;
 		     srrptr += 4
 		     ) {
@@ -628,7 +628,7 @@ int ip_options_rcv_srr(struct sk_buff *skb)
 	if (rt->rt_type != RTN_LOCAL)
 		return -EINVAL;
 
-	for (srrptr=optptr[2], srrspace = optptr[1]; srrptr <= srrspace; srrptr += 4) {
+	for (srrptr = optptr[2], srrspace = optptr[1]; srrptr <= srrspace; srrptr += 4) {
 		if (srrptr + 3 > srrspace) {
 			icmp_send(skb, ICMP_PARAMETERPROB, 0, htonl((opt->srr+2)<<24));
 			return -EINVAL;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c53b7f3..f75cf15 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3686,7 +3686,7 @@ const u8 *tcp_parse_md5sig_option(const struct tcphdr *th)
 		int opcode = *ptr++;
 		int opsize;
 
-		switch(opcode) {
+		switch (opcode) {
 		case TCPOPT_EOL:
 			return NULL;
 		case TCPOPT_NOP:
@@ -4046,7 +4046,7 @@ static void tcp_sack_remove(struct tcp_sock *tp)
 			WARN_ON(before(tp->rcv_nxt, sp->end_seq));
 
 			/* Zap this SACK, by moving forward any other SACKS. */
-			for (i=this_sack+1; i < num_sacks; i++)
+			for (i = this_sack+1; i < num_sacks; i++)
 				tp->selective_acks[i-1] = tp->selective_acks[i];
 			num_sacks--;
 			continue;
-- 
1.7.12
