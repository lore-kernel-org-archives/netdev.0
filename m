From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: [PATCH net-next 1/8] bnx2x: Fix potential link issue of
 BCM8073/BCM8727
Date: Wed, 1 Sep 2010 22:51:17 +0300
Message-ID: <1283370677.4403.132.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1286 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755034Ab0IAQdH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 12:33:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix potential link issue caused by insufficient delay time during SPIROM
load of BCM8073/BCM8727 

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com> 
---
 drivers/net/bnx2x/bnx2x_link.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 0fa0991..9b4e7b3 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -2549,8 +2549,8 @@ static void bnx2x_bcm8073_bcm8727_external_rom_boot(struct bnx2x *bp, u8 port,
 		       MDIO_PMA_REG_GEN_CTRL,
 		       MDIO_PMA_REG_GEN_CTRL_ROM_RESET_INTERNAL_MP);
 
-	/* wait for 100ms for code download via SPI port */
-	msleep(100);
+	/* wait for 120ms for code download via SPI port */
+	msleep(120);
 
 	/* Clear ser_boot_ctl bit */
 	bnx2x_cl45_write(bp, port,
-- 
1.7.1




