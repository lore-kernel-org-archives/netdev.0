From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: [PATCH net] ravb: Remove clear unhandled interrupt
Date: Sun,  6 Dec 2015 20:42:20 +0900
Message-ID: <1449402140-24272-1-git-send-email-ykaneko0929@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36130 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751540AbbLFLn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2015 06:43:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>

AVB-DMAC Reception Warning interrupt is not enabled, so it is not
necessary to clear the interrupt.

Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
---

This patch is based on the master branch of David Miller's networking
tree.

 drivers/net/ethernet/renesas/ravb_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index ed5da4d..b8fd5a5 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -1471,7 +1471,6 @@ static int ravb_close(struct net_device *ndev)
 
 	/* Disable interrupts by clearing the interrupt masks. */
 	ravb_write(ndev, 0, RIC0);
-	ravb_write(ndev, 0, RIC1);
 	ravb_write(ndev, 0, RIC2);
 	ravb_write(ndev, 0, TIC);
 
-- 
1.9.1
