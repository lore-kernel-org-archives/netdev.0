From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [PATCH net v4] r8169:  Add 2 new interrupts tested on my hardware.
Date: Tue,  2 Feb 2016 20:10:35 +0200
Message-ID: <1454436635-3325-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-225-121.residential.rdsnet.ro ([5.14.225.121]:44556 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757144AbcBBSw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 13:52:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With SWInt and TxDescUnavail interrupts now have full support interrupts (maybe).
This new interrupts is tested on my hardware RTL 8102.For another hardware need to 
 be tested.

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 5186ef9..7588ba7 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -8037,7 +8037,7 @@ static const struct rtl_cfg_info {
 		.region		= 2,
 		.align		= 8,
 		.event_slow	= SYSErr | LinkChg | RxOverflow | RxFIFOOver |
-				  PCSTimeout,
+				  PCSTimeout | SWInt | TxDescUnavail,
 		.features	= RTL_FEATURE_MSI,
 		.default_ver	= RTL_GIGA_MAC_VER_13,
 	}
-- 
2.5.0
