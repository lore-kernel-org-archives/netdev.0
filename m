From: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
Subject: [PATCH] irda: sh_irda: Enable driver compilation with COMPILE_TEST
Date: Tue, 13 May 2014 01:04:36 +0200
Message-ID: <1399935876-16954-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Cc: linux-sh@vger.kernel.org, Samuel Ortiz <samuel@sortiz.org>
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This helps increasing build testing coverage.

Signed-off-by: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
Acked-by: Simon Horman <horms@verge.net.au>
---
 drivers/net/irda/Kconfig | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Samuel, could you please pick this patch up for v3.16 ? I've pinged you twice
back at v3.14 time, I'd hate missing yet another merge window.

diff --git a/drivers/net/irda/Kconfig b/drivers/net/irda/Kconfig
index 3da44d5..8d101d6 100644
--- a/drivers/net/irda/Kconfig
+++ b/drivers/net/irda/Kconfig
@@ -396,7 +396,8 @@ config MCS_FIR
 
 config SH_IRDA
 	tristate "SuperH IrDA driver"
-	depends on IRDA && ARCH_SHMOBILE
+	depends on IRDA
+	depends on ARCH_SHMOBILE || COMPILE_TEST
 	help
 	  Say Y here if your want to enable SuperH IrDA devices.
 
-- 
Regards,

Laurent Pinchart

