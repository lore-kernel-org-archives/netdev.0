From: akpm@osdl.org
Subject: [patch 06/11] drivers/net/tokenring/lanstreamer.h Removal of old code
Date: Mon, 25 Sep 2006 16:39:21 -0700
Message-ID: <200609252339.k8PNdLik002641@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	michal.k.k.piotrowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:14004 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751716AbWIYXj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 19:39:29 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/tokenring/lanstreamer.h |   12 ------------
 1 file changed, 12 deletions(-)

diff -puN drivers/net/tokenring/lanstreamer.h~drivers-net-tokenring-lanstreamerh-removal-of-old-code drivers/net/tokenring/lanstreamer.h
--- a/drivers/net/tokenring/lanstreamer.h~drivers-net-tokenring-lanstreamerh-removal-of-old-code
+++ a/drivers/net/tokenring/lanstreamer.h
@@ -62,18 +62,6 @@
 
 #include <linux/version.h>
 
-#if STREAMER_IOCTL && (LINUX_VERSION_CODE < KERNEL_VERSION(2,5,0))
-#include <asm/ioctl.h>
-#define IOCTL_PRINT_RX_BUFS   SIOCDEVPRIVATE
-#define IOCTL_PRINT_TX_BUFS   SIOCDEVPRIVATE+1
-#define IOCTL_RX_CMD          SIOCDEVPRIVATE+2
-#define IOCTL_TX_CMD          SIOCDEVPRIVATE+3
-#define IOCTL_PRINT_REGISTERS SIOCDEVPRIVATE+4
-#define IOCTL_PRINT_BDAS      SIOCDEVPRIVATE+5
-#define IOCTL_SPIN_LOCK_TEST  SIOCDEVPRIVATE+6
-#define IOCTL_SISR_MASK       SIOCDEVPRIVATE+7
-#endif
-
 /* MAX_INTR - the maximum number of times we can loop
  * inside the interrupt function before returning
  * control to the OS (maximum value is 256)
_
