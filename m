From: "Chen, Chien-Chia" <machen-IBi9RG/b67k@public.gmane.org>
Subject: [PATCH] rtlwifi: rtl8188ee: Fix wrong header patch
Date: Tue,  2 Apr 2013 22:01:55 +0800
Message-ID: <1364911315-3601-1-git-send-email-machen@suse.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, zhiyuan_yang-kXabqFNEczNtrwSWzY7KCg@public.gmane.org,
	page_he-kXabqFNEczNtrwSWzY7KCg@public.gmane.org, Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Chen, Chien-Chia" <machen-IBi9RG/b67k@public.gmane.org>

This patch is to fix some wrong header file path.
It has caused the build failed.

Signed-off-by: Chen, Chien-Chia <machen-IBi9RG/b67k@public.gmane.org>
Cc: larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org
Cc: zhiyuan_yang-kXabqFNEczNtrwSWzY7KCg@public.gmane.org
Cc: page_he-kXabqFNEczNtrwSWzY7KCg@public.gmane.org
Cc: mmarek-AlSwsSmVLrQ@public.gmane.org
---
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.c        |    6 +++---
 drivers/net/wireless/rtlwifi/rtl8188ee/fw.c        |    6 +++---
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c        |   14 +++++++-------
 drivers/net/wireless/rtlwifi/rtl8188ee/led.c       |    4 ++--
 drivers/net/wireless/rtlwifi/rtl8188ee/phy.c       |    6 +++---
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h |    2 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/rf.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/sw.c        |    6 +++---
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c       |    8 ++++----
 9 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c b/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c
index 0a338cc..21a5cf0 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c
@@ -27,9 +27,9 @@
  *
  *****************************************************************************/
 
-#include "wifi.h"
-#include "base.h"
-#include "pci.h"
+#include "../wifi.h"
+#include "../base.h"
+#include "../pci.h"
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/fw.c b/drivers/net/wireless/rtlwifi/rtl8188ee/fw.c
index 66ff30b..57e4cc5 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/fw.c
@@ -27,9 +27,9 @@
  *
  *****************************************************************************/
 
-#include "wifi.h"
-#include "pci.h"
-#include "base.h"
+#include "../wifi.h"
+#include "../pci.h"
+#include "../base.h"
 #include "reg.h"
 #include "def.h"
 #include "fw.h"
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c b/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
index d734d19..0f464d0 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
@@ -27,13 +27,13 @@
  *
  *****************************************************************************/
 
-#include "wifi.h"
-#include "efuse.h"
-#include "base.h"
-#include "regd.h"
-#include "cam.h"
-#include "ps.h"
-#include "pci.h"
+#include "../wifi.h"
+#include "../efuse.h"
+#include "../base.h"
+#include "../regd.h"
+#include "../cam.h"
+#include "../ps.h"
+#include "../pci.h"
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/led.c b/drivers/net/wireless/rtlwifi/rtl8188ee/led.c
index 95d42af..c81a9cb 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/led.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/led.c
@@ -27,8 +27,8 @@
  *
  *****************************************************************************/
 
-#include "wifi.h"
-#include "pci.h"
+#include "../wifi.h"
+#include "../pci.h"
 #include "reg.h"
 #include "led.h"
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/phy.c b/drivers/net/wireless/rtlwifi/rtl8188ee/phy.c
index c285631..224f801 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/phy.c
@@ -27,9 +27,9 @@
  *
  *****************************************************************************/
 
-#include "wifi.h"
-#include "pci.h"
-#include "ps.h"
+#include "../wifi.h"
+#include "../pci.h"
+#include "../ps.h"
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h b/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h
index 622ea7e..70456ab 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h
@@ -30,7 +30,7 @@
 #ifndef __RTL8723E_PWRSEQCMD_H__
 #define __RTL8723E_PWRSEQCMD_H__
 
-#include "wifi.h"
+#include "../wifi.h"
 /*---------------------------------------------*/
 /* The value of cmd: 4 bits */
 /*---------------------------------------------*/
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/rf.c b/drivers/net/wireless/rtlwifi/rtl8188ee/rf.c
index e62bcab..4faafdb 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/rf.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/rf.c
@@ -27,7 +27,7 @@
  *
  *****************************************************************************/
 
-#include "wifi.h"
+#include "../wifi.h"
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c b/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
index e8ce189..c254693 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
@@ -27,9 +27,9 @@
  *
  *****************************************************************************/
 
-#include "wifi.h"
-#include "core.h"
-#include "pci.h"
+#include "../wifi.h"
+#include "../core.h"
+#include "../pci.h"
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c b/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
index 2518531..d075237 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
@@ -27,10 +27,10 @@
  *
  *****************************************************************************/
 
-#include "wifi.h"
-#include "pci.h"
-#include "base.h"
-#include "stats.h"
+#include "../wifi.h"
+#include "../pci.h"
+#include "../base.h"
+#include "../stats.h"
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
-- 
1.7.7

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
