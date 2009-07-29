From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 2/4] bnx2x: Self-test kills management traffic
Date: Wed, 29 Jul 2009 13:20:08 +0300
Message-ID: <1248862808.27379.16.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3608 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750795AbZG2KUd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2009 06:20:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Self test used to play with the management FIFO possibly while management was
running...

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 5273988..b47b531 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -9415,10 +9415,9 @@ static int bnx2x_test_registers(struct bnx2x *bp)
 		{ XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD00, 4, 0x00000001 },
 		{ XCM_REG_WU_DA_CNT_CMD00,             4, 0x00000003 },
 		{ XCM_REG_GLB_DEL_ACK_MAX_CNT_0,       4, 0x000000ff },
-		{ NIG_REG_EGRESS_MNG0_FIFO,           20, 0xffffffff },
 		{ NIG_REG_LLH0_T_BIT,                  4, 0x00000001 },
-/* 20 */	{ NIG_REG_EMAC0_IN_EN,                 4, 0x00000001 },
-		{ NIG_REG_BMAC0_IN_EN,                 4, 0x00000001 },
+		{ NIG_REG_EMAC0_IN_EN,                 4, 0x00000001 },
+/* 20 */	{ NIG_REG_BMAC0_IN_EN,                 4, 0x00000001 },
 		{ NIG_REG_XCM0_OUT_EN,                 4, 0x00000001 },
 		{ NIG_REG_BRB0_OUT_EN,                 4, 0x00000001 },
 		{ NIG_REG_LLH0_XCM_MASK,               4, 0x00000007 },
@@ -9427,8 +9426,8 @@ static int bnx2x_test_registers(struct bnx2x *bp)
 		{ NIG_REG_LLH0_DEST_MAC_0_0,         160, 0xffffffff },
 		{ NIG_REG_LLH0_DEST_IP_0_1,          160, 0xffffffff },
 		{ NIG_REG_LLH0_IPV4_IPV6_0,          160, 0x00000001 },
-/* 30 */	{ NIG_REG_LLH0_DEST_UDP_0,           160, 0x0000ffff },
-		{ NIG_REG_LLH0_DEST_TCP_0,           160, 0x0000ffff },
+		{ NIG_REG_LLH0_DEST_UDP_0,           160, 0x0000ffff },
+/* 30 */	{ NIG_REG_LLH0_DEST_TCP_0,           160, 0x0000ffff },
 		{ NIG_REG_LLH0_VLAN_ID_0,            160, 0x00000fff },
 		{ NIG_REG_XGXS_SERDES0_MODE_SEL,       4, 0x00000001 },
 		{ NIG_REG_LED_CONTROL_OVERRIDE_TRAFFIC_P0, 4, 0x00000001 },
-- 
1.5.4.3




