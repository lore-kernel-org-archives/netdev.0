From: Darren Hart <dvhart@linux.intel.com>
Subject: [PATCH 2/3] pch_gbe: Use PCH_GBE_PHY_REGS_LEN instead of 32
Date: Fri, 12 Jul 2013 17:58:06 -0700
Message-ID: <7320fe759f7076354707346a6d98b031f64f4039.1373676797.git.dvhart@linux.intel.com>
References: <1373677087-7747-1-git-send-email-dvhart@linux.intel.com>
Cc: Darren Hart <dvhart@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	netdev@vger.kernel.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1373677087-7747-1-git-send-email-dvhart@linux.intel.com>
In-Reply-To: <ce5dd365d05f8747d269aa74e0bb929935d9cdee.1373676797.git.dvhart@linux.intel.com>
References: <ce5dd365d05f8747d269aa74e0bb929935d9cdee.1373676797.git.dvhart@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
