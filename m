From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next 0/7] nfp: extend match and action for flower offload
Date: Fri,  6 Oct 2017 10:21:19 +0200
Message-ID: <1507278086-3102-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:56015 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbdJFIVa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 04:21:30 -0400
Received: by mail-wm0-f47.google.com with SMTP id u138so6352297wmu.4
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 01:21:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pieter says:

This series extends flower offload match and action capabilities. It
specifically adds offload capabilities for matching on MPLS, TTL, TOS
and flow label. Furthermore offload capabilities for action have been
expanded to include set ethernet, ipv4, ipv6, tcp and udp headers.

Pieter Jansen van Vuuren (7):
  nfp: add mpls match offloading support
  nfp: add IPv4 ttl and tos match offloading support
  nfp: add IPv6 ttl and tos match offloading support
  nfp: add set ethernet header action flower offload
  nfp: add set ipv4 header action flower offload
  nfp: add set ipv6 source and destination address
  nfp: add set tcp and udp header action flower offload

 drivers/net/ethernet/netronome/nfp/flower/action.c | 245 +++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/flower/cmsg.h   |  43 ++++
 drivers/net/ethernet/netronome/nfp/flower/match.c  |  39 +++-
 .../net/ethernet/netronome/nfp/flower/offload.c    |  20 +-
 4 files changed, 324 insertions(+), 23 deletions(-)

-- 
2.1.4
