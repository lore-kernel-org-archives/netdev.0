From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 0/2] Add support of multicast static tree
Date: Fri, 18 Jan 2013 17:59:36 +0100
Message-ID: <1358528378-2110-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:49600 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751572Ab3ARRHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 12:07:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of this serie is to add the support of proxy multicast, ie being able
to build a static multicast tree. In other words, it adds the support of (*,G)
mf[6]c entries.

 include/linux/mroute.h       |   2 +-
 include/linux/mroute6.h      |   2 +-
 include/uapi/linux/in6.h     |  15 ++----
 include/uapi/linux/mroute.h  |   3 ++
 include/uapi/linux/mroute6.h |   3 ++
 net/ipv4/ipmr.c              | 118 +++++++++++++++++++++++++++++++++++-----
 net/ipv6/ip6mr.c             | 126 ++++++++++++++++++++++++++++++++++++++-----
 7 files changed, 230 insertions(+), 39 deletions(-)

Comments are welcome.

Regards,
Nicolas
