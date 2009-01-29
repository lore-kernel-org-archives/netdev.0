From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH] fec: Fix KS8721BL_ICSR phy register offset
Date: Thu, 29 Jan 2009 10:03:08 +0100
Message-ID: <1233219791-18691-7-git-send-email-s.hauer@pengutronix.de>
References: <1233219791-18691-1-git-send-email-s.hauer@pengutronix.de>
 <1233219791-18691-2-git-send-email-s.hauer@pengutronix.de>
 <1233219791-18691-3-git-send-email-s.hauer@pengutronix.de>
 <1233219791-18691-4-git-send-email-s.hauer@pengutronix.de>
 <1233219791-18691-5-git-send-email-s.hauer@pengutronix.de>
 <1233219791-18691-6-git-send-email-s.hauer@pengutronix.de>
Cc: David Miller <davem@davemloft.net>,
	Greg Ungerer <gerg@snapgear.com>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48107 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751283AbZA2JFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 04:05:10 -0500
In-Reply-To: <1233219791-18691-6-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to the datasheet the ICSR register is at offset 27, not 22.

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
Acked-by: Greg Ungerer <gerg@uclinux.org>
---
 drivers/net/fec.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 46a441a..cab07ec 100644
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

