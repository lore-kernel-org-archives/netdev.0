From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 0/3] inet: tcp listener refactoring, part 9
Date: Fri, 13 Mar 2015 15:51:09 -0700
Message-ID: <1426287072-22175-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:34396 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113AbbCMWvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 18:51:15 -0400
Received: by yhaf73 with SMTP id f73so4310727yha.1
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 15:51:14 -0700 (PDT)
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
 net/ipv4/inet_diag.c  | 150 ++++++++++++++++----------------------------------
 net/ipv4/syncookies.c |   2 +
 net/ipv4/tcp_input.c  |   3 +
 net/ipv6/tcp_ipv6.c   |   2 -
 5 files changed, 54 insertions(+), 104 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
