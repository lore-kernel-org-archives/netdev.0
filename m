From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 3/4] stmmac: fix driver's doc when run kernel-doc script
Date: Wed, 23 May 2012 07:40:18 +0200
Message-ID: <1337751619-21941-3-git-send-email-peppe.cavallaro@st.com>
References: <1337751619-21941-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:39966 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752742Ab2EWFke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 01:40:34 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 74BCEA3
	for <netdev@vger.kernel.org>; Wed, 23 May 2012 05:40:32 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id F00D31B51
	for <netdev@vger.kernel.org>; Wed, 23 May 2012 05:40:31 +0000 (GMT)
In-Reply-To: <1337751619-21941-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index b942ed4..fd8bafc 100644
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
@@ -1856,6 +1857,8 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
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
