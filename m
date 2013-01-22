From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 0/4] Use IS_ERR_OR_NULL().
Date: Wed, 23 Jan 2013 01:32:30 +0900
Message-ID: <50FEBF1E.6070209@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:51849 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753539Ab3AVQcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 11:32:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki (4):
  net: Use IS_ERR_OR_NULL().
  ipv4: Use IS_ERR_OR_NULL().
  ipv6: Use IS_ERR_OR_NULL().
  netfilter: Use IS_ERR_OR_NULL().

 net/core/flow.c                 |    2 +-
 net/ipv4/af_inet.c              |    2 +-
 net/ipv4/netfilter/arp_tables.c |   10 +++++-----
 net/ipv4/netfilter/ip_tables.c  |   10 +++++-----
 net/ipv4/tcp.c                  |    2 +-
 net/ipv4/udp.c                  |    2 +-
 net/ipv6/addrconf.c             |    4 ++--
 net/ipv6/netfilter/ip6_tables.c |   10 +++++-----
 8 files changed, 21 insertions(+), 21 deletions(-)

-- 
1.7.9.5
