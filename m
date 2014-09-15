From: Andy Zhou <azhou@nicira.com>
Subject: [net-next v7 0/4] Refactor vxlan and l2tp to use common UDP tunnel APIs
Date: Mon, 15 Sep 2014 03:34:24 -0700
Message-ID: <1410777267-28237-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog123.obsmtp.com ([74.125.149.149]:48460 "HELO
	na3sys009aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753799AbaIOKkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 06:40:00 -0400
Received: by mail-pa0-f47.google.com with SMTP id ey11so6163057pad.6
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 03:39:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Zhou (4):
  udp_tunnel: Seperate ipv6 functions into its own file.
  udp-tunnel: Expand UDP tunnel APIs
  vxlan: Refactor vxlan driver to make use of the common UDP tunnel
    functions.
  l2tp: Refactor l2tp core driver to make use of the common UDP tunnel
    functions

 drivers/net/vxlan.c       |  105 ++++++++--------------------------
 include/net/udp_tunnel.h  |   83 ++++++++++++++++++++++++++-
 net/ipv4/udp_tunnel.c     |  138 ++++++++++++++++++++++++---------------------
 net/ipv6/Makefile         |    1 +
 net/ipv6/ip6_udp_tunnel.c |  105 ++++++++++++++++++++++++++++++++++
 net/l2tp/l2tp_core.c      |   24 ++++----
 6 files changed, 292 insertions(+), 164 deletions(-)
 create mode 100644 net/ipv6/ip6_udp_tunnel.c

-- 
1.7.9.5
