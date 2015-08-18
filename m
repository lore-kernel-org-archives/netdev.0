From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH net-next] r8169:Set RxConfig on same func. with TxConfig
Date: Tue, 18 Aug 2015 22:10:21 +0300
Message-ID: <1439925021-5772-1-git-send-email-corcodel.marian@gmail.com>
Cc: Corcodel Marian <corcodel.marian@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:35234 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753886AbbHRTKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 15:10:35 -0400
Received: by wicne3 with SMTP id ne3so102953496wic.0
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 12:10:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Add set DMA burst size and  Rx FIFO threshold on RxConfig  
  register to function rtl_set_rx_tx_config_register.


Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 6d16de3..c3c908c 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5183,6 +5183,7 @@ static void rtl_set_rx_tx_config_registers(struct rtl8169_private *tp)
 	/* Set DMA burst size and Interframe Gap Time */
 	RTL_W32(TxConfig, (TX_DMA_BURST << TxDMAShift) |
                 (InterFrameGap << TxInterFrameGapShift) | InterFrameGap2);
+	RTL_W32(RxConfig, RX_FIFO_THRESHOLD | RX_DMA_BURST);
 }
 
 static void rtl_hw_start(struct net_device *dev)
-- 
2.1.4
