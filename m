From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH v2 3/4] tcp: fix the indentation in timer calculation of
 /proc/net/tcp
Date: Mon, 18 Mar 2013 21:46:20 +0900
Message-ID: <1363610780.7791.5.camel@ubuntu-vm-makita>
References: <1363610163.7121.2.camel@ubuntu-vm-makita>
	 <1363610344.7121.5.camel@ubuntu-vm-makita>
	 <1363610615.7791.2.camel@ubuntu-vm-makita>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:41648 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330Ab3CRMq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 08:46:27 -0400
In-Reply-To: <1363610615.7791.2.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the indentation in get_tcp4_sock and get_tcp6_sock.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/ipv4/tcp_ipv4.c |   12 ++++++------
 net/ipv6/tcp_ipv6.c |   12 ++++++------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 86a0685..6f0ae53 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2660,11 +2660,11 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
 	int rx_queue;
 
 	if (icsk->icsk_pending == ICSK_TIME_RETRANS) {
-		timer_active	= 1;
-		timer_expires	= icsk->icsk_timeout;
+		timer_active		= 1;
+		timer_expires		= icsk->icsk_timeout;
 	} else if (icsk->icsk_pending == ICSK_TIME_PROBE0) {
-		timer_active	= 4;
-		timer_expires	= icsk->icsk_timeout;
+		timer_active		= 4;
+		timer_expires		= icsk->icsk_timeout;
 	} else if (timer_pending(&sk->sk_timer)) {
 		if (sk->sk_state == TCP_FIN_WAIT2 && sock_flag(sk, SOCK_DEAD)) {
 			timer_active	= 3;
@@ -2676,8 +2676,8 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
 			timer_expires	= sk->sk_timer.expires;
 		}
 	} else {
-		timer_active	= 0;
-		timer_expires = jiffies;
+		timer_active		= 0;
+		timer_expires		= jiffies;
 	}
 
 	if (sk->sk_state == TCP_LISTEN)
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index b74b133..78cdb81 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1805,11 +1805,11 @@ static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
 	srcp  = ntohs(inet->inet_sport);
 
 	if (icsk->icsk_pending == ICSK_TIME_RETRANS) {
-		timer_active	= 1;
-		timer_expires	= icsk->icsk_timeout;
+		timer_active		= 1;
+		timer_expires		= icsk->icsk_timeout;
 	} else if (icsk->icsk_pending == ICSK_TIME_PROBE0) {
-		timer_active	= 4;
-		timer_expires	= icsk->icsk_timeout;
+		timer_active		= 4;
+		timer_expires		= icsk->icsk_timeout;
 	} else if (timer_pending(&sp->sk_timer)) {
 		if (sp->sk_state == TCP_FIN_WAIT2 && sock_flag(sp, SOCK_DEAD)) {
 			timer_active	= 3;
@@ -1821,8 +1821,8 @@ static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
 			timer_expires	= sp->sk_timer.expires;
 		}
 	} else {
-		timer_active	= 0;
-		timer_expires = jiffies;
+		timer_active		= 0;
+		timer_expires		= jiffies;
 	}
 
 	seq_printf(seq,
-- 
1.7.10.4
