From: <shh.xie@gmail.com>
Subject: [PATCH] [V2] net: fsl: expands dependencies of NET_VENDOR_FREESCALE
Date: Fri, 20 Nov 2015 11:54:08 +0800
Message-ID: <1447991648-25424-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shaohui Xie <Shaohui.Xie@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0057.outbound.protection.outlook.com ([65.55.169.57]:12994
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S934262AbbKTEBZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Nov 2015 23:01:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohui Xie <Shaohui.Xie@freescale.com>

Freescale hosts some ARMv8 based SoCs, and a generic convention
ARCH_LAYERSCAPE is used to cover such SoCs. Adding ARCH_LAYERSCAPE
to dependencies of NET_VENDOR_FREESCALE to support networking on those
SoCs.

The ARCH_LAYERSCAPE is introduced by:
commit: 53a5fde05 arm64: Use generic Layerscape SoC family naming

Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
changes in v2:
1. revises commit message to add commit which introduces ARCH_LAYERSCAPE.

 drivers/net/ethernet/freescale/Kconfig | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
index ff76d4e..bee32a9 100644
--- a/drivers/net/ethernet/freescale/Kconfig
+++ b/drivers/net/ethernet/freescale/Kconfig
@@ -7,7 +7,8 @@ config NET_VENDOR_FREESCALE
 	default y
 	depends on FSL_SOC || QUICC_ENGINE || CPM1 || CPM2 || PPC_MPC512x || \
 		   M523x || M527x || M5272 || M528x || M520x || M532x || \
-		   ARCH_MXC || ARCH_MXS || (PPC_MPC52xx && PPC_BESTCOMM)
+		   ARCH_MXC || ARCH_MXS || (PPC_MPC52xx && PPC_BESTCOMM) || \
+		   ARCH_LAYERSCAPE
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y.
 
-- 
2.1.0.27.g96db324
