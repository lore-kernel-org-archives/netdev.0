From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH v3 6/6] dpaa_eth: remove obsolete comment
Date: Mon, 16 Oct 2017 21:36:10 +0300
Message-ID: <1508178970-28945-7-git-send-email-madalin.bucur@nxp.com>
References: <1508178970-28945-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <andrew@lunn.ch>,
        <vivien.didelot@savoirfairelinux.com>, <junote@outlook.com>,
        <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508178970-28945-1-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Comment is no longer valid for a long time now.

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index c6b97a1..a8d0be8 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -2449,10 +2449,6 @@ static int dpaa_phy_init(struct net_device *net_dev)
 
 	/* Remove any features not supported by the controller */
 	phy_dev->supported &= mac_dev->if_support;
-
-	/* Enable the symmetric and asymmetric PAUSE frame advertisements,
-	 * as most of the PHY drivers do not enable them by default.
-	 */
 	phy_dev->supported |= (SUPPORTED_Pause | SUPPORTED_Asym_Pause);
 	phy_dev->advertising = phy_dev->supported;
 
-- 
2.1.0
