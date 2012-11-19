From: Bill Pemberton <wfp5p-4Ng6DfrEGID2fBVCVOL8/A@public.gmane.org>
Subject: [PATCH 126/493] rfkill: remove use of __devexit_p
Date: Mon, 19 Nov 2012 13:21:15 -0500
Message-ID: <1353349642-3677-126-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p-4Ng6DfrEGID2fBVCVOL8/A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

CONFIG_HOTPLUG is going away as an option so __devexit_p is no longer
needed.

Signed-off-by: Bill Pemberton <wfp5p-4Ng6DfrEGID2fBVCVOL8/A@public.gmane.org>
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> 
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> 
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> 
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org 
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org 
---
 net/rfkill/rfkill-gpio.c      | 2 +-
 net/rfkill/rfkill-regulator.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
index 865adb6..78fc093 100644
--- a/net/rfkill/rfkill-gpio.c
+++ b/net/rfkill/rfkill-gpio.c
@@ -213,7 +213,7 @@ static int rfkill_gpio_remove(struct platform_device *pdev)
 
 static struct platform_driver rfkill_gpio_driver = {
 	.probe = rfkill_gpio_probe,
-	.remove = __devexit_p(rfkill_gpio_remove),
+	.remove = rfkill_gpio_remove,
 	.driver = {
 		   .name = "rfkill_gpio",
 		   .owner = THIS_MODULE,
diff --git a/net/rfkill/rfkill-regulator.c b/net/rfkill/rfkill-regulator.c
index 11da301..a87710d 100644
--- a/net/rfkill/rfkill-regulator.c
+++ b/net/rfkill/rfkill-regulator.c
@@ -137,7 +137,7 @@ static int __devexit rfkill_regulator_remove(struct platform_device *pdev)
 
 static struct platform_driver rfkill_regulator_driver = {
 	.probe = rfkill_regulator_probe,
-	.remove = __devexit_p(rfkill_regulator_remove),
+	.remove = rfkill_regulator_remove,
 	.driver = {
 		.name = "rfkill-regulator",
 		.owner = THIS_MODULE,
-- 
1.8.0

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
