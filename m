From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 5/5] net: defxx: constify eisa_device_id
Date: Sat, 19 Aug 2017 12:23:34 +0530
Message-ID: <1503125614-15297-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net, macro@linux-mips.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

eisa_device_id are not supposed to change at runtime. All functions
working with eisa_device_id provided by <linux/eisa.h> work with
const eisa_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/fddi/defxx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/fddi/defxx.c b/drivers/net/fddi/defxx.c
index f4a816c..61fceee 100644
--- a/drivers/net/fddi/defxx.c
+++ b/drivers/net/fddi/defxx.c
@@ -3767,7 +3767,7 @@ static void dfx_pci_unregister(struct pci_dev *pdev)
 #endif /* CONFIG_PCI */
 
 #ifdef CONFIG_EISA
-static struct eisa_device_id dfx_eisa_table[] = {
+static const struct eisa_device_id dfx_eisa_table[] = {
         { "DEC3001", DEFEA_PROD_ID_1 },
         { "DEC3002", DEFEA_PROD_ID_2 },
         { "DEC3003", DEFEA_PROD_ID_3 },
-- 
2.7.4
