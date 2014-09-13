From: Andy Zhou <azhou@nicira.com>
Subject: [net-next v6 0/4] Refactor vxlan and l2tp to use common UDP tunnel APIs
Date: Fri, 12 Sep 2014 19:21:56 -0700
Message-ID: <1410574920-16486-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog114.obsmtp.com ([74.125.149.211]:60294 "HELO
	na3sys009aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751889AbaIMC13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 22:27:29 -0400
Received: by mail-pd0-f174.google.com with SMTP id v10so2408005pde.5
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 19:27:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Zhou (4):
  udp_tunnel: Seperate ipv6 functions into its own file.
  udp-tunnel: Expand UDP tunnel APIs
  vxlan: Refactor vxlan driver to make use of the common UDP tunnel
    functions.
  l2tp: Refactor l2tp core driver to make use of the common UDP tunnel
    functions

 drivers/net/vxlan.c       |  106 ++++++++--------------------------
 include/net/udp_tunnel.h  |   84 ++++++++++++++++++++++++++-
 net/ipv4/udp_tunnel.c     |  138 ++++++++++++++++++++++++---------------------
 net/ipv6/Makefile         |    1 +
 net/ipv6/ip6_udp_tunnel.c |  105 ++++++++++++++++++++++++++++++++++
 net/l2tp/l2tp_core.c      |   25 ++++----
 6 files changed, 295 insertions(+), 164 deletions(-)
 create mode 100644 net/ipv6/ip6_udp_tunnel.c

-- 
1.7.9.5
