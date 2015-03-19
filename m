From: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
Subject: [PATCH] mac802154: fix typo in header guard
Date: Thu, 19 Mar 2015 21:23:40 +0800
Message-ID: <1426771420-29979-1-git-send-email-nicolas.iooss_linux@m4x.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicolas Iooss <nicolas.iooss_linux@m4x.org>
To: alex.aring@gmail.com, linux-wpan@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
Fixes: b6eea9ca354a ("mac802154: introduce driver-ops header")
---
 net/mac802154/driver-ops.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/mac802154/driver-ops.h b/net/mac802154/driver-ops.h
index 98180a9fff4a..a0533357b9ea 100644
--- a/net/mac802154/driver-ops.h
+++ b/net/mac802154/driver-ops.h
@@ -1,4 +1,4 @@
-#ifndef __MAC802154_DRVIER_OPS
+#ifndef __MAC802154_DRIVER_OPS
 #define __MAC802154_DRIVER_OPS
 
 #include <linux/types.h>
@@ -220,4 +220,4 @@ drv_set_promiscuous_mode(struct ieee802154_local *local, bool on)
 	return local->ops->set_promiscuous_mode(&local->hw, on);
 }
 
-#endif /* __MAC802154_DRVIER_OPS */
+#endif /* __MAC802154_DRIVER_OPS */
-- 
2.3.3
