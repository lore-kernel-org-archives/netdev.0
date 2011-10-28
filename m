From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] i825xx: Fix incorrect dependency for BVME6000_NET
Date: Fri, 28 Oct 2011 22:53:32 +0200
Message-ID: <1319835212-19473-1-git-send-email-geert@linux-m68k.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/ethernet/i825xx/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/i825xx/Kconfig b/drivers/net/ethernet/i825xx/Kconfig
index 2be4698..ca1ae98 100644
--- a/drivers/net/ethernet/i825xx/Kconfig
+++ b/drivers/net/ethernet/i825xx/Kconfig
@@ -85,7 +85,7 @@ config APRICOT
 
 config BVME6000_NET
 	tristate "BVME6000 Ethernet support"
-	depends on BVME6000MVME16x
+	depends on BVME6000
 	---help---
 	  This is the driver for the Ethernet interface on BVME4000 and
 	  BVME6000 VME boards.  Say Y here to include the driver for this chip
-- 
1.7.0.4
