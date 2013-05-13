From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/2] net/usb: r8152: Remove redundant version.h header inclusion
Date: Mon, 13 May 2013 10:25:22 +0530
Message-ID: <1368420923-32222-1-git-send-email-sachin.kamat@linaro.org>
Cc: nic_swsd@realtek.com, hayeswang@realtek.com, davem@davemloft.net,
	sachin.kamat@linaro.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:58538 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750763Ab3EMFIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 May 2013 01:08:42 -0400
Received: by mail-pd0-f178.google.com with SMTP id w11so4100749pde.9
        for <netdev@vger.kernel.org>; Sun, 12 May 2013 22:08:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

version.h header inclusion is not necessary as detected by
checkversion.pl.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
This series compile tested against linux-next (20130513).
---
 drivers/net/usb/r8152.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 14e5198..8e53e41 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -11,7 +11,6 @@
 #include <linux/signal.h>
 #include <linux/slab.h>
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/mii.h>
-- 
1.7.9.5
