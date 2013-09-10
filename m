From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/1] sfc: Staticize efx_ethtool_get_ts_info
Date: Tue, 10 Sep 2013 15:13:30 +0530
Message-ID: <1378806210-12155-1-git-send-email-sachin.kamat@linaro.org>
Cc: bhutchings@solarflare.com, linux-net-drivers@solarflare.com,
	sachin.kamat@linaro.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:52686 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011Ab3IJKBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 06:01:34 -0400
Received: by mail-pd0-f173.google.com with SMTP id p10so7379811pdj.18
        for <netdev@vger.kernel.org>; Tue, 10 Sep 2013 03:01:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'efx_ethtool_get_ts_info' is used only in this file.
Make it static.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 drivers/net/ethernet/sfc/ethtool.c |    4 ++--
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
1.7.9.5
