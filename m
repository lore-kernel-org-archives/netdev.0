From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [RFC 0/1] tcp: constify congestion_ops
Date: Tue,  1 Aug 2017 19:49:42 -0700
Message-ID: <20170802024943.7517-1-sthemmin@microsoft.com>
Cc: Stephen Hemminger <sthemmin@microsoft.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:37116 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751655AbdHBCtr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 22:49:47 -0400
Received: by mail-pg0-f41.google.com with SMTP id y129so15452477pgy.4
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 19:49:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a proposed method of making TCP congestion_ops structure const.

I wonder if restricting congestion control choices is still necessary?
It seems like being overly paranoid, and better enforced by having a more
limited kernel config, seccomp or other mechanism.

Stephen Hemminger (1):
  constify tcp congestion

 include/net/tcp.h        |  10 ++-
 net/ipv4/tcp.c           |   2 -
 net/ipv4/tcp_bbr.c       |   2 +-
 net/ipv4/tcp_bic.c       |   2 +-
 net/ipv4/tcp_cdg.c       |   2 +-
 net/ipv4/tcp_cong.c      | 162 +++++++++++++++++++++++++++++------------------
 net/ipv4/tcp_cubic.c     |   2 +-
 net/ipv4/tcp_dctcp.c     |   6 +-
 net/ipv4/tcp_highspeed.c |   2 +-
 net/ipv4/tcp_htcp.c      |   2 +-
 net/ipv4/tcp_hybla.c     |   2 +-
 net/ipv4/tcp_illinois.c  |   2 +-
 net/ipv4/tcp_lp.c        |   2 +-
 net/ipv4/tcp_nv.c        |   2 +-
 net/ipv4/tcp_scalable.c  |   2 +-
 net/ipv4/tcp_vegas.c     |   2 +-
 net/ipv4/tcp_veno.c      |   2 +-
 net/ipv4/tcp_westwood.c  |   2 +-
 net/ipv4/tcp_yeah.c      |   2 +-
 19 files changed, 124 insertions(+), 86 deletions(-)

-- 
2.11.0
