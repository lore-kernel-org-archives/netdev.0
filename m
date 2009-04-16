From: Brice Goglin <brice@myri.com>
Subject: [PATCH net-next] myri10ge: add MODULE_DEVICE_TABLE
Date: Thu, 16 Apr 2009 14:29:22 +0200
Message-ID: <49E724A2.4040109@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1934 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754632AbZDPM3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2009 08:29:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add MODULE_DEVICE_TABLE so that modinfo reports pci device id aliases.

Signed-off-by: Brice Goglin <brice@myri.com>

--- linux-tmp.old/drivers/net/myri10ge/myri10ge.c	2009-03-27 17:16:43.000000000 +0100
+++ linux-tmp/drivers/net/myri10ge/myri10ge.c	2009-04-07 20:40:07.000000000 +0200
@@ -75,7 +75,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.4.4-1.401"
+#define MYRI10GE_VERSION_STR "1.4.4-1.412"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
@@ -4035,6 +4035,8 @@
 	{0},
 };
 
+MODULE_DEVICE_TABLE(pci, myri10ge_pci_tbl);
+
 static struct pci_driver myri10ge_driver = {
 	.name = "myri10ge",
 	.probe = myri10ge_probe,


