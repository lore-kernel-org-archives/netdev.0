From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 1/3] nfp: correct name of control BAR define
Date: Wed, 29 Jun 2016 21:55:53 +0100
Message-ID: <1467233755-14334-2-git-send-email-jakub.kicinski@netronome.com>
References: <1467233755-14334-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:38186 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751230AbcF2VCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 17:02:47 -0400
Received: by mail-wm0-f50.google.com with SMTP id r201so90947265wme.1
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 14:02:42 -0700 (PDT)
In-Reply-To: <1467233755-14334-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Spell abbreviation of control as ctrl not crtl.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h        | 2 +-
 drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index e744acc18ef4..690635660195 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -63,7 +63,7 @@
 #define NFP_NET_POLL_TIMEOUT	5
 
 /* Bar allocation */
-#define NFP_NET_CRTL_BAR	0
+#define NFP_NET_CTRL_BAR	0
 #define NFP_NET_Q0_BAR		2
 #define NFP_NET_Q1_BAR		4	/* OBSOLETE */
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c b/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
index e2b22b8a20f1..37abef016a0a 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
@@ -124,11 +124,11 @@ static int nfp_netvf_pci_probe(struct pci_dev *pdev,
 	 * first NFP_NET_CFG_BAR_SZ of the BAR.  This keeps the code
 	 * the identical for PF and VF drivers.
 	 */
-	ctrl_bar = ioremap_nocache(pci_resource_start(pdev, NFP_NET_CRTL_BAR),
+	ctrl_bar = ioremap_nocache(pci_resource_start(pdev, NFP_NET_CTRL_BAR),
 				   NFP_NET_CFG_BAR_SZ);
 	if (!ctrl_bar) {
 		dev_err(&pdev->dev,
-			"Failed to map resource %d\n", NFP_NET_CRTL_BAR);
+			"Failed to map resource %d\n", NFP_NET_CTRL_BAR);
 		err = -EIO;
 		goto err_pci_regions;
 	}
-- 
1.9.1
