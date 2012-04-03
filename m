From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V3 net-next 12/28] e100: Support the get_ts_info ethtool method.
Date: Tue,  3 Apr 2012 19:47:36 +0200
Message-ID: <a0276661be73a831aaf3c5b277c9c0340e3bbafd.1333474523.git.richardcochran@gmail.com>
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
Received: from mail-wg0-f44.google.com ([74.125.82.44]:60989 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753684Ab2DCRtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 13:49:00 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so3975805wgb.1
        for <netdev@vger.kernel.org>; Tue, 03 Apr 2012 10:49:00 -0700 (PDT)
In-Reply-To: <cover.1333474520.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333474520.git.richardcochran@gmail.com>
References: <cover.1333474520.git.richardcochran@gmail.com>
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
