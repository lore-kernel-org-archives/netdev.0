From: SZ Lin <sz.lin@moxa.com>
Subject: [PATCH 1/6] net: moxa: Remove braces from single-line body
Date: Sat, 29 Jul 2017 18:42:34 +0800
Message-ID: <20170729104239.14999-2-sz.lin@moxa.com>
References: <20170729104239.14999-1-sz.lin@moxa.com>
Cc: jarod@redhat.com, jonas.jensen@gmail.com, edumazet@google.com,
        bhumirks@gmail.com, tklauser@distanz.ch, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, SZ Lin <sz.lin@moxa.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170729104239.14999-1-sz.lin@moxa.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove unnecessary braces from single-line if statement
This warning is found using checkpatch.pl

Signed-off-by: SZ Lin <sz.lin@moxa.com>
---
 drivers/net/ethernet/moxa/moxart_ether.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index c0d7d5eec7e7..105215862949 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -269,9 +269,8 @@ static int moxart_rx_poll(struct napi_struct *napi, int budget)
 		priv->rx_head = rx_head;
 	}
 
-	if (rx < budget) {
+	if (rx < budget)
 		napi_complete_done(napi, rx);
-	}
 
 	priv->reg_imr |= RPKT_FINISH_M;
 	writel(priv->reg_imr, priv->base + REG_INTERRUPT_MASK);
-- 
2.13.3
