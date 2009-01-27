From: y@pengutronix.de
Subject: [PATCH] fec: Fix KS8721BL_ICSR phy register offset
Date: Tue, 27 Jan 2009 11:24:05 +0100
Message-ID: <30482.8618689955$1233051979@news.gmane.org>
References: <1233051848-5994-1-git-send-email-y>
 <1233051848-5994-2-git-send-email-y>
 <1233051848-5994-3-git-send-email-y>
 <1233051848-5994-4-git-send-email-y>
 <1233051848-5994-5-git-send-email-y>
 <1233051848-5994-6-git-send-email-y>
Cc: Greg Ungerer <gerg@snapgear.com>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42882 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777AbZA0KYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 05:24:47 -0500
In-Reply-To: <1233051848-5994-6-git-send-email-y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sascha Hauer <s.hauer@pengutronix.de>

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

