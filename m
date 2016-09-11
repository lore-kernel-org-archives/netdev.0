From: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
Subject: [PATCH 21/26] rtlwifi: rtl818x: constify local structures
Date: Sun, 11 Sep 2016 15:06:03 +0200
Message-ID: <1473599168-30561-22-git-send-email-Julia.Lawall@lip6.fr>
References: <1473599168-30561-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1473599168-30561-1-git-send-email-Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

For structure types defined in the same file or local header files, find
top-level static structure declarations that have the following
properties:
1. Never reassigned.
2. Address never taken
3. Not passed to a top-level macro call
4. No pointer or array-typed field passed to a function or stored in a
variable.
Declare structures having all of these properties as const.

Done using Coccinelle.
Based on a suggestion by Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>.

Signed-off-by: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>

---
The semantic patch seems too long for a commit log, but is in the cover
letter.

 drivers/net/wireless/realtek/rtlwifi/rtl8188ee/sw.c |    2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192ce/sw.c |    2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192de/sw.c |    2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/sw.c |    2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192se/sw.c |    2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/sw.c |    2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/sw.c |    2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/sw.c |    2 +-
 8 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/sw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/sw.c
index 47e32cb..e7b11b4 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/sw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/sw.c
@@ -280,7 +280,7 @@ static struct rtl_mod_params rtl88ee_mod_params = {
 	.debug = DBG_EMERG,
 };
 
-static struct rtl_hal_cfg rtl88ee_hal_cfg = {
+static const struct rtl_hal_cfg rtl88ee_hal_cfg = {
 	.bar_id = 2,
 	.write_readback = true,
 	.name = "rtl88e_pci",
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/sw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/sw.c
index 4780bdc..87aa209 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/sw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/sw.c
@@ -258,7 +258,7 @@ static struct rtl_mod_params rtl92ce_mod_params = {
 	.debug = DBG_EMERG,
 };
 
-static struct rtl_hal_cfg rtl92ce_hal_cfg = {
+static const struct rtl_hal_cfg rtl92ce_hal_cfg = {
 	.bar_id = 2,
 	.write_readback = true,
 	.name = "rtl92c_pci",
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/sw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/sw.c
index c6e09a1..0538a4d 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/sw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/sw.c
@@ -262,7 +262,7 @@ static struct rtl_mod_params rtl92de_mod_params = {
 	.debug = DBG_EMERG,
 };
 
-static struct rtl_hal_cfg rtl92de_hal_cfg = {
+static const struct rtl_hal_cfg rtl92de_hal_cfg = {
 	.bar_id = 2,
 	.write_readback = true,
 	.name = "rtl8192de",
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/sw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/sw.c
index c31c6bf..ac299cb 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/sw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/sw.c
@@ -262,7 +262,7 @@ static struct rtl_mod_params rtl92ee_mod_params = {
 	.debug = DBG_EMERG,
 };
 
-static struct rtl_hal_cfg rtl92ee_hal_cfg = {
+static const struct rtl_hal_cfg rtl92ee_hal_cfg = {
 	.bar_id = 2,
 	.write_readback = true,
 	.name = "rtl92ee_pci",
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192se/sw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192se/sw.c
index 31baca41..5e8e02d 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192se/sw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192se/sw.c
@@ -306,7 +306,7 @@ static struct rtl_mod_params rtl92se_mod_params = {
 
 /* Because memory R/W bursting will cause system hang/crash
  * for 92se, so we don't read back after every write action */
-static struct rtl_hal_cfg rtl92se_hal_cfg = {
+static const struct rtl_hal_cfg rtl92se_hal_cfg = {
 	.bar_id = 1,
 	.write_readback = false,
 	.name = "rtl92s_pci",
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/sw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/sw.c
index ff49a8c..89c828a 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/sw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/sw.c
@@ -276,7 +276,7 @@ static struct rtl_mod_params rtl8723e_mod_params = {
 	.disable_watchdog = false,
 };
 
-static struct rtl_hal_cfg rtl8723e_hal_cfg = {
+static const struct rtl_hal_cfg rtl8723e_hal_cfg = {
 	.bar_id = 2,
 	.write_readback = true,
 	.name = "rtl8723e_pci",
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/sw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/sw.c
index 2101793..20b53f0 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/sw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/sw.c
@@ -276,7 +276,7 @@ static struct rtl_mod_params rtl8723be_mod_params = {
 	.ant_sel = 0,
 };
 
-static struct rtl_hal_cfg rtl8723be_hal_cfg = {
+static const struct rtl_hal_cfg rtl8723be_hal_cfg = {
 	.bar_id = 2,
 	.write_readback = true,
 	.name = "rtl8723be_pci",
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/sw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/sw.c
index 4159f9b..22f687b1 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/sw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/sw.c
@@ -316,7 +316,7 @@ static struct rtl_mod_params rtl8821ae_mod_params = {
 	.disable_watchdog = 0,
 };
 
-static struct rtl_hal_cfg rtl8821ae_hal_cfg = {
+static const struct rtl_hal_cfg rtl8821ae_hal_cfg = {
 	.bar_id = 2,
 	.write_readback = true,
 	.name = "rtl8821ae_pci",
