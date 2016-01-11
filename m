From: Manjeet Pawar <manjeet.p@samsung.com>
Subject: [PATCH 1/1] smsc: Enabling SMSC LAN911 driver for ARM64 as well.
Date: Mon, 11 Jan 2016 14:32:25 +0530
Message-ID: <1452502945-27765-1-git-send-email-manjeet.p@samsung.com>
Cc: pankaj.m@samsung.com
To: davem@davemloft.net, paul.gortmaker@windriver.com,
	schmitzmic@gmail.com, geert@linux-m68k.org, nico@fluxnic.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	manjeet.p@samsung.com, akhilesh.k@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch enable network driver support for ARM64

Signed-off-by: Akhilesh Kumar <akhilesh.k@samsung.com>
Signed-off-by: Manjeet Pawar <manjeet.p@samsung.com>
---
 drivers/net/ethernet/smsc/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/Kconfig b/drivers/net/ethernet/smsc/Kconfig
index eb9230e..6e73c73 100644
--- a/drivers/net/ethernet/smsc/Kconfig
+++ b/drivers/net/ethernet/smsc/Kconfig
@@ -77,7 +77,7 @@ config SMC911X
 	tristate "SMSC LAN911[5678] support"
 	select CRC32
 	select MII
-	depends on (ARM || SUPERH || MN10300)
+	depends on (ARM || ARM64 || SUPERH || MN10300)
 	---help---
 	  This is a driver for SMSC's LAN911x series of Ethernet chipsets
 	  including the new LAN9115, LAN9116, LAN9117, and LAN9118.
-- 
1.7.9.5
