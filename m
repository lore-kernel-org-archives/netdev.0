From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 3/3] net: neterion: Do not break word unregister.
Date: Mon, 17 Sep 2001 00:00:00 +0900
Message-ID: <201211021439.qA2EdkbO004741@94.43.138.210.xn.2iij.net>
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:58901 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753676Ab2KBOpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 10:45:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/net/ethernet/neterion/s2io.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index de50547..c98decb 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -8239,7 +8239,8 @@ static int __init s2io_starter(void)
 
 /**
  * s2io_closer - Cleanup routine for the driver
- * Description: This function is the cleanup routine for the driver. It unregist * ers the driver.
+ * Description: This function is the cleanup routine for the driver. It
+ * unregisters the driver.
  */
 
 static __exit void s2io_closer(void)
-- 
1.7.9.5
