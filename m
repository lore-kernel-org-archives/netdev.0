From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 070/493] isdn: remove use of __devexit_p
Date: Mon, 19 Nov 2012 13:20:19 -0500
Message-ID: <1353349642-3677-70-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Karsten Keil <isdn@linux-pingi.de>,
	Armin Schindler <mac@melware.de>, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41655 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754523Ab2KSSiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:38:08 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devexit_p is no longer
needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Karsten Keil <isdn@linux-pingi.de> 
Cc: Armin Schindler <mac@melware.de> 
Cc: netdev@vger.kernel.org 
---
 drivers/isdn/hardware/avm/b1pci.c           | 2 +-
 drivers/isdn/hardware/eicon/divasmain.c     | 2 +-
 drivers/isdn/hardware/mISDN/avmfritz.c      | 2 +-
 drivers/isdn/hardware/mISDN/hfcmulti.c      | 2 +-
 drivers/isdn/hardware/mISDN/hfcpci.c        | 2 +-
 drivers/isdn/hardware/mISDN/mISDNinfineon.c | 2 +-
 drivers/isdn/hardware/mISDN/netjet.c        | 2 +-
 drivers/isdn/hardware/mISDN/speedfax.c      | 2 +-
 drivers/isdn/hardware/mISDN/w6692.c         | 2 +-
 drivers/isdn/hisax/avma1_cs.c               | 2 +-
 drivers/isdn/hisax/elsa_cs.c                | 2 +-
 drivers/isdn/hisax/hfc4s8s_l1.c             | 2 +-
 drivers/isdn/hisax/hisax_fcpcipnp.c         | 4 ++--
 drivers/isdn/hisax/sedlbauer_cs.c           | 2 +-
 drivers/isdn/hisax/teles_cs.c               | 2 +-
 drivers/isdn/hysdn/hysdn_init.c             | 2 +-
 16 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/isdn/hardware/avm/b1pci.c b/drivers/isdn/hardware/avm/b1pci.c
