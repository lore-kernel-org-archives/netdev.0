From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/3] netdev: make net_device_ops const
Date: Thu, 05 Jan 2012 21:10:25 -0800
Message-ID: <20120106051051.161455988@vyatta.com>
References: <20120106051022.712047093@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Sathya Perla <sathya.perla@emulex.com>,
	Chris Metcalf <cmetcalf@tilera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sfca-50.vyatta.com ([76.74.103.50]:35082 "EHLO fiji.vyatta.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750907Ab2AFFQk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jan 2012 00:16:40 -0500
Content-Disposition: inline; filename=netdev-ops-const3.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

More drivers where net_device_ops should be const.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/ethernet/emulex/benet/be_main.c |    2 +-
 drivers/net/ethernet/tile/tilepro.c         |    3 +--
 3 files changed, 3 insertions(+), 4 deletions(-)

--- a/drivers/net/ethernet/emulex/benet/be_main.c	2012-01-03 08:06:38.418232216 -0800
+++ b/drivers/net/ethernet/emulex/benet/be_main.c	2012-01-05 08:17:04.567161286 -0800
@@ -3080,7 +3080,7 @@ fw_exit:
 	return status;
 }
 
-static struct net_device_ops be_netdev_ops = {
+static const struct net_device_ops be_netdev_ops = {
 	.ndo_open		= be_open,
 	.ndo_stop		= be_close,
 	.ndo_start_xmit		= be_xmit,
--- a/drivers/net/ethernet/tile/tilepro.c	2011-12-23 21:06:15.724436897 -0800
+++ b/drivers/net/ethernet/tile/tilepro.c	2012-01-05 08:16:03.870511570 -0800
@@ -2260,8 +2260,7 @@ static int tile_net_get_mac(struct net_d
 	return 0;
 }
 
-
-static struct net_device_ops tile_net_ops = {
+static const struct net_device_ops tile_net_ops = {
 	.ndo_open = tile_net_open,
 	.ndo_stop = tile_net_stop,
 	.ndo_start_xmit = tile_net_tx,
