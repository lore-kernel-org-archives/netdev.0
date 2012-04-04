From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V4 net-next 11/26] etherh: Support the get_ts_info ethtool method.
Date: Wed,  4 Apr 2012 10:59:26 +0200
Message-ID: <ffc12114d76b15e3f84745952a8994dec4218bd3.1333529506.git.richardcochran@gmail.com>
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
Received: from mail-wg0-f44.google.com ([74.125.82.44]:56171 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932128Ab2DDJAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 05:00:43 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so46815wgb.1
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2012 02:00:42 -0700 (PDT)
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
References: <cover.1333529504.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/8390/etherh.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/8390/etherh.c b/drivers/net/ethernet/8390/etherh.c
index 48c4948..89cba45 100644
--- a/drivers/net/ethernet/8390/etherh.c
+++ b/drivers/net/ethernet/8390/etherh.c
@@ -635,6 +635,7 @@ static const struct ethtool_ops etherh_ethtool_ops = {
 	.get_settings	= etherh_get_settings,
 	.set_settings	= etherh_set_settings,
 	.get_drvinfo	= etherh_get_drvinfo,
+	.get_ts_info	= ethtool_op_get_ts_info,
 };
 
 static const struct net_device_ops etherh_netdev_ops = {
-- 
1.7.2.5
