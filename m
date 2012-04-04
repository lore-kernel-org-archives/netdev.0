From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V4 net-next 25/26] ucc_geth: Support the get_ts_info ethtool method.
Date: Wed,  4 Apr 2012 10:59:40 +0200
Message-ID: <71c0192e5e06215d116019348e57be12fd62c9dd.1333529506.git.richardcochran@gmail.com>
References: <cover.1333529504.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Martin Porter <mporter@solarflare.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:63894 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932096Ab2DDJBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 05:01:45 -0400
Received: by mail-we0-f174.google.com with SMTP id x9so25497wej.19
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2012 02:01:44 -0700 (PDT)
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
References: <cover.1333529504.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/freescale/ucc_geth_ethtool.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth_ethtool.c b/drivers/net/ethernet/freescale/ucc_geth_ethtool.c
index a97257f..37b0353 100644
--- a/drivers/net/ethernet/freescale/ucc_geth_ethtool.c
+++ b/drivers/net/ethernet/freescale/ucc_geth_ethtool.c
@@ -415,6 +415,7 @@ static const struct ethtool_ops uec_ethtool_ops = {
 	.get_ethtool_stats      = uec_get_ethtool_stats,
 	.get_wol		= uec_get_wol,
 	.set_wol		= uec_set_wol,
+	.get_ts_info		= ethtool_op_get_ts_info,
 };
 
 void uec_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.2.5
