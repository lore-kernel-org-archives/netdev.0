From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH net v2 5/5] fsl/fman: enable compilation on ARM64
Date: Mon, 19 Dec 2016 11:22:23 +0200
Message-ID: <1482139343-8975-6-git-send-email-madalin.bucur@nxp.com>
References: <1482139343-8975-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
        <davem@davemloft.net>, <scott.wood@nxp.com>, <mpe@ellerman.id.au>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482139343-8975-1-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/fman/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fman/Kconfig b/drivers/net/ethernet/freescale/fman/Kconfig
index 79b7c84..dc0850b 100644
--- a/drivers/net/ethernet/freescale/fman/Kconfig
+++ b/drivers/net/ethernet/freescale/fman/Kconfig
@@ -1,6 +1,6 @@
 config FSL_FMAN
 	tristate "FMan support"
-	depends on FSL_SOC || COMPILE_TEST
+	depends on FSL_SOC || ARCH_LAYERSCAPE || COMPILE_TEST
 	select GENERIC_ALLOCATOR
 	select PHYLIB
 	default n
-- 
2.1.0
