From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 3/5] ATM-nicstar: Improve another size determination in
 ns_init_card()
Date: Sat, 10 Sep 2016 09:19:33 +0200
Message-ID: <c8533128-fbcf-f7fe-9354-1949b47cca32@users.sourceforge.net>
References: <fe480e1f-285a-bb98-3550-b4fa354f8174@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>,
        Paolo Bonzini <pbonzini@redhat.com>
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        Chas Williams <3chas3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <fe480e1f-285a-bb98-3550-b4fa354f8174@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 10 Sep 2016 08:30:09 +0200

Replace the specification of a data structure by a reference for a field
in a local variable as the parameter for the operator "sizeof" to make
the corresponding size determination a bit safer according to
the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/atm/nicstar.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index 96062e1..ef977bf 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -611,7 +611,7 @@ static int ns_init_card(int i, struct pci_dev *pcidev)
 	for (j = 0; j < card->rct_size; j++)
 		ns_write_sram(card, j * 4, u32d, 4);
 
-	memset(card->vcmap, 0, NS_MAX_RCTSIZE * sizeof(vc_map));
+	memset(card->vcmap, 0, sizeof(card->vcmap));
 
 	for (j = 0; j < NS_FRSCD_NUM; j++)
 		card->scd2vc[j] = NULL;
-- 
2.10.0
