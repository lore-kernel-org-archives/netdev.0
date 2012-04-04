From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V4 net-next 24/26] tg3: Support the get_ts_info ethtool method.
Date: Wed,  4 Apr 2012 10:59:39 +0200
Message-ID: <5fa2acf571904362944268a3e7b7e42bb7f3a621.1333529506.git.richardcochran@gmail.com>
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
	with ESMTP id S1755770Ab2DDJBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 05:01:41 -0400
Received: by mail-we0-f174.google.com with SMTP id x9so25497wej.19
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2012 02:01:41 -0700 (PDT)
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
References: <cover.1333529504.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 7b71387..8609798 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -12233,6 +12233,7 @@ static const struct ethtool_ops tg3_ethtool_ops = {
 	.get_rxfh_indir_size    = tg3_get_rxfh_indir_size,
 	.get_rxfh_indir		= tg3_get_rxfh_indir,
 	.set_rxfh_indir		= tg3_set_rxfh_indir,
+	.get_ts_info		= ethtool_op_get_ts_info,
 };
 
 static struct rtnl_link_stats64 *tg3_get_stats64(struct net_device *dev,
-- 
1.7.2.5
