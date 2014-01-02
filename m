From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 3/3] smsc9420: use named constants for pci_power_t values
Date: Fri,  3 Jan 2014 00:40:31 +0100
Message-ID: <1388706031-22180-4-git-send-email-Julia.Lawall@lip6.fr>
References: <1388706031-22180-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388706031-22180-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression e1,e2;
@@

pci_enable_wake(e1,
- 0
+ PCI_D0
,e2)
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/ethernet/smsc/smsc9420.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index 9d6effe..d3b967a 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -1540,7 +1540,7 @@ static int smsc9420_resume(struct pci_dev *pdev)
 
 	pci_set_master(pdev);
 
-	err = pci_enable_wake(pdev, 0, 0);
+	err = pci_enable_wake(pdev, PCI_D0, 0);
 	if (err)
 		netif_warn(pd, ifup, pd->dev, "pci_enable_wake failed: %d\n",
 			   err);
