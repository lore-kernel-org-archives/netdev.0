From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V4 net-next 12/26] fec_mpc52xx: Support the get_ts_info ethtool method.
Date: Wed,  4 Apr 2012 10:59:27 +0200
Message-ID: <bd4d7790b229dd8e2008f61beeeb158ad527744f.1333529506.git.richardcochran@gmail.com>
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
Received: from mail-wi0-f178.google.com ([209.85.212.178]:56918 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932128Ab2DDJAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 05:00:48 -0400
Received: by wibhq7 with SMTP id hq7so46678wib.1
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2012 02:00:47 -0700 (PDT)
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
References: <cover.1333529504.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/freescale/fec_mpc52xx.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.c b/drivers/net/ethernet/freescale/fec_mpc52xx.c
index 7b34d8c..97f947b 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx.c
@@ -811,6 +811,7 @@ static const struct ethtool_ops mpc52xx_fec_ethtool_ops = {
 	.get_link = ethtool_op_get_link,
 	.get_msglevel = mpc52xx_fec_get_msglevel,
 	.set_msglevel = mpc52xx_fec_set_msglevel,
+	.get_ts_info = ethtool_op_get_ts_info,
 };
 
 
-- 
1.7.2.5
