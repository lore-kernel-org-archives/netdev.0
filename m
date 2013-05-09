From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH 03/12] net/ethernet: NET_CALXEDA_XGMAC should depend on HAS_DMA
Date: Thu,  9 May 2013 23:04:45 +0200
Message-ID: <1368133494-22198-3-git-send-email-geert@linux-m68k.org>
References: <1368133494-22198-1-git-send-email-geert@linux-m68k.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368133494-22198-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If NO_DMA=y:

drivers/built-in.o: In function `xgmac_xmit':
drivers/net/ethernet/calxeda/xgmac.c:1102: undefined reference to `dma_mapping_error'

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Rob Herring <rob.herring@calxeda.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/calxeda/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/Kconfig b/drivers/net/ethernet/calxeda/Kconfig
index aba435c..184a063 100644
--- a/drivers/net/ethernet/calxeda/Kconfig
+++ b/drivers/net/ethernet/calxeda/Kconfig
@@ -1,6 +1,6 @@
 config NET_CALXEDA_XGMAC
 	tristate "Calxeda 1G/10G XGMAC Ethernet driver"
-	depends on HAS_IOMEM
+	depends on HAS_IOMEM && HAS_DMA
 	select CRC32
 	help
 	  This is the driver for the XGMAC Ethernet IP block found on Calxeda
-- 
1.7.0.4
