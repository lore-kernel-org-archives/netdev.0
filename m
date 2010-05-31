From: Joe Perches <joe@perches.com>
Subject: [PATCH] net/ipv4/tcp_input.c: fix compilation breakage when
 FASTRETRANS_DEBUG > 1
Date: Mon, 31 May 2010 11:20:55 -0700
Message-ID: <1275330055.14079.8.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2459 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754760Ab0EaSU5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 May 2010 14:20:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit: c720c7e8383aff1cb219bddf474ed89d850336e3 missed these.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv4/tcp_input.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 3e6dafc..548d575 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2639,7 +2639,7 @@ static void DBGUNDO(struct sock *sk, const char *msg)
 	if (sk->sk_family == AF_INET) {
 		printk(KERN_DEBUG "Undo %s %pI4/%u c%u l%u ss%u/%u p%u\n",
 		       msg,
-		       &inet->daddr, ntohs(inet->dport),
+		       &inet->inet_daddr, ntohs(inet->inet_dport),
 		       tp->snd_cwnd, tcp_left_out(tp),
 		       tp->snd_ssthresh, tp->prior_ssthresh,
 		       tp->packets_out);
@@ -2649,7 +2649,7 @@ static void DBGUNDO(struct sock *sk, const char *msg)
 		struct ipv6_pinfo *np = inet6_sk(sk);
 		printk(KERN_DEBUG "Undo %s %pI6/%u c%u l%u ss%u/%u p%u\n",
 		       msg,
-		       &np->daddr, ntohs(inet->dport),
+		       &np->daddr, ntohs(inet->inet_dport),
 		       tp->snd_cwnd, tcp_left_out(tp),
 		       tp->snd_ssthresh, tp->prior_ssthresh,
 		       tp->packets_out);


