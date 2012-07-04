From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] bcm87xx: fix reg-init comment typo
Date: Wed,  4 Jul 2012 17:05:45 +0200
Message-ID: <1341414345-16626-1-git-send-email-jacmet@sunsite.dk>
Cc: Peter Korsgaard <jacmet@sunsite.dk>
To: netdev@vger.kernel.org, david.daney@cavium.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:59528 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752576Ab2GDPFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 11:05:54 -0400
Received: by werb14 with SMTP id b14so4475122wer.19
        for <netdev@vger.kernel.org>; Wed, 04 Jul 2012 08:05:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

broadcom, not marvell.

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
 drivers/net/phy/bcm87xx.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/bcm87xx.c b/drivers/net/phy/bcm87xx.c
index 9a90dcf..a6df68c 100644
--- a/drivers/net/phy/bcm87xx.c
+++ b/drivers/net/phy/bcm87xx.c
@@ -22,7 +22,7 @@
 
 #if IS_ENABLED(CONFIG_OF_MDIO)
 /* Set and/or override some configuration registers based on the
- * marvell,reg-init property stored in the of_node for the phydev.
+ * broadcom,c45-reg-init property stored in the of_node for the phydev.
  *
  * broadcom,c45-reg-init = <devid reg mask value>,...;
  *
-- 
1.7.10
