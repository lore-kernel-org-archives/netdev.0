From: Colin King <colin.king@canonical.com>
Subject: [PATCH][V2] [media] gp8psk: fix spelling mistake: "firmare" -> "firmware"
Date: Thu, 29 Dec 2016 21:38:15 +0000
Message-ID: <20161229213815.27890-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Mauro Carvalho Chehab <mchehab@kernel.org>,
        Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>, linux-media@vger.kernel.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake in err message. Also change "don't" to
"does not".

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/media/usb/dvb-usb/gp8psk.c          | 2 +-
 drivers/net/wireless/realtek/rtlwifi/core.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/media/usb/dvb-usb/gp8psk.c b/drivers/media/usb/dvb-usb/gp8psk.c
index 2360e7e..26461f2 100644
--- a/drivers/media/usb/dvb-usb/gp8psk.c
+++ b/drivers/media/usb/dvb-usb/gp8psk.c
@@ -161,7 +161,7 @@ static int gp8psk_load_bcm4500fw(struct dvb_usb_device *d)
 			goto out_free;
 		}
 		if (buflen > 64) {
-			err("firmare chunk size bigger than 64 bytes.");
+			err("firmware chunk size bigger than 64 bytes.");
 			goto out_free;
 		}
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/core.c b/drivers/net/wireless/realtek/rtlwifi/core.c
index ded1493..732de0a 100644
--- a/drivers/net/wireless/realtek/rtlwifi/core.c
+++ b/drivers/net/wireless/realtek/rtlwifi/core.c
@@ -1532,7 +1532,7 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 		key_type = AESCMAC_ENCRYPTION;
 		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, "alg:CMAC\n");
 		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-			 "HW don't support CMAC encrypiton, use software CMAC encrypiton\n");
+			 "HW does not support CMAC encryption, use software CMAC encryption\n");
 		err = -EOPNOTSUPP;
 		goto out_unlock;
 	default:
-- 
2.10.2
