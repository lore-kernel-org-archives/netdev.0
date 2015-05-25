From: Shailendra Verma <shailendra.capricorn@gmail.com>
Subject: [PATCH] net:xen-netback - Change 1 to true for bool type variable.
Date: Mon, 25 May 2015 23:19:31 +0530
Message-ID: <1432576171-3563-1-git-send-email-shailendra.capricorn@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Shailendra Verma <shailendra.capricorn@gmail.com>
To: Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xenproject.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:34526 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791AbbEYRtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 13:49:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The variable separate_tx_rx_irq is bool type so assigning true
instead of 1.

Signed-off-by: Shailendra Verma <shailendra.capricorn@gmail.com>
---
 drivers/net/xen-netback/netback.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 4de46aa..792ada6 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -52,7 +52,7 @@
  * event channels are limited resource. Split event channels are
  * enabled by default.
  */
-bool separate_tx_rx_irq = 1;
+bool separate_tx_rx_irq = true;
 module_param(separate_tx_rx_irq, bool, 0644);
 
 /* The time that packets can stay on the guest Rx internal queue
-- 
1.7.9.5
