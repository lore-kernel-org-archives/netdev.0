From: Roland Stigge <stigge@antcom.de>
Subject: [PATCH] net: lpc_eth: Fix rename of dev_hw_addr_random
Date: Thu, 29 Mar 2012 00:36:26 +0200
Message-ID: <1332974186-12962-1-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Roland Stigge <stigge@antcom.de>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kevin.wells@nxp.com,
 linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

In parallel to the integration of lpc_eth.c, dev_hw_addr_random() has been
renamed to eth_hw_addr_random(). This patch fixes it also in the new driver
lpc_eth.c.

Signed-off-by: Roland Stigge <stigge@antcom.de>

---
 drivers/net/ethernet/nxp/lpc_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.orig/drivers/net/ethernet/nxp/lpc_eth.c
+++ linux-2.6/drivers/net/ethernet/nxp/lpc_eth.c
@@ -1441,7 +1441,7 @@ static int lpc_eth_drv_probe(struct plat
 	}
 #endif
 	if (!is_valid_ether_addr(ndev->dev_addr))
-		dev_hw_addr_random(ndev, ndev->dev_addr);
+		eth_hw_addr_random(ndev);
 
 	/* Reset the ethernet controller */
 	__lpc_eth_reset(pldat);
