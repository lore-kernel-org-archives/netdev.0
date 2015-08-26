From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH, net-next] r8169:Correct value on r810x_phy_power_up function
Date: Wed, 26 Aug 2015 15:16:10 +0300
Message-ID: <1440591370-24649-1-git-send-email-corcodel.marian@gmail.com>
Cc: Corcodel Marian <corcodel.marian@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:33307 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751816AbbHZMQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 08:16:23 -0400
Received: by wijn1 with SMTP id n1so22390391wij.0
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 05:16:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct value on r810x_phy_power_up function normal clean 
 bit BMCR_PDOWN

Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index d6d39df..91cf3a6 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4669,7 +4669,7 @@ static void r810x_phy_power_down(struct rtl8169_private *tp)
 static void r810x_phy_power_up(struct rtl8169_private *tp)
 {
 	rtl_writephy(tp, 0x1f, 0x0000);
-	rtl_writephy(tp, MII_BMCR, BMCR_ANENABLE);
+	rtl_writephy(tp, MII_BMCR, ~BMCR_PDOWN);
 }
 
 static void r810x_pll_power_down(struct rtl8169_private *tp)
-- 
2.1.4
