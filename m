From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH] pch_gbe: remove unused variable
Date: Mon, 26 Sep 2011 14:37:38 -0500
Message-ID: <1317065858-3201-1-git-send-email-jdmason@kudzu.us>
Cc: toshiharu-linux@dsn.okisemi.com, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:61405 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752994Ab1IZTho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 15:37:44 -0400
Received: by pzk1 with SMTP id 1so15517293pzk.1
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 12:37:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev is unused in pch_gbe_setup_rctl.  Remove this declaration to
avoid a compiler warning.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 35a7c21..5dc61b4 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -698,7 +698,6 @@ static void pch_gbe_configure_tx(struct pch_gbe_adapter *adapter)
  */
 static void pch_gbe_setup_rctl(struct pch_gbe_adapter *adapter)
 {
-	struct net_device *netdev = adapter->netdev;
 	struct pch_gbe_hw *hw = &adapter->hw;
 	u32 rx_mode, tcpip;
 
-- 
1.7.6.2
