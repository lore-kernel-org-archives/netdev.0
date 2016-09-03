From: Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH] rtl8xxxu: fix spelling mistake "firmare" -> "firmware"
Date: Sat,  3 Sep 2016 17:43:54 +0100
Message-ID: <20160903164354.13331-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jes Sorensen <Jes.Sorensen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

Trivial fix to spelling mistakes in dev_dbg message.

Signed-off-by: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
index 77048db..9cb1efa 100644
--- a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
+++ b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
@@ -3947,11 +3947,11 @@ static int rtl8xxxu_init_device(struct ieee80211_hw *hw)
 	rtl8xxxu_write16(priv, REG_TRXFF_BNDY + 2, priv->fops->trxff_boundary);
 
 	ret = rtl8xxxu_download_firmware(priv);
-	dev_dbg(dev, "%s: download_fiwmare %i\n", __func__, ret);
+	dev_dbg(dev, "%s: download_firmware %i\n", __func__, ret);
 	if (ret)
 		goto exit;
 	ret = rtl8xxxu_start_firmware(priv);
-	dev_dbg(dev, "%s: start_fiwmare %i\n", __func__, ret);
+	dev_dbg(dev, "%s: start_firmware %i\n", __func__, ret);
 	if (ret)
 		goto exit;
 
-- 
2.9.3
