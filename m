From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 311/493] isdn: remove use of __devinitdata
Date: Mon, 19 Nov 2012 13:24:20 -0500
Message-ID: <1353349642-3677-311-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41468 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754182Ab2KSSe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:34:26 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devinitdata is no
longer needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Karsten Keil <isdn@linux-pingi.de> 
Cc: netdev@vger.kernel.org 
---
 drivers/isdn/hardware/mISDN/avmfritz.c      |  2 +-
 drivers/isdn/hardware/mISDN/hfcmulti.c      |  2 +-
 drivers/isdn/hardware/mISDN/mISDNinfineon.c |  2 +-
 drivers/isdn/hardware/mISDN/netjet.c        |  2 +-
 drivers/isdn/hardware/mISDN/speedfax.c      |  2 +-
 drivers/isdn/hisax/asuscom.c                |  6 +++---
 drivers/isdn/hisax/avm_pci.c                |  4 ++--
 drivers/isdn/hisax/bkm_a4t.c                |  2 +-
 drivers/isdn/hisax/bkm_a8.c                 | 12 ++++++------
 drivers/isdn/hisax/config.c                 | 10 +++++-----
 drivers/isdn/hisax/diva.c                   | 14 +++++++-------
 drivers/isdn/hisax/elsa.c                   | 10 +++++-----
 drivers/isdn/hisax/enternow_pci.c           |  2 +-
 drivers/isdn/hisax/gazel.c                  |  2 +-
 drivers/isdn/hisax/hfc_pci.c                |  2 +-
 drivers/isdn/hisax/hfc_sx.c                 |  6 +++---
 drivers/isdn/hisax/hfcscard.c               |  6 +++---
 drivers/isdn/hisax/hisax_fcpcipnp.c         |  2 +-
 drivers/isdn/hisax/isac.c                   |  2 +-
 drivers/isdn/hisax/isurf.c                  |  2 +-
 drivers/isdn/hisax/ix1_micro.c              |  6 +++---
 drivers/isdn/hisax/niccy.c                  |  4 ++--
 drivers/isdn/hisax/nj_s.c                   |  2 +-
 drivers/isdn/hisax/nj_u.c                   |  2 +-
 drivers/isdn/hisax/sedlbauer.c              |  8 ++++----
 drivers/isdn/hisax/teles3.c                 |  6 +++---
 drivers/isdn/hisax/telespci.c               |  2 +-
 drivers/isdn/hisax/w6692.c                  |  2 +-
 28 files changed, 62 insertions(+), 62 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/avmfritz.c b/drivers/isdn/hardware/mISDN/avmfritz.c
index 44f57dc..2620876 100644
--- a/drivers/isdn/hardware/mISDN/avmfritz.c
+++ b/drivers/isdn/hardware/mISDN/avmfritz.c
@@ -1142,7 +1142,7 @@ fritz_remove_pci(struct pci_dev *pdev)
 			pr_info("%s: drvdata already removed\n", __func__);
 }
 
