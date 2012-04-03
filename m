From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V3 net-next 19/28] mv643xx_eth: Support the get_ts_info ethtool method.
Date: Tue,  3 Apr 2012 19:47:43 +0200
Message-ID: <50016870dd63c9df2dc66855275ee410bce39500.1333474524.git.richardcochran@gmail.com>
References: <cover.1333474520.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Martin Porter <mporter@solarflare.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:60390 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755376Ab2DCRt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 13:49:29 -0400
Received: by mail-we0-f174.google.com with SMTP id x9so2519946wej.19
        for <netdev@vger.kernel.org>; Tue, 03 Apr 2012 10:49:28 -0700 (PDT)
In-Reply-To: <cover.1333474520.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333474520.git.richardcochran@gmail.com>
References: <cover.1333474520.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 75af1af..153d332 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1666,6 +1666,7 @@ static const struct ethtool_ops mv643xx_eth_ethtool_ops = {
 	.get_strings		= mv643xx_eth_get_strings,
 	.get_ethtool_stats	= mv643xx_eth_get_ethtool_stats,
 	.get_sset_count		= mv643xx_eth_get_sset_count,
+	.get_ts_info		= ethtool_op_get_ts_info,
 };
 
 
-- 
1.7.2.5
