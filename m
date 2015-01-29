From: Behan Webster <behanw@converseincode.com>
Subject: [PATCH] net, ethernet, LLVMLinux: Add missing MODULE_DEVICE_TABLE()
Date: Wed, 28 Jan 2015 17:36:14 -0800
Message-ID: <1422495374-22835-1-git-send-email-behanw@converseincode.com>
Cc: behanw@converseincode.com, ajit.khaparde@emulex.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	subbu.seetharaman@emulex.com, Arnd Bergmann <arnd@arndb.de>
To: sathya.perla@emulex.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Missing MODULE_DEVICE_TABLE for pci ids from benet driver found by clang.

Signed-off-by: Behan Webster <behanw@converseincode.com>
Suggested-by: Arnd Bergmann <arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index d48806b..709400a 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -26,7 +26,6 @@
 #include <net/vxlan.h>
 
 MODULE_VERSION(DRV_VER);
-MODULE_DEVICE_TABLE(pci, be_dev_ids);
 MODULE_DESCRIPTION(DRV_DESC " " DRV_VER);
 MODULE_AUTHOR("Emulex Corporation");
 MODULE_LICENSE("GPL");
-- 
1.9.1
