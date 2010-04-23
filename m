From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH 0/3] IPv6: Add IPV6_RECVPATHMTU, IPV6_PATHMTU and IPV6_DONTFRAG support
Date: Fri, 23 Apr 2010 17:26:06 -0400
Message-ID: <1272057969-6526-1-git-send-email-brian.haley@hp.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:42502 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753516Ab0DWVei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 17:34:38 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds support for IPV6_RECVPATHMTU, IPV6_PATHMTU, and
IPV6_DONTFRAG socket options as defined in RFC 3542.

 include/linux/in6.h      |    2 +-
 include/linux/ipv6.h     |   15 +++++-
 include/net/ipv6.h       |    5 ++-
 include/net/transp_v6.h  |    3 +-
 net/ipv6/af_inet6.c      |    3 +
 net/ipv6/datagram.c      |  108 +++++++++++++++++++++++++++++++++++++++++++++-
 net/ipv6/icmp.c          |    5 +-
 net/ipv6/ip6_flowlabel.c |    3 +-
 net/ipv6/ip6_output.c    |   26 +++++++----
 net/ipv6/ipv6_sockglue.c |   49 ++++++++++++++++++++-
 net/ipv6/raw.c           |   12 ++++-
 net/ipv6/udp.c           |   12 ++++-
 12 files changed, 219 insertions(+), 24 deletions(-)
