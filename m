From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 00/15] tcp: move 14 sysctls to namespaces
Date: Thu, 26 Oct 2017 21:54:55 -0700
Message-ID: <20171027045510.5827-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:52169 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751283AbdJ0EzQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 00:55:16 -0400
Received: by mail-io0-f170.google.com with SMTP id b186so10132009iof.8
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 21:55:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ideally all TCP sysctls should be per netns.
This patch series takes care of 14 of sysctls.
More to come later.

Eric Dumazet (15):
  tcp: Namespace-ify sysctl_tcp_early_retrans
  tcp: Namespace-ify sysctl_tcp_recovery
  tcp: Namespace-ify sysctl_tcp_thin_linear_timeouts
  tcp: Namespace-ify sysctl_tcp_slow_start_after_idle
  tcp: Namespace-ify sysctl_tcp_retrans_collapse
  tcp: Namespace-ify sysctl_tcp_stdurg
  tcp: Namespace-ify sysctl_tcp_rfc1337
  tcp: Namespace-ify sysctl_tcp_abort_on_overflow
  tcp: Namespace-ify sysctl_tcp_fack
  tcp: remove stale sysctl_tcp_reordering
  tcp: Namespace-ify sysctl_tcp_max_reordering
  tcp: Namespace-ify sysctl_tcp_dsack
  tcp: Namespace-ify sysctl_tcp_app_win
  tcp: Namespace-ify sysctl_tcp_adv_win_scale
  tcp: Namespace-ify sysctl_tcp_frto

 include/net/netns/ipv4.h   |  14 ++++
 include/net/tcp.h          |  27 ++----
 net/ipv4/sysctl_net_ipv4.c | 204 ++++++++++++++++++++++-----------------------
 net/ipv4/tcp.c             |   2 +-
 net/ipv4/tcp_input.c       |  42 ++++------
 net/ipv4/tcp_ipv4.c        |   9 ++
 net/ipv4/tcp_minisocks.c   |   8 +-
 net/ipv4/tcp_output.c      |  14 ++--
 net/ipv4/tcp_recovery.c    |   2 -
 net/ipv4/tcp_timer.c       |   4 +-
 10 files changed, 157 insertions(+), 169 deletions(-)

-- 
2.15.0.rc2.357.g7e34df9404-goog
