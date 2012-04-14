From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/6] e100: Support the get_ts_info ethtool method.
Date: Sat, 14 Apr 2012 02:16:26 -0700
Message-ID: <1334394991-5839-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1334394991-5839-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:9989 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751726Ab2DNJQe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Apr 2012 05:16:34 -0400
In-Reply-To: <1334394991-5839-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e100.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index e498eff..e4d4c17 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2733,6 +2733,7 @@ static const struct ethtool_ops e100_ethtool_ops = {
 	.set_phys_id		= e100_set_phys_id,
 	.get_ethtool_stats	= e100_get_ethtool_stats,
 	.get_sset_count		= e100_get_sset_count,
+	.get_ts_info		= ethtool_op_get_ts_info,
 };
 
 static int e100_do_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
-- 
1.7.7.6
