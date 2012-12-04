From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 0/7] Allow to monitor multicast cache event via rtnetlink
Date: Tue,  4 Dec 2012 12:13:34 +0100
Message-ID: <1354619621-16016-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56623 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287Ab2LDLNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 06:13:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of this serie is to be able to monitor multicast activities via
rtnetlink.

The main changes are:
 - when user dumps mfc entries it now get all entries, included the unresolved
   cache.
 - kernel sends rtnetlink when it adds/deletes mfc entries.

As usual, the patch against iproute2 will be sent once the patches are included and
net-next merged. I can send it on demand.

 include/linux/inetdevice.h     |   3 +
 include/net/addrconf.h         |   3 +
 include/uapi/linux/netconf.h   |   1 +
 include/uapi/linux/rtnetlink.h |   8 +++
 net/ipv4/devinet.c             |  10 ++-
 net/ipv4/ipmr.c                | 107 +++++++++++++++++++++++++++++--
 net/ipv6/addrconf.c            |  10 ++-
 net/ipv6/ip6mr.c               | 141 +++++++++++++++++++++++++++++++++++------
 8 files changed, 253 insertions(+), 30 deletions(-)

Comments are welcome.

Regards,
Nicolas
