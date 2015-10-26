From: <shh.xie@gmail.com>
Subject: [PATCH] net: fsl: expands dependencies of NET_VENDOR_FREESCALE
Date: Mon, 26 Oct 2015 16:49:51 +0800
Message-ID: <1445849391-422-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <scottwood@freescale.com>, <stuart.yoder@freescale.com>,
	<bhamciu1@freescale.com>, Shaohui Xie <Shaohui.Xie@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0060.outbound.protection.outlook.com ([65.55.169.60]:12512
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753315AbbJZKog (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2015 06:44:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohui Xie <Shaohui.Xie@freescale.com>

Freescale hosts some ARMv8 based SoCs, and a generic convention
ARCH_LAYERSCAPE is used to cover such SoCs. Adding ARCH_LAYERSCAPE
to dependencies of NET_VENDOR_FREESCALE to support networking on those
SoCs.

The patch to add ARCH_LAYERSCAPE can be viewed at:
http://www.spinics.net/lists/arm-kernel/msg455583.html

Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
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
