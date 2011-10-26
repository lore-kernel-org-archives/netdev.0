From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 2/3] stmmac: fix NULL pointer dereference in capabilities fixup
Date: Wed, 26 Oct 2011 15:55:38 +0200
Message-ID: <1319637339-14866-2-git-send-email-peppe.cavallaro@st.com>
References: <1319637339-14866-1-git-send-email-peppe.cavallaro@st.com>
Cc: keguang.zhang@gmail.com, Angus Clark <angus.clark@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:38467 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932247Ab1JZNzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 09:55:55 -0400
In-Reply-To: <1319637339-14866-1-git-send-email-peppe.cavallaro@st.com>
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
+		priv->phydev->advertising = phydev->supported;
 	}
 
 	/*
-- 
1.7.4.4
