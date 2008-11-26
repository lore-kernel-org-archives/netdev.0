From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 1/4 2.6.29] cxgb3 - set hard_xmit in the netdev_ops
Date: Wed, 26 Nov 2008 12:38:14 -0800
Message-ID: <20081126203814.4786.93917.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:11440 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150AbYKZUiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 15:38:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Fix t3_eth_xmit() missing into the netdev_ops structure.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index cd9fcac..96c94a4 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2831,6 +2831,7 @@ static void __devinit print_port_info(struct adapter *adap,
 static const struct net_device_ops cxgb_netdev_ops = {
 	.ndo_open		= cxgb_open,
 	.ndo_stop		= cxgb_close,
+	.ndo_start_xmit		= t3_eth_xmit,
 	.ndo_get_stats		= cxgb_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_multicast_list	= cxgb_set_rxmode,

