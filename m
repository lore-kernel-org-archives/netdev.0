From: Benoit Taine <benoit.taine@lip6.fr>
Subject: [PATCH 18/25] smsc9420: Replace DEFINE_PCI_DEVICE_TABLE macro use
Date: Fri, 18 Jul 2014 17:27:05 +0200
Message-ID: <1405697232-11785-19-git-send-email-benoit.taine@lip6.fr>
References: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
Cc: benoit.taine@lip6.fr, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We should prefer `struct pci_device_id` over `DEFINE_PCI_DEVICE_TABLE` to meet
kernel coding style guidelines. This issue was reported by checkpatch.

Signed-off-by: Benoit Taine <benoit.taine@lip6.fr>

---
Tested by compilation without errors.

 drivers/net/ethernet/smsc/smsc9420.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index d3b967a..4a90cda 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -83,7 +83,7 @@ struct smsc9420_pdata {
 	int last_carrier;
 };
 
-static DEFINE_PCI_DEVICE_TABLE(smsc9420_id_table) = {
+static const struct pci_device_id smsc9420_id_table[] = {
 	{ PCI_VENDOR_ID_9420, PCI_DEVICE_ID_9420, PCI_ANY_ID, PCI_ANY_ID, },
 	{ 0, }
 };
