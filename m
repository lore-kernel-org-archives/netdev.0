From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/4] skge: update version
Date: Wed, 06 Jul 2011 22:00:08 -0700
Message-ID: <20110707050049.178974636@vyatta.com>
References: <20110707050003.998140428@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42592 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751284Ab1GGFBP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jul 2011 01:01:15 -0400
Content-Disposition: inline; filename=skge-version.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update version number, and take "New" off the config information
since old sk98lin has been gone for a couple years.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/Kconfig	2011-07-06 21:58:12.139686271 -0700
+++ b/drivers/net/Kconfig	2011-07-06 21:58:30.071682326 -0700
@@ -2272,7 +2272,7 @@ config SIS190
 	  will be called sis190.  This is recommended.
 
 config SKGE
-	tristate "New SysKonnect GigaEthernet support"
+	tristate "SysKonnect GigaEthernet support"
 	depends on PCI
 	select CRC32
 	---help---
--- a/drivers/net/skge.c	2011-07-06 21:57:53.915690195 -0700
+++ b/drivers/net/skge.c	2011-07-06 21:58:06.675686411 -0700
@@ -50,7 +50,7 @@
 #include "skge.h"
 
 #define DRV_NAME		"skge"
-#define DRV_VERSION		"1.13"
+#define DRV_VERSION		"1.14"
 
 #define DEFAULT_TX_RING_SIZE	128
 #define DEFAULT_RX_RING_SIZE	512


