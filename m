From: Yijing Wang <wangyijing@huawei.com>
Subject: [PATCH] bnx2x: Fix the MSI flags
Date: Wed, 25 Jun 2014 12:22:56 +0800
Message-ID: <1403670176-12072-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Ariel Elior <ariel.elior@qlogic.com>,
	"Yijing Wang" <wangyijing@huawei.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:28002 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbaFYEXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 00:23:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MSI-X should use PCI_MSIX_FLAGS not PCI_MSI_FLAGS.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 2887034..6a8b145 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12937,7 +12937,7 @@ static int bnx2x_get_num_non_def_sbs(struct pci_dev *pdev, int cnic_cnt)
 	 * without the default SB.
 	 * For VFs there is no default SB, then we return (index+1).
 	 */
-	pci_read_config_word(pdev, pdev->msix_cap + PCI_MSI_FLAGS, &control);
+	pci_read_config_word(pdev, pdev->msix_cap + PCI_MSIX_FLAGS, &control);
 
 	index = control & PCI_MSIX_FLAGS_QSIZE;
 
-- 
1.7.1
