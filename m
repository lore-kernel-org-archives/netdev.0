From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (5/17) ddp -- size_t for send/recvmsg
Date: Fri, 9 Jan 2004 13:44:36 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040109134436.6aa8fe1f@linux.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Change send/recvmsg to match prototype change in sock.h

diff -Nru a/net/appletalk/ddp.c b/net/appletalk/ddp.c
--- a/net/appletalk/ddp.c	Mon Dec  8 16:19:43 2003
+++ b/net/appletalk/ddp.c	Mon Dec  8 16:19:43 2003
@@ -1552,7 +1552,7 @@
 }
 
 static int atalk_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-			 int len)
+			 size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct atalk_sock *at = at_sk(sk);
@@ -1712,7 +1712,7 @@
 }
 
 static int atalk_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-			 int size, int flags)
+			 size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct sockaddr_at *sat = (struct sockaddr_at *)msg->msg_name;
