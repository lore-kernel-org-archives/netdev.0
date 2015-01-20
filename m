From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 0/6] netns: advertise netns via netlink
Date: Tue, 20 Jan 2015 15:15:41 +0100
Message-ID: <1421763347-4354-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:53799 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752008AbbATOP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 09:15:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The first patch of the serie fix a bug of the previous serie (present in
net-next only).
The rest of the serie adds an attribute to advertise the peer netns for
rtnetlink messages where this information is needed by userland to be able to
interpret fully the received message.

 drivers/net/macvlan.c          | 6 ++++++
 drivers/net/veth.c             | 9 +++++++++
 drivers/net/vxlan.c            | 5 +++++
 include/uapi/linux/neighbour.h | 1 +
 net/8021q/vlan_netlink.c       | 8 ++++++++
 net/core/net_namespace.c       | 1 +
 net/core/rtnetlink.c           | 5 ++++-
 net/ipv6/ip6_gre.c             | 1 +
 8 files changed, 35 insertions(+), 1 deletion(-)

Comments are welcome.

Regards,
Nicolas
