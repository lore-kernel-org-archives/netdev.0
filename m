From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH net-next 0/2] ipv6: coding style - comparisons with NULL
Date: Sun, 29 Mar 2015 14:00:03 +0100
Message-ID: <1427634005-4313-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:43483 "EHLO
	yew.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752881AbbC2NAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 09:00:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patches address some coding style issues only. No functional changes and no changes detected by objdiff.

The IPV6 code uses multiple different styles when comparing with NULL (I.e. x == NULL and !x as well as x != NULL and x). Generally the latter form is preferred according to checkpatch and so this changes aligns the code to this style. 

Ian Morris (2):
  ipv6: coding style: comparison for equality with NULL
  ipv6: coding style: comparison for inequality with NULL

 net/ipv6/addrconf.c        | 88 +++++++++++++++++++++++-----------------------
 net/ipv6/addrconf_core.c   |  2 +-
 net/ipv6/af_inet6.c        | 14 ++++----
 net/ipv6/ah6.c             |  2 +-
 net/ipv6/anycast.c         | 10 +++---
 net/ipv6/datagram.c        |  6 ++--
 net/ipv6/esp6.c            |  2 +-
 net/ipv6/exthdrs_core.c    | 10 +++---
 net/ipv6/icmp.c            | 13 ++++---
 net/ipv6/ip6_fib.c         |  4 +--
 net/ipv6/ip6_flowlabel.c   | 22 ++++++------
 net/ipv6/ip6_gre.c         | 14 ++++----
 net/ipv6/ip6_input.c       |  2 +-
 net/ipv6/ip6_offload.c     |  2 +-
 net/ipv6/ip6_output.c      | 24 ++++++-------
 net/ipv6/ip6_tunnel.c      | 12 +++----
 net/ipv6/ip6_vti.c         | 12 +++----
 net/ipv6/ip6mr.c           | 50 +++++++++++++-------------
 net/ipv6/ipv6_sockglue.c   | 10 +++---
 net/ipv6/mcast.c           | 30 ++++++++--------
 net/ipv6/ndisc.c           | 20 +++++------
 net/ipv6/raw.c             | 14 ++++----
 net/ipv6/reassembly.c      |  8 ++---
 net/ipv6/route.c           |  2 +-
 net/ipv6/sit.c             | 22 ++++++------
 net/ipv6/sysctl_net_ipv6.c |  2 +-
 net/ipv6/tcp_ipv6.c        | 20 +++++------
 net/ipv6/udp.c             | 14 ++++----
 net/ipv6/xfrm6_policy.c    |  2 +-
 29 files changed, 216 insertions(+), 217 deletions(-)

-- 
1.9.1
