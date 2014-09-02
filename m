From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH net-next 0/4] ipv6: coding style improvements
Date: Tue,  2 Sep 2014 20:16:00 +0100
Message-ID: <1409685364-4327-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:36323 "EHLO
	oak.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750954AbaIBTQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 15:16:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This sequences of patches makes adjustments to the ipv6 code to try to better
follow the kernel coding style guidelines. No changes to the resultant object
code is detected by objdiff.

Ian Morris (4):
  ipv6: coding style - no assignment in if statements
  ipv6: coding style - min to min_t conversion
  ipv6: coding style - convert printk
  ipv6: coding style - cleanse bracing

 net/ipv6/addrconf.c       |   30 ++++++++++++++++------------
 net/ipv6/addrconf_core.c  |    3 +--
 net/ipv6/ah6.c            |    7 ++++---
 net/ipv6/datagram.c       |    3 ++-
 net/ipv6/esp6.c           |    3 ++-
 net/ipv6/exthdrs_core.c   |    6 +++---
 net/ipv6/icmp.c           |    3 ++-
 net/ipv6/ip6_fib.c        |    4 ++--
 net/ipv6/ip6_flowlabel.c  |    9 ++++++---
 net/ipv6/ip6_gre.c        |    4 ++--
 net/ipv6/ip6_input.c      |   16 +++++++--------
 net/ipv6/ip6_output.c     |   32 ++++++++++++++++--------------
 net/ipv6/ip6_tunnel.c     |   22 ++++++++++-----------
 net/ipv6/ip6_vti.c        |    4 ++--
 net/ipv6/ip6mr.c          |   13 ++++++------
 net/ipv6/ipv6_sockglue.c  |    7 ++++---
 net/ipv6/mcast.c          |   48 ++++++++++++++++++++++++++-------------------
 net/ipv6/ndisc.c          |   25 ++++++++++-------------
 net/ipv6/ping.c           |    8 ++++----
 net/ipv6/raw.c            |    3 ++-
 net/ipv6/reassembly.c     |    3 ++-
 net/ipv6/route.c          |   25 +++++++++++------------
 net/ipv6/sit.c            |    7 ++++---
 net/ipv6/tcp_ipv6.c       |   10 ++++++----
 net/ipv6/udp.c            |   26 ++++++++++++------------
 net/ipv6/xfrm6_output.c   |    4 ++--
 net/ipv6/xfrm6_protocol.c |   25 ++++++++++++++---------
 net/ipv6/xfrm6_tunnel.c   |    3 ++-
 28 files changed, 191 insertions(+), 162 deletions(-)

-- 
1.7.9.5
