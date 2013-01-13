From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 0/7] IPv6 updates
Date: Mon, 14 Jan 2013 00:02:56 +0900
Message-ID: <50F2CCA0.4080500@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:38249 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755019Ab3AMPC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 10:02:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

YOSHIFUJI Hideaki (7):
  ipv6: Introduce ip6_flow_hdr() to fill version, tclass and flowlabel.
  ipv6: Introduce ip6_flowinfo() to extract flowinfo (tclass +
    flowlabel).
  ipv6: Use ipv6_get_dsfield() instead of ipv6_tclass().
  ipv6: Make ipv6_is_mld() inline and use it from ip6_mc_input().
  ipv6 route: Use ipv6_addr_hash() in rt6_info_hash_nhsfn().
  ipv6 xfrm: Use ipv6_addr_hash() in xfrm6_tunnel_spi_hash_byaddr().
  ipv6: Store Router Alert option in IP6CB directly.

 include/linux/ipv6.h             |    8 ++------
 include/net/addrconf.h           |   26 +++++++++++++++++++++++++-
 include/net/ipv6.h               |   14 ++++++++++++++
 include/uapi/linux/ipv6.h        |    2 ++
 net/ipv6/datagram.c              |   12 +++++++-----
 net/ipv6/exthdrs.c               |    3 ++-
 net/ipv6/ip6_gre.c               |    6 ++----
 net/ipv6/ip6_input.c             |   26 +++++---------------------
 net/ipv6/ip6_output.c            |    8 +++-----
 net/ipv6/ip6_tunnel.c            |    4 +---
 net/ipv6/mcast.c                 |   27 ---------------------------
 net/ipv6/netfilter/ip6t_REJECT.c |    2 +-
 net/ipv6/route.c                 |   17 +++++------------
 net/ipv6/tcp_ipv6.c              |    6 +++---
 net/ipv6/xfrm6_tunnel.c          |    2 +-
 15 files changed, 73 insertions(+), 90 deletions(-)

-- 
1.7.9.5
