From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] ATM-nicstar: Delete an error message for a failed memory
 allocation in ns_init_card()
Date: Sun, 6 Aug 2017 10:16:54 +0200
Message-ID: <15557ccf-4b14-924a-b1ce-8fa052f0e1f0@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        Chas Williams <3chas3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 6 Aug 2017 10:10:21 +0200

Omit an extra message for a memory allocation failure in this function.

This issue was detected by using the Coccinelle software.

Link: http://events.linuxfoundation.org/sites/events/files/slides/LCJ16-Refactor_Strings-WSang_0.pdf
Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/atm/nicstar.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index 9588d80f318e..08d5aa8b9524 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -372,9 +372,6 @@ static int ns_init_card(int i, struct pci_dev *pcidev)
 
 	card = kmalloc(sizeof(*card), GFP_KERNEL);
 	if (!card) {
-		printk
-		    ("nicstar%d: can't allocate memory for device structure.\n",
-		     i);
 		error = 2;
 		ns_init_card_error(card, error);
 		return error;
-- 
2.13.4
