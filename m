From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 01/11] sfc: efx_ethtool_get_ts_info() can be static
Date: Sat, 21 Sep 2013 19:33:04 +0100
Message-ID: <1379788384.1681.35.camel@bwh-desktop.uk.level5networks.com>
References: <1379788283.1681.34.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Fengguang Wu <fengguang.wu@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:32561 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969Ab3IUSdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 14:33:08 -0400
In-Reply-To: <1379788283.1681.34.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fengguang Wu <fengguang.wu@intel.com>

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 5b471cf..c8dc407 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -1035,8 +1035,8 @@ static int efx_ethtool_set_rxfh_indir(struct net_device *net_dev,
 	return 0;
 }
 
-int efx_ethtool_get_ts_info(struct net_device *net_dev,
-			    struct ethtool_ts_info *ts_info)
+static int efx_ethtool_get_ts_info(struct net_device *net_dev,
+				   struct ethtool_ts_info *ts_info)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
