From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [PATCH net-next v3.16]r8169: Add delay on set_rx_mode
Date: Sat, 26 Mar 2016 13:21:31 +0200
Message-ID: <1458991291-1600-1-git-send-email-asd@marian1000.go.ro>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-230-247.residential.rdsnet.ro ([5.14.230.247]:45261 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751135AbcCZLV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Mar 2016 07:21:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Set one line  space extra delay on set_rx_mode for starting
   on full duplex and full speed.

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 0ae8969..457b12a 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4646,6 +4646,7 @@ static void rtl_set_rx_mode(struct net_device *dev)
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
 
 	RTL_W32(MAR0 + 4, mc_filter[1]);
+
 	RTL_W32(MAR0 + 0, mc_filter[0]);
 
 	RTL_W32(RxConfig, tmp);
-- 
2.1.4
