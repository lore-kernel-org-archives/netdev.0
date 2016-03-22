From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/7] Refactor some internal library functions
Date: Tue, 22 Mar 2016 19:35:12 +0100
Message-ID: <1458671719-14361-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:43998 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751364AbcCVSgD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2016 14:36:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series is a result of reviewing color output support and
some formatting helpers usually used with struct rtattr fields.

Phil Sutter (7):
  color: introduce color helpers and COLOR_CLEAR
  ipaddress: colorize peer, broadcast and anycast addresses as well
  make format_host non-reentrant by default
  utils: make rt_addr_n2a() non-reentrant by default
  lib/utils: introduce format_host_rta()
  lib/utils: introduce rt_addr_n2a_rta()
  lib/ll_addr: improve ll_addr_n2a() a bit

 bridge/fdb.c          |  4 +--
 include/color.h       |  5 ++-
 include/utils.h       | 10 ++++--
 ip/ip6tunnel.c        |  4 +--
 ip/ipaddress.c        | 87 ++++++++++++++++++---------------------------------
 ip/ipaddrlabel.c      |  7 ++---
 ip/iplink_bond.c      |  7 +----
 ip/iplink_geneve.c    |  5 ++-
 ip/iplink_vxlan.c     | 13 ++++----
 ip/ipmaddr.c          |  6 +---
 ip/ipmroute.c         | 11 ++-----
 ip/ipneigh.c          |  6 +---
 ip/ipprefix.c         | 17 ++--------
 ip/iproute.c          | 68 ++++++++++++----------------------------
 ip/iproute_lwtunnel.c | 29 ++++-------------
 ip/iprule.c           | 39 +++++++----------------
 ip/iptoken.c          | 11 ++-----
 ip/iptunnel.c         |  8 ++---
 ip/ipxfrm.c           | 29 ++++-------------
 ip/link_gre.c         |  5 ++-
 ip/link_gre6.c        |  5 ++-
 ip/link_ip6tnl.c      | 11 ++-----
 ip/link_iptnl.c       |  7 ++---
 ip/link_vti.c         |  5 ++-
 ip/link_vti6.c        |  5 ++-
 ip/tcp_metrics.c      |  6 ++--
 ip/xfrm_monitor.c     | 16 ++--------
 lib/color.c           | 30 +++++++++++++++++-
 lib/ll_addr.c         | 15 ++-------
 lib/utils.c           | 20 ++++++++++--
 misc/ss.c             |  4 +--
 tc/f_flower.c         | 11 ++-----
 tc/m_nat.c            |  4 +--
 33 files changed, 187 insertions(+), 323 deletions(-)

-- 
2.7.2
