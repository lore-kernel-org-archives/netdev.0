From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH, net-next] r8169: Remove unfounded interrupts
Date: Sun, 23 Aug 2015 19:18:30 +0300
Message-ID: <1440346710-2028-1-git-send-email-corcodel.marian@gmail.com>
Cc: Corcodel Marian <corcodel.marian@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:34056 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051AbbHWQSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 12:18:42 -0400
Received: by widdq5 with SMTP id dq5so29582815wid.1
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2015 09:18:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unfounded interrupts which is not on RTL 8101 series.

Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 5fb79b1..5693e65 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6614,15 +6614,15 @@ static void rtl_hw_start_8101(struct net_device *dev)
 
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
-	RTL_W16(IntrMitigate, 0x0000);
+	//RTL_W16(IntrMitigate, 0x0000);
 
 	//RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 
 	rtl_set_rx_mode(dev);
 
-	RTL_R8(IntrMask);
+	//RTL_R8(IntrMask);
 
-	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xf000);
+	//RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xf000);
 }
 
 static int rtl8169_change_mtu(struct net_device *dev, int new_mtu)
-- 
2.1.4
