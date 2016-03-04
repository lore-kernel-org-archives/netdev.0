From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [PATCH v2] net: ethernet: Add missing MFD_SYSCON dependency on
 HAS_IOMEM
Date: Fri, 04 Mar 2016 10:04:52 +0900
Message-ID: <1457053492-22391-1-git-send-email-k.kozlowski@samsung.com>
Cc: Krzysztof Kozlowski <k.kozlowski@samsung.com>
To: "David S. Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The MFD_SYSCON depends on HAS_IOMEM so when selecting it avoid unmet
direct dependencies.

Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>

---

Changes since v1:
1. Fix comments from Arnd: Don't add the dependency where it exists
   already through parents or other dependencies.
---
 drivers/net/ethernet/hisilicon/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/hisilicon/Kconfig b/drivers/net/ethernet/hisilicon/Kconfig
index 74beb1867230..4ccc032633c4 100644
--- a/drivers/net/ethernet/hisilicon/Kconfig
+++ b/drivers/net/ethernet/hisilicon/Kconfig
@@ -25,6 +25,7 @@ config HIX5HD2_GMAC
 
 config HIP04_ETH
 	tristate "HISILICON P04 Ethernet support"
+	depends on HAS_IOMEM	# For MFD_SYSCON
 	select MARVELL_PHY
 	select MFD_SYSCON
 	select HNS_MDIO
-- 
2.5.0
