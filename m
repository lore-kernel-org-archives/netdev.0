From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 5/7 v3] au1000-eth: fix asm -> linux headers inclusion
Date: Wed, 8 Sep 2010 23:11:49 +0200
Message-ID: <201009082311.49582.florian@openwrt.org>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46813 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755304Ab0IHVKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 17:10:44 -0400
Received: by mail-wy0-f174.google.com with SMTP id 22so488057wyf.19
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 14:10:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Replace asm/io.h and asm/cpu.h wih linux/io.h and linux/cpu.h

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index f758b60..4bbc537 100644
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


