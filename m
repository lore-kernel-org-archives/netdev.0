From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net v2 0/4] ovs: fix rtnl notifications on interface deletion
Date: Mon, 13 Jun 2016 10:31:03 +0200
Message-ID: <1465806667-23148-1-git-send-email-nicolas.dichtel@6wind.com>
References: <CAOrHB_DCupNkAz+BSaOKKE+KLYhK-hytqW2vEV1yQ-iYr6hakg@mail.gmail.com>
Cc: netdev@vger.kernel.org, pshelar@ovn.org, jesse@kernel.org,
	linville@tuxdriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:38130 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964880AbcFMIbN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 04:31:13 -0400
In-Reply-To: <CAOrHB_DCupNkAz+BSaOKKE+KLYhK-hytqW2vEV1yQ-iYr6hakg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There was no rtnl notifications for interfaces (gre, vxlan, geneve) created
by ovs. This problem is fixed by adjusting the creation path.

v1 -> v2:
 - add patch #1 and #4
 - rework error handling in patch #2

 drivers/net/geneve.c | 14 ++++++++++---
 drivers/net/vxlan.c  | 58 ++++++++++++++++++++++++++++++----------------------
 net/ipv4/ip_gre.c    | 14 ++++++++++---
 3 files changed, 56 insertions(+), 30 deletions(-)

Regards,
Nicolas
