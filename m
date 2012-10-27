From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next] net/cadence: depend on HAS_IOMEM
Date: Sat, 27 Oct 2012 14:10:23 +0200
Message-ID: <1351339823-24987-1-git-send-email-manabian@gmail.com>
Cc: netdev@vger.kernel.org, Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net,
	fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:59226 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293Ab2J0MKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2012 08:10:53 -0400
Received: by mail-la0-f46.google.com with SMTP id h6so2885468lag.19
        for <netdev@vger.kernel.org>; Sat, 27 Oct 2012 05:10:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes the following build failure on S390:
  In file included from drivers/net/ethernet/cadence/at91_ether.c:35:0:
   drivers/net/ethernet/cadence/macb.h: In function 'macb_is_gem':
   drivers/net/ethernet/cadence/macb.h:563:2: error: implicit declaration of function '__raw_readl' [-Werror=implicit-function-declaration]
   drivers/net/ethernet/cadence/at91_ether.c: In function 'update_mac_address':
   drivers/net/ethernet/cadence/at91_ether.c:119:2: error: implicit declaration of function '__raw_writel' [-Werror=implicit-function-declaration]
   cc1: some warnings being treated as errors

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/cadence/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethernet/cadence/Kconfig
index 40172d1..ceb0de0 100644
--- a/drivers/net/ethernet/cadence/Kconfig
+++ b/drivers/net/ethernet/cadence/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_CADENCE
 	bool "Cadence devices"
+	depends on HAS_IOMEM
 	default y
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y.
-- 
1.8.0
