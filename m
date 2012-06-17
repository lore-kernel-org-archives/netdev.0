From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net PATCH 2/2] bnx2x: fix link for BCM57711 with 84823 phy
Date: Sun, 17 Jun 2012 09:27:15 +0300
Message-ID: <1339914435-12912-3-git-send-email-yuvalmin@broadcom.com>
References: <1339914435-12912-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, yaniv.rosner@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3310 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752545Ab2FQGgP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jun 2012 02:36:15 -0400
In-Reply-To: <1339914435-12912-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yaniv Rosner <yaniv.rosner@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 65f673f..e0b1fbc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -9754,7 +9754,7 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 
 	msleep(1);
 
-	if (!(CHIP_IS_E1(bp)))
+	if (!(CHIP_IS_E1x(bp)))
 		port = BP_PATH(bp);
 	else
 		port = params->port;
-- 
1.7.9.rc2
