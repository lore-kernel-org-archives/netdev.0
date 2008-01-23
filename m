From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [PATCH] Introducing socket mark socket option
Date: Wed, 23 Jan 2008 13:40:05 +0100
Message-ID: <12010920051270-git-send-email-panther@balabit.hu>
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-arch@vger.kernel.org, Laszlo Attila Toth <panther@balabit.hu>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A userspace program may wish to set the mark for each packets its send
without using the netfilter MARK target. Changing the mark can be used
mark based routing without netfilter or for packet filtering.

It requires CAP_NET_ADMIN capability.

Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>
---
 include/asm-alpha/socket.h    |    2 ++
 include/asm-arm/socket.h      |    2 ++
 include/asm-avr32/socket.h    |    2 ++
 include/asm-blackfin/socket.h |    3 +++
 include/asm-cris/socket.h     |    2 ++
 include/asm-frv/socket.h      |    2 ++
 include/asm-h8300/socket.h    |    2 ++
 include/asm-ia64/socket.h     |    2 ++
 include/asm-m32r/socket.h     |    2 ++
 include/asm-m68k/socket.h     |    2 ++
 include/asm-mips/socket.h     |    2 ++
 include/asm-parisc/socket.h   |    2 ++
 include/asm-powerpc/socket.h  |    2 ++
 include/asm-s390/socket.h     |    2 ++
 include/asm-sh/socket.h       |    2 ++
 include/asm-sparc/socket.h    |    2 ++
 include/asm-sparc64/socket.h  |    1 +
 include/asm-v850/socket.h     |    2 ++
 include/asm-x86/socket.h      |    2 ++
 include/asm-xtensa/socket.h   |    2 ++
 include/net/route.h           |    2 ++
 include/net/sock.h            |    2 ++
 net/core/sock.c               |   11 +++++++++++
 net/ipv4/icmp.c               |    1 +
 net/ipv4/ip_output.c          |    3 +++
 net/ipv4/raw.c                |    2 ++
 26 files changed, 61 insertions(+), 0 deletions(-)

diff --git a/include/asm-alpha/socket.h b/include/asm-alpha/socket.h
index 1fede7f..08c9793 100644
--- a/include/asm-alpha/socket.h
+++ b/include/asm-alpha/socket.h
@@ -60,4 +60,6 @@
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	20
 #define SO_SECURITY_ENCRYPTION_NETWORK		21
 
+#define SO_MARK			36
+
 #endif /* _ASM_SOCKET_H */
diff --git a/include/asm-arm/socket.h b/include/asm-arm/socket.h
index 65a1a64..6817be9 100644
--- a/include/asm-arm/socket.h
+++ b/include/asm-arm/socket.h
@@ -52,4 +52,6 @@
 #define SO_TIMESTAMPNS		35
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
+#define SO_MARK			36
+
 #endif /* _ASM_SOCKET_H */
diff --git a/include/asm-avr32/socket.h b/include/asm-avr32/socket.h
index a0d0507..35863f2 100644
--- a/include/asm-avr32/socket.h
+++ b/include/asm-avr32/socket.h
@@ -52,4 +52,6 @@
 #define SO_TIMESTAMPNS		35
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
+#define SO_MARK			36
+
 #endif /* __ASM_AVR32_SOCKET_H */
diff --git a/include/asm-blackfin/socket.h b/include/asm-blackfin/socket.h
index 5213c96..2ca702e 100644
--- a/include/asm-blackfin/socket.h
+++ b/include/asm-blackfin/socket.h
@@ -50,4 +50,7 @@
 #define SO_PASSSEC		34
 #define SO_TIMESTAMPNS		35
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
+
+#define SO_MARK			36
+
 #endif				/* _ASM_SOCKET_H */
diff --git a/include/asm-cris/socket.h b/include/asm-cris/socket.h
index 5b18dfd..9df0ca8 100644
--- a/include/asm-cris/socket.h
+++ b/include/asm-cris/socket.h
@@ -54,6 +54,8 @@
 #define SO_TIMESTAMPNS		35
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
+#define SO_MARK			36
+
 #endif /* _ASM_SOCKET_H */
 
 
diff --git a/include/asm-frv/socket.h b/include/asm-frv/socket.h
index a823bef..e51ca67 100644
--- a/include/asm-frv/socket.h
+++ b/include/asm-frv/socket.h
@@ -52,5 +52,7 @@
 #define SO_TIMESTAMPNS		35
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
+#define SO_MARK			36
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/include/asm-h8300/socket.h b/include/asm-h8300/socket.h
index 39911d8..da2520d 100644
--- a/include/asm-h8300/socket.h
+++ b/include/asm-h8300/socket.h
@@ -52,4 +52,6 @@
 #define SO_TIMESTAMPNS		35
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
+#define SO_MARK			36
+
 #endif /* _ASM_SOCKET_H */
