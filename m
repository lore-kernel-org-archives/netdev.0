From: "MORANGE,DAMIEN (HP-France,ex1)" <damien.morange@hp.com>
Subject: [PATCH] lksctp 0.6.9 backport on 2.4.23-pre4
Date: Fri, 19 Sep 2003 14:41:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <B320F712053ED411869200D0B747A3CA0FE4752D@laplace.grenoble.hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----_=_NextPart_000_01C37EAB.5A49A8B0"
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com, samudrala@us.ibm.com,
        lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "'David S. Miller'" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C37EAB.5A49A8B0
Content-Type: text/plain;
	charset="iso-8859-1"

Hi,
 
> Care to provide this as a BK tree I can pull from?
> (please don't combine the patches into one big changeset,
>  keep them separate, comment them properly, and preserve the
>  revision history, that's the whole point of this)

As requested, I have uploaded at:

<http://linux-lksctp.bkbits.net:8080/lksctp-2.4>

the 3 ChangeSets needed to backport LKSCTP 0.6.9 onto linux 
kernel 2.4.23-pre4.

I also attach to this mail the output of:
bk export -t patch -du -r1.1126,1.1128 >
csets.patch.ChangeSets_1.1127_1.1128

Since ChangeSet 1.1129 adds lots of new files, I voluntarily
skipped it to not overflow the mailing list.

Comments welcome.

Best regards,

-- 
Damien Morange




The ChangeSets are:


1.1127:
<http://linux-lksctp.bkbits.net:8080/lksctp-2.4/cset@1.1127?nav=index.html|C
hangeSet@-7d>

[SCTP] LKSCTP 0.6.9 backport on kernel 2.4 patch #1

Adding the necessary changes to the kernel IP stack so that
SCTP can perform Path MTU discovery.
No other SCTP-specific changes.
The resulting kernel is functionally unchanged.


1.1128:
<http://linux-lksctp.bkbits.net:8080/lksctp-2.4/cset@1.1128?nav=index.html|C
hangeSet@-7d>

[SCTP] LKSCTP 0.6.9 backport on kernel 2.4 patch #2

This patch modifies the kernel existing files to add the SCTP
functionality.
It cannot work without the 3rd patch of this serie,
but it is issued to better highlight the required changes.


1.1129:
<http://linux-lksctp.bkbits.net:8080/lksctp-2.4/cset@1.1129?nav=index.html|C
hangeSet@-7d>

[SCTP] LKSCTP 0.6.9 backport on kernel 2.4 patch #3

This patch consists only in new files.
It adds the SCTP protocol engine and the SCTP sockets layers
to the IP stack.
This patches requires patches #1 and #2 to be applied.


------_=_NextPart_000_01C37EAB.5A49A8B0
Content-Type: application/octet-stream;
	name="csets.patch.ChangeSets_1.1127_1.1128"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="csets.patch.ChangeSets_1.1127_1.1128"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or =
higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1126  -> 1.1128=20
#	include/linux/sysctl.h	1.32    -> 1.33  =20
#	      kernel/ksyms.c	1.78    -> 1.79  =20
#	   include/net/tcp.h	1.23    -> 1.24  =20
#	  net/ipv4/af_inet.c	1.11    -> 1.12  =20
#	       net/Config.in	1.13    -> 1.14  =20
#	        net/socket.c	1.16    -> 1.17  =20
#	  include/net/snmp.h	1.5     -> 1.6   =20
#	 include/linux/net.h	1.3     -> 1.4   =20
#	       net/netsyms.c	1.43    -> 1.45  =20
#	        net/Makefile	1.7     -> 1.8   =20
#	  include/linux/in.h	1.2     -> 1.3   =20
#	 net/ipv6/tcp_ipv6.c	1.25    -> 1.26  =20
#	 net/ipv6/af_inet6.c	1.11    -> 1.12  =20
#	    include/net/ip.h	1.3     -> 1.4   =20
#	net/ipv4/tcp_output.c	1.15    -> 1.16  =20
#	  include/net/sock.h	1.15    -> 1.16  =20
#	include/net/inet_common.h	1.1     -> 1.2   =20
#	   net/ipv6/Makefile	1.2     -> 1.3   =20
#	include/linux/socket.h	1.7     -> 1.8   =20
#	  include/net/ipv6.h	1.5     -> 1.6   =20
#	Documentation/Configure.help	1.193   -> 1.194 =20
#	net/ipv4/ip_output.c	1.14    -> 1.15  =20
#	               (new)	        -> 1.1     net/ipv6/ipv6_syms.c
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/19	damien.morange@hp.com	1.1127
# [SCTP] LKSCTP 0.6.9 backport on kernel 2.4 patch #1
#=20
# Adding the necessary changes to the kernel IP stack so that SCTP
# can perform Path MTU discovery.
# No other SCTP-specific changes.
# The resulting kernel is functionally unchanged.
# --------------------------------------------
# 03/09/19	damien.morange@hp.com	1.1128
# [SCTP] LKSCTP 0.6.9 backport on kernel 2.4 patch #2
#=20
# This patch modifies the kernel existing files to add the SCTP
# functionality.
# It cannot work without the 3rd patch of this serie,
# but it is issued to better highlight the required changes.
# --------------------------------------------
#
diff -Nru a/Documentation/Configure.help b/Documentation/Configure.help
--- a/Documentation/Configure.help	Fri Sep 19 15:34:00 2003
+++ b/Documentation/Configure.help	Fri Sep 19 15:34:00 2003
@@ -6101,6 +6101,61 @@
=20
   It is safe to say N here for now.
=20
+The SCTP Protocol (EXPERIMENTAL)
+CONFIG_IP_SCTP
+  Stream Control Transmission Protocol
+
+  From RFC 2960 (http://www.ietf.org/rfc/rfc2960.txt)
+
+  "SCTP is a reliable transport protocol operating on top of a
+  connectionless packet network such as IP.  It offers the following
+  services to its users:
+
+  -- acknowledged error-free non-duplicated transfer of user data,
+  -- data fragmentation to conform to discovered path MTU size,
+  -- sequenced delivery of user messages within multiple streams,
+  with an option for order-of-arrival delivery of individual user
+  messages,
+  -- optional bundling of multiple user messages into a single SCTP
+  packet, and
+  -- network-level fault tolerance through supporting of multi-
+  homing at either or both ends of an association."
+
+  This protocol support is also available as a module ( =3D code which
+  can be inserted in and removed from the running kernel whenever you
+  want). The module will be called sctp. If you want to compile it
+  as a module, say M here and read <file:Documentation/modules.txt>.
+
+  If in doubt, say N.
+
+SCTP: Use old checksum (Adler-32)
+CONFIG_SCTP_ADLER32
+  RCF2960 currently specifies the Adler-32 checksum algorithm for =
SCTP.
+  This has been deprecated and replaced by an algorithm now referred
+  to as crc32c.
+
+  If you say Y, this will use the Adler-32 algorithm, this might be=20
+  useful for interoperation with downlevel peers.=20
+
+  If unsure, say N. =20
+
+SCTP: Debug messages
+CONFIG_SCTP_DBG_MSG
+  If you say Y, this will enable verbose debugging messages.=20
+
+  If unsure, say N.  However, if you are running into problems, use=20
+  this option to gather detailed trace information
+
+SCTP: Debug object counts
+CONFIG_SCTP_DBG_OBJCNT
+  If you say Y, this will enable debugging support for counting the=20
+  type of objects that are currently allocated.  This is useful for=20
+  identifying memory leaks.   If the /proc filesystem is enabled this=20
+  debug information can be viewed by=20
+  'cat /proc/net/sctp/sctp_dbg_objcnt'
+
+  If unsure, say N
+
 Kernel httpd acceleration
 CONFIG_KHTTPD
   The kernel httpd acceleration daemon (kHTTPd) is a (limited) web
diff -Nru a/include/linux/in.h b/include/linux/in.h
--- a/include/linux/in.h	Fri Sep 19 15:34:00 2003
+++ b/include/linux/in.h	Fri Sep 19 15:34:00 2003
@@ -41,6 +41,7 @@
   IPPROTO_ESP =3D 50,            /* Encapsulation Security Payload =
protocol */
   IPPROTO_AH =3D 51,             /* Authentication Header protocol     =
  */
   IPPROTO_COMP   =3D 108,                /* Compression Header =
protocol */
+  IPPROTO_SCTP   =3D 132,		/* Stream Control Transport Protocol    */
=20
   IPPROTO_RAW	 =3D 255,		/* Raw IP packets			*/
   IPPROTO_MAX
diff -Nru a/include/linux/net.h b/include/linux/net.h
--- a/include/linux/net.h	Fri Sep 19 15:34:00 2003
+++ b/include/linux/net.h	Fri Sep 19 15:34:00 2003
@@ -141,6 +141,7 @@
 				  const struct iovec * iov, long count, long size);
 extern struct socket *sockfd_lookup(int fd, int *err);
=20
+extern int	sock_map_fd(struct socket *sock);
 extern int	net_ratelimit(void);
 extern unsigned long net_random(void);
 extern void net_srandom(unsigned long);
diff -Nru a/include/linux/socket.h b/include/linux/socket.h
--- a/include/linux/socket.h	Fri Sep 19 15:34:00 2003
+++ b/include/linux/socket.h	Fri Sep 19 15:34:00 2003
@@ -242,6 +242,7 @@
 #define SOL_UDP		17
 #define SOL_IPV6	41
 #define SOL_ICMPV6	58
+#define SOL_SCTP	132
 #define SOL_RAW		255
 #define SOL_IPX		256
 #define SOL_AX25	257
diff -Nru a/include/linux/sysctl.h b/include/linux/sysctl.h
--- a/include/linux/sysctl.h	Fri Sep 19 15:34:00 2003
+++ b/include/linux/sysctl.h	Fri Sep 19 15:34:00 2003
@@ -176,7 +176,8 @@
 	NET_TR=3D14,
 	NET_DECNET=3D15,
 	NET_ECONET=3D16,
-	NET_KHTTPD=3D17
+	NET_KHTTPD=3D17,
+	NET_SCTP=3D18
 };
