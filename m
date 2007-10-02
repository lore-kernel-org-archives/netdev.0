From: akpm@linux-foundation.org
Subject: [patch 05/13] skge: remove broken and unused PHY_M_PC_MDI_XMODE macro
Date: Tue, 02 Oct 2007 14:11:38 -0700
Message-ID: <200710022111.l92LBcbo022488@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	m.kozlowski@tuxland.pl, shemminger@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55217 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754837AbXJBVMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 17:12:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/skge.h |    2 --
 1 file changed, 2 deletions(-)

diff -puN drivers/net/skge.h~skge-remove-broken-and-unused-phy_m_pc_mdi_xmode-macro drivers/net/skge.h
--- a/drivers/net/skge.h~skge-remove-broken-and-unused-phy_m_pc_mdi_xmode-macro
+++ a/drivers/net/skge.h
@@ -1351,8 +1351,6 @@ enum {
 	PHY_M_PC_EN_DET_PLUS	= 3<<8, /* Energy Detect Plus (Mode 2) */
 };
 
-#define PHY_M_PC_MDI_XMODE(x)	((((u16)(x)<<5) & PHY_M_PC_MDIX_MSK)
-
 enum {
 	PHY_M_PC_MAN_MDI	= 0, /* 00 = Manual MDI configuration */
 	PHY_M_PC_MAN_MDIX	= 1, /* 01 = Manual MDIX configuration */
_
