From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 0/2] tunnels: don't allow to add the same tunnel twice
Date: Fri, 11 Apr 2014 15:51:17 +0200
Message-ID: <1397224279-4161-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:37691 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932081AbaDKNv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 09:51:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This serie fix the check of an existing tunnel with the same parameters when
a new tunnel is added.
I've checked all users of ip_tunnel_newlink(): gre, gretap, ipip and vti. The
bug exists only for gre and vti.

 net/ipv4/ip_gre.c | 2 +-
 net/ipv4/ip_vti.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

Regards,
Nicolas