-static struct pci_device_id fcpci_ids[] __devinitdata = {
+static struct pci_device_id fcpci_ids[] = {
 	{ PCI_VENDOR_ID_AVM, PCI_DEVICE_ID_AVM_A1, PCI_ANY_ID, PCI_ANY_ID,
 	  0, 0, (unsigned long) "Fritz!Card PCI"},
 	{ PCI_VENDOR_ID_AVM, PCI_DEVICE_ID_AVM_A1_V2, PCI_ANY_ID, PCI_ANY_ID,
diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index ad6cf8e..36798bf 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -5351,7 +5351,7 @@ static const struct hm_map hfcm_map[] = {
 
 #undef H
 #define H(x)	((unsigned long)&hfcm_map[x])
-static struct pci_device_id hfmultipci_ids[] __devinitdata = {
+static struct pci_device_id hfmultipci_ids[] = {
 
 	/* Cards with HFC-4S Chip */
 	{ PCI_VENDOR_ID_CCD, PCI_DEVICE_ID_CCD_HFC4S, PCI_VENDOR_ID_CCD,
diff --git a/drivers/isdn/hardware/mISDN/mISDNinfineon.c b/drivers/isdn/hardware/mISDN/mISDNinfineon.c
index 6810521..f8ab56d 100644
--- a/drivers/isdn/hardware/mISDN/mISDNinfineon.c
+++ b/drivers/isdn/hardware/mISDN/mISDNinfineon.c
@@ -125,7 +125,7 @@ struct inf_hw {
 #define PCI_SUBVENDOR_SEDLBAUER_PCI     0x53
 #define PCI_SUB_ID_SEDLBAUER            0x01
 
-static struct pci_device_id infineon_ids[] __devinitdata = {
+static struct pci_device_id infineon_ids[] = {
 	{ PCI_VDEVICE(EICON, PCI_DEVICE_ID_EICON_DIVA20), INF_DIVA20 },
 	{ PCI_VDEVICE(EICON, PCI_DEVICE_ID_EICON_DIVA20_U), INF_DIVA20U },
 	{ PCI_VDEVICE(EICON, PCI_DEVICE_ID_EICON_DIVA201), INF_DIVA201 },
diff --git a/drivers/isdn/hardware/mISDN/netjet.c b/drivers/isdn/hardware/mISDN/netjet.c
index d464735..cc68656 100644
--- a/drivers/isdn/hardware/mISDN/netjet.c
+++ b/drivers/isdn/hardware/mISDN/netjet.c
@@ -1137,7 +1137,7 @@ static void __devexit nj_remove(struct pci_dev *pdev)
 /* We cannot select cards with PCI_SUB... IDs, since here are cards with
  * SUB IDs set to PCI_ANY_ID, so we need to match all and reject
  * known other cards which not work with this driver - see probe function */
-static struct pci_device_id nj_pci_ids[] __devinitdata = {
+static struct pci_device_id nj_pci_ids[] = {
 	{ PCI_VENDOR_ID_TIGERJET, PCI_DEVICE_ID_TIGERJET_300,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{ }
diff --git a/drivers/isdn/hardware/mISDN/speedfax.c b/drivers/isdn/hardware/mISDN/speedfax.c
index c292507..f728992 100644
--- a/drivers/isdn/hardware/mISDN/speedfax.c
+++ b/drivers/isdn/hardware/mISDN/speedfax.c
@@ -491,7 +491,7 @@ sfax_remove_pci(struct pci_dev *pdev)
 		pr_debug("%s: drvdata already removed\n", __func__);
 }
 
-static struct pci_device_id sfaxpci_ids[] __devinitdata = {
+static struct pci_device_id sfaxpci_ids[] = {
 	{ PCI_VENDOR_ID_TIGERJET, PCI_DEVICE_ID_TIGERJET_100,
 	  PCI_SUBVENDOR_SPEEDFAX_PYRAMID, PCI_SUB_ID_SEDLBAUER,
 	  0, 0, (unsigned long) "Pyramid Speedfax + PCI"
diff --git a/drivers/isdn/hisax/asuscom.c b/drivers/isdn/hisax/asuscom.c
index e324be4..3006f5b 100644
--- a/drivers/isdn/hisax/asuscom.c
+++ b/drivers/isdn/hisax/asuscom.c
@@ -295,7 +295,7 @@ Asus_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 }
 
 #ifdef __ISAPNP__
-static struct isapnp_device_id asus_ids[] __devinitdata = {
+static struct isapnp_device_id asus_ids[] = {
 	{ ISAPNP_VENDOR('A', 'S', 'U'), ISAPNP_FUNCTION(0x1688),
 	  ISAPNP_VENDOR('A', 'S', 'U'), ISAPNP_FUNCTION(0x1688),
 	  (unsigned long) "Asus1688 PnP" },
@@ -311,8 +311,8 @@ static struct isapnp_device_id asus_ids[] __devinitdata = {
 	{ 0, }
 };
 
-static struct isapnp_device_id *ipid __devinitdata = &asus_ids[0];
-static struct pnp_card *pnp_c __devinitdata = NULL;
+static struct isapnp_device_id *ipid = &asus_ids[0];
+static struct pnp_card *pnp_c = NULL;
 #endif
 
 int
diff --git a/drivers/isdn/hisax/avm_pci.c b/drivers/isdn/hisax/avm_pci.c
index 2536aa4..9ec8b79 100644
--- a/drivers/isdn/hisax/avm_pci.c
+++ b/drivers/isdn/hisax/avm_pci.c
@@ -777,7 +777,7 @@ static int avm_pnp_setup(struct IsdnCardState *cs)
 
 #else
 
-static struct pnp_card *pnp_avm_c __devinitdata = NULL;
+static struct pnp_card *pnp_avm_c = NULL;
 
 static int avm_pnp_setup(struct IsdnCardState *cs)
 {
@@ -832,7 +832,7 @@ static int avm_pci_setup(struct IsdnCardState *cs)
 
 #else
 
-static struct pci_dev *dev_avm __devinitdata = NULL;
+static struct pci_dev *dev_avm = NULL;
 
 static int avm_pci_setup(struct IsdnCardState *cs)
 {
diff --git a/drivers/isdn/hisax/bkm_a4t.c b/drivers/isdn/hisax/bkm_a4t.c
index f186b02..65244e0 100644
--- a/drivers/isdn/hisax/bkm_a4t.c
+++ b/drivers/isdn/hisax/bkm_a4t.c
@@ -323,7 +323,7 @@ static int a4t_cs_init(struct IsdnCard *card,
 	return (1);
 }
 
-static struct pci_dev *dev_a4t __devinitdata = NULL;
+static struct pci_dev *dev_a4t = NULL;
 
 int
 setup_bkm_a4t(struct IsdnCard *card)
diff --git a/drivers/isdn/hisax/bkm_a8.c b/drivers/isdn/hisax/bkm_a8.c
index 48c50cf..b81ce05 100644
--- a/drivers/isdn/hisax/bkm_a8.c
+++ b/drivers/isdn/hisax/bkm_a8.c
@@ -267,12 +267,12 @@ sct_alloc_io(u_int adr, u_int len)
 	return (0);
 }
 
-static struct pci_dev *dev_a8 __devinitdata = NULL;
-static u16  sub_vendor_id __devinitdata = 0;
-static u16  sub_sys_id __devinitdata = 0;
-static u_char pci_bus __devinitdata = 0;
-static u_char pci_device_fn __devinitdata = 0;
-static u_char pci_irq __devinitdata = 0;
+static struct pci_dev *dev_a8 = NULL;
+static u16  sub_vendor_id = 0;
+static u16  sub_sys_id = 0;
+static u_char pci_bus = 0;
+static u_char pci_device_fn = 0;
+static u_char pci_irq = 0;
 
 int
 setup_sct_quadro(struct IsdnCard *card)
diff --git a/drivers/isdn/hisax/config.c b/drivers/isdn/hisax/config.c
index 420e3be..95cdcbf 100644
--- a/drivers/isdn/hisax/config.c
+++ b/drivers/isdn/hisax/config.c
@@ -338,11 +338,11 @@ static int io[HISAX_MAX_CARDS] = { 0, };
 #define IO0_IO1
 #endif
 #ifdef IO0_IO1
-static int io0[HISAX_MAX_CARDS] __devinitdata = { 0, };
-static int io1[HISAX_MAX_CARDS] __devinitdata = { 0, };
+static int io0[HISAX_MAX_CARDS] = { 0, };
+static int io1[HISAX_MAX_CARDS] = { 0, };
 #endif
-static int irq[HISAX_MAX_CARDS] __devinitdata = { 0, };
-static int mem[HISAX_MAX_CARDS] __devinitdata = { 0, };
+static int irq[HISAX_MAX_CARDS] = { 0, };
+static int mem[HISAX_MAX_CARDS] = { 0, };
 static char *id = HiSaxID;
 
 MODULE_DESCRIPTION("ISDN4Linux: Driver for passive ISDN cards");
@@ -1914,7 +1914,7 @@ static void EChannel_proc_rcv(struct hisax_d_if *d_if)
 #ifdef CONFIG_PCI
 #include <linux/pci.h>
 
-static struct pci_device_id hisax_pci_tbl[] __devinitdata __used = {
+static struct pci_device_id hisax_pci_tbl[] __used = {
 #ifdef CONFIG_HISAX_FRITZPCI
 	{PCI_VDEVICE(AVM,      PCI_DEVICE_ID_AVM_A1)			},
 #endif
diff --git a/drivers/isdn/hisax/diva.c b/drivers/isdn/hisax/diva.c
index 1360ec4..32827d4 100644
--- a/drivers/isdn/hisax/diva.c
+++ b/drivers/isdn/hisax/diva.c
@@ -1041,7 +1041,7 @@ static int setup_diva_isa(struct IsdnCard *card)
 #endif	/* CONFIG_ISA */
 
 #ifdef __ISAPNP__
-static struct isapnp_device_id diva_ids[] __devinitdata = {
+static struct isapnp_device_id diva_ids[] = {
 	{ ISAPNP_VENDOR('G', 'D', 'I'), ISAPNP_FUNCTION(0x51),
 	  ISAPNP_VENDOR('G', 'D', 'I'), ISAPNP_FUNCTION(0x51),
 	  (unsigned long) "Diva picola" },
@@ -1063,8 +1063,8 @@ static struct isapnp_device_id diva_ids[] __devinitdata = {
 	{ 0, }
 };
 
-static struct isapnp_device_id *ipid __devinitdata = &diva_ids[0];
-static struct pnp_card *pnp_c __devinitdata = NULL;
+static struct isapnp_device_id *ipid = &diva_ids[0];
+static struct pnp_card *pnp_c = NULL;
 
 static int setup_diva_isapnp(struct IsdnCard *card)
 {
@@ -1149,10 +1149,10 @@ static int setup_diva_isapnp(struct IsdnCard *card)
 #endif	/* ISAPNP */
 
 #ifdef CONFIG_PCI
-static struct pci_dev *dev_diva __devinitdata = NULL;
-static struct pci_dev *dev_diva_u __devinitdata = NULL;
-static struct pci_dev *dev_diva201 __devinitdata = NULL;
-static struct pci_dev *dev_diva202 __devinitdata = NULL;
+static struct pci_dev *dev_diva = NULL;
+static struct pci_dev *dev_diva_u = NULL;
+static struct pci_dev *dev_diva201 = NULL;
+static struct pci_dev *dev_diva202 = NULL;
 
 static int setup_diva_pci(struct IsdnCard *card)
 {
diff --git a/drivers/isdn/hisax/elsa.c b/drivers/isdn/hisax/elsa.c
index 97a51ba..eddb64e 100644
--- a/drivers/isdn/hisax/elsa.c
+++ b/drivers/isdn/hisax/elsa.c
@@ -902,7 +902,7 @@ setup_elsa_isa(struct IsdnCard *card)
 }
 
 #ifdef __ISAPNP__
-static struct isapnp_device_id elsa_ids[] __devinitdata = {
+static struct isapnp_device_id elsa_ids[] = {
 	{ ISAPNP_VENDOR('E', 'L', 'S'), ISAPNP_FUNCTION(0x0133),
 	  ISAPNP_VENDOR('E', 'L', 'S'), ISAPNP_FUNCTION(0x0133),
 	  (unsigned long) "Elsa QS1000" },
@@ -912,8 +912,8 @@ static struct isapnp_device_id elsa_ids[] __devinitdata = {
 	{ 0, }
 };
 
-static struct isapnp_device_id *ipid __devinitdata = &elsa_ids[0];
-static struct pnp_card *pnp_c __devinitdata = NULL;
+static struct isapnp_device_id *ipid = &elsa_ids[0];
+static struct pnp_card *pnp_c = NULL;
 #endif	/* __ISAPNP__ */
 
 static int
@@ -1027,8 +1027,8 @@ setup_elsa_pcmcia(struct IsdnCard *card)
 }
 
 #ifdef CONFIG_PCI
-static	struct pci_dev *dev_qs1000 __devinitdata = NULL;
-static	struct pci_dev *dev_qs3000 __devinitdata = NULL;
+static	struct pci_dev *dev_qs1000 = NULL;
+static	struct pci_dev *dev_qs3000 = NULL;
 
 static int
 setup_elsa_pci(struct IsdnCard *card)
diff --git a/drivers/isdn/hisax/enternow_pci.c b/drivers/isdn/hisax/enternow_pci.c
index 98696d2..2025b4b 100644
--- a/drivers/isdn/hisax/enternow_pci.c
+++ b/drivers/isdn/hisax/enternow_pci.c
@@ -384,7 +384,7 @@ static int en_cs_init_rest(struct IsdnCard *card,
 	return (1);
 }
 
-static struct pci_dev *dev_netjet __devinitdata = NULL;
+static struct pci_dev *dev_netjet = NULL;
 
 /* called by config.c */
 int
diff --git a/drivers/isdn/hisax/gazel.c b/drivers/isdn/hisax/gazel.c
index 23afa66..46717fd 100644
--- a/drivers/isdn/hisax/gazel.c
+++ b/drivers/isdn/hisax/gazel.c
@@ -532,7 +532,7 @@ setup_gazelisa(struct IsdnCard *card, struct IsdnCardState *cs)
 }
 
 #ifdef CONFIG_PCI
-static struct pci_dev *dev_tel __devinitdata = NULL;
+static struct pci_dev *dev_tel = NULL;
 
 static int
 setup_gazelpci(struct IsdnCardState *cs)
diff --git a/drivers/isdn/hisax/hfc_pci.c b/drivers/isdn/hisax/hfc_pci.c
index 8da93ae..3ccd724 100644
--- a/drivers/isdn/hisax/hfc_pci.c
+++ b/drivers/isdn/hisax/hfc_pci.c
@@ -1632,7 +1632,7 @@ hfcpci_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 
 
 /* this variable is used as card index when more than one cards are present */
-static struct pci_dev *dev_hfcpci __devinitdata = NULL;
+static struct pci_dev *dev_hfcpci = NULL;
 
 int
 setup_hfcpci(struct IsdnCard *card)
diff --git a/drivers/isdn/hisax/hfc_sx.c b/drivers/isdn/hisax/hfc_sx.c
index d7b95d0..9209d5a 100644
--- a/drivers/isdn/hisax/hfc_sx.c
+++ b/drivers/isdn/hisax/hfc_sx.c
@@ -1381,15 +1381,15 @@ hfcsx_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 }
 
 #ifdef __ISAPNP__
-static struct isapnp_device_id hfc_ids[] __devinitdata = {
+static struct isapnp_device_id hfc_ids[] = {
 	{ ISAPNP_VENDOR('T', 'A', 'G'), ISAPNP_FUNCTION(0x2620),
 	  ISAPNP_VENDOR('T', 'A', 'G'), ISAPNP_FUNCTION(0x2620),
 	  (unsigned long) "Teles 16.3c2" },
 	{ 0, }
 };
 
-static struct isapnp_device_id *ipid __devinitdata = &hfc_ids[0];
-static struct pnp_card *pnp_c __devinitdata = NULL;
+static struct isapnp_device_id *ipid = &hfc_ids[0];
+static struct pnp_card *pnp_c = NULL;
 #endif
 
 int
diff --git a/drivers/isdn/hisax/hfcscard.c b/drivers/isdn/hisax/hfcscard.c
index 5b228c0..f63035c 100644
--- a/drivers/isdn/hisax/hfcscard.c
+++ b/drivers/isdn/hisax/hfcscard.c
@@ -136,7 +136,7 @@ hfcs_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 }
 
 #ifdef __ISAPNP__
-static struct isapnp_device_id hfc_ids[] __devinitdata = {
+static struct isapnp_device_id hfc_ids[] = {
 	{ ISAPNP_VENDOR('A', 'N', 'X'), ISAPNP_FUNCTION(0x1114),
 	  ISAPNP_VENDOR('A', 'N', 'X'), ISAPNP_FUNCTION(0x1114),
 	  (unsigned long) "Acer P10" },
@@ -161,8 +161,8 @@ static struct isapnp_device_id hfc_ids[] __devinitdata = {
 	{ 0, }
 };
 
-static struct isapnp_device_id *ipid __devinitdata = &hfc_ids[0];
-static struct pnp_card *pnp_c __devinitdata = NULL;
+static struct isapnp_device_id *ipid = &hfc_ids[0];
+static struct pnp_card *pnp_c = NULL;
 #endif
 
 int
diff --git a/drivers/isdn/hisax/hisax_fcpcipnp.c b/drivers/isdn/hisax/hisax_fcpcipnp.c
index 9b37d22..cd06398 100644
--- a/drivers/isdn/hisax/hisax_fcpcipnp.c
+++ b/drivers/isdn/hisax/hisax_fcpcipnp.c
@@ -70,7 +70,7 @@ static struct pci_device_id fcpci_ids[] = {
 MODULE_DEVICE_TABLE(pci, fcpci_ids);
 
 #ifdef CONFIG_PNP
-static struct pnp_device_id fcpnp_ids[] __devinitdata = {
+static struct pnp_device_id fcpnp_ids[] = {
 	{
 		.id		= "AVM0900",
 		.driver_data	= (unsigned long) "Fritz!Card PnP",
diff --git a/drivers/isdn/hisax/isac.c b/drivers/isdn/hisax/isac.c
index 0e7cd86..696bfb8 100644
--- a/drivers/isdn/hisax/isac.c
+++ b/drivers/isdn/hisax/isac.c
@@ -24,7 +24,7 @@
 #define DBUSY_TIMER_VALUE 80
 #define ARCOFI_USE 1
 
-static char *ISACVer[] __devinitdata =
+static char *ISACVer[] =
 {"2086/2186 V1.1", "2085 B1", "2085 B2",
  "2085 V2.3"};
 
diff --git a/drivers/isdn/hisax/isurf.c b/drivers/isdn/hisax/isurf.c
index fb3b691..d0f987b 100644
--- a/drivers/isdn/hisax/isurf.c
+++ b/drivers/isdn/hisax/isurf.c
@@ -194,7 +194,7 @@ isurf_auxcmd(struct IsdnCardState *cs, isdn_ctrl *ic) {
 }
 
 #ifdef __ISAPNP__
-static struct pnp_card *pnp_c __devinitdata = NULL;
+static struct pnp_card *pnp_c = NULL;
 #endif
 
 int
diff --git a/drivers/isdn/hisax/ix1_micro.c b/drivers/isdn/hisax/ix1_micro.c
index 2683050..9c4d5f2 100644
--- a/drivers/isdn/hisax/ix1_micro.c
+++ b/drivers/isdn/hisax/ix1_micro.c
@@ -209,7 +209,7 @@ ix1_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 }
 
 #ifdef __ISAPNP__
-static struct isapnp_device_id itk_ids[] __devinitdata = {
+static struct isapnp_device_id itk_ids[] = {
 	{ ISAPNP_VENDOR('I', 'T', 'K'), ISAPNP_FUNCTION(0x25),
 	  ISAPNP_VENDOR('I', 'T', 'K'), ISAPNP_FUNCTION(0x25),
 	  (unsigned long) "ITK micro 2" },
@@ -219,8 +219,8 @@ static struct isapnp_device_id itk_ids[] __devinitdata = {
 	{ 0, }
 };
 
-static struct isapnp_device_id *ipid __devinitdata = &itk_ids[0];
-static struct pnp_card *pnp_c __devinitdata = NULL;
+static struct isapnp_device_id *ipid = &itk_ids[0];
+static struct pnp_card *pnp_c = NULL;
 #endif
 
 
diff --git a/drivers/isdn/hisax/niccy.c b/drivers/isdn/hisax/niccy.c
index 6ec3936..e4c33cf 100644
--- a/drivers/isdn/hisax/niccy.c
+++ b/drivers/isdn/hisax/niccy.c
@@ -223,7 +223,7 @@ static int niccy_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 }
 
 #ifdef __ISAPNP__
-static struct pnp_card *pnp_c __devinitdata = NULL;
+static struct pnp_card *pnp_c = NULL;
 #endif
 
 int setup_niccy(struct IsdnCard *card)
@@ -298,7 +298,7 @@ int setup_niccy(struct IsdnCard *card)
 		}
 	} else {
 #ifdef CONFIG_PCI
-		static struct pci_dev *niccy_dev __devinitdata;
+		static struct pci_dev *niccy_dev;
 
 		u_int pci_ioaddr;
 		cs->subtyp = 0;
diff --git a/drivers/isdn/hisax/nj_s.c b/drivers/isdn/hisax/nj_s.c
index 11e7e77..80517cd 100644
--- a/drivers/isdn/hisax/nj_s.c
+++ b/drivers/isdn/hisax/nj_s.c
@@ -256,7 +256,7 @@ static int njs_cs_init_rest(struct IsdnCard *card,
 	return (1);
 }
 
-static struct pci_dev *dev_netjet __devinitdata = NULL;
+static struct pci_dev *dev_netjet = NULL;
 
 int
 setup_netjet_s(struct IsdnCard *card)
diff --git a/drivers/isdn/hisax/nj_u.c b/drivers/isdn/hisax/nj_u.c
index 2dbc349..cde4e00 100644
--- a/drivers/isdn/hisax/nj_u.c
+++ b/drivers/isdn/hisax/nj_u.c
@@ -219,7 +219,7 @@ static int nju_cs_init_rest(struct IsdnCard *card,
 	return (1);
 }
 
-static struct pci_dev *dev_netjet __devinitdata = NULL;
+static struct pci_dev *dev_netjet = NULL;
 
 int
 setup_netjet_u(struct IsdnCard *card)
diff --git a/drivers/isdn/hisax/sedlbauer.c b/drivers/isdn/hisax/sedlbauer.c
index c0b06a0..e43684f 100644
--- a/drivers/isdn/hisax/sedlbauer.c
+++ b/drivers/isdn/hisax/sedlbauer.c
@@ -517,7 +517,7 @@ Sedl_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 }
 
 #ifdef __ISAPNP__
-static struct isapnp_device_id sedl_ids[] __devinitdata = {
+static struct isapnp_device_id sedl_ids[] = {
 	{ ISAPNP_VENDOR('S', 'A', 'G'), ISAPNP_FUNCTION(0x01),
 	  ISAPNP_VENDOR('S', 'A', 'G'), ISAPNP_FUNCTION(0x01),
 	  (unsigned long) "Speed win" },
@@ -527,8 +527,8 @@ static struct isapnp_device_id sedl_ids[] __devinitdata = {
 	{ 0, }
 };
 
-static struct isapnp_device_id *ipid __devinitdata = &sedl_ids[0];
-static struct pnp_card *pnp_c __devinitdata = NULL;
+static struct isapnp_device_id *ipid = &sedl_ids[0];
+static struct pnp_card *pnp_c = NULL;
 
 static int
 setup_sedlbauer_isapnp(struct IsdnCard *card, int *bytecnt)
@@ -599,7 +599,7 @@ setup_sedlbauer_isapnp(struct IsdnCard *card, int *bytecnt)
 #endif /* __ISAPNP__ */
 
 #ifdef CONFIG_PCI
-static struct pci_dev *dev_sedl __devinitdata = NULL;
+static struct pci_dev *dev_sedl = NULL;
 
 static int
 setup_sedlbauer_pci(struct IsdnCard *card)
diff --git a/drivers/isdn/hisax/teles3.c b/drivers/isdn/hisax/teles3.c
index d0d5cb7..9d82a27 100644
--- a/drivers/isdn/hisax/teles3.c
+++ b/drivers/isdn/hisax/teles3.c
@@ -253,7 +253,7 @@ Teles_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 
 #ifdef __ISAPNP__
 
-static struct isapnp_device_id teles_ids[] __devinitdata = {
+static struct isapnp_device_id teles_ids[] = {
 	{ ISAPNP_VENDOR('T', 'A', 'G'), ISAPNP_FUNCTION(0x2110),
 	  ISAPNP_VENDOR('T', 'A', 'G'), ISAPNP_FUNCTION(0x2110),
 	  (unsigned long) "Teles 16.3 PnP" },
@@ -266,8 +266,8 @@ static struct isapnp_device_id teles_ids[] __devinitdata = {
 	{ 0, }
 };
 
-static struct isapnp_device_id *ipid __devinitdata = &teles_ids[0];
-static struct pnp_card *pnp_c __devinitdata = NULL;
+static struct isapnp_device_id *ipid = &teles_ids[0];
+static struct pnp_card *pnp_c = NULL;
 #endif
 
 int
diff --git a/drivers/isdn/hisax/telespci.c b/drivers/isdn/hisax/telespci.c
index 87d0678..9ec163a 100644
--- a/drivers/isdn/hisax/telespci.c
+++ b/drivers/isdn/hisax/telespci.c
@@ -283,7 +283,7 @@ TelesPCI_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 	return (0);
 }
 
-static struct pci_dev *dev_tel __devinitdata = NULL;
+static struct pci_dev *dev_tel = NULL;
 
 int
 setup_telespci(struct IsdnCard *card)
diff --git a/drivers/isdn/hisax/w6692.c b/drivers/isdn/hisax/w6692.c
index 6b44081..8c74c3a 100644
--- a/drivers/isdn/hisax/w6692.c
+++ b/drivers/isdn/hisax/w6692.c
@@ -991,7 +991,7 @@ w6692_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 
 static int id_idx;
 
-static struct pci_dev *dev_w6692 __devinitdata = NULL;
+static struct pci_dev *dev_w6692 = NULL;
 
 int
 setup_w6692(struct IsdnCard *card)
-- 
1.8.0