=20
 /* /proc/sys/kernel/random */
@@ -509,6 +510,21 @@
 	NET_DECNET_DEBUG_LEVEL =3D 255
 };
=20
+/* /proc/sys/net/sctp */
+enum {
+	NET_SCTP_RTO_INITIAL =3D 1,
+	NET_SCTP_RTO_MIN     =3D 2,
+	NET_SCTP_RTO_MAX     =3D 3,
+	NET_SCTP_RTO_ALPHA   =3D 4,
+	NET_SCTP_RTO_BETA    =3D 5,
+	NET_SCTP_VALID_COOKIE_LIFE       =3D  6,
+	NET_SCTP_ASSOCIATION_MAX_RETRANS =3D  7,
+	NET_SCTP_PATH_MAX_RETRANS        =3D  8,
+	NET_SCTP_MAX_INIT_RETRANSMITS    =3D  9,
+	NET_SCTP_HB_INTERVAL             =3D 10,
+	NET_SCTP_PRESERVE_ENABLE         =3D 11,
+	NET_SCTP_MAX_BURST               =3D 12,
+};
 /* /proc/sys/net/khttpd/ */
 enum {
 	NET_KHTTPD_DOCROOT	=3D 1,
diff -Nru a/include/net/inet_common.h b/include/net/inet_common.h
--- a/include/net/inet_common.h	Fri Sep 19 15:34:00 2003
+++ b/include/net/inet_common.h	Fri Sep 19 15:34:00 2003
@@ -43,6 +43,14 @@
 extern void			inet_sock_destruct(struct sock *sk);
 extern atomic_t			inet_sock_nr;
=20
+extern int			inet_bind(struct socket *sock,
+					  struct sockaddr *uaddr, int addr_len);
+extern int			inet_getname(struct socket *sock,
+					     struct sockaddr *uaddr,
+					     int *uaddr_len, int peer);
+extern int			inet_ioctl(struct socket *sock,
+					   unsigned int cmd, unsigned long arg);
+
 #endif
=20
=20
diff -Nru a/include/net/ip.h b/include/net/ip.h
--- a/include/net/ip.h	Fri Sep 19 15:34:00 2003
+++ b/include/net/ip.h	Fri Sep 19 15:34:00 2003
@@ -96,7 +96,7 @@
 extern int		ip_fragment(struct sk_buff *skb, int (*out)(struct =
sk_buff*));
 extern int		ip_do_nat(struct sk_buff *skb);
 extern void		ip_send_check(struct iphdr *ip);
-extern int		ip_queue_xmit(struct sk_buff *skb);
+extern int		ip_queue_xmit(struct sk_buff *skb, int ipfragok);
 extern void		ip_init(void);
 extern int		ip_build_xmit(struct sock *sk,
 				      int getfrag (const void *,
diff -Nru a/include/net/ipv6.h b/include/net/ipv6.h
--- a/include/net/ipv6.h	Fri Sep 19 15:34:00 2003
+++ b/include/net/ipv6.h	Fri Sep 19 15:34:00 2003
@@ -353,6 +353,14 @@
 						u32 info, u8 *payload);
 extern void			ipv6_local_error(struct sock *sk, int err, struct flowi =
*fl, u32 info);
=20
+extern int inet6_release(struct socket *sock);
+extern int inet6_bind(struct socket *sock, struct sockaddr *uaddr,=20
+		      int addr_len);
+extern int inet6_getname(struct socket *sock, struct sockaddr *uaddr,
+			 int *uaddr_len, int peer);
+extern int inet6_ioctl(struct socket *sock, unsigned int cmd,=20
+		       unsigned long arg);
+
 #endif /* __KERNEL__ */
 #endif /* _NET_IPV6_H */
=20
diff -Nru a/include/net/snmp.h b/include/net/snmp.h
--- a/include/net/snmp.h	Fri Sep 19 15:34:00 2003
+++ b/include/net/snmp.h	Fri Sep 19 15:34:00 2003
@@ -212,6 +212,35 @@
 	unsigned long   __pad[0];
 } ____cacheline_aligned;=20
=20
+/* draft-ietf-sigtran-sctp-mib-07.txt */
+struct sctp_mib
+{
+	unsigned long   SctpCurrEstab;
+	unsigned long   SctpActiveEstabs;
+	unsigned long   SctpPassiveEstabs;
+	unsigned long   SctpAborteds;
+	unsigned long   SctpShutdowns;
+	unsigned long   SctpOutOfBlues;
+	unsigned long   SctpChecksumErrors;
+	unsigned long   SctpOutCtrlChunks;
+	unsigned long   SctpOutOrderChunks;
+	unsigned long   SctpOutUnorderChunks;
+	unsigned long   SctpInCtrlChunks;
+	unsigned long   SctpInOrderChunks;
+	unsigned long   SctpInUnorderChunks;
+	unsigned long   SctpFragUsrMsgs;
+	unsigned long   SctpReasmUsrMsgs;
+	unsigned long   SctpOutSCTPPacks;
+	unsigned long   SctpInSCTPPacks;
+	unsigned long   SctpRtoAlgorithm;
+	unsigned long   SctpRtoMin;
+	unsigned long   SctpRtoMax;
+	unsigned long   SctpRtoInitial;
+	unsigned long   SctpValCookieLife;
+	unsigned long   SctpMaxInitRetr;
+	unsigned long   __pad[0];
+};
+
 struct linux_mib=20
 {
 	unsigned long	SyncookiesSent;
diff -Nru a/include/net/sock.h b/include/net/sock.h
--- a/include/net/sock.h	Fri Sep 19 15:34:00 2003
+++ b/include/net/sock.h	Fri Sep 19 15:34:00 2003
@@ -49,6 +49,9 @@
 #include <linux/icmp.h>
 #endif
 #include <linux/tcp.h>		/* struct tcphdr */
+#if defined(CONFIG_IP_SCTP) || defined (CONFIG_IP_SCTP_MODULE)
+#include <net/sctp/structs.h>	/* struct sctp_opt */
+#endif
=20
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>	/* struct sk_buff */
@@ -586,6 +589,9 @@
=20
 	union {
 		struct tcp_opt		af_tcp;
+#if defined(CONFIG_IP_SCTP) || defined (CONFIG_IP_SCTP_MODULE)
+		struct sctp_opt		af_sctp;
+#endif
 #if defined(CONFIG_INET) || defined (CONFIG_INET_MODULE)
 		struct raw_opt		tp_raw4;
 #endif
diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	Fri Sep 19 15:34:00 2003
+++ b/include/net/tcp.h	Fri Sep 19 15:34:00 2003
@@ -555,7 +555,8 @@
  */
=20
 struct tcp_func {
-	int			(*queue_xmit)		(struct sk_buff *skb);
+	int			(*queue_xmit)		(struct sk_buff *skb,
+							 int ipfragok);
=20
 	void			(*send_check)		(struct sock *sk,
 							 struct tcphdr *th,
diff -Nru a/kernel/ksyms.c b/kernel/ksyms.c
--- a/kernel/ksyms.c	Fri Sep 19 15:34:00 2003
+++ b/kernel/ksyms.c	Fri Sep 19 15:34:00 2003
@@ -513,6 +513,9 @@
 EXPORT_SYMBOL(seq_release);
 EXPORT_SYMBOL(seq_read);
 EXPORT_SYMBOL(seq_lseek);
+EXPORT_SYMBOL(single_open);
+EXPORT_SYMBOL(single_release);
+EXPORT_SYMBOL(seq_release_private);
=20
 /* Program loader interfaces */
 EXPORT_SYMBOL(setup_arg_pages);
diff -Nru a/net/Config.in b/net/Config.in
--- a/net/Config.in	Fri Sep 19 15:34:00 2003
+++ b/net/Config.in	Fri Sep 19 15:34:00 2003
@@ -29,6 +29,9 @@
    if [ "$CONFIG_EXPERIMENTAL" =3D "y" ]; then
       source net/khttpd/Config.in
    fi
+   if [ "$CONFIG_EXPERIMENTAL" =3D "y" ]; then
+      source net/sctp/Config.in
+   fi
 fi
 if [ "$CONFIG_EXPERIMENTAL" =3D "y" ]; then
    tristate 'Asynchronous Transfer Mode (ATM) (EXPERIMENTAL)' =
CONFIG_ATM
diff -Nru a/net/Makefile b/net/Makefile
--- a/net/Makefile	Fri Sep 19 15:34:00 2003
+++ b/net/Makefile	Fri Sep 19 15:34:00 2003
@@ -7,7 +7,7 @@
=20
 O_TARGET :=3D	network.o
=20
-mod-subdirs :=3D	ipv4/netfilter ipv6/netfilter ipx irda bluetooth atm =
netlink sched core
+mod-subdirs :=3D	ipv4/netfilter ipv6/netfilter ipx irda bluetooth atm =
netlink sched core sctp
 export-objs :=3D	netsyms.o
=20
 subdir-y :=3D	core ethernet
@@ -19,6 +19,7 @@
 subdir-$(CONFIG_NETFILTER)	+=3D ipv4/netfilter
 subdir-$(CONFIG_UNIX)		+=3D unix
 subdir-$(CONFIG_IPV6)		+=3D ipv6
+subdir-$(CONFIG_IP_SCTP)	+=3D sctp
=20
 ifneq ($(CONFIG_IPV6),n)
 ifneq ($(CONFIG_IPV6),)
diff -Nru a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
--- a/net/ipv4/af_inet.c	Fri Sep 19 15:34:00 2003
+++ b/net/ipv4/af_inet.c	Fri Sep 19 15:34:00 2003
@@ -470,7 +470,7 @@
 /* It is off by default, see below. */
 int sysctl_ip_nonlocal_bind;
=20
-static int inet_bind(struct socket *sock, struct sockaddr *uaddr, int =
addr_len)
+int inet_bind(struct socket *sock, struct sockaddr *uaddr, int =
addr_len)
 {
 	struct sockaddr_in *addr=3D(struct sockaddr_in *)uaddr;
 	struct sock *sk=3Dsock->sk;
@@ -703,7 +703,7 @@
  *	This does both peername and sockname.
  */
 =20
-static int inet_getname(struct socket *sock, struct sockaddr *uaddr,
+int inet_getname(struct socket *sock, struct sockaddr *uaddr,
 		 int *uaddr_len, int peer)
 {
 	struct sock *sk		=3D sock->sk;
@@ -820,7 +820,7 @@
  *	There's a good 20K of config code hanging around the kernel.
  */
=20
-static int inet_ioctl(struct socket *sock, unsigned int cmd, unsigned =
long arg)
+int inet_ioctl(struct socket *sock, unsigned int cmd, unsigned long =
arg)
 {
 	struct sock *sk =3D sock->sk;
 	int err;
diff -Nru a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
--- a/net/ipv4/ip_output.c	Fri Sep 19 15:34:00 2003
+++ b/net/ipv4/ip_output.c	Fri Sep 19 15:34:00 2003
@@ -339,7 +339,7 @@
 	return ip_fragment(skb, skb->dst->output);
 }
=20
-int ip_queue_xmit(struct sk_buff *skb)
+int ip_queue_xmit(struct sk_buff *skb, int ipfragok)
 {
 	struct sock *sk =3D skb->sk;
 	struct ip_options *opt =3D sk->protinfo.af_inet.opt;
@@ -384,7 +384,7 @@
 	iph =3D (struct iphdr *) skb_push(skb, sizeof(struct iphdr) + (opt ? =
opt->optlen : 0));
 	*((__u16 *)iph)	=3D htons((4 << 12) | (5 << 8) | =
(sk->protinfo.af_inet.tos & 0xff));
 	iph->tot_len =3D htons(skb->len);
-	if (ip_dont_fragment(sk, &rt->u.dst))
+	if (ip_dont_fragment(sk, &rt->u.dst) && !ipfragok)
 		iph->frag_off =3D htons(IP_DF);
 	else
 		iph->frag_off =3D 0;
diff -Nru a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c	Fri Sep 19 15:34:00 2003
+++ b/net/ipv4/tcp_output.c	Fri Sep 19 15:34:00 2003
@@ -275,7 +275,7 @@
=20
 		TCP_INC_STATS(TcpOutSegs);
=20
-		err =3D tp->af_specific->queue_xmit(skb);
+		err =3D tp->af_specific->queue_xmit(skb, 0);
 		if (err <=3D 0)
 			return err;
=20
diff -Nru a/net/ipv6/Makefile b/net/ipv6/Makefile
--- a/net/ipv6/Makefile	Fri Sep 19 15:34:00 2003
+++ b/net/ipv6/Makefile	Fri Sep 19 15:34:00 2003
@@ -13,7 +13,9 @@
 		route.o ip6_fib.o ipv6_sockglue.o ndisc.o udp.o raw.o \
 		protocol.o icmp.o mcast.o reassembly.o tcp_ipv6.o \
 		exthdrs.o sysctl_net_ipv6.o datagram.o proc.o \
-		ip6_flowlabel.o
+		ip6_flowlabel.o ipv6_syms.o
+
+export-objs :=3D ipv6_syms.o
=20
 obj-m  :=3D $(O_TARGET)
=20
diff -Nru a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
--- a/net/ipv6/af_inet6.c	Fri Sep 19 15:34:00 2003
+++ b/net/ipv6/af_inet6.c	Fri Sep 19 15:34:00 2003
@@ -233,7 +233,7 @@
=20
=20
 /* bind for INET6 API */
-static int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int =
addr_len)
+int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int =
addr_len)
 {
 	struct sockaddr_in6 *addr=3D(struct sockaddr_in6 *)uaddr;
 	struct sock *sk =3D sock->sk;
@@ -329,7 +329,7 @@
 	return 0;
 }
=20
-static int inet6_release(struct socket *sock)
+int inet6_release(struct socket *sock)
 {
 	struct sock *sk =3D sock->sk;
=20
@@ -376,7 +376,7 @@
  *	This does both peername and sockname.
  */
 =20
-static int inet6_getname(struct socket *sock, struct sockaddr *uaddr,
+int inet6_getname(struct socket *sock, struct sockaddr *uaddr,
 		 int *uaddr_len, int peer)
 {
 	struct sockaddr_in6 *sin=3D(struct sockaddr_in6 *)uaddr;
@@ -413,7 +413,7 @@
 	return(0);
 }
=20
-static int inet6_ioctl(struct socket *sock, unsigned int cmd, unsigned =
long arg)
+int inet6_ioctl(struct socket *sock, unsigned int cmd, unsigned long =
arg)
 {
 	struct sock *sk =3D sock->sk;
 	int err =3D -EINVAL;
diff -Nru a/net/ipv6/ipv6_syms.c b/net/ipv6/ipv6_syms.c
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/net/ipv6/ipv6_syms.c	Fri Sep 19 15:34:00 2003
@@ -0,0 +1,35 @@
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <net/protocol.h>
+#include <net/ipv6.h>
+#include <net/addrconf.h>
+#include <net/ip6_route.h>
+
+EXPORT_SYMBOL(ipv6_addr_type);
+EXPORT_SYMBOL(icmpv6_send);
+EXPORT_SYMBOL(icmpv6_statistics);
+EXPORT_SYMBOL(icmpv6_err_convert);
+EXPORT_SYMBOL(ndisc_mc_map);
+EXPORT_SYMBOL(register_inet6addr_notifier);
+EXPORT_SYMBOL(unregister_inet6addr_notifier);
+EXPORT_SYMBOL(ip6_route_output);
+#ifdef CONFIG_NETFILTER
+EXPORT_SYMBOL(ip6_route_me_harder);
+#endif
+EXPORT_SYMBOL(addrconf_lock);
+EXPORT_SYMBOL(ipv6_setsockopt);
+EXPORT_SYMBOL(ipv6_getsockopt);
+EXPORT_SYMBOL(inet6_register_protosw);
+EXPORT_SYMBOL(inet6_unregister_protosw);
+EXPORT_SYMBOL(inet6_add_protocol);
+EXPORT_SYMBOL(inet6_del_protocol);
+EXPORT_SYMBOL(ip6_xmit);
+EXPORT_SYMBOL(inet6_release);
+EXPORT_SYMBOL(inet6_bind);
+EXPORT_SYMBOL(inet6_getname);
+EXPORT_SYMBOL(inet6_ioctl);
+EXPORT_SYMBOL(ipv6_get_saddr);
+EXPORT_SYMBOL(ipv6_chk_addr);
+EXPORT_SYMBOL(in6_dev_finish_destroy);
diff -Nru a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c	Fri Sep 19 15:34:00 2003
+++ b/net/ipv6/tcp_ipv6.c	Fri Sep 19 15:34:00 2003
@@ -59,7 +59,7 @@
 				  struct sk_buff *skb);
=20
 static int	tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb);
-static int	tcp_v6_xmit(struct sk_buff *skb);
+static int	tcp_v6_xmit(struct sk_buff *skb, int ipfragok);
=20
 static struct tcp_func ipv6_mapped;
 static struct tcp_func ipv6_specific;
@@ -1715,7 +1715,7 @@
 	return 0;
 }
=20
-static int tcp_v6_xmit(struct sk_buff *skb)
+static int tcp_v6_xmit(struct sk_buff *skb, int ipfragok)
 {
 	struct sock *sk =3D skb->sk;
 	struct ipv6_pinfo * np =3D &sk->net_pinfo.af_inet6;
diff -Nru a/net/netsyms.c b/net/netsyms.c
--- a/net/netsyms.c	Fri Sep 19 15:34:00 2003
+++ b/net/netsyms.c	Fri Sep 19 15:34:00 2003
@@ -60,7 +60,7 @@
=20
 extern struct net_proto_family inet_family_ops;
=20
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE) || defined =
(CONFIG_KHTTPD) || defined (CONFIG_KHTTPD_MODULE)
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE) || defined =
(CONFIG_KHTTPD) || defined (CONFIG_KHTTPD_MODULE) || defined =
(CONFIG_IP_SCTP_MODULE)
 #include <linux/in6.h>
 #include <linux/icmpv6.h>
 #include <net/ipv6.h>
@@ -164,6 +164,7 @@
 EXPORT_SYMBOL(put_cmsg);
 EXPORT_SYMBOL(sock_kmalloc);
 EXPORT_SYMBOL(sock_kfree_s);
+EXPORT_SYMBOL(sock_map_fd);
 EXPORT_SYMBOL(sockfd_lookup);
=20
 #ifdef CONFIG_FILTER
@@ -256,6 +257,8 @@
 EXPORT_SYMBOL(ip_route_output_key);
 EXPORT_SYMBOL(ip_route_input);
 EXPORT_SYMBOL(icmp_send);
+EXPORT_SYMBOL(icmp_statistics);
+EXPORT_SYMBOL(icmp_err_convert);
 EXPORT_SYMBOL(ip_options_compile);
 EXPORT_SYMBOL(ip_options_undo);
 EXPORT_SYMBOL(arp_send);
@@ -294,19 +297,7 @@
 #endif
=20
=20
-#ifdef CONFIG_IPV6
-EXPORT_SYMBOL(ipv6_addr_type);
-EXPORT_SYMBOL(icmpv6_send);
-EXPORT_SYMBOL(ndisc_mc_map);
-EXPORT_SYMBOL(register_inet6addr_notifier);
-EXPORT_SYMBOL(unregister_inet6addr_notifier);
-#include <net/ip6_route.h>
-EXPORT_SYMBOL(ip6_route_output);
-#ifdef CONFIG_NETFILTER
-EXPORT_SYMBOL(ip6_route_me_harder);
-#endif
-#endif
-#if defined (CONFIG_IPV6_MODULE) || defined (CONFIG_KHTTPD) || defined =
(CONFIG_KHTTPD_MODULE)
+#if defined (CONFIG_IPV6_MODULE) || defined (CONFIG_KHTTPD) || defined =
(CONFIG_KHTTPD_MODULE) || defined (CONFIG_IP_SCTP_MODULE)
 /* inet functions common to v4 and v6 */
 EXPORT_SYMBOL(inet_release);
 EXPORT_SYMBOL(inet_stream_connect);
@@ -421,6 +412,14 @@
 #endif
=20
 EXPORT_SYMBOL(tcp_read_sock);
+
+#ifdef CONFIG_IP_SCTP_MODULE
+EXPORT_SYMBOL(ip_setsockopt);
+EXPORT_SYMBOL(ip_getsockopt);
+EXPORT_SYMBOL(inet_ioctl);
+EXPORT_SYMBOL(inet_bind);
+EXPORT_SYMBOL(inet_getname);
+#endif /* CONFIG_IP_SCTP_MODULE */
=20
 EXPORT_SYMBOL(netlink_set_err);
 EXPORT_SYMBOL(netlink_broadcast);
diff -Nru a/net/socket.c b/net/socket.c
--- a/net/socket.c	Fri Sep 19 15:34:00 2003
+++ b/net/socket.c	Fri Sep 19 15:34:00 2003
@@ -325,7 +325,7 @@
  *	but we take care of internal coherence yet.
  */
=20
-static int sock_map_fd(struct socket *sock)
+int sock_map_fd(struct socket *sock)
 {
 	int fd;
 	struct qstr this;

------_=_NextPart_000_01C37EAB.5A49A8B0--
