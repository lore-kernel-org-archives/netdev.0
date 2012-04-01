From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 net-next 20/28] pxa168_eth: Support the get_ts_info ethtool method.
Date: Sun,  1 Apr 2012 17:20:05 +0200
Message-ID: <dd9637282607fbd955c8ce98f057f31242d217ad.1333289292.git.richardcochran@gmail.com>
References: <cover.1333289292.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Martin Porter <mporter@solarflare.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:33711 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752044Ab2DAPVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 11:21:51 -0400
Received: by mail-wi0-f172.google.com with SMTP id hj6so1936554wib.1
        for <netdev@vger.kernel.org>; Sun, 01 Apr 2012 08:21:50 -0700 (PDT)
In-Reply-To: <cover.1333289292.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333289292.git.richardcochran@gmail.com>
References: <cover.1333289292.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/marvell/pxa168_eth.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 45a6333..44bad60 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1457,6 +1457,7 @@ static const struct ethtool_ops pxa168_ethtool_ops = {
 	.set_settings = pxa168_set_settings,
 	.get_drvinfo = pxa168_get_drvinfo,
 	.get_link = ethtool_op_get_link,
+	.get_ts_info = ethtool_op_get_ts_info,
 };
 
 static const struct net_device_ops pxa168_eth_netdev_ops = {
-- 
1.7.2.5
