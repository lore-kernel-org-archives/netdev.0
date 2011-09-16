From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] can-gw: add netlink based CAN routing
Date: Fri, 16 Sep 2011 18:55:35 -0400 (EDT)
Message-ID: <20110916.185535.1478839992833376282.davem@davemloft.net>
References: <4E5F955B.8030806@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sojkam1@fel.cvut.cz, pisa@cmp.felk.cvut.cz,
	hanzalek@fel.cvut.cz, oliver.hartkopp@volkswagen.de
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44433 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932454Ab1IPW5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 18:57:50 -0400
In-Reply-To: <4E5F955B.8030806@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Thu, 01 Sep 2011 16:23:23 +0200

> This patch adds a CAN Gateway/Router to route (and modify) CAN frames.
> 
> It is based on the PF_CAN core infrastructure for msg filtering and msg
> sending and can optionally modify routed CAN frames on the fly.
> CAN frames can *only* be routed between CAN network interfaces (one hop).
> They can be modified with AND/OR/XOR/SET operations as configured by the
> netlink configuration interface known e.g. from iptables. From the netlink
> view this can-gw implements RTM_{NEW|DEL|GET}ROUTE for PF_CAN.
> 
> The CAN specific userspace tool to manage CAN routing entries can be found in
> the CAN utils http://svn.berlios.de/wsvn/socketcan/trunk/can-utils/cangw.c
> at the SocketCAN SVN on BerliOS.
> 
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

Applied.
