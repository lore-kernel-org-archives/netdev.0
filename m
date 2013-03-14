From: Robert de Vries <rhdv@xs4all.nl>
Subject: [PATCH] smsc75xx: configuration help incorrectly mentions smsc95xx
Date: Thu, 14 Mar 2013 20:29:06 +0100
Message-ID: <1363289346-3084-1-git-send-email-rhdv@xs4all.nl>
Cc: Robert de Vries <rhdv@xs4all.nl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from calvin.xs4all.nl ([80.100.38.15]:60587 "EHLO calvin.xs4all.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750951Ab3CNThl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Mar 2013 15:37:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Kconfig file help information incorrectly mentions that the
SMSC LAN75xx config option is for SMSC LAN95xx devices.

Signed-off-by: Robert de Vries <rhdv@xs4all.nl>
---
 drivers/net/usb/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 3b6e9b8..7c769d8 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -268,7 +268,7 @@ config USB_NET_SMSC75XX
 	select CRC16
 	select CRC32
 	help
-	  This option adds support for SMSC LAN95XX based USB 2.0
+	  This option adds support for SMSC LAN75XX based USB 2.0
 	  Gigabit Ethernet adapters.
 
 config USB_NET_SMSC95XX
-- 
1.7.9.5
