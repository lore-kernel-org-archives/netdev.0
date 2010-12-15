From: Arnaud Ebalard <arno@natisbad.org>
Subject: [PATCH] asix: add USB ID for Logitec LAN-GTJ U2A
Date: Wed, 15 Dec 2010 23:16:30 +0100
Message-ID: <87sjxy4w3o.fsf@totally-fudged-out-message-id>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "stable team" <stable@kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	"David Hollis" <dhollis@davehollis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:56892 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751718Ab0LOWcA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Dec 2010 17:32:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Logitec LAN-GTJ U2A (http://www.pro.logitec.co.jp/pro/g/gLAN-GTJU2A/)
USB 2.0 10/10/1000 Ethernet adapter is based on ASIX AX88178 chipset.

This patch adds missing USB ID for the device. This is a candidate for
stable kernels (ASIX AX88178 support is available upstream for years).

Tested on current net-2.6.

Signed-off-by: Arnaud Ebalard <arno@natisbad.org>
---
 drivers/net/usb/asix.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index aea4645..6140b56 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -1508,6 +1508,10 @@ static const struct usb_device_id	products [] = {
 	USB_DEVICE (0x0b95, 0x1780),
 	.driver_info = (unsigned long) &ax88178_info,
 }, {
+	// Logitec LAN-GTJ/U2A
+	USB_DEVICE (0x0789, 0x0160),
+	.driver_info = (unsigned long) &ax88178_info,
+}, {
 	// Linksys USB200M Rev 2
 	USB_DEVICE (0x13b1, 0x0018),
 	.driver_info = (unsigned long) &ax88772_info,
-- 
1.7.2.3

