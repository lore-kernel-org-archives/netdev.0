From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH v4 1/4] Clean up indentation in net/ipv6/transp_v6.h
Date: Sat,  1 Jun 2013 10:05:47 +0900
Message-ID: <1370048750-28441-1-git-send-email-lorenzo@google.com>
Cc: Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Vasiliy Kulikov <segoon@openwall.com>,
	Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f74.google.com ([209.85.212.74]:38513 "EHLO
	mail-vb0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755092Ab3FABMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 21:12:17 -0400
Received: by mail-vb0-f74.google.com with SMTP id w15so206164vbf.5
        for <netdev@vger.kernel.org>; Fri, 31 May 2013 18:12:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce the indentation of most of the functions and make it a
bit more consistent. This allows longer function and arg names
to be consistently indented without wrapping.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/net/transp_v6.h | 70 ++++++++++++++++++++++++-------------------------
 1 file changed, 35 insertions(+), 35 deletions(-)

diff --git a/include/net/transp_v6.h b/include/net/transp_v6.h
index eb40e71..2d9d0e3 100644
--- a/include/net/transp_v6.h
+++ b/include/net/transp_v6.h
@@ -7,47 +7,47 @@
  *	IPv6 transport protocols
  */
 
-extern struct proto rawv6_prot;
-extern struct proto udpv6_prot;
-extern struct proto udplitev6_prot;
-extern struct proto tcpv6_prot;
-extern struct proto pingv6_prot;
+extern struct proto     rawv6_prot;
+extern struct proto     udpv6_prot;
+extern struct proto     udplitev6_prot;
+extern struct proto     tcpv6_prot;
+extern struct proto     pingv6_prot;
 
 struct flowi6;
 
 /* extension headers */
-extern int				ipv6_exthdrs_init(void);
-extern void				ipv6_exthdrs_exit(void);
-extern int				ipv6_frag_init(void);
-extern void				ipv6_frag_exit(void);
+extern int		ipv6_exthdrs_init(void);
+extern void		ipv6_exthdrs_exit(void);
+extern int		ipv6_frag_init(void);
+extern void		ipv6_frag_exit(void);
 
 /* transport protocols */
-extern int				pingv6_init(void);
-extern void				pingv6_exit(void);
-extern int				rawv6_init(void);
-extern void				rawv6_exit(void);
-extern int				udpv6_init(void);
-extern void				udpv6_exit(void);
-extern int 				udplitev6_init(void);
-extern void 				udplitev6_exit(void);
-extern int				tcpv6_init(void);
-extern void				tcpv6_exit(void);
-
-extern int				udpv6_connect(struct sock *sk,
-						      struct sockaddr *uaddr,
-						      int addr_len);
-
-extern int			ip6_datagram_recv_ctl(struct sock *sk,
-						      struct msghdr *msg,
-						      struct sk_buff *skb);
-
-extern int			ip6_datagram_send_ctl(struct net *net,
-						      struct sock *sk,
-						      struct msghdr *msg,
-						      struct flowi6 *fl6,
-						      struct ipv6_txoptions *opt,
-						      int *hlimit, int *tclass,
-						      int *dontfrag);
+extern int		pingv6_init(void);
+extern void		pingv6_exit(void);
+extern int		rawv6_init(void);
+extern void		rawv6_exit(void);
+extern int		udpv6_init(void);
+extern void		udpv6_exit(void);
+extern int		udplitev6_init(void);
+extern void		udplitev6_exit(void);
+extern int		tcpv6_init(void);
+extern void		tcpv6_exit(void);
+
+extern int		udpv6_connect(struct sock *sk,
+				      struct sockaddr *uaddr,
+				      int addr_len);
+
+extern int		ip6_datagram_recv_ctl(struct sock *sk,
+					      struct msghdr *msg,
+					      struct sk_buff *skb);
+
+extern int		ip6_datagram_send_ctl(struct net *net,
+					      struct sock *sk,
+					      struct msghdr *msg,
+					      struct flowi6 *fl6,
+					      struct ipv6_txoptions *opt,
+					      int *hlimit, int *tclass,
+					      int *dontfrag);
 
 #define		LOOPBACK4_IPV6		cpu_to_be32(0x7f000006)
 
-- 
1.8.2.1
