From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 13/25] net: mvpp2: Fix a jump label position in mvpp2_rx()
Date: Mon, 17 Apr 2017 17:23:21 +0200
Message-ID: <26d7b00f-85bb-5123-7334-a75542d86449@users.sourceforge.net>
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
Date: Mon, 17 Apr 2017 10:52:02 +0200

The script "checkpatch.pl" pointed out that labels should not be indented.
Thus delete two horizontal tabs before the jump label "err_drop_frame"
in the function "mvpp2_rx".

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/mvpp2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 3bddb8fcd595..4f4b659d7297 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -5515,7 +5515,7 @@ static int mvpp2_rx(struct mvpp2_port *port, int rx_todo,
 		 * comprised by the RX descriptor.
 		 */
 		if (rx_status & MVPP2_RXD_ERR_SUMMARY) {
-		err_drop_frame:
+err_drop_frame:
 			dev->stats.rx_errors++;
 			mvpp2_rx_error(port, rx_desc);
 			/* Return the buffer to the pool */
-- 
2.12.2

