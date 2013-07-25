From: Darren Hart <dvhart@linux.intel.com>
Subject: [PATCH net-next 1/2] pch_gbe: Use PCH_GBE_PHY_REGS_LEN instead of 32
Date: Wed, 24 Jul 2013 22:10:11 -0700
Message-ID: <b04d68ebb04aa2d4ab9392c5353a53c81be7b847.1374728627.git.dvhart@linux.intel.com>
References: <cover.1374728627.git.dvhart@linux.intel.com>
Cc: Darren Hart <dvhart@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Linux Net Dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:11242 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751106Ab3GYFKQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jul 2013 01:10:16 -0400
In-Reply-To: <cover.1374728627.git.dvhart@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid using magic numbers when we have perfectly good defines just lying
around.

Signed-off-by: Darren Hart <dvhart@linux.intel.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index ab1039a..749ddd9 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -682,7 +682,7 @@ static int pch_gbe_init_phy(struct pch_gbe_adapter *adapter)
 	}
 	adapter->hw.phy.addr = adapter->mii.phy_id;
 	netdev_dbg(netdev, "phy_addr = %d\n", adapter->mii.phy_id);
-	if (addr == 32)
+	if (addr == PCH_GBE_PHY_REGS_LEN)
 		return -EAGAIN;
 	/* Selected the phy and isolate the rest */
 	for (addr = 0; addr < PCH_GBE_PHY_REGS_LEN; addr++) {
-- 
1.8.3.1
