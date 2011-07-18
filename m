From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 06/45] bna: Use DEFINE_PCI_DEVICE_TABLE and Print Driver Version
Date: Mon, 18 Jul 2011 01:19:34 -0700
Message-ID: <1310977178-312-7-git-send-email-rmody@brocade.com>
References: <1310977178-312-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37718 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753557Ab1GRIUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:20:44 -0400
In-Reply-To: <1310977178-312-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Use DEFINE_PCI_DEVICE_TABLE in place of struct pci_device_id
 - Print the dirver version when module is loaded

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bnad.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index f57e491..abad4e3 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -3230,7 +3230,7 @@ bnad_pci_remove(struct pci_dev *pdev)
 	free_netdev(netdev);
 }
 
-static const struct pci_device_id bnad_pci_id_table[] = {
+static DEFINE_PCI_DEVICE_TABLE(bnad_pci_id_table) = {
 	{
 		PCI_DEVICE(PCI_VENDOR_ID_BROCADE,
 			PCI_DEVICE_ID_BROCADE_CT),
@@ -3253,7 +3253,7 @@ bnad_module_init(void)
 {
 	int err;
 
-	pr_info("Brocade 10G Ethernet driver\n");
+	pr_info("Brocade 10G Ethernet driver %s\n", BNAD_VERSION);
 
 	bfa_nw_ioc_auto_recover(bnad_ioc_auto_recover);
 
-- 
1.7.1

