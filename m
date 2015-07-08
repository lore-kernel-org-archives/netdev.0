From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/3] inet: timewait cleanups
Date: Wed,  8 Jul 2015 14:28:27 -0700
Message-ID: <1436390910-13117-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:35390 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759162AbbGHV2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 17:28:37 -0400
Received: by iecuq6 with SMTP id uq6so164614400iec.2
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 14:28:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another round of patches to make tw handling simpler.

Eric Dumazet (3):
  inet: remove BUG_ON() in twsk_destructor()
  inet: simplify timewait refcounting
  inet: inet_twsk_deschedule factorization

 include/net/inet_hashtables.h    |  4 +--
 include/net/inet_timewait_sock.h |  8 +++---
 include/net/timewait_sock.h      |  3 ---
 net/ipv4/inet_hashtables.c       | 38 +++++++++------------------
 net/ipv4/inet_timewait_sock.c    | 55 ++++++++++------------------------------
 net/ipv4/tcp_ipv4.c              |  3 +--
 net/ipv4/tcp_minisocks.c         |  6 ++---
 net/ipv6/inet6_hashtables.c      |  9 ++-----
 net/ipv6/tcp_ipv6.c              |  3 +--
 net/netfilter/xt_TPROXY.c        |  6 ++---
 10 files changed, 39 insertions(+), 96 deletions(-)

-- 
2.4.3.573.g4eafbef
