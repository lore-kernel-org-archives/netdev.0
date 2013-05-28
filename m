From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 0/2] Add support of IPv4 over IPv4 for module sit
Date: Tue, 28 May 2013 11:48:14 +0200
Message-ID: <1369734496-21961-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:42075 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933792Ab3E1JtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 05:49:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of this serie is to be able to have IPv4 and IPv6 adresses over the
same IPv4 tunnel interface. Before this patch, even if encapsulation addresses
were the same, two interfaces were needed to have 4in4 and 6in4: one 'ipip'
interface and one 'sit' interface.
Now, it's possible to configure the mode of the 'sit' interface: 6in4, 4in4 or
both and thus have only one interface for 6in4 and 4in4.

The patch against iproute2 will be sent once the patches are included and
net-next merged. I can send it on demand.

 include/net/ip_tunnels.h |   2 +-
 net/ipv4/ip_gre.c        |   2 +-
 net/ipv4/ip_tunnel.c     |   4 +-
 net/ipv4/ipip.c          |   2 +-
 net/ipv4/xfrm4_tunnel.c  |   2 +-
 net/ipv6/sit.c           | 119 +++++++++++++++++++++++++++++++++++++++++++++--
 6 files changed, 122 insertions(+), 9 deletions(-)

Comments are welcome.

Regards,
Nicolas
