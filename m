From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V4 net-next 19/26] r6040: Support the get_ts_info ethtool method.
Date: Wed,  4 Apr 2012 10:59:34 +0200
Message-ID: <9d6c7bddfbca1fc3660b208f100c91220ec0a2cd.1333529506.git.richardcochran@gmail.com>
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
	with ESMTP id S1755770Ab2DDJBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 05:01:20 -0400
Received: by mail-we0-f174.google.com with SMTP id x9so25497wej.19
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2012 02:01:19 -0700 (PDT)
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
References: <cover.1333529504.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/rdc/r6040.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index b96e192..a26307f 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -973,6 +973,7 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_settings		= netdev_get_settings,
 	.set_settings		= netdev_set_settings,
 	.get_link		= ethtool_op_get_link,
+	.get_ts_info		= ethtool_op_get_ts_info,
 };
 
 static const struct net_device_ops r6040_netdev_ops = {
-- 
1.7.2.5
