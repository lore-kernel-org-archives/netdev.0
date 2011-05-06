From: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Subject: [PATCH 1/2] PCH_GbE : Fixed the issue of collision detection
Date: Fri, 06 May 2011 21:53:51 +0900
Message-ID: <4DC3EF5F.1030306@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Tomoya Morinaga <tomoya-linux@dsn.okisemi.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Ewe, Kok Howg" <kok.howg.ewe@intel.com>
To: ML netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The collision detection setting was invalid.
When collision occurred, because data was not resenr, 
there was an issue to which a transmitting throughput falls.

This patch enables the collision detection.

Signed-off-by: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
---
 drivers/net/pch_gbe/pch_gbe_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/pch_gbe_main.c
index 8300f64..babe663 100644
--- a/drivers/net/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -43,8 +43,7 @@ const char pch_driver_version[] = DRV_VERSION;
 
 #define PCH_GBE_MAC_RGMII_CTRL_SETTING ( \
 	PCH_GBE_CHIP_TYPE_INTERNAL | \
-	PCH_GBE_RGMII_MODE_RGMII   | \
-	PCH_GBE_CRS_SEL              \
+	PCH_GBE_RGMII_MODE_RGMII     \
 	)
 
 /* Ethertype field values */
-- 
1.6.2.5
