From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/17) pppoe -- size_t in send/recvmsg
Date: Fri, 9 Jan 2004 13:42:15 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040109134215.14fbcf8a@linux.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Michal Ostrowski <mostrows@styx.uwaterloo.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert PPPoe for size_t in send/recv msg

diff -Nru a/drivers/net/pppoe.c b/drivers/net/pppoe.c
--- a/drivers/net/pppoe.c	Mon Dec  8 16:19:40 2003
+++ b/drivers/net/pppoe.c	Mon Dec  8 16:19:40 2003
@@ -775,8 +775,8 @@
 }
 
 
-static int pppoe_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
-		  int total_len)
+static int pppoe_sendmsg(struct kiocb *iocb, struct socket *sock, 
+		  struct msghdr *m, size_t total_len)
 {
 	struct sk_buff *skb = NULL;
 	struct sock *sk = sock->sk;
@@ -939,7 +939,7 @@
 };
 
 static int pppoe_recvmsg(struct kiocb *iocb, struct socket *sock,
-		  struct msghdr *m, int total_len, int flags)
+		  struct msghdr *m, size_t total_len, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb = NULL;
