From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: [PATCH] remove unbalanced opening brace from drivers/atm/iphase.c
Date: Sun, 12 Apr 2009 21:49:24 +0200
Message-ID: <1239565764-8203-1-git-send-email-m.kozlowski@tuxland.pl>
Cc: netdev@vger.kernel.org, Mariusz Kozlowski <m.kozlowski@tuxland.pl>
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from orion.ambsoft.pl ([212.109.144.130]:37411 "EHLO
	orion.ambsoft.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901AbZDLTt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2009 15:49:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's under #ifdef 0 but I think it's worth fixing anyway.

Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
---
 drivers/atm/iphase.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index 78c9736..dd8c3ec 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -795,7 +795,7 @@ static void ia_hw_type(IADEV *iadev) {
          iadev->rx_buf_sz, iadev->rx_pkt_ram);)
 
 #if 0
-   if ((memType & FE_MASK) == FE_SINGLE_MODE) {
+   if ((memType & FE_MASK) == FE_SINGLE_MODE)
       iadev->phy_type = PHY_OC3C_S;
    else if ((memType & FE_MASK) == FE_UTP_OPTION)
       iadev->phy_type = PHY_UTP155;
-- 
1.5.6.3

