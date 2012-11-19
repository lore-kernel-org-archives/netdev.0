From: Bill Pemberton <wfp5p-4Ng6DfrEGID2fBVCVOL8/A@public.gmane.org>
Subject: [PATCH 085/493] net/wireless: remove use of __devexit_p
Date: Mon, 19 Nov 2012 13:20:34 -0500
Message-ID: <1353349642-3677-85-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Simon Kelley <simon-xn1N/tgparsycpQjotevgVpr/1R2p/CL@public.gmane.org>,
	Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>,
	Stanislav Yakovlev <stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	Ivo van Doorn <IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Gertjan van Wingerde <gwingerde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Helmut Schaa <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	Herton Ronaldo Krzesinski <herton-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Hin-Tak Leung <htl10-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Luciano Coelho <coelho-l0cyMroinI0@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org,
	b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org
To: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p-4Ng6DfrEGID2fBVCVOL8/A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

CONFIG_HOTPLUG is going away as an option so __devexit_p is no longer
needed.

Signed-off-by: Bill Pemberton <wfp5p-4Ng6DfrEGID2fBVCVOL8/A@public.gmane.org>
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> 
Cc: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> 
Cc: Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> 
Cc: "Luis R. Rodriguez" <mcgrof-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org> 
Cc: Simon Kelley <simon-xn1N/tgparsycpQjotevgVpr/1R2p/CL@public.gmane.org> 
Cc: Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org> 
Cc: Stanislav Yakovlev <stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> 
Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> 
Cc: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org> 
Cc: Ivo van Doorn <IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> 
Cc: Gertjan van Wingerde <gwingerde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> 
Cc: Helmut Schaa <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org> 
Cc: Herton Ronaldo Krzesinski <herton-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> 
Cc: Hin-Tak Leung <htl10-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org> 
Cc: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> 
Cc: Luciano Coelho <coelho-l0cyMroinI0@public.gmane.org> 
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org 
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org 
Cc: ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org 
Cc: b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org 
Cc: brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org 
Cc: libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org 
Cc: users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org 
---
 drivers/net/wireless/adm8211.c                        | 2 +-
 drivers/net/wireless/airo.c                           | 2 +-
 drivers/net/wireless/ath/ath5k/pci.c                  | 2 +-
 drivers/net/wireless/atmel_pci.c                      | 2 +-
 drivers/net/wireless/b43/pcmcia.c                     | 2 +-
 drivers/net/wireless/b43/sdio.c                       | 2 +-
 drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c | 2 +-
 drivers/net/wireless/ipw2x00/ipw2100.c                | 2 +-
 drivers/net/wireless/ipw2x00/ipw2200.c                | 2 +-
 drivers/net/wireless/iwlegacy/3945-mac.c              | 2 +-
 drivers/net/wireless/iwlegacy/4965-mac.c              | 2 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c               | 2 +-
 drivers/net/wireless/libertas/if_spi.c                | 2 +-
 drivers/net/wireless/mwl8k.c                          | 4 ++--
 drivers/net/wireless/orinoco/orinoco_nortel.c         | 2 +-
 drivers/net/wireless/orinoco/orinoco_pci.c            | 2 +-
 drivers/net/wireless/orinoco/orinoco_plx.c            | 2 +-
 drivers/net/wireless/orinoco/orinoco_tmd.c            | 2 +-
 drivers/net/wireless/p54/p54pci.c                     | 2 +-
 drivers/net/wireless/p54/p54spi.c                     | 2 +-
 drivers/net/wireless/p54/p54usb.c                     | 2 +-
 drivers/net/wireless/rt2x00/rt2400pci.c               | 2 +-
 drivers/net/wireless/rt2x00/rt2500pci.c               | 2 +-
 drivers/net/wireless/rt2x00/rt2800pci.c               | 4 ++--
 drivers/net/wireless/rt2x00/rt61pci.c                 | 2 +-
 drivers/net/wireless/rtl818x/rtl8180/dev.c            | 2 +-
 drivers/net/wireless/rtl818x/rtl8187/dev.c            | 2 +-
 drivers/net/wireless/ti/wl1251/sdio.c                 | 2 +-
 drivers/net/wireless/ti/wl1251/spi.c                  | 2 +-
 drivers/net/wireless/ti/wl12xx/main.c                 | 2 +-
 drivers/net/wireless/ti/wl18xx/main.c                 | 2 +-
 drivers/net/wireless/ti/wlcore/sdio.c                 | 2 +-
 drivers/net/wireless/ti/wlcore/spi.c                  | 2 +-
 33 files changed, 35 insertions(+), 35 deletions(-)

diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
index 154a496..a05bac2 100644
--- a/drivers/net/wireless/adm8211.c
+++ b/drivers/net/wireless/adm8211.c
@@ -1985,7 +1985,7 @@ static struct pci_driver adm8211_driver = {
 	.name		= "adm8211",
 	.id_table	= adm8211_pci_id_table,
 	.probe		= adm8211_probe,
-	.remove		= __devexit_p(adm8211_remove),
+	.remove		= adm8211_remove,
 #ifdef CONFIG_PM
 	.suspend	= adm8211_suspend,
 	.resume		= adm8211_resume,
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 57f7db1..af1096b 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -78,7 +78,7 @@ static struct pci_driver airo_driver = {
 	.name     = DRV_NAME,
 	.id_table = card_ids,
 	.probe    = airo_pci_probe,
-	.remove   = __devexit_p(airo_pci_remove),
+	.remove   = airo_pci_remove,
 	.suspend  = airo_pci_suspend,
 	.resume   = airo_pci_resume,
 };
diff --git a/drivers/net/wireless/ath/ath5k/pci.c b/drivers/net/wireless/ath/ath5k/pci.c
index dff48fb..c3ba483 100644
--- a/drivers/net/wireless/ath/ath5k/pci.c
+++ b/drivers/net/wireless/ath/ath5k/pci.c
@@ -336,7 +336,7 @@ static struct pci_driver ath5k_pci_driver = {
 	.name		= KBUILD_MODNAME,
 	.id_table	= ath5k_pci_id_table,
 	.probe		= ath5k_pci_probe,
-	.remove		= __devexit_p(ath5k_pci_remove),
+	.remove		= ath5k_pci_remove,
 	.driver.pm	= ATH5K_PM_OPS,
 };
 
diff --git a/drivers/net/wireless/atmel_pci.c b/drivers/net/wireless/atmel_pci.c
index 51e33b5..fbe6580 100644
--- a/drivers/net/wireless/atmel_pci.c
+++ b/drivers/net/wireless/atmel_pci.c
@@ -45,7 +45,7 @@ static struct pci_driver atmel_driver = {
 	.name     = "atmel",
 	.id_table = card_ids,
 	.probe    = atmel_pci_probe,
-	.remove   = __devexit_p(atmel_pci_remove),
+	.remove   = atmel_pci_remove,
 };
 
 
diff --git a/drivers/net/wireless/b43/pcmcia.c b/drivers/net/wireless/b43/pcmcia.c
index 714cad6..3477213 100644
--- a/drivers/net/wireless/b43/pcmcia.c
+++ b/drivers/net/wireless/b43/pcmcia.c
@@ -125,7 +125,7 @@ static struct pcmcia_driver b43_pcmcia_driver = {
 	.name		= "b43-pcmcia",
 	.id_table	= b43_pcmcia_tbl,
 	.probe		= b43_pcmcia_probe,
-	.remove		= __devexit_p(b43_pcmcia_remove),
+	.remove		= b43_pcmcia_remove,
 	.suspend	= b43_pcmcia_suspend,
 	.resume		= b43_pcmcia_resume,
 };
diff --git a/drivers/net/wireless/b43/sdio.c b/drivers/net/wireless/b43/sdio.c
index a54fb2d..80b0755 100644
--- a/drivers/net/wireless/b43/sdio.c
+++ b/drivers/net/wireless/b43/sdio.c
@@ -193,7 +193,7 @@ static struct sdio_driver b43_sdio_driver = {
 	.name		= "b43-sdio",
 	.id_table	= b43_sdio_ids,
 	.probe		= b43_sdio_probe,
-	.remove		= __devexit_p(b43_sdio_remove),
+	.remove		= b43_sdio_remove,
 };
 
 int b43_sdio_init(void)
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
index a744ea5..cdd5aa2 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
@@ -1160,7 +1160,7 @@ static struct bcma_driver brcms_bcma_driver = {
 	.probe    = brcms_bcma_probe,
 	.suspend  = brcms_suspend,
 	.resume   = brcms_resume,
-	.remove   = __devexit_p(brcms_remove),
+	.remove   = brcms_remove,
 	.id_table = brcms_coreid_table,
 };
 
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index 29b8fa1..b96c615 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -6609,7 +6609,7 @@ static struct pci_driver ipw2100_pci_driver = {
 	.name = DRV_NAME,
 	.id_table = ipw2100_pci_id_table,
 	.probe = ipw2100_pci_init_one,
-	.remove = __devexit_p(ipw2100_pci_remove_one),
+	.remove = ipw2100_pci_remove_one,
 #ifdef CONFIG_PM
 	.suspend = ipw2100_suspend,
 	.resume = ipw2100_resume,
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 768bf61..b809b99 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -12057,7 +12057,7 @@ static struct pci_driver ipw_driver = {
 	.name = DRV_NAME,
 	.id_table = card_ids,
 	.probe = ipw_pci_probe,
-	.remove = __devexit_p(ipw_pci_remove),
+	.remove = ipw_pci_remove,
 #ifdef CONFIG_PM
 	.suspend = ipw_pci_suspend,
 	.resume = ipw_pci_resume,
diff --git a/drivers/net/wireless/iwlegacy/3945-mac.c b/drivers/net/wireless/iwlegacy/3945-mac.c
index e252acb..88fdd39 100644
--- a/drivers/net/wireless/iwlegacy/3945-mac.c
+++ b/drivers/net/wireless/iwlegacy/3945-mac.c
@@ -3884,7 +3884,7 @@ static struct pci_driver il3945_driver = {
 	.name = DRV_NAME,
 	.id_table = il3945_hw_card_ids,
 	.probe = il3945_pci_probe,
-	.remove = __devexit_p(il3945_pci_remove),
+	.remove = il3945_pci_remove,
 	.driver.pm = IL_LEGACY_PM_OPS,
 };
 
diff --git a/drivers/net/wireless/iwlegacy/4965-mac.c b/drivers/net/wireless/iwlegacy/4965-mac.c
index eac4dc8..14e0a94 100644
--- a/drivers/net/wireless/iwlegacy/4965-mac.c
+++ b/drivers/net/wireless/iwlegacy/4965-mac.c
@@ -6772,7 +6772,7 @@ static struct pci_driver il4965_driver = {
 	.name = DRV_NAME,
 	.id_table = il4965_hw_card_ids,
 	.probe = il4965_pci_probe,
-	.remove = __devexit_p(il4965_pci_remove),
+	.remove = il4965_pci_remove,
 	.driver.pm = IL_LEGACY_PM_OPS,
 };
 
diff --git a/drivers/net/wireless/iwlwifi/pcie/drv.c b/drivers/net/wireless/iwlwifi/pcie/drv.c
index 2a46753..7cb27af 100644
--- a/drivers/net/wireless/iwlwifi/pcie/drv.c
+++ b/drivers/net/wireless/iwlwifi/pcie/drv.c
@@ -353,7 +353,7 @@ static struct pci_driver iwl_pci_driver = {
 	.name = DRV_NAME,
 	.id_table = iwl_hw_card_ids,
 	.probe = iwl_pci_probe,
-	.remove = __devexit_p(iwl_pci_remove),
+	.remove = iwl_pci_remove,
 	.driver.pm = IWL_PM_OPS,
 };
 
diff --git a/drivers/net/wireless/libertas/if_spi.c b/drivers/net/wireless/libertas/if_spi.c
index 9604a1c..98cccc7 100644
--- a/drivers/net/wireless/libertas/if_spi.c
+++ b/drivers/net/wireless/libertas/if_spi.c
@@ -1285,7 +1285,7 @@ static const struct dev_pm_ops if_spi_pm_ops = {
 
 static struct spi_driver libertas_spi_driver = {
 	.probe	= if_spi_probe,
-	.remove = __devexit_p(libertas_spi_remove),
+	.remove = libertas_spi_remove,
 	.driver = {
 		.name	= "libertas_spi",
 		.owner	= THIS_MODULE,
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index 3db4950..c26cfaa 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -5929,8 +5929,8 @@ static struct pci_driver mwl8k_driver = {
 	.name		= MWL8K_NAME,
 	.id_table	= mwl8k_pci_id_table,
 	.probe		= mwl8k_probe,
-	.remove		= __devexit_p(mwl8k_remove),
-	.shutdown	= __devexit_p(mwl8k_shutdown),
+	.remove		= mwl8k_remove,
+	.shutdown	= mwl8k_shutdown,
 };
 
 module_pci_driver(mwl8k_driver);
diff --git a/drivers/net/wireless/orinoco/orinoco_nortel.c b/drivers/net/wireless/orinoco/orinoco_nortel.c
index 326396b..f286540 100644
--- a/drivers/net/wireless/orinoco/orinoco_nortel.c
+++ b/drivers/net/wireless/orinoco/orinoco_nortel.c
@@ -288,7 +288,7 @@ static struct pci_driver orinoco_nortel_driver = {
 	.name		= DRIVER_NAME,
 	.id_table	= orinoco_nortel_id_table,
 	.probe		= orinoco_nortel_init_one,
-	.remove		= __devexit_p(orinoco_nortel_remove_one),
+	.remove		= orinoco_nortel_remove_one,
 	.suspend	= orinoco_pci_suspend,
 	.resume		= orinoco_pci_resume,
 };
diff --git a/drivers/net/wireless/orinoco/orinoco_pci.c b/drivers/net/wireless/orinoco/orinoco_pci.c
index 6058c66..bf6d436 100644
--- a/drivers/net/wireless/orinoco/orinoco_pci.c
+++ b/drivers/net/wireless/orinoco/orinoco_pci.c
@@ -228,7 +228,7 @@ static struct pci_driver orinoco_pci_driver = {
 	.name		= DRIVER_NAME,
 	.id_table	= orinoco_pci_id_table,
 	.probe		= orinoco_pci_init_one,
-	.remove		= __devexit_p(orinoco_pci_remove_one),
+	.remove		= orinoco_pci_remove_one,
 	.suspend	= orinoco_pci_suspend,
 	.resume		= orinoco_pci_resume,
 };
diff --git a/drivers/net/wireless/orinoco/orinoco_plx.c b/drivers/net/wireless/orinoco/orinoco_plx.c
index 2bac824..63a614f 100644
--- a/drivers/net/wireless/orinoco/orinoco_plx.c
+++ b/drivers/net/wireless/orinoco/orinoco_plx.c
@@ -334,7 +334,7 @@ static struct pci_driver orinoco_plx_driver = {
 	.name		= DRIVER_NAME,
 	.id_table	= orinoco_plx_id_table,
 	.probe		= orinoco_plx_init_one,
-	.remove		= __devexit_p(orinoco_plx_remove_one),
+	.remove		= orinoco_plx_remove_one,
 	.suspend	= orinoco_pci_suspend,
 	.resume		= orinoco_pci_resume,
 };
diff --git a/drivers/net/wireless/orinoco/orinoco_tmd.c b/drivers/net/wireless/orinoco/orinoco_tmd.c
index 93159d6..f67f43e 100644
--- a/drivers/net/wireless/orinoco/orinoco_tmd.c
+++ b/drivers/net/wireless/orinoco/orinoco_tmd.c
@@ -214,7 +214,7 @@ static struct pci_driver orinoco_tmd_driver = {
 	.name		= DRIVER_NAME,
 	.id_table	= orinoco_tmd_id_table,
 	.probe		= orinoco_tmd_init_one,
-	.remove		= __devexit_p(orinoco_tmd_remove_one),
+	.remove		= orinoco_tmd_remove_one,
 	.suspend	= orinoco_pci_suspend,
 	.resume		= orinoco_pci_resume,
 };
diff --git a/drivers/net/wireless/p54/p54pci.c b/drivers/net/wireless/p54/p54pci.c
index b439079..b382469 100644
--- a/drivers/net/wireless/p54/p54pci.c
+++ b/drivers/net/wireless/p54/p54pci.c
@@ -699,7 +699,7 @@ static struct pci_driver p54p_driver = {
 	.name		= "p54pci",
 	.id_table	= p54p_table,
 	.probe		= p54p_probe,
-	.remove		= __devexit_p(p54p_remove),
+	.remove		= p54p_remove,
 	.driver.pm	= P54P_PM_OPS,
 };
 
diff --git a/drivers/net/wireless/p54/p54spi.c b/drivers/net/wireless/p54/p54spi.c
index f792990..51129f4 100644
--- a/drivers/net/wireless/p54/p54spi.c
+++ b/drivers/net/wireless/p54/p54spi.c
@@ -710,7 +710,7 @@ static struct spi_driver p54spi_driver = {
 	},
 
 	.probe		= p54spi_probe,
-	.remove		= __devexit_p(p54spi_remove),
+	.remove		= p54spi_remove,
 };
 
 static int __init p54spi_init(void)
diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p54usb.c
index effb044..0463ac2 100644
--- a/drivers/net/wireless/p54/p54usb.c
+++ b/drivers/net/wireless/p54/p54usb.c
@@ -1131,7 +1131,7 @@ static struct usb_driver p54u_driver = {
 	.name	= "p54usb",
 	.id_table = p54u_table,
 	.probe = p54u_probe,
-	.disconnect = __devexit_p(p54u_disconnect),
+	.disconnect = p54u_disconnect,
 	.pre_reset = p54u_pre_reset,
 	.post_reset = p54u_post_reset,
 #ifdef CONFIG_PM
diff --git a/drivers/net/wireless/rt2x00/rt2400pci.c b/drivers/net/wireless/rt2x00/rt2400pci.c
index e3a2d90..a2d2bc2 100644
--- a/drivers/net/wireless/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/rt2x00/rt2400pci.c
@@ -1831,7 +1831,7 @@ static struct pci_driver rt2400pci_driver = {
 	.name		= KBUILD_MODNAME,
 	.id_table	= rt2400pci_device_table,
 	.probe		= rt2400pci_probe,
-	.remove		= __devexit_p(rt2x00pci_remove),
+	.remove		= rt2x00pci_remove,
 	.suspend	= rt2x00pci_suspend,
 	.resume		= rt2x00pci_resume,
 };
diff --git a/drivers/net/wireless/rt2x00/rt2500pci.c b/drivers/net/wireless/rt2x00/rt2500pci.c
index 479d756..9bea10f 100644
--- a/drivers/net/wireless/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/rt2x00/rt2500pci.c
@@ -2122,7 +2122,7 @@ static struct pci_driver rt2500pci_driver = {
 	.name		= KBUILD_MODNAME,
 	.id_table	= rt2500pci_device_table,
 	.probe		= rt2500pci_probe,
-	.remove		= __devexit_p(rt2x00pci_remove),
+	.remove		= rt2x00pci_remove,
 	.suspend	= rt2x00pci_suspend,
 	.resume		= rt2x00pci_resume,
 };
diff --git a/drivers/net/wireless/rt2x00/rt2800pci.c b/drivers/net/wireless/rt2x00/rt2800pci.c
index 27829e1..9224d87 100644
--- a/drivers/net/wireless/rt2x00/rt2800pci.c
+++ b/drivers/net/wireless/rt2x00/rt2800pci.c
@@ -1176,7 +1176,7 @@ static struct platform_driver rt2800soc_driver = {
 		.mod_name	= KBUILD_MODNAME,
 	},
 	.probe		= rt2800soc_probe,
-	.remove		= __devexit_p(rt2x00soc_remove),
+	.remove		= rt2x00soc_remove,
 	.suspend	= rt2x00soc_suspend,
 	.resume		= rt2x00soc_resume,
 };
@@ -1193,7 +1193,7 @@ static struct pci_driver rt2800pci_driver = {
 	.name		= KBUILD_MODNAME,
 	.id_table	= rt2800pci_device_table,
 	.probe		= rt2800pci_probe,
-	.remove		= __devexit_p(rt2x00pci_remove),
+	.remove		= rt2x00pci_remove,
 	.suspend	= rt2x00pci_suspend,
 	.resume		= rt2x00pci_resume,
 };
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/rt2x00/rt61pci.c
index d6582a2..f95792c 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -3094,7 +3094,7 @@ static struct pci_driver rt61pci_driver = {
 	.name		= KBUILD_MODNAME,
 	.id_table	= rt61pci_device_table,
 	.probe		= rt61pci_probe,
-	.remove		= __devexit_p(rt2x00pci_remove),
+	.remove		= rt2x00pci_remove,
 	.suspend	= rt2x00pci_suspend,
 	.resume		= rt2x00pci_resume,
 };
diff --git a/drivers/net/wireless/rtl818x/rtl8180/dev.c b/drivers/net/wireless/rtl818x/rtl8180/dev.c
index 021d83e..b117541 100644
--- a/drivers/net/wireless/rtl818x/rtl8180/dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8180/dev.c
@@ -1170,7 +1170,7 @@ static struct pci_driver rtl8180_driver = {
 	.name		= KBUILD_MODNAME,
 	.id_table	= rtl8180_table,
 	.probe		= rtl8180_probe,
-	.remove		= __devexit_p(rtl8180_remove),
+	.remove		= rtl8180_remove,
 #ifdef CONFIG_PM
 	.suspend	= rtl8180_suspend,
 	.resume		= rtl8180_resume,
diff --git a/drivers/net/wireless/rtl818x/rtl8187/dev.c b/drivers/net/wireless/rtl818x/rtl8187/dev.c
index 7811b63..9892310 100644
--- a/drivers/net/wireless/rtl818x/rtl8187/dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8187/dev.c
@@ -1664,7 +1664,7 @@ static struct usb_driver rtl8187_driver = {
 	.name		= KBUILD_MODNAME,
 	.id_table	= rtl8187_table,
 	.probe		= rtl8187_probe,
-	.disconnect	= __devexit_p(rtl8187_disconnect),
+	.disconnect	= rtl8187_disconnect,
 	.disable_hub_initiated_lpm = 1,
 };
 
diff --git a/drivers/net/wireless/ti/wl1251/sdio.c b/drivers/net/wireless/ti/wl1251/sdio.c
index e2750a1..e3f287f 100644
--- a/drivers/net/wireless/ti/wl1251/sdio.c
+++ b/drivers/net/wireless/ti/wl1251/sdio.c
@@ -347,7 +347,7 @@ static struct sdio_driver wl1251_sdio_driver = {
 	.name		= "wl1251_sdio",
 	.id_table	= wl1251_devices,
 	.probe		= wl1251_sdio_probe,
-	.remove		= __devexit_p(wl1251_sdio_remove),
+	.remove		= wl1251_sdio_remove,
 	.drv.pm		= &wl1251_sdio_pm_ops,
 };
 
diff --git a/drivers/net/wireless/ti/wl1251/spi.c b/drivers/net/wireless/ti/wl1251/spi.c
index 567660c..3ec61b9 100644
--- a/drivers/net/wireless/ti/wl1251/spi.c
+++ b/drivers/net/wireless/ti/wl1251/spi.c
@@ -326,7 +326,7 @@ static struct spi_driver wl1251_spi_driver = {
 	},
 
 	.probe		= wl1251_spi_probe,
-	.remove		= __devexit_p(wl1251_spi_remove),
+	.remove		= wl1251_spi_remove,
 };
 
 static int __init wl1251_spi_init(void)
diff --git a/drivers/net/wireless/ti/wl12xx/main.c b/drivers/net/wireless/ti/wl12xx/main.c
index dadf1db..bc522b6 100644
--- a/drivers/net/wireless/ti/wl12xx/main.c
+++ b/drivers/net/wireless/ti/wl12xx/main.c
@@ -1733,7 +1733,7 @@ MODULE_DEVICE_TABLE(platform, wl12xx_id_table);
 
 static struct platform_driver wl12xx_driver = {
 	.probe		= wl12xx_probe,
-	.remove		= __devexit_p(wlcore_remove),
+	.remove		= wlcore_remove,
 	.id_table	= wl12xx_id_table,
 	.driver = {
 		.name	= "wl12xx_driver",
diff --git a/drivers/net/wireless/ti/wl18xx/main.c b/drivers/net/wireless/ti/wl18xx/main.c
index a39682a..2d037d5 100644
--- a/drivers/net/wireless/ti/wl18xx/main.c
+++ b/drivers/net/wireless/ti/wl18xx/main.c
@@ -1536,7 +1536,7 @@ MODULE_DEVICE_TABLE(platform, wl18xx_id_table);
 
 static struct platform_driver wl18xx_driver = {
 	.probe		= wl18xx_probe,
-	.remove		= __devexit_p(wlcore_remove),
+	.remove		= wlcore_remove,
 	.id_table	= wl18xx_id_table,
 	.driver = {
 		.name	= "wl18xx_driver",
diff --git a/drivers/net/wireless/ti/wlcore/sdio.c b/drivers/net/wireless/ti/wlcore/sdio.c
index 73ace4b..830bf0d 100644
--- a/drivers/net/wireless/ti/wlcore/sdio.c
+++ b/drivers/net/wireless/ti/wlcore/sdio.c
@@ -384,7 +384,7 @@ static struct sdio_driver wl1271_sdio_driver = {
 	.name		= "wl1271_sdio",
 	.id_table	= wl1271_devices,
 	.probe		= wl1271_probe,
-	.remove		= __devexit_p(wl1271_remove),
+	.remove		= wl1271_remove,
 #ifdef CONFIG_PM
 	.drv = {
 		.pm = &wl1271_sdio_pm_ops,
diff --git a/drivers/net/wireless/ti/wlcore/spi.c b/drivers/net/wireless/ti/wlcore/spi.c
index a519bc3..b183001 100644
--- a/drivers/net/wireless/ti/wlcore/spi.c
+++ b/drivers/net/wireless/ti/wlcore/spi.c
@@ -422,7 +422,7 @@ static struct spi_driver wl1271_spi_driver = {
 	},
 
 	.probe		= wl1271_probe,
-	.remove		= __devexit_p(wl1271_remove),
+	.remove		= wl1271_remove,
 };
 
 static int __init wl1271_init(void)
-- 
1.8.0

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
