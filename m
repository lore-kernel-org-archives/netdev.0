From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [RESEND: PATCH net-next] net: netcp: remove unused kconfig option and code
Date: Tue, 20 Jan 2015 14:27:09 -0500
Message-ID: <1421782029-11201-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Murali Karicheri <m-karicheri2@ti.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently CPTS is built into the netcp driver even though there is no
call out to the CPTS driver. This patch removes the dependency in Kconfig
and remove cpts.o from the Makefile for NetCP.

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
---
 - Resend with PATCH prefix.
 drivers/net/ethernet/ti/Kconfig  |    2 +-
 drivers/net/ethernet/ti/Makefile |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
index e11bcfa..824e376 100644
--- a/drivers/net/ethernet/ti/Kconfig
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -73,7 +73,7 @@ config TI_CPSW
 config TI_CPTS
 	boolean "TI Common Platform Time Sync (CPTS) Support"
 	depends on TI_CPSW
-	depends on TI_CPSW || TI_KEYSTONE_NET
+	depends on TI_CPSW
 	select PTP_1588_CLOCK
 	---help---
 	  This driver supports the Common Platform Time Sync unit of
diff --git a/drivers/net/ethernet/ti/Makefile b/drivers/net/ethernet/ti/Makefile
index 465d03d..0a9813b 100644
--- a/drivers/net/ethernet/ti/Makefile
+++ b/drivers/net/ethernet/ti/Makefile
@@ -13,4 +13,4 @@ ti_cpsw-y := cpsw_ale.o cpsw.o cpts.o
 
 obj-$(CONFIG_TI_KEYSTONE_NETCP) += keystone_netcp.o
 keystone_netcp-y := netcp_core.o netcp_ethss.o	netcp_sgmii.o \
-			netcp_xgbepcsr.o cpsw_ale.o cpts.o
+			netcp_xgbepcsr.o cpsw_ale.o
-- 
1.7.9.5
