From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/4] net: remove clear_sk() method
Date: Tue, 23 Aug 2016 11:39:25 -0700
Message-ID: <1471977569-27190-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33794 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753849AbcHWSjs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 14:39:48 -0400
Received: by mail-pf0-f170.google.com with SMTP id p64so46214051pfb.1
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 11:39:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since IPv6 socket lookups no longer dereference pinet6 pointer
and UDP lost SLAB_DESTROY_BY_RCU special rules, we no longer
need special clear_sk() methods.

Eric Dumazet (4):
  ipv6: udp: remove udp_v6_clear_sk()
  udp: get rid of sk_prot_clear_portaddr_nulls()
  ipv6: tcp: get rid of tcp_v6_clear_sk()
  net: remove clear_sk() method

 include/net/sock.h  |  3 ---
 net/core/sock.c     | 26 ++------------------------
 net/ipv4/udp.c      |  1 -
 net/ipv4/udplite.c  |  1 -
 net/ipv6/tcp_ipv6.c | 12 ------------
 net/ipv6/udp.c      | 12 ------------
 net/ipv6/udp_impl.h |  2 --
 net/ipv6/udplite.c  |  1 -
 8 files changed, 2 insertions(+), 56 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
