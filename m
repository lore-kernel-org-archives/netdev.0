From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 5/6 v2] au1000-eth: fix asm -> linux headers inclusion
Date: Thu, 12 Aug 2010 10:10:04 +0200
Message-ID: <201008121010.04897.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39589 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932926Ab0HLIKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 04:10:04 -0400
Received: by mail-ww0-f44.google.com with SMTP id 40so1218472wwj.1
        for <netdev@vger.kernel.org>; Thu, 12 Aug 2010 01:10:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Replace asm/io.h and asm/cpu.h wih linux/io.h and linux/cpu.h

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 7625573..7b823c9 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -58,11 +58,11 @@
 #include <linux/crc32.h>
 #include <linux/phy.h>
 #include <linux/platform_device.h>
+#include <linux/cpu.h>
+#include <linux/io.h>
 
-#include <asm/cpu.h>
 #include <asm/mipsregs.h>
 #include <asm/irq.h>
-#include <asm/io.h>
 #include <asm/processor.h>
 
 #include <au1000.h>


