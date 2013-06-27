From: David Chang <dchang@suse.com>
Subject: [PATCH 1/2 net-next] usbnet: ax88179_178a: Correct a typo in description
Date: Thu, 27 Jun 2013 17:16:42 +0800
Message-ID: <1372324603-4556-1-git-send-email-dchang@suse.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jlee@suse.com,
	David Chang <dchang@suse.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Correct a typo in description of driver_info, it should be Gigabit

Signed-off-by: David Chang <dchang@suse.com>
---
 drivers/net/usb/ax88179_178a.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
index bd8758f..7ce243b 100644
--- a/drivers/net/usb/ax88179_178a.c
+++ b/drivers/net/usb/ax88179_178a.c
@@ -1371,7 +1371,7 @@ static int ax88179_stop(struct usbnet *dev)
 }
 
 static const struct driver_info ax88179_info = {
-	.description = "ASIX AX88179 USB 3.0 Gigibit Ethernet",
+	.description = "ASIX AX88179 USB 3.0 Gigabit Ethernet",
 	.bind = ax88179_bind,
 	.unbind = ax88179_unbind,
 	.status = ax88179_status,
@@ -1384,7 +1384,7 @@ static const struct driver_info ax88179_info = {
 };
 
 static const struct driver_info ax88178a_info = {
-	.description = "ASIX AX88178A USB 2.0 Gigibit Ethernet",
+	.description = "ASIX AX88178A USB 2.0 Gigabit Ethernet",
 	.bind = ax88179_bind,
 	.unbind = ax88179_unbind,
 	.status = ax88179_status,
-- 
1.8.1.4
