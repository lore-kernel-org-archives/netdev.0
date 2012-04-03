From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V3 net-next 27/28] ucc_geth: Support the get_ts_info ethtool method.
Date: Tue,  3 Apr 2012 19:47:51 +0200
Message-ID: <f7df194f7d0e98f4c4ac14194b186db2a4195aeb.1333474525.git.richardcochran@gmail.com>
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
Received: from mail-wi0-f178.google.com ([209.85.212.178]:64626 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753921Ab2DCRuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 13:50:03 -0400
Received: by mail-wi0-f178.google.com with SMTP id hq7so3974680wib.1
        for <netdev@vger.kernel.org>; Tue, 03 Apr 2012 10:50:03 -0700 (PDT)
In-Reply-To: <cover.1333474520.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333474520.git.richardcochran@gmail.com>
References: <cover.1333474520.git.richardcochran@gmail.com>
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
