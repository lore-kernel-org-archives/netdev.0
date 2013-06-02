From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next post Lorenzo] transp_v6.h: style neatening
Date: Sun, 02 Jun 2013 10:04:26 -0700
Message-ID: <1370192666.7400.16.camel@joe-AO722>
References: <1370049940.10556.100.camel@joe-AO722>
	 <20130601.195806.2024506377665086082.davem@davemloft.net>
	 <1370142368.2086.6.camel@joe-AO722>
	 <20130602.012918.1216932529595713857.davem@davemloft.net>
	 <1370164995.2086.30.camel@joe-AO722>
	 <CAKD1Yr0rRBWZ8WcMSo-xoG=X8kptBdhFBk36CjLX72BZkHuSvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Vasiliy Kulikov <segoon@openwall.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:41637 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754429Ab3FBRE1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Jun 2013 13:04:27 -0400
In-Reply-To: <CAKD1Yr0rRBWZ8WcMSo-xoG=X8kptBdhFBk36CjLX72BZkHuSvw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use a more current code style.

Remove extern from function prototypes.
Align function arguments and reflow to 80 cols.
Use network comment styles.

Signed-off-by: Joe Perches <joe@perches.com>
cc: Lorenzo Colitti <lorenzo@google.com>, 
---
> I don't have strong feelings about indentation, but if possible I
> would like to avoid re-spinning this patchset more than twice over
> formatting changes to this file.

You could do nothing and David could apply this if
he wants a more complete neatening.

Or do what David wants.  He's the maintainer.

 include/net/transp_v6.h | 89 ++++++++++++++++++++-----------------------------
 1 file changed, 37 insertions(+), 52 deletions(-)

diff --git a/include/net/transp_v6.h b/include/net/transp_v6.h
index 6dddc08..48660e5 100644
--- a/include/net/transp_v6.h
+++ b/include/net/transp_v6.h
@@ -3,72 +3,57 @@
 
 #include <net/checksum.h>
 
-/*
- *	IPv6 transport protocols
- */
-
-extern struct proto     rawv6_prot;
-extern struct proto     udpv6_prot;
-extern struct proto     udplitev6_prot;
-extern struct proto     tcpv6_prot;
-extern struct proto     pingv6_prot;
+/* IPv6 transport protocols */
+extern struct proto rawv6_prot;
+extern struct proto udpv6_prot;
+extern struct proto udplitev6_prot;
+extern struct proto tcpv6_prot;
+extern struct proto pingv6_prot;
 
 struct flowi6;
 
 /* extension headers */
-extern int		ipv6_exthdrs_init(void);
-extern void		ipv6_exthdrs_exit(void);
-extern int		ipv6_frag_init(void);
-extern void		ipv6_frag_exit(void);
+int ipv6_exthdrs_init(void);
+void ipv6_exthdrs_exit(void);
+int ipv6_frag_init(void);
+void ipv6_frag_exit(void);
 
 /* transport protocols */
-extern int		pingv6_init(void);
-extern void		pingv6_exit(void);
-extern int		rawv6_init(void);
-extern void		rawv6_exit(void);
-extern int		udpv6_init(void);
-extern void		udpv6_exit(void);
-extern int		udplitev6_init(void);
-extern void		udplitev6_exit(void);
-extern int		tcpv6_init(void);
-extern void		tcpv6_exit(void);
+int pingv6_init(void);
+void pingv6_exit(void);
+int rawv6_init(void);
+void rawv6_exit(void);
+int udpv6_init(void);
+void udpv6_exit(void);
+int udplitev6_init(void);
+void udplitev6_exit(void);
+int tcpv6_init(void);
+void tcpv6_exit(void);
 
-extern int		udpv6_connect(struct sock *sk,
-				      struct sockaddr *uaddr,
-				      int addr_len);
+int udpv6_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len);
 
-extern int		ip6_datagram_recv_ctl(struct sock *sk,
-					      struct msghdr *msg,
-					      struct sk_buff *skb);
+int ip6_datagram_recv_ctl(struct sock *sk, struct msghdr *msg,
+			  struct sk_buff *skb);
 
-extern int		ip6_datagram_send_ctl(struct net *net,
-					      struct sock *sk,
-					      struct msghdr *msg,
-					      struct flowi6 *fl6,
-					      struct ipv6_txoptions *opt,
-					      int *hlimit, int *tclass,
-					      int *dontfrag);
+int ip6_datagram_send_ctl(struct net *net, struct sock *sk, struct msghdr *msg,
+			  struct flowi6 *fl6, struct ipv6_txoptions *opt,
+			  int *hlimit, int *tclass, int *dontfrag);
 
-extern void		ip6_dgram_sock_seq_show(struct seq_file *seq,
-						struct sock *sp,
-						__u16 srcp,
-						__u16 destp,
-						int bucket);
+void ip6_dgram_sock_seq_show(struct seq_file *seq, struct sock *sp,
+			     __u16 srcp, __u16 destp, int bucket);
 
-#define		LOOPBACK4_IPV6		cpu_to_be32(0x7f000006)
+#define LOOPBACK4_IPV6 cpu_to_be32(0x7f000006)
 
-/*
- *	address family specific functions
- */
+/* address family specific functions */
 extern const struct inet_connection_sock_af_ops ipv4_specific;
 
-extern void inet6_destroy_sock(struct sock *sk);
+void inet6_destroy_sock(struct sock *sk);
 
-#define IPV6_SEQ_DGRAM_HEADER \
-			   "  sl  "					\
-			   "local_address                         "	\
-			   "remote_address                        "	\
-			   "st tx_queue rx_queue tr tm->when retrnsmt"	\
-			   "   uid  timeout inode ref pointer drops\n"
+#define IPV6_SEQ_DGRAM_HEADER					       \
+	"  sl  "						       \
+	"local_address                         "		       \
+	"remote_address                        "		       \
+	"st tx_queue rx_queue tr tm->when retrnsmt"		       \
+	"   uid  timeout inode ref pointer drops\n"
 
 #endif
