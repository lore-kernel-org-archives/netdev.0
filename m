From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH net 2/3] dpaa_eth: remove redundant dependency on FSL_SOC
Date: Thu, 15 Dec 2016 15:13:05 +0200
Message-ID: <1481807586-4798-3-git-send-email-madalin.bucur@nxp.com>
References: <1481807586-4798-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
        <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481807586-4798-1-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/dpaa/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/dpaa/Kconfig b/drivers/net/ethernet/freescale/dpaa/Kconfig
index f3a3454..a654736 100644
--- a/drivers/net/ethernet/freescale/dpaa/Kconfig
+++ b/drivers/net/ethernet/freescale/dpaa/Kconfig
@@ -1,6 +1,6 @@
 menuconfig FSL_DPAA_ETH
 	tristate "DPAA Ethernet"
-	depends on FSL_SOC && FSL_DPAA && FSL_FMAN
+	depends on FSL_DPAA && FSL_FMAN
 	select PHYLIB
 	select FSL_FMAN_MAC
 	---help---
-- 
2.1.0
