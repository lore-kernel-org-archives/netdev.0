From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/4] tcp: Namespaceify 3 sysctls
Date: Wed,  7 Jun 2017 10:34:35 -0700
Message-ID: <20170607173439.17092-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:33275 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751441AbdFGReo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 13:34:44 -0400
Received: by mail-pg0-f41.google.com with SMTP id f185so7551027pgc.0
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 10:34:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move tcp_sack, tcp_window_scaling and tcp_timestamps
sysctls to network namespaces.

Eric Dumazet (4):
  tcp: add a struct net parameter to tcp_parse_options()
  tcp: Namespaceify sysctl_tcp_sack
  tcp: Namespaceify sysctl_tcp_window_scaling
  tcp: Namespaceify sysctl_tcp_timestamps

 drivers/infiniband/hw/cxgb4/cm.c |  2 +-
 include/net/netns/ipv4.h         |  3 +++
 include/net/secure_seq.h         |  5 +++--
 include/net/tcp.h                | 10 ++++------
 net/core/secure_seq.c            |  9 +++++----
 net/ipv4/syncookies.c            | 17 +++++++++-------
 net/ipv4/sysctl_net_ipv4.c       | 42 ++++++++++++++++++++--------------------
 net/ipv4/tcp_input.c             | 29 +++++++++++++--------------
 net/ipv4/tcp_ipv4.c              | 11 +++++++----
 net/ipv4/tcp_minisocks.c         |  4 ++--
 net/ipv4/tcp_output.c            | 13 +++++++------
 net/ipv6/syncookies.c            |  7 ++++---
 net/ipv6/tcp_ipv6.c              |  7 ++++---
 13 files changed, 86 insertions(+), 73 deletions(-)

-- 
2.13.0.506.g27d5fe0cd-goog
