From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH] ucc_geth_ethtool: Fix typo
Date: Tue, 29 Apr 2008 14:02:49 +0200
Message-ID: <1209470569-31270-1-git-send-email-Joakim.Tjernlund@transmode.se>
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: Li Yang <LeoLi@freescale.com>, Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:20066 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754010AbYD2MCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 08:02:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---
 drivers/net/ucc_geth_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ucc_geth_ethtool.c
index 9a9622c..a995a3a 100644
--- a/drivers/net/ucc_geth_ethtool.c
+++ b/drivers/net/ucc_geth_ethtool.c
@@ -314,7 +314,7 @@ static void uec_get_strings(struct net_device *netdev, u32 stringset, u8 *buf)
 		buf += UEC_TX_FW_STATS_LEN * ETH_GSTRING_LEN;
 	}
 	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_RX)
-		memcpy(buf, tx_fw_stat_gstrings, UEC_RX_FW_STATS_LEN *
+		memcpy(buf, rx_fw_stat_gstrings, UEC_RX_FW_STATS_LEN *
 			       	ETH_GSTRING_LEN);
 }
 
-- 
1.5.5.1

