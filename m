From: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Subject: [PATCH 2/2] pch_gbe driver: The wrong of initializer entry
Date: Tue, 30 Nov 2010 01:18:07 +0900
Message-ID: <4CF3D23F.3040003@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	John Linn <john.linn@xilinx.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	Maxime Bizon <mbizon@freebox.fr>,
	Greg Rose <gregory.v.rose@intel.com>,
	ML netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	"Ewe, Kok Howg" <kok.howg.ewe@intel.com>
To: "Dr. David Alan Gilbert" <linux@treblig.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The wrong of initializer entry was modified.

Signed-off-by: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Reported-by: Dr. David Alan Gilbert <linux@treblig.org>
---
 drivers/net/pch_gbe/pch_gbe_param.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/pch_gbe/pch_gbe_param.c b/drivers/net/pch_gbe/pch_gbe_param.c
index 2510146..ef0996a 100644
--- a/drivers/net/pch_gbe/pch_gbe_param.c
+++ b/drivers/net/pch_gbe/pch_gbe_param.c
@@ -434,8 +434,8 @@ void pch_gbe_check_options(struct pch_gbe_adapter *adapter)
 			.err  = "using default of "
 				__MODULE_STRING(PCH_GBE_DEFAULT_TXD),
 			.def  = PCH_GBE_DEFAULT_TXD,
-			.arg  = { .r = { .min = PCH_GBE_MIN_TXD } },
-			.arg  = { .r = { .max = PCH_GBE_MAX_TXD } }
+			.arg  = { .r = { .min = PCH_GBE_MIN_TXD,
+					 .max = PCH_GBE_MAX_TXD } }
 		};
 		struct pch_gbe_tx_ring *tx_ring = adapter->tx_ring;
 		tx_ring->count = TxDescriptors;
@@ -450,8 +450,8 @@ void pch_gbe_check_options(struct pch_gbe_adapter *adapter)
 			.err  = "using default of "
 				__MODULE_STRING(PCH_GBE_DEFAULT_RXD),
 			.def  = PCH_GBE_DEFAULT_RXD,
-			.arg  = { .r = { .min = PCH_GBE_MIN_RXD } },
-			.arg  = { .r = { .max = PCH_GBE_MAX_RXD } }
+			.arg  = { .r = { .min = PCH_GBE_MIN_RXD,
+					 .max = PCH_GBE_MAX_RXD } }
 		};
 		struct pch_gbe_rx_ring *rx_ring = adapter->rx_ring;
 		rx_ring->count = RxDescriptors;
-- 1.6.2.5 
