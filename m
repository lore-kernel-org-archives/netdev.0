From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH] fec: Fix KS8721BL_ICSR phy register offset
Date: Tue, 27 Jan 2009 11:40:01 +0100
Message-ID: <1233052804-31228-7-git-send-email-s.hauer@pengutronix.de>
References: <1233052804-31228-1-git-send-email-s.hauer@pengutronix.de>
 <1233052804-31228-2-git-send-email-s.hauer@pengutronix.de>
 <1233052804-31228-3-git-send-email-s.hauer@pengutronix.de>
 <1233052804-31228-4-git-send-email-s.hauer@pengutronix.de>
 <1233052804-31228-5-git-send-email-s.hauer@pengutronix.de>
 <1233052804-31228-6-git-send-email-s.hauer@pengutronix.de>
Cc: Greg Ungerer <gerg@snapgear.com>,
	frederic rodo <fred.rodo@gmail.com>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:47061 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930AbZA0Kkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 05:40:42 -0500
In-Reply-To: <1233052804-31228-6-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to the datasheet the ICSR register is at offset 27, not 22.

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/fec.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index d7ba07c..f36ee43 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1111,7 +1111,7 @@ static phy_info_t const phy_info_am79c874 = {
 /* register definitions for the 8721 */
 
 #define MII_KS8721BL_RXERCR	21
-#define MII_KS8721BL_ICSR	22
+#define MII_KS8721BL_ICSR	27
 #define	MII_KS8721BL_PHYCR	31
 
 static phy_cmd_t const phy_cmd_ks8721bl_config[] = {
-- 
1.5.6.5

