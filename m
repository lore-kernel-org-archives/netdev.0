From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next 0/2] ip_tunnel: Allow policy-based routing through tunnels
Date: Wed, 19 Apr 2017 12:30:52 -0400
Message-ID: <20170419163054.31173-1-kraigatgoog@gmail.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f179.google.com ([209.85.216.179]:35083 "EHLO
        mail-qt0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934198AbdDSQa5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 12:30:57 -0400
Received: by mail-qt0-f179.google.com with SMTP id y33so23636563qta.2
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 09:30:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

iproute2 changes to follow.  Example usage:
  ip link add gre-test type gre local 10.0.0.1 remote 10.0.0.2 fwmark 0x4
  ip -detail link show gre-test
  ...
  ip link set gre-test type gre fwmark 0


Craig Gallek (2):
  ip6_tunnel: Allow policy-based routing through tunnels
  ip_tunnel: Allow policy-based routing through tunnels

 include/net/ip6_tunnel.h       |  2 ++
 include/net/ip_tunnels.h       |  5 +++--
 include/uapi/linux/if_tunnel.h |  3 +++
 net/ipv4/ip_gre.c              | 24 +++++++++++++++++-------
 net/ipv4/ip_tunnel.c           | 27 +++++++++++++++++----------
 net/ipv4/ip_vti.c              | 20 +++++++++++++++-----
 net/ipv4/ipip.c                | 24 +++++++++++++++++-------
 net/ipv6/ip6_gre.c             | 14 +++++++++++++-
 net/ipv6/ip6_tunnel.c          | 15 ++++++++++++++-
 net/ipv6/ip6_vti.c             | 10 +++++++++-
 net/ipv6/sit.c                 | 37 ++++++++++++++++++++++++-------------
 11 files changed, 134 insertions(+), 47 deletions(-)

-- 
2.12.2.816.g2cccc81164-goog
