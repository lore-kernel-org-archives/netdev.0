From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: Fix unused variable warning
Date: Fri, 20 Jan 2017 14:47:19 +0530
Message-ID: <1484903839-5890-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, hariprasad@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:38350 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751982AbdATJSH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 04:18:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix unused variable warning when CONFIG_PCI_IOV is not
defined.

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 4da6f90..49e000e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4643,7 +4643,9 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	u32 whoami, pl_rev;
 	enum chip_type chip;
 	static int adap_idx = 1;
+#ifdef CONFIG_PCI_IOV
 	u32 v, port_vec;
+#endif
 
 	printk_once(KERN_INFO "%s - version %s\n", DRV_DESC, DRV_VERSION);
 
-- 
2.1.0
