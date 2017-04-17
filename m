From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 16/25] net: mvpp2: Rename a jump label in
 mvpp2_tx_frag_process()
Date: Mon, 17 Apr 2017 17:26:18 +0200
Message-ID: <0253300e-221d-49b8-6dae-6fd1fd738261@users.sourceforge.net>
References: <d6f26bba-c678-5b66-4f5d-85f56d895190@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Jarod Wilson <jarod@redhat.com>,
        Jisheng Zhang <jszhang@marvell.com>,
        Mirko Lindner <mlindner@marvell.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Russell King <rmk+kernel@armlinux.org.uk>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <d6f26bba-c678-5b66-4f5d-85f56d895190@users.sourceforge.net>
Content-Language: en-GB
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 17 Apr 2017 11:36:34 +0200

Adjust jump labels according to the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/mvpp2.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 717d79dcb6aa..8f4348316d28 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -5606,7 +5606,7 @@ static int mvpp2_tx_frag_process(struct mvpp2_port *port, struct sk_buff *skb,
 					       DMA_TO_DEVICE);
 		if (dma_mapping_error(port->dev->dev.parent, buf_dma_addr)) {
 			mvpp2_txq_desc_put(txq);
-			goto error;
+			goto cleanup;
 		}
 
 		mvpp2_txdesc_offset_set(port, tx_desc,
@@ -5627,8 +5627,7 @@ static int mvpp2_tx_frag_process(struct mvpp2_port *port, struct sk_buff *skb,
 	}
 
 	return 0;
-
-error:
+cleanup:
 	/* Release all descriptors that were used to map fragments of
 	 * this packet, as well as the corresponding DMA mappings
 	 */
-- 
2.12.2

