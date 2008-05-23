From: Li Yang <leoli@freescale.com>
Subject: [PATCH 1/2] ucc_geth_ethtool: Fix typo
Date: Fri, 23 May 2008 18:11:26 +0800
Message-ID: <1211537487-24953-2-git-send-email-leoli@freescale.com>
References: <1211537487-24953-1-git-send-email-leoli@freescale.com>
Cc: netdev@vger.kernel.org,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>,
	Li Yang <leoli@freescale.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:54260 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753806AbYEWJ7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2008 05:59:40 -0400
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw02.freescale.net (8.12.11/de01egw02) with ESMTP id m4N9xbJQ004359
	for <netdev@vger.kernel.org>; Fri, 23 May 2008 02:59:38 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id m4N9xXcd027564
	for <netdev@vger.kernel.org>; Fri, 23 May 2008 04:59:36 -0500 (CDT)
In-Reply-To: <1211537487-24953-1-git-send-email-leoli@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Signed-off-by: Li Yang <leoli@freescale.com>
---
 drivers/net/ucc_geth_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ucc_geth_ethtool.c
index 299b7f1..b84ffd8 100644
--- a/drivers/net/ucc_geth_ethtool.c
+++ b/drivers/net/ucc_geth_ethtool.c
@@ -308,7 +308,7 @@ static void uec_get_strings(struct net_device *netdev, u32 stringset, u8 *buf)
 		buf += UEC_TX_FW_STATS_LEN * ETH_GSTRING_LEN;
 	}
 	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_RX)
-		memcpy(buf, tx_fw_stat_gstrings, UEC_RX_FW_STATS_LEN *
+		memcpy(buf, rx_fw_stat_gstrings, UEC_RX_FW_STATS_LEN *
 			       	ETH_GSTRING_LEN);
 }
 
-- 
1.5.5.1.248.g4b17

