From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 0/2 v2] Add support of multicast static tree
Date: Mon, 21 Jan 2013 17:00:24 +0100
Message-ID: <1358784026-4071-1-git-send-email-nicolas.dichtel@6wind.com>
References: <OF894319C2.8EF01FDC-ON87257AFA.004BC5D6-85257AFA.004E0255@us.ibm.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	netdev-owner@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:51140 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859Ab3AUQIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 11:08:34 -0500
In-Reply-To: <OF894319C2.8EF01FDC-ON87257AFA.004BC5D6-85257AFA.004E0255@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of this serie is to add the support of proxy multicast, ie being able
to build a static multicast tree. In other words, it adds the support of (*,G)
mf[6]c entries.

v2: use INADDR_ANY instead of 0 for IPv4 addresses

 include/linux/mroute.h       |   2 +-
 include/linux/mroute6.h      |   2 +-
 include/uapi/linux/in6.h     |  15 ++----
 include/uapi/linux/mroute.h  |   3 ++
 include/uapi/linux/mroute6.h |   3 ++
 net/ipv4/ipmr.c              | 119 +++++++++++++++++++++++++++++++++++-----
 net/ipv6/ip6mr.c             | 126 ++++++++++++++++++++++++++++++++++++++-----
 7 files changed, 231 insertions(+), 39 deletions(-)

Comments are welcome.

Regards,
Nicolas
