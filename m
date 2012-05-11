From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH] wlcore: wlcore should depend on MAC80211
Date: Fri, 11 May 2012 06:39:54 +0200
Message-ID: <1336711194-26883-1-git-send-email-levinsasha928@gmail.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>
To: coelho@ti.com, linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

wlcore can't be built if MAC80211 isn't set.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 drivers/net/wireless/ti/wlcore/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/ti/wlcore/Kconfig b/drivers/net/wireless/ti/wlcore/Kconfig
index 9d04c38..54156b0 100644
--- a/drivers/net/wireless/ti/wlcore/Kconfig
+++ b/drivers/net/wireless/ti/wlcore/Kconfig
@@ -1,6 +1,6 @@
 config WLCORE
 	tristate "TI wlcore support"
-	depends on WL_TI && GENERIC_HARDIRQS
+	depends on WL_TI && GENERIC_HARDIRQS && MAC80211
 	depends on INET
 	select FW_LOADER
 	---help---
-- 
1.7.8.5
