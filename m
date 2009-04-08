From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH] r6040: set MODULE_VERSION
Date: Wed, 8 Apr 2009 10:35:00 +0200
Message-ID: <200904081035.00444.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:2650 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752993AbZDHIfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 04:35:06 -0400
Received: by yw-out-2324.google.com with SMTP id 5so4417ywb.1
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2009 01:35:05 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch sets MODULE_VERSION in order to help users track
changes to this module.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 0a37f99..e23d7fa 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -160,6 +160,7 @@ MODULE_AUTHOR("Sten Wang <sten.wang@rdc.com.tw>,"
 	"Florian Fainelli <florian@openwrt.org>");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("RDC R6040 NAPI PCI FastEthernet driver");
+MODULE_VERSION(DRV_VERSION " " DRV_RELDATE);
 
 /* RX and TX interrupts that we handle */
 #define RX_INTS			(RX_FIFO_FULL | RX_NO_DESC | RX_FINISH)
