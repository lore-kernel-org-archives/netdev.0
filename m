From: Cyril Brulebois <kibi@debian.org>
Subject: [PATCH] wireless: rt2x00: add new rt2800usb device
Date: Tue, 28 Oct 2014 16:42:41 +0100
Message-ID: <1414510961-28920-1-git-send-email-kibi@debian.org>
Cc: linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Cyril Brulebois <kibi@debian.org>, stable@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>,
	Helmut Schaa <helmut.schaa@googlemail.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

0x1b75 0xa200 AirLive WN-200USB wireless 11b/g/n dongle

References: https://bugs.debian.org/766802
Reported-by: Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>
Cc: stable@vger.kernel.org
Signed-off-by: Cyril Brulebois <kibi@debian.org>
---
 drivers/net/wireless/rt2x00/rt2800usb.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wireless/rt2x00/rt2800usb.c
index 573897b..8444313 100644
--- a/drivers/net/wireless/rt2x00/rt2800usb.c
+++ b/drivers/net/wireless/rt2x00/rt2800usb.c
@@ -1111,6 +1111,7 @@ static struct usb_device_id rt2800usb_device_table[] = {
 	/* Ovislink */
 	{ USB_DEVICE(0x1b75, 0x3071) },
 	{ USB_DEVICE(0x1b75, 0x3072) },
+	{ USB_DEVICE(0x1b75, 0xa200) },
 	/* Para */
 	{ USB_DEVICE(0x20b8, 0x8888) },
 	/* Pegatron */
-- 
1.7.10.4
