From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/3] tcp listener refactoring, part 9
Date: Fri, 13 Mar 2015 13:19:15 -0700
Message-ID: <1426277958-9772-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f73.google.com ([209.85.192.73]:33958 "EHLO
	mail-qg0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521AbbCMUZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 16:25:40 -0400
Received: by qgdq107 with SMTP id q107so4171845qgd.1
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 13:25:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This preliminary work pushes socket convergence a bit more:

1) request sock ir_iif is universally set

2) inet_diag can use common helpers to reduce LOC

Eric Dumazet (3):
  inet: fill request sock ir_iif for IPv4
  inet_diag: adjust inet_sk_diag_fill() bug condition
  inet_diag: factorize code in new inet_diag_msg_common_fill() helper

 net/dccp/ipv4.c       |   1 +
 net/ipv4/inet_diag.c  | 151 ++++++++++++++++----------------------------------
 net/ipv4/syncookies.c |   2 +
 net/ipv4/tcp_input.c  |   3 +
 net/ipv6/tcp_ipv6.c   |   2 -
 5 files changed, 55 insertions(+), 104 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
