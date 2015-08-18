From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH, net-next] r8169:Correct value on RxMaxSize register
Date: Tue, 18 Aug 2015 20:10:30 +0300
Message-ID: <1439917830-1952-1-git-send-email-corcodel.marian@gmail.com>
Cc: Corcodel Marian <corcodel.marian@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:38830 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751801AbbHRRKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 13:10:43 -0400
Received: by wicja10 with SMTP id ja10so114313246wic.1
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 10:10:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On here want to be original value, period.


Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index aff5437..6d16de3 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5219,8 +5219,8 @@ static u16 rtl_rw_cpluscmd(void __iomem *ioaddr)
 
 static void rtl_set_rx_max_size(void __iomem *ioaddr, unsigned int rx_buf_sz)
 {
-	/* Low hurts. Let's disable the filtering. */
-	RTL_W16(RxMaxSize, rx_buf_sz + 1);
+	
+	RTL_W16(RxMaxSize, rx_buf_sz);
 }
 
 static void rtl8169_set_magic_reg(void __iomem *ioaddr, unsigned mac_version)
-- 
2.1.4
