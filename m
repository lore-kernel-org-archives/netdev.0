From: Joe Perches <joe@perches.com>
Subject: [trivial PATCH] treewide: Remove unnecessary SSB_DEVTABLE_END macro
Date: Tue, 10 Feb 2015 13:19:24 -0800
Message-ID: <1423603164.15343.5.camel@perches.com>
References: <1423601703.15343.3.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>, b43-dev@lists.infradead.org,
	linux-usb <linux-usb@vger.kernel.org>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423601703.15343.3.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the normal {} instead of a macro to terminate an array.

Remove the macro too.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/broadcom/b44.c   | 2 +-
 drivers/net/wireless/b43/main.c       | 2 +-
 drivers/net/wireless/b43legacy/main.c | 2 +-
 drivers/ssb/driver_gige.c             | 2 +-
 drivers/usb/host/ssb-hcd.c            | 2 +-
 include/linux/mod_devicetable.h       | 2 --
 6 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index d86d6ba..bd5916a 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -121,7 +121,7 @@ static struct pci_driver b44_pci_driver = {
 
 static const struct ssb_device_id b44_ssb_tbl[] = {
 	SSB_DEVICE(SSB_VENDOR_BROADCOM, SSB_DEV_ETHERNET, SSB_ANY_REV),
-	SSB_DEVTABLE_END
+	{},
 };
 MODULE_DEVICE_TABLE(ssb, b44_ssb_tbl);
 
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 6acb2b5..ccbdb05 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -144,7 +144,7 @@ static const struct ssb_device_id b43_ssb_tbl[] = {
 	SSB_DEVICE(SSB_VENDOR_BROADCOM, SSB_DEV_80211, 13),
 	SSB_DEVICE(SSB_VENDOR_BROADCOM, SSB_DEV_80211, 15),
 	SSB_DEVICE(SSB_VENDOR_BROADCOM, SSB_DEV_80211, 16),
-	SSB_DEVTABLE_END
+	{},
 };
 MODULE_DEVICE_TABLE(ssb, b43_ssb_tbl);
 #endif
diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/b43legacy/main.c
index 1aec214..4e58c00 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -86,7 +86,7 @@ MODULE_PARM_DESC(fwpostfix, "Postfix for the firmware files to load.");
 static const struct ssb_device_id b43legacy_ssb_tbl[] = {
 	SSB_DEVICE(SSB_VENDOR_BROADCOM, SSB_DEV_80211, 2),
 	SSB_DEVICE(SSB_VENDOR_BROADCOM, SSB_DEV_80211, 4),
-	SSB_DEVTABLE_END
+	{},
 };
 MODULE_DEVICE_TABLE(ssb, b43legacy_ssb_tbl);
 
diff --git a/drivers/ssb/driver_gige.c b/drivers/ssb/driver_gige.c
index 21f71a1..e973405 100644
--- a/drivers/ssb/driver_gige.c
+++ b/drivers/ssb/driver_gige.c
@@ -24,7 +24,7 @@ MODULE_LICENSE("GPL");
 
 static const struct ssb_device_id ssb_gige_tbl[] = {
 	SSB_DEVICE(SSB_VENDOR_BROADCOM, SSB_DEV_ETHERNET_GBIT, SSB_ANY_REV),
-	SSB_DEVTABLE_END
+	{},
 };
 /* MODULE_DEVICE_TABLE(ssb, ssb_gige_tbl); */
 
diff --git a/drivers/usb/host/ssb-hcd.c b/drivers/usb/host/ssb-hcd.c
index 0196f76..ffc32f4 100644
--- a/drivers/usb/host/ssb-hcd.c
+++ b/drivers/usb/host/ssb-hcd.c
@@ -251,7 +251,7 @@ static const struct ssb_device_id ssb_hcd_table[] = {
 	SSB_DEVICE(SSB_VENDOR_BROADCOM, SSB_DEV_USB11_HOSTDEV, SSB_ANY_REV),
 	SSB_DEVICE(SSB_VENDOR_BROADCOM, SSB_DEV_USB11_HOST, SSB_ANY_REV),
 	SSB_DEVICE(SSB_VENDOR_BROADCOM, SSB_DEV_USB20_HOST, SSB_ANY_REV),
-	SSB_DEVTABLE_END
+	{},
 };
 MODULE_DEVICE_TABLE(ssb, ssb_hcd_table);
 
diff --git a/include/linux/mod_devicetable.h b/include/linux/mod_devicetable.h
index 72f24b6..e530533 100644
--- a/include/linux/mod_devicetable.h
+++ b/include/linux/mod_devicetable.h
@@ -364,8 +364,6 @@ struct ssb_device_id {
 } __attribute__((packed, aligned(2)));
 #define SSB_DEVICE(_vendor, _coreid, _revision)  \
 	{ .vendor = _vendor, .coreid = _coreid, .revision = _revision, }
-#define SSB_DEVTABLE_END  \
-	{ 0, },
 
 #define SSB_ANY_VENDOR		0xFFFF
 #define SSB_ANY_ID		0xFFFF
