From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 net-next 12/28] e100: Support the get_ts_info ethtool method.
Date: Sun,  1 Apr 2012 17:19:57 +0200
Message-ID: <897c29ffcd27ff698a28b89b8ca9f1217d8e457c.1333289292.git.richardcochran@gmail.com>
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
Received: from mail-wi0-f170.google.com ([209.85.212.170]:59467 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751728Ab2DAPVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 11:21:18 -0400
Received: by wibhr17 with SMTP id hr17so1851393wib.1
        for <netdev@vger.kernel.org>; Sun, 01 Apr 2012 08:21:17 -0700 (PDT)
In-Reply-To: <cover.1333289292.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333289292.git.richardcochran@gmail.com>
References: <cover.1333289292.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/e100.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 8a1ba85..eb6b97d 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2735,6 +2735,7 @@ static const struct ethtool_ops e100_ethtool_ops = {
 	.set_phys_id		= e100_set_phys_id,
 	.get_ethtool_stats	= e100_get_ethtool_stats,
 	.get_sset_count		= e100_get_sset_count,
+	.get_ts_info		= ethtool_op_get_ts_info,
 };
 
 static int e100_do_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
-- 
1.7.2.5
