From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] net: can: usb: peak_usb: pcan_usb_core.c:  Cleaning up missing null-terminate in conjunction with strncpy
Date: Sun, 14 Sep 2014 19:31:37 +0200
Message-ID: <1410715898-15904-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Stephane Grosjean <s.grosjean@peak-system.com>,
	Alexey Khoroshilov <khoroshilov@ispras.ru>,
	"Christopher R. Baker" <cbaker@rec.ri.cmu.edu>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replacing strncpy with strlcpy to avoid strings that lacks null terminate.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/net/can/usb/peak_usb/pcan_usb_core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_core.c b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
index 644e6ab..d4fe8ac 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_core.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
@@ -830,7 +830,7 @@ static void peak_usb_disconnect(struct usb_interface *intf)
 		char name[IFNAMSIZ];
 
 		dev->state &= ~PCAN_USB_STATE_CONNECTED;
-		strncpy(name, netdev->name, IFNAMSIZ);
+		strlcpy(name, netdev->name, IFNAMSIZ);
 
 		unregister_netdev(netdev);
 		free_candev(netdev);
-- 
1.7.10.4

