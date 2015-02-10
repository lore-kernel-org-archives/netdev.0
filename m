From: Joe Perches <joe@perches.com>
Subject: [trivial PATCH] treewide: Remove unnecessary BCMA_CORETABLE_END
 macro
Date: Tue, 10 Feb 2015 12:55:03 -0800
Message-ID: <1423601703.15343.3.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>, brcm80211-dev-list@broadcom.com,
	linux-spi <linux-spi@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the normal {} instead of a macro to terminate an array.

Remove the macro too.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/broadcom/bgmac.c                 | 2 +-
 drivers/net/wireless/b43/main.c                       | 2 +-
 drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c | 2 +-
 drivers/spi/spi-bcm53xx.c                             | 2 +-
 drivers/usb/host/bcma-hcd.c                           | 2 +-
 include/linux/mod_devicetable.h                       | 2 --
 6 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 3007d95..ea63cb0 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -21,7 +21,7 @@
 static const struct bcma_device_id bgmac_bcma_tbl[] = {
 	BCMA_CORE(BCMA_MANUF_BCM, BCMA_CORE_4706_MAC_GBIT, BCMA_ANY_REV, BCMA_ANY_CLASS),
 	BCMA_CORE(BCMA_MANUF_BCM, BCMA_CORE_MAC_GBIT, BCMA_ANY_REV, BCMA_ANY_CLASS),
-	BCMA_CORETABLE_END
+	{},
 };
 MODULE_DEVICE_TABLE(bcma, bgmac_bcma_tbl);
 
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 2c90886..6acb2b5 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -127,7 +127,7 @@ static const struct bcma_device_id b43_bcma_tbl[] = {
 	BCMA_CORE(BCMA_MANUF_BCM, BCMA_CORE_80211, 0x1E, BCMA_ANY_CLASS),
 	BCMA_CORE(BCMA_MANUF_BCM, BCMA_CORE_80211, 0x28, BCMA_ANY_CLASS),
 	BCMA_CORE(BCMA_MANUF_BCM, BCMA_CORE_80211, 0x2A, BCMA_ANY_CLASS),
-	BCMA_CORETABLE_END
+	{},
 };
 MODULE_DEVICE_TABLE(bcma, b43_bcma_tbl);
 #endif
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
index f95b524..4813506 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
@@ -99,7 +99,7 @@ static struct bcma_device_id brcms_coreid_table[] = {
 	BCMA_CORE(BCMA_MANUF_BCM, BCMA_CORE_80211, 17, BCMA_ANY_CLASS),
 	BCMA_CORE(BCMA_MANUF_BCM, BCMA_CORE_80211, 23, BCMA_ANY_CLASS),
 	BCMA_CORE(BCMA_MANUF_BCM, BCMA_CORE_80211, 24, BCMA_ANY_CLASS),
-	BCMA_CORETABLE_END
+	{},
 };
 MODULE_DEVICE_TABLE(bcma, brcms_coreid_table);
 
diff --git a/drivers/spi/spi-bcm53xx.c b/drivers/spi/spi-bcm53xx.c
index 17b34cb..3fb91c8 100644
--- a/drivers/spi/spi-bcm53xx.c
+++ b/drivers/spi/spi-bcm53xx.c
@@ -216,7 +216,7 @@ static struct spi_board_info bcm53xx_info = {
 
 static const struct bcma_device_id bcm53xxspi_bcma_tbl[] = {
 	BCMA_CORE(BCMA_MANUF_BCM, BCMA_CORE_NS_QSPI, BCMA_ANY_REV, BCMA_ANY_CLASS),
-	BCMA_CORETABLE_END
+	{},
 };
 MODULE_DEVICE_TABLE(bcma, bcm53xxspi_bcma_tbl);
 
diff --git a/drivers/usb/host/bcma-hcd.c b/drivers/usb/host/bcma-hcd.c
index cd6d0af..526cfab 100644
--- a/drivers/usb/host/bcma-hcd.c
+++ b/drivers/usb/host/bcma-hcd.c
@@ -306,7 +306,7 @@ static int bcma_hcd_resume(struct bcma_device *dev)
 
 static const struct bcma_device_id bcma_hcd_table[] = {
 	BCMA_CORE(BCMA_MANUF_BCM, BCMA_CORE_USB20_HOST, BCMA_ANY_REV, BCMA_ANY_CLASS),
-	BCMA_CORETABLE_END
+	{},
 };
 MODULE_DEVICE_TABLE(bcma, bcma_hcd_table);
 
diff --git a/include/linux/mod_devicetable.h b/include/linux/mod_devicetable.h
index 745def8..6711d57 100644
--- a/include/linux/mod_devicetable.h
+++ b/include/linux/mod_devicetable.h
@@ -380,8 +380,6 @@ struct bcma_device_id {
 } __attribute__((packed,aligned(2)));
 #define BCMA_CORE(_manuf, _id, _rev, _class)  \
 	{ .manuf = _manuf, .id = _id, .rev = _rev, .class = _class, }
-#define BCMA_CORETABLE_END  \
-	{ 0, },
 
 #define BCMA_ANY_MANUF		0xFFFF
 #define BCMA_ANY_ID		0xFFFF
