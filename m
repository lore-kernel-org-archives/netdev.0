From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH]: Remove duplicate declarations from netlink.h
Date: Fri, 27 Aug 2004 14:59:55 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <412F304B.7080804@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010607040205020002070909"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010607040205020002070909
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch removes some duplicate delarations from netlink.h.


--------------010607040205020002070909
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/27 14:35:59+02:00 kaber@coreworks.de 
#   [NETLINK]: Remove duplicate declarations
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# include/linux/netlink.h
#   2004/08/27 14:35:21+02:00 kaber@coreworks.de +0 -7
#   [NETLINK]: Remove duplicate declarations
# 
diff -Nru a/include/linux/netlink.h b/include/linux/netlink.h
--- a/include/linux/netlink.h	2004-08-27 14:46:19 +02:00
+++ b/include/linux/netlink.h	2004-08-27 14:46:19 +02:00
@@ -134,13 +134,6 @@
 void netlink_detachskb(struct sock *sk, struct sk_buff *skb);
 int netlink_sendskb(struct sock *sk, struct sk_buff *skb, int protocol);
 
-/* finegrained unicast helpers: */
-struct sock *netlink_getsockbypid(struct sock *ssk, u32 pid);
-struct sock *netlink_getsockbyfilp(struct file *filp);
-int netlink_attachskb(struct sock *sk, struct sk_buff *skb, int nonblock, long timeo);
-void netlink_detachskb(struct sock *sk, struct sk_buff *skb);
-int netlink_sendskb(struct sock *sk, struct sk_buff *skb, int protocol);
-
 /*
  *	skb should fit one page. This choice is good for headerless malloc.
  *

--------------010607040205020002070909--
