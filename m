From: Scott Branden <sbranden@broadcom.com>
Subject: [PATCH] wireless: rt2x00: add new rt2800usb device DWA 130
Date: Mon, 16 Mar 2015 10:59:52 -0700
Message-ID: <1426528792-992-1-git-send-email-sbranden@broadcom.com>
References: <Scott Branden <sbranden@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
	<users@rt2x00.serialmonkey.com>,
	Scott Branden <sbranden@broadcom.com>,
	Pieter Truter <ptruter@broadcom.com>
To: <bcm-kernel-feedback-list@broadcom.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Helmut Schaa <helmut.schaa@googlemail.com>,
	Kalle Valo <kvalo@codeaurora.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Scott Branden <sbranden@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the USB Id to link the D-Link DWA 130 USB Wifi adapter
to the rt2830 driver.

Signed-off-by: Scott Branden <sbranden@broadcom.com>
Signed-off-by: Pieter Truter <ptruter@broadcom.com>
---
 drivers/net/wireless/rt2x00/rt2800usb.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wireless/rt2x00/rt2800usb.c
index 8444313..8694ddd 100644
--- a/drivers/net/wireless/rt2x00/rt2800usb.c
+++ b/drivers/net/wireless/rt2x00/rt2800usb.c
@@ -1040,6 +1040,7 @@ static struct usb_device_id rt2800usb_device_table[] = {
 	{ USB_DEVICE(0x07d1, 0x3c17) },
 	{ USB_DEVICE(0x2001, 0x3317) },
 	{ USB_DEVICE(0x2001, 0x3c1b) },
+	{ USB_DEVICE(0x2001, 0x3c25) },
 	/* Draytek */
 	{ USB_DEVICE(0x07fa, 0x7712) },
 	/* DVICO */
-- 
2.3.3
