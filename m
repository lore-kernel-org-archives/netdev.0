From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 0/4] Allow to deactivate fb tunnels device
Date: Fri, 16 Nov 2012 17:14:12 +0100
Message-ID: <1353082456-21234-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:37991 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752185Ab2KPQNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 11:13:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This serie proposes a module option to avoid the creation of the fb tunnels
device for sit/ipip/ip6tnl.
It also add netlink management for 6RD tunnels. The last info that still
requires ioctl is the management of the potential routers list (prl) for isatap
(note that this ioctl is not performed on the fb device).

As usual, the patch against iproute2 will be sent once the patches are included and
net-next merged. I can send it on demand.

 include/uapi/linux/if_tunnel.h |   4 +
 net/ipv4/ipip.c                |  42 ++++----
 net/ipv6/ip6_tunnel.c          |  43 +++++----
 net/ipv6/sit.c                 | 211 ++++++++++++++++++++++++++++++++---------
 4 files changed, 221 insertions(+), 79 deletions(-)

Comments are welcome.

Regards,
Nicolas
