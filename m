From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 17/25] net: mvpp2: Rename a jump label in mvpp2_txq_init()
Date: Mon, 17 Apr 2017 17:27:13 +0200
Message-ID: <1f79b52d-673f-63bb-0bd8-713139a322ab@users.sourceforge.net>
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
Date: Mon, 17 Apr 2017 12:58:33 +0200

Adjust jump labels according to the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/mvpp2.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 8f4348316d28..a5cd1036012a 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -5087,7 +5087,7 @@ static int mvpp2_txq_init(struct mvpp2_port *port,
 						sizeof(*txq_pcpu->buffs),
 						GFP_KERNEL);
 		if (!txq_pcpu->buffs)
-			goto error;
+			goto cleanup;
 
 		txq_pcpu->count = 0;
 		txq_pcpu->reserved_num = 0;
@@ -5096,8 +5096,7 @@ static int mvpp2_txq_init(struct mvpp2_port *port,
 	}
 
 	return 0;
-
-error:
+cleanup:
 	for_each_present_cpu(cpu) {
 		txq_pcpu = per_cpu_ptr(txq->pcpu, cpu);
 		kfree(txq_pcpu->buffs);
-- 
2.12.2

