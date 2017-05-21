From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 0/4] net: Add extack for route add/delete failures
Date: Sun, 21 May 2017 10:12:01 -0600
Message-ID: <20170521161205.36720-1-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:34825 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756191AbdEUQMS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 12:12:18 -0400
Received: by mail-pg0-f43.google.com with SMTP id q125so57125936pgq.2
        for <netdev@vger.kernel.org>; Sun, 21 May 2017 09:12:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the extack feature to improve error messages to user on route
add and delete failures.

David Ahern (4):
  net: ipv4: Plumb extack through route add functions
  net: ipv4: Add extack messages for route add failures
  net: ipv6: Plumb extack through route add functions
  net: ipv6: Add extack messages for route add failures

 include/linux/netlink.h  |   5 ++
 include/net/ip6_fib.h    |   3 +-
 include/net/ip6_route.h  |   2 +-
 include/net/ip_fib.h     |   3 +-
 net/ipv4/fib_frontend.c  |  18 ++++---
 net/ipv4/fib_lookup.h    |   3 +-
 net/ipv4/fib_semantics.c | 133 ++++++++++++++++++++++++++++++++++++-----------
 net/ipv4/fib_trie.c      |   4 +-
 net/ipv6/addrconf.c      |   4 +-
 net/ipv6/ip6_fib.c       |  18 +++++--
 net/ipv6/route.c         |  97 ++++++++++++++++++++++------------
 11 files changed, 208 insertions(+), 82 deletions(-)

-- 
2.11.0 (Apple Git-81)
