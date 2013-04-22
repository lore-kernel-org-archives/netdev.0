From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH v4 net-next 3/6] bnx2x: remove non-necessary assignment
Date: Mon, 22 Apr 2013 16:48:08 +0300
Message-ID: <1366638491-27184-4-git-send-email-dmitry@broadcom.com>
References: <1366638491-27184-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: romieu@fz.zoreil.com, "Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4004 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753944Ab3DVNs1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Apr 2013 09:48:27 -0400
In-Reply-To: <1366638491-27184-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC: Francious Romieu <romieu@fz.zoreil.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 8ae51f9..8d5c21e 100644
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
