From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V4 net-next 16/26] macb: Support the get_ts_info ethtool method.
Date: Wed,  4 Apr 2012 10:59:31 +0200
Message-ID: <696e4ad08075d6060f49555d909bdb7531aad0c6.1333529506.git.richardcochran@gmail.com>
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
	with ESMTP id S1755770Ab2DDJBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 05:01:03 -0400
Received: by wejx9 with SMTP id x9so25497wej.19
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2012 02:01:02 -0700 (PDT)
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
References: <cover.1333529504.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/cadence/macb.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index c4834c2..1466bc4 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1213,6 +1213,7 @@ static const struct ethtool_ops macb_ethtool_ops = {
 	.set_settings		= macb_set_settings,
 	.get_drvinfo		= macb_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
+	.get_ts_info		= ethtool_op_get_ts_info,
 };
 
 static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
-- 
1.7.2.5
