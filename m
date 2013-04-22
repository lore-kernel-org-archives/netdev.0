From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH v3 net-next 3/6] bnx2x: remove non-necessary assignment
Date: Mon, 22 Apr 2013 13:15:05 +0300
Message-ID: <1366625708-5678-4-git-send-email-dmitry@broadcom.com>
References: <1366625708-5678-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: romueu@fz.zoreil.com, "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Francious Romieu" <romieu@fz.zoreil.com>
To: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4547 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752812Ab3DVKP0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Apr 2013 06:15:26 -0400
In-Reply-To: <1366625708-5678-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC: Francious Romieu <romieu@fz.zoreil.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index ec07b2b..f4ed10a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1385,7 +1385,6 @@ static int bnx2x_get_eeprom(struct net_device *dev,
 			    struct ethtool_eeprom *eeprom, u8 *eebuf)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-	int rc;
 
 	if (!netif_running(dev)) {
 		DP(BNX2X_MSG_ETHTOOL  | BNX2X_MSG_NVM,
@@ -1400,9 +1399,7 @@ static int bnx2x_get_eeprom(struct net_device *dev,
 
 	/* parameters already validated in ethtool_get_eeprom */
 
-	rc = bnx2x_nvram_read(bp, eeprom->offset, eebuf, eeprom->len);
-
-	return rc;
+	return bnx2x_nvram_read(bp, eeprom->offset, eebuf, eeprom->len);
 }
 
 static int bnx2x_get_module_eeprom(struct net_device *dev,
-- 
1.8.1.4
