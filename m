From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: qcom/emac: make function emac_isr static
Date: Thu,  5 Oct 2017 10:10:23 +0100
Message-ID: <20171005091023.27781-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The function emac_isr is local to the source and does not need to
be in global scope, so make it static.

Cleans up sparse warnings:
symbol 'emac_isr' was not declared. Should it be static?

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/qualcomm/emac/emac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
index 759543512117..f477ba29c569 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac.c
@@ -130,7 +130,7 @@ static int emac_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	return emac_mac_tx_buf_send(adpt, &adpt->tx_q, skb);
 }
 
-irqreturn_t emac_isr(int _irq, void *data)
+static irqreturn_t emac_isr(int _irq, void *data)
 {
 	struct emac_irq *irq = data;
 	struct emac_adapter *adpt =
-- 
2.14.1
