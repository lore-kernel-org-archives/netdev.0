From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] xgmac: cleanups
Date: Wed, 4 Jan 2012 15:01:16 -0800
Message-ID: <20120104150116.2174467d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <rob.herring@calxeda.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37818 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757163Ab2ADXBS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jan 2012 18:01:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make local function static, make ethtool_ops const.
Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/ethernet/calxeda/xgmac.c	2011-12-07 10:54:18.724278422 -0800
+++ b/drivers/net/ethernet/calxeda/xgmac.c	2012-01-04 14:27:38.311770831 -0800
@@ -1440,7 +1440,7 @@ static void xgmac_poll_controller(struct
 }
 #endif
 
-struct rtnl_link_stats64 *
+static struct rtnl_link_stats64 *
 xgmac_get_stats64(struct net_device *dev,
 		       struct rtnl_link_stats64 *storage)
 {
@@ -1675,7 +1675,7 @@ static int xgmac_set_wol(struct net_devi
 	return 0;
 }
 
-static struct ethtool_ops xgmac_ethtool_ops = {
+static const struct ethtool_ops xgmac_ethtool_ops = {
 	.get_settings = xgmac_ethtool_getsettings,
 	.get_link = ethtool_op_get_link,
 	.get_pauseparam = xgmac_get_pauseparam,
