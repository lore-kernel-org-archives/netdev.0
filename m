From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] brcm80211: simplify assignment
Date: Wed, 18 May 2016 02:57:13 +0200
Message-ID: <1463533033-13336-1-git-send-email-xypron.glpk@gmx.de>
Cc: linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:50809 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751513AbcERA51 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2016 20:57:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplify assignment in wlc_phy_rxcal_gainctrl_nphy_rev5.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c
index 99dac9b..b3aab2f 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c
@@ -27017,7 +27017,7 @@ wlc_phy_rxcal_gainctrl_nphy_rev5(struct brcms_phy *pi, u8 rx_core,
 		tx_core = 1 - rx_core;
 
 	num_samps = 1024;
-	desired_log2_pwr = (cal_type == 0) ? 13 : 13;
+	desired_log2_pwr = 13;
 
 	wlc_phy_rx_iq_coeffs_nphy(pi, 0, &save_comp);
 	zero_comp.a0 = zero_comp.b0 = zero_comp.a1 = zero_comp.b1 = 0x0;
-- 
2.1.4
