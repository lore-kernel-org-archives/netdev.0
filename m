From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 3/4] bond: implement [add/del]_slave ops
Date: Sun, 13 Feb 2011 20:33:01 +0100
Message-ID: <20110213193300.GF2740@psychotron.redhat.com>
References: <20110213193105.GD2740@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9621 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754762Ab1BMTdH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Feb 2011 14:33:07 -0500
Content-Disposition: inline
In-Reply-To: <20110213193105.GD2740@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

allow enslaving/releasing using netlink interface

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/bonding/bond_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 9f87787..77e3c6a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4657,6 +4657,8 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_netpoll_cleanup	= bond_netpoll_cleanup,
 	.ndo_poll_controller	= bond_poll_controller,
 #endif
+	.ndo_add_slave		= bond_enslave,
+	.ndo_del_slave		= bond_release,
 };
 
 static void bond_destructor(struct net_device *bond_dev)
-- 
1.7.3.4

