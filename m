From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH net-next] r8169: Replace TX_DMA_BURST
Date: Mon, 17 Aug 2015 20:42:22 +0300
Message-ID: <1439833342-2948-1-git-send-email-corcodel.marian@gmail.com>
Cc: Corcodel Marian <corcodel.marian@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:36328 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867AbbHQRmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 13:42:36 -0400
Received: by wicja10 with SMTP id ja10so76034577wic.1
        for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 10:42:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace TX_DMA_BURST with 3 wich corespond on 128
 descriptors  send on Tx burst DMA .Packet size consist in unit of 128
 descriptors.  Ensure to  keep this units grouped


Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index fecb7c9..1994ccb 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -85,7 +85,7 @@
 static const int multicast_filter_limit = 32;
 
 #define MAX_READ_REQUEST_SHIFT	12
-#define TX_DMA_BURST	7	/* Maximum PCI burst, '7' is unlimited */
+#define TX_DMA_BURST	3	/* Maximum PCI burst, '7' is unlimited */
 #define InterFrameGap	0x03	/* 3 means InterFrameGap = the shortest one */
 
 #define R8169_REGS_SIZE		256
-- 
2.1.4
