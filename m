From: Kirill Smelkov <kirr@mns.spb.ru>
Subject: [PATCH, RESEND] r8169: Kill SafeMtu macro
Date: Mon, 29 Oct 2012 21:55:12 +0400
Message-ID: <20121029175512.GA13577@tugrik.mns.mnsspb.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Kirill Smelkov <kirr@mns.spb.ru>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mnsspb.ru ([84.204.75.2]:54122 "EHLO mail.mnsspb.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932119Ab2J2RyP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 13:54:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After d58d46b5 (r8169: jumbo fixes.) max frame len is stored in
rtl_chip_infos[].jumbo_max for each chip and SafeMtu should be gone.

Signed-off-by: Kirill Smelkov <kirr@mns.spb.ru>
---
 drivers/net/ethernet/realtek/r8169.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index e7ff886..7ca6618 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -78,7 +78,6 @@ static const int multicast_filter_limit = 32;
 
 #define MAX_READ_REQUEST_SHIFT	12
 #define TX_DMA_BURST	7	/* Maximum PCI burst, '7' is unlimited */
-#define SafeMtu		0x1c20	/* ... actually life sucks beyond ~7k */
 #define InterFrameGap	0x03	/* 3 means InterFrameGap = the shortest one */
 
 #define R8169_REGS_SIZE		256
-- 
1.8.0.rc1.231.g17358b9