diff --git a/include/asm-ia64/socket.h b/include/asm-ia64/socket.h
index 9e42ce4..d5ef0aa 100644
--- a/include/asm-ia64/socket.h
+++ b/include/asm-ia64/socket.h
@@ -61,4 +61,6 @@
 #define SO_TIMESTAMPNS		35
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
+#define SO_MARK			36
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/include/asm-m32r/socket.h b/include/asm-m32r/socket.h
index 793d5d3..9a0e200 100644
--- a/include/asm-m32r/socket.h
+++ b/include/asm-m32r/socket.h
@@ -52,4 +52,6 @@
 #define SO_TIMESTAMPNS		35
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
+#define SO_MARK			36
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/include/asm-m68k/socket.h b/include/asm-m68k/socket.h
index 6d21b90..dbc64e9 100644
--- a/include/asm-m68k/socket.h
+++ b/include/asm-m68k/socket.h
@@ -52,4 +52,6 @@
 #define SO_TIMESTAMPNS		35
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
+#define SO_MARK			36
+
 #endif /* _ASM_SOCKET_H */
diff --git a/include/asm-mips/socket.h b/include/asm-mips/socket.h
index 9594568..63f6025 100644
--- a/include/asm-mips/socket.h
+++ b/include/asm-mips/socket.h
@@ -73,6 +73,8 @@ To add: #define SO_REUSEPORT 0x0200	/* Allow local address and port reuse.  */
 #define SO_TIMESTAMPNS		35
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
+#define SO_MARK			36
+
 #ifdef __KERNEL__
 
 /** sock_type - Socket types
diff --git a/include/asm-parisc/socket.h b/include/asm-parisc/socket.h
index 99e868f..69a7a0d 100644
--- a/include/asm-parisc/socket.h
+++ b/include/asm-parisc/socket.h
@@ -52,4 +52,6 @@
 #define SO_PEERSEC		0x401d
 #define SO_PASSSEC		0x401e
 
+#define SO_MARK			0x401f
+
 #endif /* _ASM_SOCKET_H */
diff --git a/include/asm-powerpc/socket.h b/include/asm-powerpc/socket.h
index 403e9fd..f5a4e16 100644
--- a/include/asm-powerpc/socket.h
+++ b/include/asm-powerpc/socket.h
@@ -59,4 +59,6 @@
 #define SO_TIMESTAMPNS		35
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
+#define SO_MARK			36
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/include/asm-s390/socket.h b/include/asm-s390/socket.h
index 1161ebe..c786ab6 100644
--- a/include/asm-s390/socket.h
+++ b/include/asm-s390/socket.h
@@ -60,4 +60,6 @@
 #define SO_TIMESTAMPNS		35
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
+#define SO_MARK			36
+
 #endif /* _ASM_SOCKET_H */
diff --git a/include/asm-sh/socket.h b/include/asm-sh/socket.h
index c48d6fc..6d4bf65 100644
--- a/include/asm-sh/socket.h
+++ b/include/asm-sh/socket.h
@@ -52,4 +52,6 @@
 #define SO_TIMESTAMPNS		35
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
+#define SO_MARK			36
+
 #endif /* __ASM_SH_SOCKET_H */
diff --git a/include/asm-sparc/socket.h b/include/asm-sparc/socket.h
index 7c14239..2e2bd0b 100644
--- a/include/asm-sparc/socket.h
+++ b/include/asm-sparc/socket.h
@@ -52,6 +52,8 @@
 #define SO_TIMESTAMPNS		0x0021
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
+#define SO_MARK			0x0022
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/include/asm-sparc64/socket.h b/include/asm-sparc64/socket.h
index 986441d..44a625a 100644
--- a/include/asm-sparc64/socket.h
+++ b/include/asm-sparc64/socket.h
@@ -57,4 +57,5 @@
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
 #define SO_SECURITY_ENCRYPTION_NETWORK		0x5004
 
+#define SO_MARK			0x0022
 #endif /* _ASM_SOCKET_H */
diff --git a/include/asm-v850/socket.h b/include/asm-v850/socket.h
index a4c2493..e199a2b 100644
--- a/include/asm-v850/socket.h
+++ b/include/asm-v850/socket.h
@@ -52,4 +52,6 @@
 #define SO_TIMESTAMPNS		35
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
+#define SO_MARK			36
+
 #endif /* __V850_SOCKET_H__ */
