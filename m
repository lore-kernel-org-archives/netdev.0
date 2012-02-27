From: Greg Dietsche <Gregory.Dietsche@cuw.edu>
Subject: [PATCH 1/4] iwlegacy: Kconfig: Move Debugging Options
Date: Mon, 27 Feb 2012 12:25:30 -0600
Message-ID: <1330367133-26465-2-git-send-email-Gregory.Dietsche@cuw.edu>
References: <1330367133-26465-1-git-send-email-Gregory.Dietsche@cuw.edu>
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Greg Dietsche <Gregory.Dietsche@cuw.edu>
To: sgruszka@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330367133-26465-1-git-send-email-Gregory.Dietsche@cuw.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the debug options so they appear below the 3945 / 4965 options.

Signed-off-by: Greg Dietsche <Gregory.Dietsche@cuw.edu>
---
 drivers/net/wireless/iwlegacy/Kconfig |   78 ++++++++++++++++----------------
 1 files changed, 39 insertions(+), 39 deletions(-)

diff --git a/drivers/net/wireless/iwlegacy/Kconfig b/drivers/net/wireless/iwlegacy/Kconfig
index 05bd375..4d81b80 100644
--- a/drivers/net/wireless/iwlegacy/Kconfig
+++ b/drivers/net/wireless/iwlegacy/Kconfig
@@ -6,45 +6,6 @@ config IWLEGACY
 	select LEDS_TRIGGERS
 	select MAC80211_LEDS
 
-menu "Debugging Options"
-	depends on IWLEGACY
-
-config IWLEGACY_DEBUG
-	bool "Enable full debugging output in iwlegacy (iwl 3945/4965) drivers"
-	depends on IWLEGACY
-	---help---
-	  This option will enable debug tracing output for the iwlegacy
-	  drivers.
-
-	  This will result in the kernel module being ~100k larger.  You can
-	  control which debug output is sent to the kernel log by setting the
-	  value in
-
-		/sys/class/net/wlan0/device/debug_level
-
-	  This entry will only exist if this option is enabled.
-
-	  To set a value, simply echo an 8-byte hex value to the same file:
-
-		  % echo 0x43fff > /sys/class/net/wlan0/device/debug_level
-
-	  You can find the list of debug mask values in:
-		  drivers/net/wireless/iwlegacy/common.h
-
-	  If this is your first time using this driver, you should say Y here
-	  as the debug information can assist others in helping you resolve
-	  any problems you may encounter.
-
-config IWLEGACY_DEBUGFS
-        bool "iwlegacy (iwl 3945/4965) debugfs support"
-        depends on IWLEGACY && MAC80211_DEBUGFS
-        ---help---
-	  Enable creation of debugfs files for the iwlegacy drivers. This
-	  is a low-impact option that allows getting insight into the
-	  driver's state at runtime.
-
-endmenu
-
 config IWL4965
 	tristate "Intel Wireless WiFi 4965AGN (iwl4965)"
 	depends on PCI && MAC80211
@@ -98,3 +59,42 @@ config IWL3945
 	  inserted in and removed from the running kernel whenever you want),
 	  say M here and read <file:Documentation/kbuild/modules.txt>.  The
 	  module will be called iwl3945.
+
+menu "Debugging Options"
+	depends on IWLEGACY
+
+config IWLEGACY_DEBUG
+	bool "Enable full debugging output in iwlegacy (iwl 3945/4965) drivers"
+	depends on IWLEGACY
+	---help---
+	  This option will enable debug tracing output for the iwlegacy
+	  drivers.
+
+	  This will result in the kernel module being ~100k larger.  You can
+	  control which debug output is sent to the kernel log by setting the
+	  value in
+
+		/sys/class/net/wlan0/device/debug_level
+
+	  This entry will only exist if this option is enabled.
+
+	  To set a value, simply echo an 8-byte hex value to the same file:
+
+		  % echo 0x43fff > /sys/class/net/wlan0/device/debug_level
+
+	  You can find the list of debug mask values in:
+		  drivers/net/wireless/iwlegacy/common.h
+
+	  If this is your first time using this driver, you should say Y here
+	  as the debug information can assist others in helping you resolve
+	  any problems you may encounter.
+
+config IWLEGACY_DEBUGFS
+        bool "iwlegacy (iwl 3945/4965) debugfs support"
+        depends on IWLEGACY && MAC80211_DEBUGFS
+        ---help---
+	  Enable creation of debugfs files for the iwlegacy drivers. This
+	  is a low-impact option that allows getting insight into the
+	  driver's state at runtime.
+
+endmenu
-- 
1.7.6.4
