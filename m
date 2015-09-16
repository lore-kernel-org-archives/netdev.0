From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH net-next] net: fix cdc-phonet.c dependency and build error
Date: Wed, 16 Sep 2015 11:32:41 -0700
Message-ID: <55F9B5C9.1060509@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Fengguang Wu <fengguang.wu@intel.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:55099 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752648AbbIPScs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 14:32:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>

Fix build error caused by missing Kconfig dependency:

ERROR: "cdc_parse_cdc_header" [drivers/net/usb/cdc-phonet.ko] undefined!

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 drivers/net/usb/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next-20150916.orig/drivers/net/usb/Kconfig
+++ linux-next-20150916/drivers/net/usb/Kconfig
@@ -541,7 +541,7 @@ config USB_NET_INT51X1
 
 config USB_CDC_PHONET
 	tristate "CDC Phonet support"
-	depends on PHONET
+	depends on PHONET && USB_USBNET
 	help
 	  Choose this option to support the Phonet interface to a Nokia
 	  cellular modem, as found on most Nokia handsets with the