diff --git a/include/asm-x86/socket.h b/include/asm-x86/socket.h
index 99ca648..80af9c4 100644
--- a/include/asm-x86/socket.h
+++ b/include/asm-x86/socket.h
@@ -52,4 +52,6 @@
 #define SO_TIMESTAMPNS		35
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
+#define SO_MARK			36
+
 #endif /* _ASM_SOCKET_H */
diff --git a/include/asm-xtensa/socket.h b/include/asm-xtensa/socket.h
index 1f5aeac..6100682 100644
--- a/include/asm-xtensa/socket.h
+++ b/include/asm-xtensa/socket.h
@@ -63,4 +63,6 @@
 #define SO_TIMESTAMPNS		35
 #define SCM_TIMESTAMPNS		SO_TIMESTAMPNS
 
+#define SO_MARK			36
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/net/route.h b/include/net/route.h
index 5847e6f..326c499 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -27,6 +27,7 @@
 #include <net/dst.h>
 #include <net/inetpeer.h>
 #include <net/flow.h>
+#include <net/sock.h>
 #include <linux/in_route.h>
 #include <linux/rtnetlink.h>
 #include <linux/route.h>
@@ -148,6 +149,7 @@ static inline int ip_route_connect(struct rtable **rp, __be32 dst,
 				   int flags)
 {
 	struct flowi fl = { .oif = oif,
+			    .mark = sk->sk_mark,
 			    .nl_u = { .ip4_u = { .daddr = dst,
 						 .saddr = src,
 						 .tos   = tos } },
diff --git a/include/net/sock.h b/include/net/sock.h
index 9023244..e3fb4c0 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -262,6 +262,8 @@ struct sock {
 	__u32			sk_sndmsg_off;
 	int			sk_write_pending;
 	void			*sk_security;
+	__u32			sk_mark;
+	/* XXX 4 bytes hole on 64 bit */
 	void			(*sk_state_change)(struct sock *sk);
 	void			(*sk_data_ready)(struct sock *sk, int bytes);
 	void			(*sk_write_space)(struct sock *sk);
diff --git a/net/core/sock.c b/net/core/sock.c
index 1c4b1cd..433715f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -667,6 +667,13 @@ set_rcvbuf:
 		else
 			clear_bit(SOCK_PASSSEC, &sock->flags);
 		break;
+	case SO_MARK:
+		if (!capable(CAP_NET_ADMIN))
+			ret = -EPERM;
+		else {
+			sk->sk_mark = val;
+		}
+		break;
 
 		/* We implement the SO_SNDLOWAT etc to
 		   not be settable (1003.1g 5.3) */
@@ -836,6 +843,10 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 	case SO_PEERSEC:
 		return security_socket_getpeersec_stream(sock, optval, optlen, len);
 
+	case SO_MARK:
+		v.val = sk->sk_mark;
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 1dbe89c..d25f66a 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -403,6 +403,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 					      { .daddr = daddr,
 						.saddr = rt->rt_spec_dst,
 						.tos = RT_TOS(ip_hdr(skb)->tos) } },
+				    .mark = sk->sk_mark,
 				    .proto = IPPROTO_ICMP };
 		security_skb_classify_flow(skb, &fl);
 		if (ip_route_output_key(&rt, &fl))
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index e57de0f..299cefa 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -168,6 +168,7 @@ int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
 	}
 
 	skb->priority = sk->sk_priority;
+	skb->mark = sk->sk_mark;
 
 	/* Send it out. */
 	return ip_local_out(skb);
@@ -385,6 +386,7 @@ packet_routed:
 			     (skb_shinfo(skb)->gso_segs ?: 1) - 1);
 
 	skb->priority = sk->sk_priority;
+	skb->mark = sk->sk_mark;
 
 	return ip_local_out(skb);
 
@@ -1282,6 +1284,7 @@ int ip_push_pending_frames(struct sock *sk)
 	iph->daddr = rt->rt_dst;
 
 	skb->priority = sk->sk_priority;
+	skb->mark = sk->sk_mark;
 	skb->dst = dst_clone(&rt->u.dst);
 
 	if (iph->protocol == IPPROTO_ICMP)
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 91a5218..a50e657 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -352,6 +352,7 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 	skb_reserve(skb, hh_len);
 
 	skb->priority = sk->sk_priority;
+	skb->mark = sk->sk_mark;
 	skb->dst = dst_clone(&rt->u.dst);
 
 	skb_reset_network_header(skb);
@@ -544,6 +545,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 	{
 		struct flowi fl = { .oif = ipc.oif,
+				    .mark = sk->sk_mark,
 				    .nl_u = { .ip4_u =
 					      { .daddr = daddr,
 						.saddr = saddr,
-- 
1.5.2.5

