From: Colin King <colin.king@canonical.com>
Subject: [PATCH] zd1211rw: fix spelling mistake "firmeware" -> "firmware"
Date: Mon, 22 Aug 2016 19:35:05 +0100
Message-ID: <20160822183505.26568-1-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Daniel Drake <dsd@gentoo.org>, Ulrich Kunitz <kune@deine-taler.de>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake in dev_err message.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/zydas/zd1211rw/zd_usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/zydas/zd1211rw/zd_usb.c b/drivers/net/wireless/zydas/zd1211rw/zd_usb.c
index a912dc0..c5effd6c 100644
--- a/drivers/net/wireless/zydas/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zydas/zd1211rw/zd_usb.c
@@ -193,7 +193,7 @@ static int upload_code(struct usb_device *udev,
 			0, 0, p, sizeof(ret), 5000 /* ms */);
 		if (r != sizeof(ret)) {
 			dev_err(&udev->dev,
-				"control request firmeware confirmation failed."
+				"control request firmware confirmation failed."
 				" Return value %d\n", r);
 			if (r >= 0)
 				r = -ENODEV;
-- 
2.9.3
