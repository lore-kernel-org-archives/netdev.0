From: Avinash kumar <avi.kp.137@gmail.com>
Subject: [PATCH] drivers: net: phy: marvell.c: removed checkpatch.pl warnings
Date: Mon, 30 Sep 2013 09:36:44 +0530
Message-ID: <1380514004-8701-1-git-send-email-avi.kp.137@gmail.com>
Cc: michal.simek@xilinx.com, lars@metafoo.de, RHoover@digilentinc.com,
	netdev@vger.kernel.org, Avinash kumar <avi.kp.137@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:63540 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876Ab3I3EGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 00:06:54 -0400
Received: by mail-pb0-f41.google.com with SMTP id rp2so5046875pbb.0
        for <netdev@vger.kernel.org>; Sun, 29 Sep 2013 21:06:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

removes following warnings-
drivers/net/phy/marvell.c:37: WARNING: Use #include <linux/io.h> instead of <asm/io.h>
drivers/net/phy/marvell.c:39: WARNING: Use #include <linux/uaccess.h> instead of <asm/uaccess.h>

Signed-off-by: Avinash Kumar <avi.kp.137@gmail.com>
---
 drivers/net/phy/marvell.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 2e91477..2e3c778e 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -34,9 +34,9 @@
 #include <linux/marvell_phy.h>
 #include <linux/of.h>
 
-#include <asm/io.h>
+#include <linux/io.h>
 #include <asm/irq.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 
 #define MII_MARVELL_PHY_PAGE		22
 
-- 
1.7.9.5
