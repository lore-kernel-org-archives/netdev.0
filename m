From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 2/3] stmmac: fix NULL pointer dereference in capabilities fixup (v2)
Date: Thu, 27 Oct 2011 07:43:08 +0200
Message-ID: <1319694189-25223-2-git-send-email-peppe.cavallaro@st.com>
References: <1319637339-14866-1-git-send-email-peppe.cavallaro@st.com>
 <1319694189-25223-1-git-send-email-peppe.cavallaro@st.com>
Cc: Angus Clark <angus.clark@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:41695 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751118Ab1J0Fn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 01:43:27 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 523E1BE
	for <netdev@vger.kernel.org>; Thu, 27 Oct 2011 05:43:25 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 185481328
	for <netdev@vger.kernel.org>; Thu, 27 Oct 2011 05:43:25 +0000 (GMT)
In-Reply-To: <1319694189-25223-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Angus Clark <angus.clark@st.com>

Signed-off-by: Angus Clark <angus.clark@st.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index fcdd5a2..f77eaa6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -325,7 +325,7 @@ static int stmmac_init_phy(struct net_device *dev)
 	    (interface == PHY_INTERFACE_MODE_RMII))) {
 		phydev->supported &= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
 				      SUPPORTED_Asym_Pause);
-		priv->phydev->advertising = priv->phydev->supported;
+		phydev->advertising = phydev->supported;
 	}
 
 	/*
-- 
1.7.4.4
