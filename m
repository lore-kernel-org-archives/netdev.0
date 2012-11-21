From: Joe Perches <joe@perches.com>
Subject: [PATCH] brcmsmac: Add __printf verification to logging prototypes
Date: Wed, 21 Nov 2012 10:17:34 -0800
Message-ID: <a74034e340d7db52dfb0b1a01c18759eb091fd18.1353521783.git.joe@perches.com>
Cc: Brett Rudley <brudley@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Kan Yan <kanyan@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adding __printf helps spot format and argument mismatches.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/brcm80211/brcmsmac/debug.h |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmsmac/debug.h b/drivers/net/wireless/brcm80211/brcmsmac/debug.h
index c0d2cf7..f77066b 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/debug.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/debug.h
@@ -8,17 +8,23 @@
 #include "main.h"
 #include "mac80211_if.h"
 
+__printf(2, 3)
 void __brcms_info(struct device *dev, const char *fmt, ...);
+__printf(2, 3)
 void __brcms_warn(struct device *dev, const char *fmt, ...);
+__printf(2, 3)
 void __brcms_err(struct device *dev, const char *fmt, ...);
+__printf(2, 3)
 void __brcms_crit(struct device *dev, const char *fmt, ...);
 
 #if defined(CONFIG_BRCMDBG) || defined(CONFIG_BRCM_TRACING)
+__printf(4, 5)
 void __brcms_dbg(struct device *dev, u32 level, const char *func,
 		 const char *fmt, ...);
 #else
-static inline void __brcms_dbg(struct device *dev, u32 level,
-			       const char *func, const char *fmt, ...)
+static inline __printf(4, 5)
+void __brcms_dbg(struct device *dev, u32 level, const char *func,
+		 const char *fmt, ...)
 {
 }
 #endif
-- 
1.7.8.112.g3fd21
