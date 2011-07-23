From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: [PATCH] can: c_can: remove duplicated #include
Date: Sat, 23 Jul 2011 16:19:40 +0800
Message-ID: <1311409180-2988-1-git-send-email-weiyi.huang@gmail.com>
Cc: netdev@vger.kernel.org, Huang Weiyi <weiyi.huang@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:46215 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751471Ab1GWITy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2011 04:19:54 -0400
Received: by mail-pz0-f42.google.com with SMTP id 37so4899732pzk.1
        for <netdev@vger.kernel.org>; Sat, 23 Jul 2011 01:19:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove duplicated #include('s) in
  drivers/net/can/c_can/c_can.c
  drivers/net/can/c_can/c_can_platform.c

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
---
 drivers/net/can/c_can/c_can.c          |    1 -
 drivers/net/can/c_can/c_can_platform.c |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 80adc83..536bda0 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -33,7 +33,6 @@
 #include <linux/if_arp.h>
 #include <linux/if_ether.h>
 #include <linux/list.h>
-#include <linux/delay.h>
 #include <linux/io.h>
 
 #include <linux/can.h>
diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index 0e300cf..0b5c6f8 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -27,7 +27,6 @@
 #include <linux/if_arp.h>
 #include <linux/if_ether.h>
 #include <linux/list.h>
-#include <linux/delay.h>
 #include <linux/io.h>
 #include <linux/platform_device.h>
 #include <linux/clk.h>
-- 
1.5.6.4