index b305e6b..cc1b671 100644
--- a/drivers/isdn/hardware/avm/b1pci.c
+++ b/drivers/isdn/hardware/avm/b1pci.c
@@ -362,7 +362,7 @@ static struct pci_driver b1pci_pci_driver = {
 	.name		= "b1pci",
 	.id_table	= b1pci_pci_tbl,
 	.probe		= b1pci_pci_probe,
-	.remove		= __devexit_p(b1pci_pci_remove),
+	.remove		= b1pci_pci_remove,
 };
 
 static struct capi_driver capi_driver_b1pci = {
diff --git a/drivers/isdn/hardware/eicon/divasmain.c b/drivers/isdn/hardware/eicon/divasmain.c
index ca6d276..3dfe2bb 100644
--- a/drivers/isdn/hardware/eicon/divasmain.c
+++ b/drivers/isdn/hardware/eicon/divasmain.c
@@ -155,7 +155,7 @@ static void __devexit divas_remove_one(struct pci_dev *pdev);
 static struct pci_driver diva_pci_driver = {
 	.name     = "divas",
 	.probe    = divas_init_one,
-	.remove   = __devexit_p(divas_remove_one),
+	.remove   = divas_remove_one,
 	.id_table = divas_pci_tbl,
 };
 
diff --git a/drivers/isdn/hardware/mISDN/avmfritz.c b/drivers/isdn/hardware/mISDN/avmfritz.c
index dceaec8..922f29f 100644
--- a/drivers/isdn/hardware/mISDN/avmfritz.c
+++ b/drivers/isdn/hardware/mISDN/avmfritz.c
@@ -1154,7 +1154,7 @@ MODULE_DEVICE_TABLE(pci, fcpci_ids);
 static struct pci_driver fcpci_driver = {
 	.name = "fcpci",
 	.probe = fritzpci_probe,
-	.remove = __devexit_p(fritz_remove_pci),
+	.remove = fritz_remove_pci,
 	.id_table = fcpci_ids,
 };
 
diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index f027942..ad6cf8e 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -5472,7 +5472,7 @@ hfcmulti_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 static struct pci_driver hfcmultipci_driver = {
 	.name		= "hfc_multi",
 	.probe		= hfcmulti_probe,
-	.remove		= __devexit_p(hfc_remove_pci),
+	.remove		= hfc_remove_pci,
 	.id_table	= hfmultipci_ids,
 };
 
diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardware/mISDN/hfcpci.c
index 6e99d73..580e629 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -2263,7 +2263,7 @@ hfc_remove_pci(struct pci_dev *pdev)
 static struct pci_driver hfc_driver = {
 	.name = "hfcpci",
 	.probe = hfc_probe,
-	.remove = __devexit_p(hfc_remove_pci),
+	.remove = hfc_remove_pci,
 	.id_table = hfc_ids,
 };
 
diff --git a/drivers/isdn/hardware/mISDN/mISDNinfineon.c b/drivers/isdn/hardware/mISDN/mISDNinfineon.c
index 631eb3f..a43fddf 100644
--- a/drivers/isdn/hardware/mISDN/mISDNinfineon.c
+++ b/drivers/isdn/hardware/mISDN/mISDNinfineon.c
@@ -1149,7 +1149,7 @@ inf_remove(struct pci_dev *pdev)
 static struct pci_driver infineon_driver = {
 	.name = "ISDN Infineon pci",
 	.probe = inf_probe,
-	.remove = __devexit_p(inf_remove),
+	.remove = inf_remove,
 	.id_table = infineon_ids,
 };
 
diff --git a/drivers/isdn/hardware/mISDN/netjet.c b/drivers/isdn/hardware/mISDN/netjet.c
index 9bcade5..2cfed9f 100644
--- a/drivers/isdn/hardware/mISDN/netjet.c
+++ b/drivers/isdn/hardware/mISDN/netjet.c
@@ -1147,7 +1147,7 @@ MODULE_DEVICE_TABLE(pci, nj_pci_ids);
 static struct pci_driver nj_driver = {
 	.name = "netjet",
 	.probe = nj_probe,
-	.remove = __devexit_p(nj_remove),
+	.remove = nj_remove,
 	.id_table = nj_pci_ids,
 };
 
diff --git a/drivers/isdn/hardware/mISDN/speedfax.c b/drivers/isdn/hardware/mISDN/speedfax.c
index 93f344d..92c6059 100644
--- a/drivers/isdn/hardware/mISDN/speedfax.c
+++ b/drivers/isdn/hardware/mISDN/speedfax.c
@@ -507,7 +507,7 @@ MODULE_DEVICE_TABLE(pci, sfaxpci_ids);
 static struct pci_driver sfaxpci_driver = {
 	.name = "speedfax+ pci",
 	.probe = sfaxpci_probe,
-	.remove = __devexit_p(sfax_remove_pci),
+	.remove = sfax_remove_pci,
 	.id_table = sfaxpci_ids,
 };
 
diff --git a/drivers/isdn/hardware/mISDN/w6692.c b/drivers/isdn/hardware/mISDN/w6692.c
index 335fe64..34be200 100644
--- a/drivers/isdn/hardware/mISDN/w6692.c
+++ b/drivers/isdn/hardware/mISDN/w6692.c
@@ -1414,7 +1414,7 @@ MODULE_DEVICE_TABLE(pci, w6692_ids);
 static struct pci_driver w6692_driver = {
 	.name =  "w6692",
 	.probe = w6692_probe,
-	.remove = __devexit_p(w6692_remove_pci),
+	.remove = w6692_remove_pci,
 	.id_table = w6692_ids,
 };
 
diff --git a/drivers/isdn/hisax/avma1_cs.c b/drivers/isdn/hisax/avma1_cs.c
index c644557..7f5d8b6 100644
--- a/drivers/isdn/hisax/avma1_cs.c
+++ b/drivers/isdn/hisax/avma1_cs.c
@@ -156,7 +156,7 @@ static struct pcmcia_driver avma1cs_driver = {
 	.owner		= THIS_MODULE,
 	.name		= "avma1_cs",
 	.probe		= avma1cs_probe,
-	.remove		= __devexit_p(avma1cs_detach),
+	.remove		= avma1cs_detach,
 	.id_table	= avma1cs_ids,
 };
 
diff --git a/drivers/isdn/hisax/elsa_cs.c b/drivers/isdn/hisax/elsa_cs.c
index a8c4d3f..231ec71 100644
--- a/drivers/isdn/hisax/elsa_cs.c
+++ b/drivers/isdn/hisax/elsa_cs.c
@@ -210,7 +210,7 @@ static struct pcmcia_driver elsa_cs_driver = {
 	.owner		= THIS_MODULE,
 	.name		= "elsa_cs",
 	.probe		= elsa_cs_probe,
-	.remove		= __devexit_p(elsa_cs_detach),
+	.remove		= elsa_cs_detach,
 	.id_table	= elsa_ids,
 	.suspend	= elsa_suspend,
 	.resume		= elsa_resume,
diff --git a/drivers/isdn/hisax/hfc4s8s_l1.c b/drivers/isdn/hisax/hfc4s8s_l1.c
index f794850..e85b612 100644
--- a/drivers/isdn/hisax/hfc4s8s_l1.c
+++ b/drivers/isdn/hisax/hfc4s8s_l1.c
@@ -1662,7 +1662,7 @@ hfc4s8s_remove(struct pci_dev *pdev)
 static struct pci_driver hfc4s8s_driver = {
 	.name	= "hfc4s8s_l1",
 	.probe	= hfc4s8s_probe,
-	.remove	= __devexit_p(hfc4s8s_remove),
+	.remove	= hfc4s8s_remove,
 	.id_table	= hfc4s8s_ids,
 };
 
diff --git a/drivers/isdn/hisax/hisax_fcpcipnp.c b/drivers/isdn/hisax/hisax_fcpcipnp.c
index e4f47fe..3d063d1 100644
--- a/drivers/isdn/hisax/hisax_fcpcipnp.c
+++ b/drivers/isdn/hisax/hisax_fcpcipnp.c
@@ -973,7 +973,7 @@ static void __devexit fcpnp_remove(struct pnp_dev *pdev)
 static struct pnp_driver fcpnp_driver = {
 	.name		= "fcpnp",
 	.probe		= fcpnp_probe,
-	.remove		= __devexit_p(fcpnp_remove),
+	.remove		= fcpnp_remove,
 	.id_table	= fcpnp_ids,
 };
 #endif
@@ -990,7 +990,7 @@ static void __devexit fcpci_remove(struct pci_dev *pdev)
 static struct pci_driver fcpci_driver = {
 	.name		= "fcpci",
 	.probe		= fcpci_probe,
-	.remove		= __devexit_p(fcpci_remove),
+	.remove		= fcpci_remove,
 	.id_table	= fcpci_ids,
 };
 
diff --git a/drivers/isdn/hisax/sedlbauer_cs.c b/drivers/isdn/hisax/sedlbauer_cs.c
index f0dfc0c..42abb24 100644
--- a/drivers/isdn/hisax/sedlbauer_cs.c
+++ b/drivers/isdn/hisax/sedlbauer_cs.c
@@ -201,7 +201,7 @@ static struct pcmcia_driver sedlbauer_driver = {
 	.owner		= THIS_MODULE,
 	.name		= "sedlbauer_cs",
 	.probe		= sedlbauer_probe,
-	.remove		= __devexit_p(sedlbauer_detach),
+	.remove		= sedlbauer_detach,
 	.id_table	= sedlbauer_ids,
 	.suspend	= sedlbauer_suspend,
 	.resume		= sedlbauer_resume,
diff --git a/drivers/isdn/hisax/teles_cs.c b/drivers/isdn/hisax/teles_cs.c
index 4deac45..a36fa04 100644
--- a/drivers/isdn/hisax/teles_cs.c
+++ b/drivers/isdn/hisax/teles_cs.c
@@ -192,7 +192,7 @@ static struct pcmcia_driver teles_cs_driver = {
 	.owner		= THIS_MODULE,
 	.name		= "teles_cs",
 	.probe		= teles_probe,
-	.remove		= __devexit_p(teles_detach),
+	.remove		= teles_detach,
 	.id_table       = teles_ids,
 	.suspend	= teles_suspend,
 	.resume		= teles_resume,
diff --git a/drivers/isdn/hysdn/hysdn_init.c b/drivers/isdn/hysdn/hysdn_init.c
index b61bbb4..c103c28 100644
--- a/drivers/isdn/hysdn/hysdn_init.c
+++ b/drivers/isdn/hysdn/hysdn_init.c
@@ -147,7 +147,7 @@ static struct pci_driver hysdn_pci_driver = {
 	.name		= "hysdn",
 	.id_table	= hysdn_pci_tbl,
 	.probe		= hysdn_pci_init_one,
-	.remove		= __devexit_p(hysdn_pci_remove_one),
+	.remove		= hysdn_pci_remove_one,
 };
 
 static int hysdn_have_procfs;
-- 
1.8.0
