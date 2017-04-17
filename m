From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 20/25] net: mvpp2: Adjust a null pointer check in
 mvpp2_egress_enable()
Date: Mon, 17 Apr 2017 17:30:12 +0200
Message-ID: <54acb3f4-8a0c-90ba-4267-f62e10baa252@users.sourceforge.net>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d6f26bba-c678-5b66-4f5d-85f56d895190@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 17 Apr 2017 14:07:52 +0200

The script "checkpatch.pl" pointed information out like the following.

Comparison to NULL could be written "txq->descs".

Thus fix the affected source code place.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/mvpp2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 3bdd3f1fe34e..9b875d776b29 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -4415,7 +4415,7 @@ static void mvpp2_egress_enable(struct mvpp2_port *port)
 	for (queue = 0; queue < txq_number; queue++) {
 		struct mvpp2_tx_queue *txq = port->txqs[queue];
 
-		if (txq->descs != NULL)
+		if (txq->descs)
 			qmap |= (1 << queue);
 	}
 
-- 
2.12.2
