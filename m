From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH net 1/4] fsl/fman: fix 1G support for QSGMII interfaces
Date: Thu, 15 Dec 2016 15:11:34 +0200
Message-ID: <1481807497-4724-2-git-send-email-madalin.bucur@nxp.com>
References: <1481807497-4724-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: madalin.bucur@nxp.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
 davem@davemloft.net
To: <netdev@vger.kernel.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1481807497-4724-1-git-send-email-madalin.bucur@nxp.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

QSGMII ports were not advertising 1G speed.

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
Reviewed-by: Camelia Groza <camelia.groza@nxp.com>
---
 drivers/net/ethernet/freescale/fman/mac.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/freescale/fman/mac.c b/drivers/net/ethernet/freescale/fman/mac.c
index 69ca42c..0b31f85 100644
--- a/drivers/net/ethernet/freescale/fman/mac.c
+++ b/drivers/net/ethernet/freescale/fman/mac.c
@@ -594,6 +594,7 @@ static const u16 phy2speed[] = {
 	[PHY_INTERFACE_MODE_RGMII_RXID]	= SPEED_1000,
 	[PHY_INTERFACE_MODE_RGMII_TXID]	= SPEED_1000,
 	[PHY_INTERFACE_MODE_RTBI]		= SPEED_1000,
+	[PHY_INTERFACE_MODE_QSGMII]		= SPEED_1000,
 	[PHY_INTERFACE_MODE_XGMII]		= SPEED_10000
 };
 
-- 
2.1.0
