From: akpm@osdl.org
Subject: [patch 07/11] drivers/net/typhoon.c Removal of old code
Date: Mon, 25 Sep 2006 16:39:21 -0700
Message-ID: <200609252339.k8PNdMRI002644@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	michal.k.k.piotrowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:15796 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751718AbWIYXjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 19:39:31 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/typhoon.c |    4 ----
 1 file changed, 4 deletions(-)

diff -puN drivers/net/typhoon.c~drivers-net-typhoonc-removal-of-old-code drivers/net/typhoon.c
--- a/drivers/net/typhoon.c~drivers-net-typhoonc-removal-of-old-code
+++ a/drivers/net/typhoon.c
@@ -333,11 +333,7 @@ enum state_values {
 #define TYPHOON_RESET_TIMEOUT_NOSLEEP	((6 * 1000000) / TYPHOON_UDELAY)
 #define TYPHOON_WAIT_TIMEOUT		((1000000 / 2) / TYPHOON_UDELAY)
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 5, 28)
-#define typhoon_synchronize_irq(x) synchronize_irq()
-#else
 #define typhoon_synchronize_irq(x) synchronize_irq(x)
-#endif
 
 #if defined(NETIF_F_TSO)
 #define skb_tso_size(x)		(skb_shinfo(x)->gso_size)
_
