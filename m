From: Benoit Taine <benoit.taine@lip6.fr>
Subject: [PATCH 10/25] netxen: Replace DEFINE_PCI_DEVICE_TABLE macro use
Date: Fri, 18 Jul 2014 17:26:57 +0200
Message-ID: <1405697232-11785-11-git-send-email-benoit.taine@lip6.fr>
References: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
Cc: benoit.taine@lip6.fr, Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Manish Chopra <manish.chopra@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isis.lip6.fr ([132.227.60.2]:54977 "EHLO isis.lip6.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762593AbaGRPfZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2014 11:35:25 -0400
In-Reply-To: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should prefer `struct pci_device_id` over `DEFINE_PCI_DEVICE_TABLE` to meet
kernel coding style guidelines. This issue was reported by checkpatch.

Signed-off-by: Benoit Taine <benoit.taine@lip6.fr>

---
Tested by compilation without errors.

 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 5bf0581..1159031 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -99,7 +99,7 @@ static int netxen_nic_set_mac(struct net_device *netdev, void *p);
 	{PCI_DEVICE(PCI_VENDOR_ID_NETXEN, (device)), \
 	.class = PCI_CLASS_NETWORK_ETHERNET << 8, .class_mask = ~0}
 
-static DEFINE_PCI_DEVICE_TABLE(netxen_pci_tbl) = {
+static const struct pci_device_id netxen_pci_tbl[] = {
 	ENTRY(PCI_DEVICE_ID_NX2031_10GXSR),
 	ENTRY(PCI_DEVICE_ID_NX2031_10GCX4),
 	ENTRY(PCI_DEVICE_ID_NX2031_4GCU),
