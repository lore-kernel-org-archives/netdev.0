From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] stmmac: remove ifdef NETIF_F_TSO from stmmac_ethtool.c
Date: Thu, 14 Oct 2010 07:54:19 +0200
Message-ID: <1287035659-17988-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:35651 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754647Ab0JNFyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 01:54:31 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 8AF4E9F
	for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 05:54:28 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 269B11622
	for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 05:54:28 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Reported-by: Armando Visconti <armando.visconti@st.com>
---
 drivers/net/stmmac/stmmac_ethtool.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac/stmmac_ethtool.c
index f080509..9262f4a 100644
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -377,10 +377,8 @@ static struct ethtool_ops stmmac_ethtool_ops = {
 	.get_wol = stmmac_get_wol,
 	.set_wol = stmmac_set_wol,
 	.get_sset_count	= stmmac_get_sset_count,
-#ifdef NETIF_F_TSO
 	.get_tso = ethtool_op_get_tso,
 	.set_tso = ethtool_op_set_tso,
-#endif
 };
 
 void stmmac_set_ethtool_ops(struct net_device *netdev)
-- 
1.5.5.6

