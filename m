From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [NET-NEXT PATCH] ixgbe: convert directly reference of netdev->priv
Date: Fri, 21 Nov 2008 17:32:54 +0800
Message-ID: <49268046.9020801@cn.fujitsu.com>
References: <20081121020055.22180.24154.stgit@gitlost.lost>	<49267BE8.6020205@cn.fujitsu.com> <20081121.012115.193683243.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, alexander.h.duyck@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64056 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751696AbYKUJdP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 04:33:15 -0500
In-Reply-To: <20081121.012115.193683243.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/ixgbe/ixgbe_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index aaa4404..ad9759d 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -99,7 +99,7 @@ static struct ixgbe_stats ixgbe_gstrings_stats[] = {
 	(sizeof(struct ixgbe_queue_stats) / sizeof(u64)))
 #define IXGBE_GLOBAL_STATS_LEN ARRAY_SIZE(ixgbe_gstrings_stats)
 #define IXGBE_PB_STATS_LEN ( \
-                 (((struct ixgbe_adapter *)netdev->priv)->flags & \
+                 (((struct ixgbe_adapter *)netdev_priv(netdev))->flags & \
                  IXGBE_FLAG_DCB_ENABLED) ? \
                  (sizeof(((struct ixgbe_adapter *)0)->stats.pxonrxc) + \
                   sizeof(((struct ixgbe_adapter *)0)->stats.pxontxc) + \
-- 
1.5.3.4

