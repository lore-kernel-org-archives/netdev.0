From: Phil Reid <preid@electromag.com.au>
Subject: [PATCH 0/1] net: stmmac: Don't search for phys if mdio node is defined.
Date: Tue, 15 Mar 2016 15:34:32 +0800
Message-ID: <1458027273-127737-1-git-send-email-preid@electromag.com.au>
Cc: Phil Reid <preid@electromag.com.au>
To: peppe.cavallaro@st.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.59.230.133] ([203.59.230.133]:40280 "EHLO
	preid-centos7.electromag.com.au" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S934112AbcCOHoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 03:44:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a dt mdio entry has been added least assume that we wont
search for phys attached. The DT and of_mdiobus_register already do
this. This stops DSA phys being found and phys created for them, as
this is handled by the DSA driver.

Note: I'm not 100% sure that priv->plat->phy_node should be included
in the conditional here. But it looks like if a phy-handle is used
then we don't want to search for phys.

Phil Reid (1):
  net: stmmac: Don't search for phys if mdio node is defined.

 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 4 ++++
 1 file changed, 4 insertions(+)

-- 
1.8.3.1
