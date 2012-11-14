From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 0/10] Add support of tunnel management via rtnetlink
Date: Wed, 14 Nov 2012 16:13:57 +0100
Message-ID: <1352906047-11604-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34719 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964800Ab2KNPQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 10:16:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of this serie is to add the support of ipip, sit and ip6tnl tunnels
via rtnetlink.

The patch against iproute2 will be sent once the patches are included and
net-next merged. I can send it on demand.

 include/uapi/linux/if_tunnel.h |   2 +
 net/ipv4/ipip.c                | 175 ++++++++++++++++++++++++++++++------
 net/ipv6/ip6_tunnel.c          | 177 +++++++++++++++++++++++++++++++-----
 net/ipv6/sit.c                 | 199 +++++++++++++++++++++++++++++++++--------
 4 files changed, 469 insertions(+), 84 deletions(-)

Comments are welcome.

Regards,
Nicolas
