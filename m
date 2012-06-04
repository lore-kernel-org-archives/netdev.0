From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 2/4] stmmac: fix driver's doc when run kernel-doc script
Date: Mon,  4 Jun 2012 17:37:48 +0200
Message-ID: <1338824270-9222-3-git-send-email-peppe.cavallaro@st.com>
References: <1338824270-9222-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:59793 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760818Ab2FDPiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 11:38:18 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 66D04121
	for <netdev@vger.kernel.org>; Mon,  4 Jun 2012 15:38:09 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 1C526463E
	for <netdev@vger.kernel.org>; Mon,  4 Jun 2012 15:38:09 +0000 (GMT)
In-Reply-To: <1338824270-9222-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 0caae72..18ed878 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -833,8 +833,9 @@ static u32 stmmac_get_synopsys_id(struct stmmac_priv *priv)
 
 /**
  * stmmac_selec_desc_mode
- * @dev : device pointer
- * Description: select the Enhanced/Alternate or Normal descriptors */
+ * @priv : private structure
+ * Description: select the Enhanced/Alternate or Normal descriptors
+ */
 static void stmmac_selec_desc_mode(struct stmmac_priv *priv)
 {
 	if (priv->plat->enh_desc) {
@@ -1860,6 +1861,8 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 /**
  * stmmac_dvr_probe
  * @device: device pointer
+ * @plat_dat: platform data pointer
+ * @addr: iobase memory address
  * Description: this is the main probe function used to
  * call the alloc_etherdev, allocate the priv structure.
  */
-- 
1.7.4.4
