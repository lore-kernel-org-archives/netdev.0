From: Richard Genoud <richard.genoud@gmail.com>
Subject: [PATCH] Remove duplicate slow protocol define in bond_3ad.h
Date: Sat,  9 May 2009 18:59:16 +0200
Message-ID: <1241888356-7575-1-git-send-email-richard.genoud@gmail.com>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Richard Genoud <richard.genoud@gmail.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:42103 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752083AbZEIQ7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2009 12:59:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ETH_P_SLOW is already defined in include/linux/if_ether.h.
There's no need to define BOND_ETH_P_LACPDU in drivers/net/bonding/bond_3ad.h

Signed-off-by: Richard Genoud <richard.genoud@gmail.com>
---
 drivers/net/bonding/bond_3ad.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
index a306230..2c46a15 100644
--- a/drivers/net/bonding/bond_3ad.h
+++ b/drivers/net/bonding/bond_3ad.h
@@ -26,10 +26,10 @@
 #include <asm/byteorder.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
+#include <linux/if_ether.h>
 
 // General definitions
-#define BOND_ETH_P_LACPDU       0x8809
-#define PKT_TYPE_LACPDU         cpu_to_be16(BOND_ETH_P_LACPDU)
+#define PKT_TYPE_LACPDU         cpu_to_be16(ETH_P_SLOW)
 #define AD_TIMER_INTERVAL       100 /*msec*/
 
 #define MULTICAST_LACPDU_ADDR    {0x01, 0x80, 0xC2, 0x00, 0x00, 0x02}
-- 
1.6.0.4

