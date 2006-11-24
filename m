From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 0/7][IP] IProute2 ip command updates
Date: Fri, 24 Nov 2006 12:31:23 +0900
Message-ID: <200611241231.23953.nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: takamiya@po.ntts.co.jp, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:55263 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S1757591AbWKXDb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Nov 2006 22:31:29 -0500
Content-Disposition: inline
To: shemminger@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

# First of all, I'm sorry I sent wrong email two times from
# "Masahide@neptune.linux-ipv6.org" which is not a valid addresss.
# Please delete them!

These are iproute2 updates. Please review and apply them.

o Modify IPv6 address lifetimes
o Introduce IPv6-over-IPv6 tunnel command

HEADLINES
---------

    [IP] ADDR: Fix print format for lifetimes.
    [IP] ADDR: Enable to add IPv6 address with valid/preferred lifetime.
    [IP] ADDR: Add the 'change' and 'replace' commands to the IPv6 address manipulation conte
xt.
    [IP] ADDR: Define 0xFFFFFFFFU as INFINITY_LIFE_TIME regarding to the kernel.
    [IP] TUNNEL: Split common functions to export them.
    [IP] TUNNEL: Import ip6tunnel.c.
    [IP] TUNNEL: IPv6-over-IPv6 tunnel support.

DIFFSTAT
--------

 include/linux/ip6_tunnel.h |   34 ++++
 ip/Makefile                |    2
 ip/ip6tunnel.c             |  387 ++++++++++++++++++++++++++++++++++++++++++++
 ip/ip_common.h             |    5 +
 ip/ipaddress.c             |   74 +++++++-
 ip/iptunnel.c              |  175 ++++----------------
 ip/tunnel.c                |  166 +++++++++++++++++++
 ip/tunnel.h                |   35 ++++
 8 files changed, 732 insertions(+), 146 deletions(-)


-- 
Masahide NAKAMURA
