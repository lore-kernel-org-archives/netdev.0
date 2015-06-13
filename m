From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: tcp_v6_connect() cleanup
Date: Fri, 12 Jun 2015 19:34:03 -0700
Message-ID: <1434162843.27504.114.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35249 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbbFMCeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 22:34:05 -0400
Received: by pacyx8 with SMTP id yx8so31692515pac.2
        for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 19:34:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Remove dead code from tcp_v6_connect()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/tcp_ipv6.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 45a7176ed460681558808439f20e1622423f4c32..6748c4277affad71cd721e3a985af10c31c047ad 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -120,7 +120,6 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct in6_addr *saddr = NULL, *final_p, final;
-	struct rt6_info *rt;
 	struct flowi6 fl6;
 	struct dst_entry *dst;
 	int addr_type;
@@ -258,7 +257,6 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	sk->sk_gso_type = SKB_GSO_TCPV6;
 	__ip6_dst_store(sk, dst, NULL, NULL);
 
-	rt = (struct rt6_info *) dst;
 	if (tcp_death_row.sysctl_tw_recycle &&
 	    !tp->rx_opt.ts_recent_stamp &&
 	    ipv6_addr_equal(&fl6.daddr, &sk->sk_v6_daddr))
