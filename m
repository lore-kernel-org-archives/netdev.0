From: Pablo Neira <pablo@eurodev.net>
Subject: [PATCH 1/4] [NETLINK] fix broken indentation in netlink.h
Date: Fri, 11 Feb 2005 01:13:55 +0100
Message-ID: <420BF8C3.3050305@eurodev.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010800010108090902080203"
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010800010108090902080203
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

the subject says all

--
Pablo

--------------010800010108090902080203
Content-Type: text/x-patch;
 name="00ident-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="00ident-fix.patch"

===== include/linux/netlink.h 1.23 vs edited =====
--- 1.23/include/linux/netlink.h	2005-02-07 06:59:39 +01:00
+++ edited/include/linux/netlink.h	2005-02-10 01:16:41 +01:00
@@ -4,11 +4,11 @@
 #include <linux/socket.h> /* for sa_family_t */
 #include <linux/types.h>
 
-#define NETLINK_ROUTE		0	/* Routing/device hook				*/
-#define NETLINK_SKIP		1	/* Reserved for ENskip  			*/
-#define NETLINK_USERSOCK	2	/* Reserved for user mode socket protocols 	*/
-#define NETLINK_FIREWALL	3	/* Firewalling hook				*/
-#define NETLINK_TCPDIAG		4	/* TCP socket monitoring			*/
+#define NETLINK_ROUTE		0	/* Routing/device hook */
+#define NETLINK_SKIP		1	/* Reserved for ENskip */
+#define NETLINK_USERSOCK	2	/* For user mode socket protocols */
+#define NETLINK_FIREWALL	3	/* Firewalling hook */
+#define NETLINK_TCPDIAG		4	/* TCP socket monitoring */
 #define NETLINK_NFLOG		5	/* netfilter/iptables ULOG */
 #define NETLINK_XFRM		6	/* ipsec */
 #define NETLINK_SELINUX		7	/* SELinux event notifications */
@@ -42,8 +42,10 @@
 /* Flags values */
 
 #define NLM_F_REQUEST		1	/* It is request message. 	*/
-#define NLM_F_MULTI		2	/* Multipart message, terminated by NLMSG_DONE */
-#define NLM_F_ACK		4	/* Reply with ack, with zero or error code */
+#define NLM_F_MULTI		2	/* Multipart message, 
+					   terminated by NLMSG_DONE */
+#define NLM_F_ACK		4	/* Reply with ack, with zero or 
+					   error code */
 #define NLM_F_ECHO		8	/* Echo this request 		*/
 
 /* Modifiers to GET request */
@@ -73,7 +75,8 @@
 #define NLMSG_SPACE(len) NLMSG_ALIGN(NLMSG_LENGTH(len))
 #define NLMSG_DATA(nlh)  ((void*)(((char*)nlh) + NLMSG_LENGTH(0)))
 #define NLMSG_NEXT(nlh,len)	 ((len) -= NLMSG_ALIGN((nlh)->nlmsg_len), \
-				  (struct nlmsghdr*)(((char*)(nlh)) + NLMSG_ALIGN((nlh)->nlmsg_len)))
+				  (struct nlmsghdr*)(((char*)(nlh)) + \
+				   NLMSG_ALIGN((nlh)->nlmsg_len)))
 #define NLMSG_OK(nlh,len) ((len) >= (int)sizeof(struct nlmsghdr) && \
 			   (nlh)->nlmsg_len >= sizeof(struct nlmsghdr) && \
 			   (nlh)->nlmsg_len <= (len))
@@ -90,7 +93,7 @@
 	struct nlmsghdr msg;
 };
 
-#define NET_MAJOR 36		/* Major 36 is reserved for networking 						*/
+#define NET_MAJOR 36		/* Major 36 is reserved for networking 	*/
 
 enum {
 	NETLINK_UNCONNECTED = 0,
@@ -116,9 +119,11 @@
 #define NETLINK_CREDS(skb)	(&NETLINK_CB((skb)).creds)
 
 
-extern struct sock *netlink_kernel_create(int unit, void (*input)(struct sock *sk, int len));
+extern struct sock *
+netlink_kernel_create(int unit, void (*input)(struct sock *sk, int len));
 extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
-extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 pid, int nonblock);
+extern int 
+netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 pid, int nonblock);
 extern int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, __u32 pid,
 			     __u32 group, int allocation);
 extern void netlink_set_err(struct sock *ssk, __u32 pid, __u32 group, int code);
@@ -127,7 +132,8 @@
 
 /* finegrained unicast helpers: */
 struct sock *netlink_getsockbyfilp(struct file *filp);
-int netlink_attachskb(struct sock *sk, struct sk_buff *skb, int nonblock, long timeo);
+int netlink_attachskb(struct sock *sk, struct sk_buff *skb, int nonblock,
+		      long timeo);
 void netlink_detachskb(struct sock *sk, struct sk_buff *skb);
 int netlink_sendskb(struct sock *sk, struct sk_buff *skb, int protocol);
 
@@ -175,7 +181,8 @@
 
 extern int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 			      struct nlmsghdr *nlh,
-			      int (*dump)(struct sk_buff *skb, struct netlink_callback*),
+			      int (*dump)(struct sk_buff *skb, 
+				          struct netlink_callback*),
 			      int (*done)(struct netlink_callback*));
 
 

--------------010800010108090902080203--
