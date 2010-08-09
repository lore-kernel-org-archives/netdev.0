From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 5/6] au1000-eth: fix asm -> linux headers inclusion
Date: Mon, 9 Aug 2010 22:03:44 +0200
Message-ID: <201008092203.45938.florian@openwrt.org>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55363 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755979Ab0HIUC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 16:02:57 -0400
Received: by mail-ww0-f44.google.com with SMTP id 40so12017023wwj.1
        for <netdev@vger.kernel.org>; Mon, 09 Aug 2010 13:02:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Replace asm/io.h and asm/cpu.h wih linux/io.h and linux/cpu.h

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index f8f1f5e..4605c3d 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -56,11 +56,11 @@
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


