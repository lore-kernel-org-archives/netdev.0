From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ipv4 use static in several places (trivial)
Date: Wed, 28 Apr 2004 11:16:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040428111641.7e40de54@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

More functions and data that should be static.

diff -Nru a/net/ipv4/devinet.c b/net/ipv4/devinet.c
--- a/net/ipv4/devinet.c	Wed Apr 28 10:49:55 2004
+++ b/net/ipv4/devinet.c	Wed Apr 28 10:49:55 2004
@@ -998,7 +998,7 @@
 	return NOTIFY_DONE;
 }
 
-struct notifier_block ip_netdev_notifier = {
+static struct notifier_block ip_netdev_notifier = {
 	.notifier_call =inetdev_event,
 };
 
diff -Nru a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c	Wed Apr 28 10:49:55 2004
+++ b/net/ipv4/tcp.c	Wed Apr 28 10:49:55 2004
@@ -753,9 +753,6 @@
 	goto out;
 }
 
-ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffset,
-			 size_t psize, int flags);
-
 static inline int can_coalesce(struct sk_buff *skb, int i, struct page *page,
 			       int off)
 {
@@ -836,7 +833,7 @@
 	return err;
 }
 
-ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffset,
+static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffset,
 			 size_t psize, int flags)
 {
 	struct tcp_opt *tp = tcp_sk(sk);
diff -Nru a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	Wed Apr 28 10:49:55 2004
+++ b/net/ipv4/tcp_input.c	Wed Apr 28 10:49:55 2004
@@ -1062,7 +1062,7 @@
  * which indicates that we should follow the traditional RTO recovery,
  * i.e. mark everything lost and do go-back-N retransmission.
  */
-void tcp_enter_frto_loss(struct sock *sk)
+static void tcp_enter_frto_loss(struct sock *sk)
 {
 	struct tcp_opt *tp = tcp_sk(sk);
 	struct sk_buff *skb;
