From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH net-next v1] net: netcp: remove unused kconfig option and code
Date: Tue, 27 Jan 2015 09:49:54 -0500
Message-ID: <1422370194-2828-1-git-send-email-m-karicheri2@ti.com>
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
 v1 - removed the dependancy line introduced earlier as per comment
 drivers/net/ethernet/ti/Kconfig  |    1 -
 drivers/net/ethernet/ti/Makefile |    2 +-
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
index e11bcfa..4ea1663 100644
--- a/drivers/net/ethernet/ti/Kconfig
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -73,7 +73,6 @@ config TI_CPSW
 config TI_CPTS
 	boolean "TI Common Platform Time Sync (CPTS) Support"
 	depends on TI_CPSW
-	depends on TI_CPSW || TI_KEYSTONE_NET
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
