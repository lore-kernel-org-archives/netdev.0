From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH v2] fsl/fman: add dependency on HAS_DMA
Date: Mon, 26 Jun 2017 18:47:00 +0300
Message-ID: <1498492020-17623-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
        Madalin Bucur <madalin.bucur@nxp.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A previous commit (5567e989198b5a8d) inserted a dependency on DMA
API that requires HAS_DMA to be added in Kconfig.

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/fman/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/freescale/fman/Kconfig b/drivers/net/ethernet/freescale/fman/Kconfig
index dc0850b..8870a9a 100644
--- a/drivers/net/ethernet/freescale/fman/Kconfig
+++ b/drivers/net/ethernet/freescale/fman/Kconfig
@@ -2,6 +2,7 @@ config FSL_FMAN
 	tristate "FMan support"
 	depends on FSL_SOC || ARCH_LAYERSCAPE || COMPILE_TEST
 	select GENERIC_ALLOCATOR
+	depends on HAS_DMA
 	select PHYLIB
 	default n
 	help
-- 
2.1.0
