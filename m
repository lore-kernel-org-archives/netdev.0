From: Jianjun Kong <jianjun@zeuux.org>
Subject: [PATCH 1/4] nets: clean up net/ipv4/ip_fragment.c tcp_timer.c
	ip_input.c
Date: Mon, 3 Nov 2008 18:41:38 +0800
Message-ID: <20081103104138.GB19058@ubuntu>
References: <20081102074446.GA12140@ubuntu> <490DEAD3.3030202@cosmosbay.com> <20081103082002.GG14553@ubuntu> <20081103.002808.142907024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeuux.org ([210.51.160.52]:64607 "EHLO z.billxu.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754965AbYKCKlc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 05:41:32 -0500
Content-Disposition: inline
In-Reply-To: <20081103.002808.142907024.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[PATCH 1/4] clean up 'net/ipv4/ip_fragment.c tcp_timer.c ip_input.c' about code style.

Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
---
 net/ipv4/ip_fragment.c |    2 +-
 net/ipv4/ip_input.c    |    4 ++--
 net/ipv4/tcp_timer.c   |    4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 8c495e3..1a3c37b 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -56,7 +56,7 @@ struct ipfrag_skb_cb
 	int			offset;
 };
 
-#define FRAG_CB(skb)	((struct ipfrag_skb_cb*)((skb)->cb))
+#define FRAG_CB(skb)	((struct ipfrag_skb_cb *)((skb)->cb))
 
 /* Describe an entry in the "incomplete datagrams" queue. */
 struct ipq {
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 1b6475c..70bedab 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -340,9 +340,9 @@ static int ip_rcv_finish(struct sk_buff *skb)
 		struct ip_rt_acct *st = per_cpu_ptr(ip_rt_acct, smp_processor_id());
 		u32 idx = skb->dst->tclassid;
 		st[idx&0xFF].o_packets++;
-		st[idx&0xFF].o_bytes+=skb->len;
+		st[idx&0xFF].o_bytes += skb->len;
 		st[(idx>>16)&0xFF].i_packets++;
-		st[(idx>>16)&0xFF].i_bytes+=skb->len;
+		st[(idx>>16)&0xFF].i_bytes += skb->len;
 	}
 #endif
 
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 9843f6c..3df339e 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -171,7 +171,7 @@ static int tcp_write_timeout(struct sock *sk)
 
 static void tcp_delack_timer(unsigned long data)
 {
-	struct sock *sk = (struct sock*)data;
+	struct sock *sk = (struct sock *)data;
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 
@@ -396,7 +396,7 @@ out:;
 
 static void tcp_write_timer(unsigned long data)
 {
-	struct sock *sk = (struct sock*)data;
+	struct sock *sk = (struct sock *)data;
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	int event;
 
-- 
1.5.6.3

