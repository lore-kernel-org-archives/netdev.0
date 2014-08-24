From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH net-next 0/3] IPV6 Code cleansing
Date: Sun, 24 Aug 2014 21:53:09 +0100
Message-ID: <1408913592-10630-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:46109 "EHLO
	oak.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753117AbaHXUxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 16:53:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This sequence of patches reduces the number of checkpatch issues in the ipv6
code. Other than changes to whitespace, there is no change to the code.

There are no changes to object output as detected by objdump.

Ian Morris (3):
  ipv6: White-space cleansing : Line Layouts
  ipv6: White-space cleansing : Structure layouts
  ipv6: White-space cleansing : gaps between function and symbol export

 net/ipv6/addrconf.c              |   12 ++---
 net/ipv6/af_inet6.c              |   12 ++---
 net/ipv6/ah6.c                   |   21 ++++----
 net/ipv6/datagram.c              |    8 +--
 net/ipv6/esp6.c                  |   15 +++---
 net/ipv6/exthdrs.c               |    2 +-
 net/ipv6/icmp.c                  |   10 ++--
 net/ipv6/inet6_connection_sock.c |    6 +--
 net/ipv6/inet6_hashtables.c      |    5 +-
 net/ipv6/ip6_flowlabel.c         |   19 ++++----
 net/ipv6/ip6_icmp.c              |    2 +-
 net/ipv6/ip6_input.c             |    6 +--
 net/ipv6/ip6_offload.c           |    2 +-
 net/ipv6/ip6_output.c            |   21 ++++----
 net/ipv6/ip6_tunnel.c            |   32 ++++++------
 net/ipv6/ip6mr.c                 |    4 +-
 net/ipv6/ipcomp6.c               |    6 +--
 net/ipv6/ipv6_sockglue.c         |   26 +++++-----
 net/ipv6/mcast.c                 |  100 +++++++++++++++++++-------------------
 net/ipv6/mip6.c                  |   10 ++--
 net/ipv6/ndisc.c                 |   17 +++----
 net/ipv6/output_core.c           |    2 +-
 net/ipv6/proc.c                  |    2 +-
 net/ipv6/raw.c                   |    8 +--
 net/ipv6/reassembly.c            |   12 ++---
 net/ipv6/route.c                 |   22 ++++-----
 net/ipv6/sit.c                   |   12 ++---
 net/ipv6/tunnel6.c               |    4 +-
 net/ipv6/udp.c                   |   18 +++----
 net/ipv6/xfrm6_input.c           |    6 +--
 net/ipv6/xfrm6_output.c          |    1 -
 net/ipv6/xfrm6_policy.c          |   22 ++++-----
 net/ipv6/xfrm6_state.c           |   14 +++---
 net/ipv6/xfrm6_tunnel.c          |    4 +-
 34 files changed, 216 insertions(+), 247 deletions(-)

-- 
1.7.9.5
