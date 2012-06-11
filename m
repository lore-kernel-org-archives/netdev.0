From: Roland Stigge <stigge@antcom.de>
Subject: [PATCH 2/3] net: lpc_eth: Increase number of TX descriptors
Date: Mon, 11 Jun 2012 10:03:12 +0200
Message-ID: <1339401793-12258-2-git-send-email-stigge@antcom.de>
References: <1339401793-12258-1-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Roland Stigge <stigge@antcom.de>
To: davem@davemloft.net, eric.dumazet@gmail.com, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, kevin.wells@nxp.com,
 srinivas.bakki@nxp.com, aletes.xgr@gmail.com,
 linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1339401793-12258-1-git-send-email-stigge@antcom.de>
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

Since we have enough SRAM, we can increase the number of TX descriptors, so the
"BUSY" warning about occupied TX descriptors doesn't need to show up as often.

Signed-off-by: Roland Stigge <stigge@antcom.de>
Tested-by: Alexandre Pereira da Silva <aletes.xgr@gmail.com>

---
 drivers/net/ethernet/nxp/lpc_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.orig/drivers/net/ethernet/nxp/lpc_eth.c
+++ linux-2.6/drivers/net/ethernet/nxp/lpc_eth.c
@@ -56,7 +56,7 @@
 
 #define ENET_MAXF_SIZE 1536
 #define ENET_RX_DESC 48
-#define ENET_TX_DESC 16
+#define ENET_TX_DESC 32
 
 #define NAPI_WEIGHT 16
