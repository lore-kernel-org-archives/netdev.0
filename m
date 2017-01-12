From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch net-next] stmmac: indent an if statement
Date: Thu, 12 Jan 2017 21:46:32 +0300
Message-ID: <20170112184631.GA12157@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexandre Torgue <alexandre.torgue@st.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        jpinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:24849 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750916AbdALSqr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 13:46:47 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The break statement should be indented one more tab.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index ac32f9e..4daa8a3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -191,7 +191,7 @@ static int stmmac_dt_phy(struct plat_stmmacenet_data *plat,
 		for_each_child_of_node(np, plat->mdio_node) {
 			if (of_device_is_compatible(plat->mdio_node,
 						    "snps,dwmac-mdio"))
-			break;
+				break;
 		}
 	}
 
