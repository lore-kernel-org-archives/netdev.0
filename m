From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 232/493] isdn: remove use of __devinit
Date: Mon, 19 Nov 2012 13:23:01 -0500
Message-ID: <1353349642-3677-232-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Karsten Keil <isdn@linux-pingi.de>,
	Armin Schindler <mac@melware.de>, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41412 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753975Ab2KSSdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:33:31 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devinit is no longer
needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Karsten Keil <isdn@linux-pingi.de> 
Cc: Armin Schindler <mac@melware.de> 
Cc: netdev@vger.kernel.org 
---
 drivers/isdn/hardware/avm/b1pci.c           |  2 +-
 drivers/isdn/hardware/avm/c4.c              |  2 +-
 drivers/isdn/hardware/avm/t1pci.c           |  2 +-
 drivers/isdn/hardware/eicon/divasmain.c     |  2 +-
 drivers/isdn/hardware/mISDN/avmfritz.c      |  4 ++--
 drivers/isdn/hardware/mISDN/hfcpci.c        |  2 +-
 drivers/isdn/hardware/mISDN/mISDNinfineon.c | 11 +++++------
 drivers/isdn/hardware/mISDN/netjet.c        |  4 ++--
 drivers/isdn/hardware/mISDN/speedfax.c      |  8 ++++----
 drivers/isdn/hardware/mISDN/w6692.c         |  2 +-
 drivers/isdn/hisax/amd7930_fn.c             |  2 +-
 drivers/isdn/hisax/asuscom.c                |  2 +-
 drivers/isdn/hisax/avm_a1.c                 |  2 +-
 drivers/isdn/hisax/avm_a1p.c                |  2 +-
 drivers/isdn/hisax/avm_pci.c                | 12 ++++++------
 drivers/isdn/hisax/avma1_cs.c               |  6 +++---
 drivers/isdn/hisax/bkm_a4t.c                |  6 +++---
 drivers/isdn/hisax/bkm_a8.c                 |  4 ++--
 drivers/isdn/hisax/config.c                 |  6 +++---
 drivers/isdn/hisax/diva.c                   | 16 ++++++++--------
 drivers/isdn/hisax/elsa.c                   | 14 +++++++-------
 drivers/isdn/hisax/elsa_cs.c                |  6 +++---
 drivers/isdn/hisax/enternow_pci.c           |  8 ++++----
 drivers/isdn/hisax/gazel.c                  |  6 +++---
 drivers/isdn/hisax/hfc4s8s_l1.c             |  4 ++--
 drivers/isdn/hisax/hfc_pci.c                |  2 +-
 drivers/isdn/hisax/hfc_sx.c                 |  2 +-
 drivers/isdn/hisax/hfcscard.c               |  2 +-
 drivers/isdn/hisax/hisax_fcpcipnp.c         |  9 ++++-----
 drivers/isdn/hisax/icc.c                    |  2 +-
 drivers/isdn/hisax/isac.c                   |  4 ++--
 drivers/isdn/hisax/isurf.c                  |  2 +-
 drivers/isdn/hisax/ix1_micro.c              |  2 +-
 drivers/isdn/hisax/mic.c                    |  2 +-
 drivers/isdn/hisax/niccy.c                  |  2 +-
 drivers/isdn/hisax/nj_s.c                   |  8 ++++----
 drivers/isdn/hisax/nj_u.c                   |  8 ++++----
 drivers/isdn/hisax/s0box.c                  |  2 +-
 drivers/isdn/hisax/saphir.c                 |  2 +-
 drivers/isdn/hisax/sedlbauer.c              | 10 +++++-----
 drivers/isdn/hisax/sedlbauer_cs.c           |  6 +++---
 drivers/isdn/hisax/sportster.c              |  4 ++--
 drivers/isdn/hisax/teleint.c                |  2 +-
 drivers/isdn/hisax/teles0.c                 |  2 +-
 drivers/isdn/hisax/teles3.c                 |  2 +-
 drivers/isdn/hisax/teles_cs.c               |  6 +++---
 drivers/isdn/hisax/telespci.c               |  2 +-
 drivers/isdn/hisax/w6692.c                  |  2 +-
 drivers/isdn/hysdn/hysdn_init.c             |  2 +-
 49 files changed, 110 insertions(+), 112 deletions(-)

diff --git a/drivers/isdn/hardware/avm/b1pci.c b/drivers/isdn/hardware/avm/b1pci.c
index cc1b671..cedf68d 100644
--- a/drivers/isdn/hardware/avm/b1pci.c
+++ b/drivers/isdn/hardware/avm/b1pci.c
@@ -299,7 +299,7 @@ static void b1pciv4_remove(struct pci_dev *pdev)
 
 #endif /* CONFIG_ISDN_DRV_AVMB1_B1PCIV4 */
 
-static int __devinit b1pci_pci_probe(struct pci_dev *pdev,
+static int b1pci_pci_probe(struct pci_dev *pdev,
 				     const struct pci_device_id *ent)
 {
 	struct capicardparams param;
diff --git a/drivers/isdn/hardware/avm/c4.c b/drivers/isdn/hardware/avm/c4.c
index 98f1881..9c3cf39 100644
--- a/drivers/isdn/hardware/avm/c4.c
+++ b/drivers/isdn/hardware/avm/c4.c
@@ -1249,7 +1249,7 @@ err:
 
 /* ------------------------------------------------------------- */
 
-static int __devinit c4_probe(struct pci_dev *dev,
+static int c4_probe(struct pci_dev *dev,
 			      const struct pci_device_id *ent)
 {
 	int nr = ent->driver_data;
diff --git a/drivers/isdn/hardware/avm/t1pci.c b/drivers/isdn/hardware/avm/t1pci.c
index cb9a304..be431ff 100644
--- a/drivers/isdn/hardware/avm/t1pci.c
+++ b/drivers/isdn/hardware/avm/t1pci.c
@@ -187,7 +187,7 @@ static char *t1pci_procinfo(struct capi_ctr *ctrl)
 
 /* ------------------------------------------------------------- */
 
-static int __devinit t1pci_probe(struct pci_dev *dev,
+static int t1pci_probe(struct pci_dev *dev,
 				 const struct pci_device_id *ent)
 {
 	struct capicardparams param;
diff --git a/drivers/isdn/hardware/eicon/divasmain.c b/drivers/isdn/hardware/eicon/divasmain.c
index 3dfe2bb..26454e2 100644
--- a/drivers/isdn/hardware/eicon/divasmain.c
+++ b/drivers/isdn/hardware/eicon/divasmain.c
@@ -688,7 +688,7 @@ static int __init divas_register_chrdev(void)
 /* --------------------------------------------------------------------------
    PCI driver section
    -------------------------------------------------------------------------- */
-static int __devinit divas_init_one(struct pci_dev *pdev,
+static int divas_init_one(struct pci_dev *pdev,
 				    const struct pci_device_id *ent)
 {
 	void *pdiva = NULL;
diff --git a/drivers/isdn/hardware/mISDN/avmfritz.c b/drivers/isdn/hardware/mISDN/avmfritz.c
index 922f29f..44f57dc 100644
--- a/drivers/isdn/hardware/mISDN/avmfritz.c
+++ b/drivers/isdn/hardware/mISDN/avmfritz.c
@@ -1034,7 +1034,7 @@ release_card(struct fritzcard *card)
 	AVM_cnt--;
 }
 
-static int __devinit
+static int
 setup_instance(struct fritzcard *card)
 {
 	int i, err;
@@ -1096,7 +1096,7 @@ error:
 	return err;
 }
 
-static int __devinit
+static int
 fritzpci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	int err = -ENOMEM;
diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardware/mISDN/hfcpci.c
index 580e629..ff06897 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -2215,7 +2215,7 @@ static struct pci_device_id hfc_ids[] =
 	{},
 };
 
-static int __devinit
+static int
 hfc_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	int		err = -ENOMEM;
diff --git a/drivers/isdn/hardware/mISDN/mISDNinfineon.c b/drivers/isdn/hardware/mISDN/mISDNinfineon.c
index a43fddf..6810521 100644
--- a/drivers/isdn/hardware/mISDN/mISDNinfineon.c
+++ b/drivers/isdn/hardware/mISDN/mISDNinfineon.c
@@ -603,7 +603,7 @@ inf_ctrl(struct inf_hw *hw, u32 cmd, u_long arg)
 	return ret;
 }
 
-static int __devinit
+static int
 init_irq(struct inf_hw *hw)
 {
 	int	ret, cnt = 3;
@@ -662,7 +662,7 @@ release_io(struct inf_hw *hw)
 	}
 }
 
-static int __devinit
+static int
 setup_io(struct inf_hw *hw)
 {
 	int err = 0;
@@ -896,7 +896,7 @@ release_card(struct inf_hw *card) {
 	inf_cnt--;
 }
 
-static int __devinit
+static int
 setup_instance(struct inf_hw *card)
 {
 	int err;
@@ -1060,8 +1060,7 @@ static const struct inf_cinfo inf_card_info[] = {
 	}
 };
 
-static const struct inf_cinfo * __devinit
-get_card_info(enum inf_types typ)
+static const struct inf_cinfo *get_card_info(enum inf_types typ)
 {
 	const struct inf_cinfo *ci = inf_card_info;
 
@@ -1073,7 +1072,7 @@ get_card_info(enum inf_types typ)
 	return NULL;
 }
 
-static int __devinit
+static int
 inf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	int err = -ENOMEM;
diff --git a/drivers/isdn/hardware/mISDN/netjet.c b/drivers/isdn/hardware/mISDN/netjet.c
index 2cfed9f..d464735 100644
--- a/drivers/isdn/hardware/mISDN/netjet.c
+++ b/drivers/isdn/hardware/mISDN/netjet.c
@@ -1008,7 +1008,7 @@ nj_setup(struct tiger_hw *card)
 }
 
 
-static int __devinit
+static int
 setup_instance(struct tiger_hw *card)
 {
 	int i, err;
@@ -1059,7 +1059,7 @@ error:
 	return err;
 }
 
-static int __devinit
+static int
 nj_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	int err = -ENOMEM;
diff --git a/drivers/isdn/hardware/mISDN/speedfax.c b/drivers/isdn/hardware/mISDN/speedfax.c
index 92c6059..c292507 100644
--- a/drivers/isdn/hardware/mISDN/speedfax.c
+++ b/drivers/isdn/hardware/mISDN/speedfax.c
@@ -282,7 +282,7 @@ sfax_dctrl(struct mISDNchannel *ch, u32 cmd, void *arg)
 	return err;
 }
 
-static int __devinit
+static int
 init_card(struct sfax_hw *sf)
 {
 	int	ret, cnt = 3;
@@ -321,7 +321,7 @@ init_card(struct sfax_hw *sf)
 }
 
 
-static int __devinit
+static int
 setup_speedfax(struct sfax_hw *sf)
 {
 	u_long flags;
@@ -371,7 +371,7 @@ release_card(struct sfax_hw *card) {
 	sfax_cnt--;
 }
 
-static int __devinit
+static int
 setup_instance(struct sfax_hw *card)
 {
 	const struct firmware *firmware;
@@ -451,7 +451,7 @@ error_fw:
 	return err;
 }
 
-static int __devinit
+static int
 sfaxpci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	int err = -ENOMEM;
diff --git a/drivers/isdn/hardware/mISDN/w6692.c b/drivers/isdn/hardware/mISDN/w6692.c
index 34be200..6033fa1 100644
--- a/drivers/isdn/hardware/mISDN/w6692.c
+++ b/drivers/isdn/hardware/mISDN/w6692.c
@@ -1355,7 +1355,7 @@ error_setup:
 	return err;
 }
 
-static int __devinit
+static int
 w6692_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	int		err = -ENOMEM;
diff --git a/drivers/isdn/hisax/amd7930_fn.c b/drivers/isdn/hisax/amd7930_fn.c
index 525471e..5215152 100644
--- a/drivers/isdn/hisax/amd7930_fn.c
+++ b/drivers/isdn/hisax/amd7930_fn.c
@@ -786,7 +786,7 @@ void Amd7930_init(struct IsdnCardState *cs)
 	}
 }
 
-void __devinit
+void
 setup_Amd7930(struct IsdnCardState *cs)
 {
 	INIT_WORK(&cs->tqueue, Amd7930_bh);
diff --git a/drivers/isdn/hisax/asuscom.c b/drivers/isdn/hisax/asuscom.c
index 2b74a40..e324be4 100644
--- a/drivers/isdn/hisax/asuscom.c
+++ b/drivers/isdn/hisax/asuscom.c
@@ -315,7 +315,7 @@ static struct isapnp_device_id *ipid __devinitdata = &asus_ids[0];
 static struct pnp_card *pnp_c __devinitdata = NULL;
 #endif
 
-int __devinit
+int
 setup_asuscom(struct IsdnCard *card)
 {
 	int bytecnt;
diff --git a/drivers/isdn/hisax/avm_a1.c b/drivers/isdn/hisax/avm_a1.c
index 402d489..915d166 100644
--- a/drivers/isdn/hisax/avm_a1.c
+++ b/drivers/isdn/hisax/avm_a1.c
@@ -177,7 +177,7 @@ AVM_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 	return (0);
 }
 
-int __devinit
+int
 setup_avm_a1(struct IsdnCard *card)
 {
 	u_char val;
diff --git a/drivers/isdn/hisax/avm_a1p.c b/drivers/isdn/hisax/avm_a1p.c
index 3934719..bc52d54 100644
--- a/drivers/isdn/hisax/avm_a1p.c
+++ b/drivers/isdn/hisax/avm_a1p.c
@@ -213,7 +213,7 @@ AVM_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 	return 0;
 }
 
-int __devinit setup_avm_a1_pcmcia(struct IsdnCard *card)
+int setup_avm_a1_pcmcia(struct IsdnCard *card)
 {
 	u_char model, vers;
 	struct IsdnCardState *cs = card->cs;
diff --git a/drivers/isdn/hisax/avm_pci.c b/drivers/isdn/hisax/avm_pci.c
index 979492d..2536aa4 100644
--- a/drivers/isdn/hisax/avm_pci.c
+++ b/drivers/isdn/hisax/avm_pci.c
@@ -718,7 +718,7 @@ AVM_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 	return (0);
 }
 
-static int __devinit avm_setup_rest(struct IsdnCardState *cs)
+static int avm_setup_rest(struct IsdnCardState *cs)
 {
 	u_int val, ver;
 
@@ -770,7 +770,7 @@ static int __devinit avm_setup_rest(struct IsdnCardState *cs)
 
 #ifndef __ISAPNP__
 
-static int __devinit avm_pnp_setup(struct IsdnCardState *cs)
+static int avm_pnp_setup(struct IsdnCardState *cs)
 {
 	return (1);	/* no-op: success */
 }
@@ -779,7 +779,7 @@ static int __devinit avm_pnp_setup(struct IsdnCardState *cs)
 
 static struct pnp_card *pnp_avm_c __devinitdata = NULL;
 
-static int __devinit avm_pnp_setup(struct IsdnCardState *cs)
+static int avm_pnp_setup(struct IsdnCardState *cs)
 {
 	struct pnp_dev *pnp_avm_d = NULL;
 
@@ -825,7 +825,7 @@ static int __devinit avm_pnp_setup(struct IsdnCardState *cs)
 
 #ifndef CONFIG_PCI
 
-static int __devinit avm_pci_setup(struct IsdnCardState *cs)
+static int avm_pci_setup(struct IsdnCardState *cs)
 {
 	return (1);	/* no-op: success */
 }
@@ -834,7 +834,7 @@ static int __devinit avm_pci_setup(struct IsdnCardState *cs)
 
 static struct pci_dev *dev_avm __devinitdata = NULL;
 
-static int __devinit avm_pci_setup(struct IsdnCardState *cs)
+static int avm_pci_setup(struct IsdnCardState *cs)
 {
 	if ((dev_avm = hisax_find_pci_device(PCI_VENDOR_ID_AVM,
 					     PCI_DEVICE_ID_AVM_A1, dev_avm))) {
@@ -867,7 +867,7 @@ static int __devinit avm_pci_setup(struct IsdnCardState *cs)
 
 #endif /* CONFIG_PCI */
 
-int __devinit
+int
 setup_avm_pcipnp(struct IsdnCard *card)
 {
 	struct IsdnCardState *cs = card->cs;
diff --git a/drivers/isdn/hisax/avma1_cs.c b/drivers/isdn/hisax/avma1_cs.c
index 7f5d8b6..ed534d3 100644
--- a/drivers/isdn/hisax/avma1_cs.c
+++ b/drivers/isdn/hisax/avma1_cs.c
@@ -38,11 +38,11 @@ module_param(isdnprot, int, 0);
 
 /*====================================================================*/
 
-static int avma1cs_config(struct pcmcia_device *link) __devinit;
+static int avma1cs_config(struct pcmcia_device *link);
 static void avma1cs_release(struct pcmcia_device *link);
 static void avma1cs_detach(struct pcmcia_device *p_dev) __devexit;
 
-static int __devinit avma1cs_probe(struct pcmcia_device *p_dev)
+static int avma1cs_probe(struct pcmcia_device *p_dev)
 {
 	dev_dbg(&p_dev->dev, "avma1cs_attach()\n");
 
@@ -72,7 +72,7 @@ static int avma1cs_configcheck(struct pcmcia_device *p_dev, void *priv_data)
 }
 
 
-static int __devinit avma1cs_config(struct pcmcia_device *link)
+static int avma1cs_config(struct pcmcia_device *link)
 {
 	int i = -1;
 	char devname[128];
diff --git a/drivers/isdn/hisax/bkm_a4t.c b/drivers/isdn/hisax/bkm_a4t.c
index f6bf9c6..f186b02 100644
--- a/drivers/isdn/hisax/bkm_a4t.c
+++ b/drivers/isdn/hisax/bkm_a4t.c
@@ -253,7 +253,7 @@ BKM_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 	return (0);
 }
 
-static int __devinit a4t_pci_probe(struct pci_dev *dev_a4t,
+static int a4t_pci_probe(struct pci_dev *dev_a4t,
 				   struct IsdnCardState *cs,
 				   u_int *found,
 				   u_int *pci_memaddr)
@@ -275,7 +275,7 @@ static int __devinit a4t_pci_probe(struct pci_dev *dev_a4t,
 	return (-1);			/* continue looping */
 }
 
-static int __devinit a4t_cs_init(struct IsdnCard *card,
+static int a4t_cs_init(struct IsdnCard *card,
 				 struct IsdnCardState *cs,
 				 u_int pci_memaddr)
 {
@@ -325,7 +325,7 @@ static int __devinit a4t_cs_init(struct IsdnCard *card,
 
 static struct pci_dev *dev_a4t __devinitdata = NULL;
 
-int __devinit
+int
 setup_bkm_a4t(struct IsdnCard *card)
 {
 	struct IsdnCardState *cs = card->cs;
diff --git a/drivers/isdn/hisax/bkm_a8.c b/drivers/isdn/hisax/bkm_a8.c
index c9c98f0..48c50cf 100644
--- a/drivers/isdn/hisax/bkm_a8.c
+++ b/drivers/isdn/hisax/bkm_a8.c
@@ -255,7 +255,7 @@ BKM_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 	return (0);
 }
 
-static int __devinit
+static int
 sct_alloc_io(u_int adr, u_int len)
 {
 	if (!request_region(adr, len, "scitel")) {
@@ -274,7 +274,7 @@ static u_char pci_bus __devinitdata = 0;
 static u_char pci_device_fn __devinitdata = 0;
 static u_char pci_irq __devinitdata = 0;
 
-int __devinit
+int
 setup_sct_quadro(struct IsdnCard *card)
 {
 	struct IsdnCardState *cs = card->cs;
diff --git a/drivers/isdn/hisax/config.c b/drivers/isdn/hisax/config.c
index 386f544..420e3be 100644
--- a/drivers/isdn/hisax/config.c
+++ b/drivers/isdn/hisax/config.c
@@ -852,7 +852,7 @@ static int init_card(struct IsdnCardState *cs)
 	return 3;
 }
 
-static int __devinit hisax_cs_setup_card(struct IsdnCard *card)
+static int hisax_cs_setup_card(struct IsdnCard *card)
 {
 	int ret;
 
@@ -1171,7 +1171,7 @@ outf_cs:
 	return 0;
 }
 
-/* Used from an exported function but calls __devinit functions.
+/* Used from an exported function but calls functions.
  * Tell modpost not to warn (__ref)
  */
 static int __ref checkcard(int cardnr, char *id, int *busy_flag,
@@ -1547,7 +1547,7 @@ static void __exit HiSax_exit(void)
 	printk(KERN_INFO "HiSax module removed\n");
 }
 
-int __devinit hisax_init_pcmcia(void *pcm_iob, int *busy_flag, struct IsdnCard *card)
+int hisax_init_pcmcia(void *pcm_iob, int *busy_flag, struct IsdnCard *card)
 {
 	u_char ids[16];
 	int ret = -1;
diff --git a/drivers/isdn/hisax/diva.c b/drivers/isdn/hisax/diva.c
index 62a2945..1360ec4 100644
--- a/drivers/isdn/hisax/diva.c
+++ b/drivers/isdn/hisax/diva.c
@@ -904,7 +904,7 @@ Diva_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 	return (0);
 }
 
-static int __devinit setup_diva_common(struct IsdnCardState *cs)
+static int setup_diva_common(struct IsdnCardState *cs)
 {
 	int bytecnt;
 	u_char val;
@@ -997,7 +997,7 @@ static int __devinit setup_diva_common(struct IsdnCardState *cs)
 
 #ifdef CONFIG_ISA
 
-static int __devinit setup_diva_isa(struct IsdnCard *card)
+static int setup_diva_isa(struct IsdnCard *card)
 {
 	struct IsdnCardState *cs = card->cs;
 	u_char val;
@@ -1033,7 +1033,7 @@ static int __devinit setup_diva_isa(struct IsdnCard *card)
 
 #else	/* if !CONFIG_ISA */
 
-static int __devinit setup_diva_isa(struct IsdnCard *card)
+static int setup_diva_isa(struct IsdnCard *card)
 {
 	return (-1);	/* card not found; continue search */
 }
@@ -1066,7 +1066,7 @@ static struct isapnp_device_id diva_ids[] __devinitdata = {
 static struct isapnp_device_id *ipid __devinitdata = &diva_ids[0];
 static struct pnp_card *pnp_c __devinitdata = NULL;
 
-static int __devinit setup_diva_isapnp(struct IsdnCard *card)
+static int setup_diva_isapnp(struct IsdnCard *card)
 {
 	struct IsdnCardState *cs = card->cs;
 	struct pnp_dev *pnp_d;
@@ -1141,7 +1141,7 @@ static int __devinit setup_diva_isapnp(struct IsdnCard *card)
 
 #else	/* if !ISAPNP */
 
-static int __devinit setup_diva_isapnp(struct IsdnCard *card)
+static int setup_diva_isapnp(struct IsdnCard *card)
 {
 	return (-1);	/* card not found; continue search */
 }
@@ -1154,7 +1154,7 @@ static struct pci_dev *dev_diva_u __devinitdata = NULL;
 static struct pci_dev *dev_diva201 __devinitdata = NULL;
 static struct pci_dev *dev_diva202 __devinitdata = NULL;
 
-static int __devinit setup_diva_pci(struct IsdnCard *card)
+static int setup_diva_pci(struct IsdnCard *card)
 {
 	struct IsdnCardState *cs = card->cs;
 
@@ -1231,14 +1231,14 @@ static int __devinit setup_diva_pci(struct IsdnCard *card)
 
 #else	/* if !CONFIG_PCI */
 
-static int __devinit setup_diva_pci(struct IsdnCard *card)
+static int setup_diva_pci(struct IsdnCard *card)
 {
 	return (-1);	/* card not found; continue search */
 }
 
 #endif	/* CONFIG_PCI */
 
-int __devinit
+int
 setup_diva(struct IsdnCard *card)
 {
 	int rc, have_card = 0;
diff --git a/drivers/isdn/hisax/elsa.c b/drivers/isdn/hisax/elsa.c
index 64ba26a..97a51ba 100644
--- a/drivers/isdn/hisax/elsa.c
+++ b/drivers/isdn/hisax/elsa.c
@@ -831,7 +831,7 @@ probe_elsa(struct IsdnCardState *cs)
 	return (CARD_portlist[i]);
 }
 
-static int __devinit
+static int
 setup_elsa_isa(struct IsdnCard *card)
 {
 	struct IsdnCardState *cs = card->cs;
@@ -916,7 +916,7 @@ static struct isapnp_device_id *ipid __devinitdata = &elsa_ids[0];
 static struct pnp_card *pnp_c __devinitdata = NULL;
 #endif	/* __ISAPNP__ */
 
-static int __devinit
+static int
 setup_elsa_isapnp(struct IsdnCard *card)
 {
 	struct IsdnCardState *cs = card->cs;
@@ -994,7 +994,7 @@ setup_elsa_isapnp(struct IsdnCard *card)
 	return (1);
 }
 
-static void __devinit
+static void
 setup_elsa_pcmcia(struct IsdnCard *card)
 {
 	struct IsdnCardState *cs = card->cs;
@@ -1030,7 +1030,7 @@ setup_elsa_pcmcia(struct IsdnCard *card)
 static	struct pci_dev *dev_qs1000 __devinitdata = NULL;
 static	struct pci_dev *dev_qs3000 __devinitdata = NULL;
 
-static int __devinit
+static int
 setup_elsa_pci(struct IsdnCard *card)
 {
 	struct IsdnCardState *cs = card->cs;
@@ -1089,14 +1089,14 @@ setup_elsa_pci(struct IsdnCard *card)
 
 #else
 
-static int __devinit
+static int
 setup_elsa_pci(struct IsdnCard *card)
 {
 	return (1);
 }
 #endif /* CONFIG_PCI */
 
-static int __devinit
+static int
 setup_elsa_common(struct IsdnCard *card)
 {
 	struct IsdnCardState *cs = card->cs;
@@ -1212,7 +1212,7 @@ setup_elsa_common(struct IsdnCard *card)
 	return (1);
 }
 
-int __devinit
+int
 setup_elsa(struct IsdnCard *card)
 {
 	int rc;
diff --git a/drivers/isdn/hisax/elsa_cs.c b/drivers/isdn/hisax/elsa_cs.c
index 231ec71..8366a37 100644
--- a/drivers/isdn/hisax/elsa_cs.c
+++ b/drivers/isdn/hisax/elsa_cs.c
@@ -62,7 +62,7 @@ MODULE_LICENSE("Dual MPL/GPL");
 static int protocol = 2;        /* EURO-ISDN Default */
 module_param(protocol, int, 0);
 
-static int elsa_cs_config(struct pcmcia_device *link) __devinit;
+static int elsa_cs_config(struct pcmcia_device *link);
 static void elsa_cs_release(struct pcmcia_device *link);
 static void elsa_cs_detach(struct pcmcia_device *p_dev) __devexit;
 
@@ -72,7 +72,7 @@ typedef struct local_info_t {
 	int			cardnr;
 } local_info_t;
 
-static int __devinit elsa_cs_probe(struct pcmcia_device *link)
+static int elsa_cs_probe(struct pcmcia_device *link)
 {
 	local_info_t *local;
 
@@ -126,7 +126,7 @@ static int elsa_cs_configcheck(struct pcmcia_device *p_dev, void *priv_data)
 	return -ENODEV;
 }
 
-static int __devinit elsa_cs_config(struct pcmcia_device *link)
+static int elsa_cs_config(struct pcmcia_device *link)
 {
 	int i;
 	IsdnCard_t icard;
diff --git a/drivers/isdn/hisax/enternow_pci.c b/drivers/isdn/hisax/enternow_pci.c
index b1e38b5..98696d2 100644
--- a/drivers/isdn/hisax/enternow_pci.c
+++ b/drivers/isdn/hisax/enternow_pci.c
@@ -300,7 +300,7 @@ enpci_interrupt(int intno, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-static int __devinit en_pci_probe(struct pci_dev *dev_netjet,
+static int en_pci_probe(struct pci_dev *dev_netjet,
 				  struct IsdnCardState *cs)
 {
 	if (pci_enable_device(dev_netjet))
@@ -326,7 +326,7 @@ static int __devinit en_pci_probe(struct pci_dev *dev_netjet,
 	return (1);
 }
 
-static void __devinit en_cs_init(struct IsdnCard *card,
+static void en_cs_init(struct IsdnCard *card,
 				 struct IsdnCardState *cs)
 {
 	cs->hw.njet.auxa = cs->hw.njet.base + NETJET_AUXDATA;
@@ -350,7 +350,7 @@ static void __devinit en_cs_init(struct IsdnCard *card,
 	outb(cs->hw.njet.auxd, cs->hw.njet.auxa);
 }
 
-static int __devinit en_cs_init_rest(struct IsdnCard *card,
+static int en_cs_init_rest(struct IsdnCard *card,
 				     struct IsdnCardState *cs)
 {
 	const int bytecnt = 256;
@@ -387,7 +387,7 @@ static int __devinit en_cs_init_rest(struct IsdnCard *card,
 static struct pci_dev *dev_netjet __devinitdata = NULL;
 
 /* called by config.c */
-int __devinit
+int
 setup_enternow_pci(struct IsdnCard *card)
 {
 	int ret;
diff --git a/drivers/isdn/hisax/gazel.c b/drivers/isdn/hisax/gazel.c
index 4fef775..23afa66 100644
--- a/drivers/isdn/hisax/gazel.c
+++ b/drivers/isdn/hisax/gazel.c
@@ -483,7 +483,7 @@ error:
 	return 1;
 }
 
-static int __devinit
+static int
 setup_gazelisa(struct IsdnCard *card, struct IsdnCardState *cs)
 {
 	printk(KERN_INFO "Gazel: ISA PnP card automatic recognition\n");
@@ -534,7 +534,7 @@ setup_gazelisa(struct IsdnCard *card, struct IsdnCardState *cs)
 #ifdef CONFIG_PCI
 static struct pci_dev *dev_tel __devinitdata = NULL;
 
-static int __devinit
+static int
 setup_gazelpci(struct IsdnCardState *cs)
 {
 	u_int pci_ioaddr0 = 0, pci_ioaddr1 = 0;
@@ -622,7 +622,7 @@ setup_gazelpci(struct IsdnCardState *cs)
 }
 #endif /* CONFIG_PCI */
 
-int __devinit
+int
 setup_gazel(struct IsdnCard *card)
 {
 	struct IsdnCardState *cs = card->cs;
diff --git a/drivers/isdn/hisax/hfc4s8s_l1.c b/drivers/isdn/hisax/hfc4s8s_l1.c
index e85b612..ef7c07b 100644
--- a/drivers/isdn/hisax/hfc4s8s_l1.c
+++ b/drivers/isdn/hisax/hfc4s8s_l1.c
@@ -1497,7 +1497,7 @@ enable_pci_ports(hfc4s8s_hw *hw)
 /* initialise the HFC-4s/8s hardware */
 /* return 0 on success.              */
 /*************************************/
-static int __devinit
+static int
 setup_instance(hfc4s8s_hw *hw)
 {
 	int err = -EIO;
@@ -1585,7 +1585,7 @@ out:
 /*****************************************/
 /* PCI hotplug interface: probe new card */
 /*****************************************/
-static int __devinit
+static int
 hfc4s8s_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	int err = -ENOMEM;
diff --git a/drivers/isdn/hisax/hfc_pci.c b/drivers/isdn/hisax/hfc_pci.c
index f60d4be..8da93ae 100644
--- a/drivers/isdn/hisax/hfc_pci.c
+++ b/drivers/isdn/hisax/hfc_pci.c
@@ -1634,7 +1634,7 @@ hfcpci_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 /* this variable is used as card index when more than one cards are present */
 static struct pci_dev *dev_hfcpci __devinitdata = NULL;
 
-int __devinit
+int
 setup_hfcpci(struct IsdnCard *card)
 {
 	u_long flags;
diff --git a/drivers/isdn/hisax/hfc_sx.c b/drivers/isdn/hisax/hfc_sx.c
index 4ec279c..d7b95d0 100644
--- a/drivers/isdn/hisax/hfc_sx.c
+++ b/drivers/isdn/hisax/hfc_sx.c
@@ -1392,7 +1392,7 @@ static struct isapnp_device_id *ipid __devinitdata = &hfc_ids[0];
 static struct pnp_card *pnp_c __devinitdata = NULL;
 #endif
 
-int __devinit
+int
 setup_hfcsx(struct IsdnCard *card)
 {
 	struct IsdnCardState *cs = card->cs;
diff --git a/drivers/isdn/hisax/hfcscard.c b/drivers/isdn/hisax/hfcscard.c
index a5f048b..5b228c0 100644
--- a/drivers/isdn/hisax/hfcscard.c
+++ b/drivers/isdn/hisax/hfcscard.c
@@ -165,7 +165,7 @@ static struct isapnp_device_id *ipid __devinitdata = &hfc_ids[0];
 static struct pnp_card *pnp_c __devinitdata = NULL;
 #endif
 
-int __devinit
+int
 setup_hfcs(struct IsdnCard *card)
 {
 	struct IsdnCardState *cs = card->cs;
diff --git a/drivers/isdn/hisax/hisax_fcpcipnp.c b/drivers/isdn/hisax/hisax_fcpcipnp.c
index 3d063d1..9b37d22 100644
--- a/drivers/isdn/hisax/hisax_fcpcipnp.c
+++ b/drivers/isdn/hisax/hisax_fcpcipnp.c
@@ -712,7 +712,7 @@ static inline void fcpci_init(struct fritz_adapter *adapter)
 
 // ----------------------------------------------------------------------
 
-static int __devinit fcpcipnp_setup(struct fritz_adapter *adapter)
+static int fcpcipnp_setup(struct fritz_adapter *adapter)
 {
 	u32 val = 0;
 	int retval;
@@ -836,8 +836,7 @@ static void __devexit fcpcipnp_release(struct fritz_adapter *adapter)
 
 // ----------------------------------------------------------------------
 
-static struct fritz_adapter * __devinit
-new_adapter(void)
+static struct fritz_adapter *new_adapter(void)
 {
 	struct fritz_adapter *adapter;
 	struct hisax_b_if *b_if[2];
@@ -876,7 +875,7 @@ static void delete_adapter(struct fritz_adapter *adapter)
 	kfree(adapter);
 }
 
-static int __devinit fcpci_probe(struct pci_dev *pdev,
+static int fcpci_probe(struct pci_dev *pdev,
 				 const struct pci_device_id *ent)
 {
 	struct fritz_adapter *adapter;
@@ -917,7 +916,7 @@ err:
 }
 
 #ifdef CONFIG_PNP
-static int __devinit fcpnp_probe(struct pnp_dev *pdev, const struct pnp_device_id *dev_id)
+static int fcpnp_probe(struct pnp_dev *pdev, const struct pnp_device_id *dev_id)
 {
 	struct fritz_adapter *adapter;
 	int retval;
diff --git a/drivers/isdn/hisax/icc.c b/drivers/isdn/hisax/icc.c
index 7be762b..cb8897a 100644
--- a/drivers/isdn/hisax/icc.c
+++ b/drivers/isdn/hisax/icc.c
@@ -673,7 +673,7 @@ clear_pending_icc_ints(struct IsdnCardState *cs)
 	cs->writeisac(cs, ICC_MASK, 0xFF);
 }
 
-void __devinit
+void
 setup_icc(struct IsdnCardState *cs)
 {
 	INIT_WORK(&cs->tqueue, icc_bh);
diff --git a/drivers/isdn/hisax/isac.c b/drivers/isdn/hisax/isac.c
index bcd70a3..0e7cd86 100644
--- a/drivers/isdn/hisax/isac.c
+++ b/drivers/isdn/hisax/isac.c
@@ -28,7 +28,7 @@ static char *ISACVer[] __devinitdata =
 {"2086/2186 V1.1", "2085 B1", "2085 B2",
  "2085 V2.3"};
 
-void __devinit ISACVersion(struct IsdnCardState *cs, char *s)
+void ISACVersion(struct IsdnCardState *cs, char *s)
 {
 	int val;
 
@@ -669,7 +669,7 @@ void clear_pending_isac_ints(struct IsdnCardState *cs)
 	cs->writeisac(cs, ISAC_MASK, 0xFF);
 }
 
-void __devinit
+void
 setup_isac(struct IsdnCardState *cs)
 {
 	INIT_WORK(&cs->tqueue, isac_bh);
diff --git a/drivers/isdn/hisax/isurf.c b/drivers/isdn/hisax/isurf.c
index c1530fe..fb3b691 100644
--- a/drivers/isdn/hisax/isurf.c
+++ b/drivers/isdn/hisax/isurf.c
@@ -197,7 +197,7 @@ isurf_auxcmd(struct IsdnCardState *cs, isdn_ctrl *ic) {
 static struct pnp_card *pnp_c __devinitdata = NULL;
 #endif
 
-int __devinit
+int
 setup_isurf(struct IsdnCard *card)
 {
 	int ver;
diff --git a/drivers/isdn/hisax/ix1_micro.c b/drivers/isdn/hisax/ix1_micro.c
index 5f299f8..2683050 100644
--- a/drivers/isdn/hisax/ix1_micro.c
+++ b/drivers/isdn/hisax/ix1_micro.c
@@ -224,7 +224,7 @@ static struct pnp_card *pnp_c __devinitdata = NULL;
 #endif
 
 
-int __devinit
+int
 setup_ix1micro(struct IsdnCard *card)
 {
 	struct IsdnCardState *cs = card->cs;
diff --git a/drivers/isdn/hisax/mic.c b/drivers/isdn/hisax/mic.c
index 08a6b7f..1a62df5 100644
--- a/drivers/isdn/hisax/mic.c
+++ b/drivers/isdn/hisax/mic.c
@@ -187,7 +187,7 @@ mic_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 	return (0);
 }
 
-int __devinit
+int
 setup_mic(struct IsdnCard *card)
 {
 	int bytecnt;
diff --git a/drivers/isdn/hisax/niccy.c b/drivers/isdn/hisax/niccy.c
index 6569e03..6ec3936 100644
--- a/drivers/isdn/hisax/niccy.c
+++ b/drivers/isdn/hisax/niccy.c
@@ -226,7 +226,7 @@ static int niccy_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 static struct pnp_card *pnp_c __devinitdata = NULL;
 #endif
 
-int __devinit setup_niccy(struct IsdnCard *card)
+int setup_niccy(struct IsdnCard *card)
 {
 	struct IsdnCardState *cs = card->cs;
 	char tmp[64];
diff --git a/drivers/isdn/hisax/nj_s.c b/drivers/isdn/hisax/nj_s.c
index f36ff69..11e7e77 100644
--- a/drivers/isdn/hisax/nj_s.c
+++ b/drivers/isdn/hisax/nj_s.c
@@ -148,7 +148,7 @@ NETjet_S_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 	return (0);
 }
 
-static int __devinit njs_pci_probe(struct pci_dev *dev_netjet,
+static int njs_pci_probe(struct pci_dev *dev_netjet,
 				   struct IsdnCardState *cs)
 {
 	u32 cfg;
@@ -187,7 +187,7 @@ static int __devinit njs_pci_probe(struct pci_dev *dev_netjet,
 	return (1);
 }
 
-static int __devinit njs_cs_init(struct IsdnCard *card,
+static int njs_cs_init(struct IsdnCard *card,
 				 struct IsdnCardState *cs)
 {
 
@@ -225,7 +225,7 @@ static int __devinit njs_cs_init(struct IsdnCard *card,
 	return 1;			/* end loop */
 }
 
-static int __devinit njs_cs_init_rest(struct IsdnCard *card,
+static int njs_cs_init_rest(struct IsdnCard *card,
 				      struct IsdnCardState *cs)
 {
 	const int bytecnt = 256;
@@ -258,7 +258,7 @@ static int __devinit njs_cs_init_rest(struct IsdnCard *card,
 
 static struct pci_dev *dev_netjet __devinitdata = NULL;
 
-int __devinit
+int
 setup_netjet_s(struct IsdnCard *card)
 {
 	int ret;
diff --git a/drivers/isdn/hisax/nj_u.c b/drivers/isdn/hisax/nj_u.c
index 333484a..2dbc349 100644
--- a/drivers/isdn/hisax/nj_u.c
+++ b/drivers/isdn/hisax/nj_u.c
@@ -128,7 +128,7 @@ NETjet_U_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 	return (0);
 }
 
-static int __devinit nju_pci_probe(struct pci_dev *dev_netjet,
+static int nju_pci_probe(struct pci_dev *dev_netjet,
 				   struct IsdnCardState *cs)
 {
 	if (pci_enable_device(dev_netjet))
@@ -148,7 +148,7 @@ static int __devinit nju_pci_probe(struct pci_dev *dev_netjet,
 	return (1);
 }
 
-static int __devinit nju_cs_init(struct IsdnCard *card,
+static int nju_cs_init(struct IsdnCard *card,
 				 struct IsdnCardState *cs)
 {
 	cs->hw.njet.auxa = cs->hw.njet.base + NETJET_AUXDATA;
@@ -187,7 +187,7 @@ static int __devinit nju_cs_init(struct IsdnCard *card,
 	return 1;			/* end loop */
 }
 
-static int __devinit nju_cs_init_rest(struct IsdnCard *card,
+static int nju_cs_init_rest(struct IsdnCard *card,
 				      struct IsdnCardState *cs)
 {
 	const int bytecnt = 256;
@@ -221,7 +221,7 @@ static int __devinit nju_cs_init_rest(struct IsdnCard *card,
 
 static struct pci_dev *dev_netjet __devinitdata = NULL;
 
-int __devinit
+int
 setup_netjet_u(struct IsdnCard *card)
 {
 	int ret;
diff --git a/drivers/isdn/hisax/s0box.c b/drivers/isdn/hisax/s0box.c
index 383c4e7..15ec277 100644
--- a/drivers/isdn/hisax/s0box.c
+++ b/drivers/isdn/hisax/s0box.c
@@ -210,7 +210,7 @@ S0Box_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 	return (0);
 }
 
-int __devinit
+int
 setup_s0box(struct IsdnCard *card)
 {
 	struct IsdnCardState *cs = card->cs;
diff --git a/drivers/isdn/hisax/saphir.c b/drivers/isdn/hisax/saphir.c
index 75dcae6..fbf8b745 100644
--- a/drivers/isdn/hisax/saphir.c
+++ b/drivers/isdn/hisax/saphir.c
@@ -240,7 +240,7 @@ saphir_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 }
 
 
-int __devinit
+int
 setup_saphir(struct IsdnCard *card)
 {
 	struct IsdnCardState *cs = card->cs;
diff --git a/drivers/isdn/hisax/sedlbauer.c b/drivers/isdn/hisax/sedlbauer.c
index 1ee531b..c0b06a0 100644
--- a/drivers/isdn/hisax/sedlbauer.c
+++ b/drivers/isdn/hisax/sedlbauer.c
@@ -530,7 +530,7 @@ static struct isapnp_device_id sedl_ids[] __devinitdata = {
 static struct isapnp_device_id *ipid __devinitdata = &sedl_ids[0];
 static struct pnp_card *pnp_c __devinitdata = NULL;
 
-static int __devinit
+static int
 setup_sedlbauer_isapnp(struct IsdnCard *card, int *bytecnt)
 {
 	struct IsdnCardState *cs = card->cs;
@@ -591,7 +591,7 @@ setup_sedlbauer_isapnp(struct IsdnCard *card, int *bytecnt)
 }
 #else
 
-static int __devinit
+static int
 setup_sedlbauer_isapnp(struct IsdnCard *card, int *bytecnt)
 {
 	return -1;
@@ -601,7 +601,7 @@ setup_sedlbauer_isapnp(struct IsdnCard *card, int *bytecnt)
 #ifdef CONFIG_PCI
 static struct pci_dev *dev_sedl __devinitdata = NULL;
 
-static int __devinit
+static int
 setup_sedlbauer_pci(struct IsdnCard *card)
 {
 	struct IsdnCardState *cs = card->cs;
@@ -667,7 +667,7 @@ setup_sedlbauer_pci(struct IsdnCard *card)
 
 #else
 
-static int __devinit
+static int
 setup_sedlbauer_pci(struct IsdnCard *card)
 {
 	return (1);
@@ -675,7 +675,7 @@ setup_sedlbauer_pci(struct IsdnCard *card)
 
 #endif /* CONFIG_PCI */
 
-int __devinit
+int
 setup_sedlbauer(struct IsdnCard *card)
 {
 	int bytecnt = 8, ver, val, rc;
diff --git a/drivers/isdn/hisax/sedlbauer_cs.c b/drivers/isdn/hisax/sedlbauer_cs.c
index 42abb24..ac3f9fd 100644
--- a/drivers/isdn/hisax/sedlbauer_cs.c
+++ b/drivers/isdn/hisax/sedlbauer_cs.c
@@ -62,7 +62,7 @@ MODULE_LICENSE("Dual MPL/GPL");
 static int protocol = 2;        /* EURO-ISDN Default */
 module_param(protocol, int, 0);
 
-static int sedlbauer_config(struct pcmcia_device *link) __devinit;
+static int sedlbauer_config(struct pcmcia_device *link);
 static void sedlbauer_release(struct pcmcia_device *link);
 
 static void sedlbauer_detach(struct pcmcia_device *p_dev) __devexit;
@@ -73,7 +73,7 @@ typedef struct local_info_t {
 	int			cardnr;
 } local_info_t;
 
-static int __devinit sedlbauer_probe(struct pcmcia_device *link)
+static int sedlbauer_probe(struct pcmcia_device *link)
 {
 	local_info_t *local;
 
@@ -110,7 +110,7 @@ static int sedlbauer_config_check(struct pcmcia_device *p_dev, void *priv_data)
 	return pcmcia_request_io(p_dev);
 }
 
-static int __devinit sedlbauer_config(struct pcmcia_device *link)
+static int sedlbauer_config(struct pcmcia_device *link)
 {
 	int ret;
 	IsdnCard_t  icard;
diff --git a/drivers/isdn/hisax/sportster.c b/drivers/isdn/hisax/sportster.c
index 1267298..c8ce100 100644
--- a/drivers/isdn/hisax/sportster.c
+++ b/drivers/isdn/hisax/sportster.c
@@ -183,7 +183,7 @@ Sportster_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 	return (0);
 }
 
-static int __devinit
+static int
 get_io_range(struct IsdnCardState *cs)
 {
 	int i, j, adr;
@@ -208,7 +208,7 @@ get_io_range(struct IsdnCardState *cs)
 	}
 }
 
-int __devinit
+int
 setup_sportster(struct IsdnCard *card)
 {
 	struct IsdnCardState *cs = card->cs;
diff --git a/drivers/isdn/hisax/teleint.c b/drivers/isdn/hisax/teleint.c
index fa329e2..e8f12ab 100644
--- a/drivers/isdn/hisax/teleint.c
+++ b/drivers/isdn/hisax/teleint.c
@@ -259,7 +259,7 @@ TeleInt_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 	return (0);
 }
 
-int __devinit
+int
 setup_TeleInt(struct IsdnCard *card)
 {
 	struct IsdnCardState *cs = card->cs;
diff --git a/drivers/isdn/hisax/teles0.c b/drivers/isdn/hisax/teles0.c
index 49b4a26..277dda5 100644
--- a/drivers/isdn/hisax/teles0.c
+++ b/drivers/isdn/hisax/teles0.c
@@ -263,7 +263,7 @@ Teles_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 	return (0);
 }
 
-int __devinit
+int
 setup_teles0(struct IsdnCard *card)
 {
 	u_char val;
diff --git a/drivers/isdn/hisax/teles3.c b/drivers/isdn/hisax/teles3.c
index 220b919..d0d5cb7 100644
--- a/drivers/isdn/hisax/teles3.c
+++ b/drivers/isdn/hisax/teles3.c
@@ -270,7 +270,7 @@ static struct isapnp_device_id *ipid __devinitdata = &teles_ids[0];
 static struct pnp_card *pnp_c __devinitdata = NULL;
 #endif
 
-int __devinit
+int
 setup_teles3(struct IsdnCard *card)
 {
 	u_char val;
diff --git a/drivers/isdn/hisax/teles_cs.c b/drivers/isdn/hisax/teles_cs.c
index a36fa04..685ecab 100644
--- a/drivers/isdn/hisax/teles_cs.c
+++ b/drivers/isdn/hisax/teles_cs.c
@@ -43,7 +43,7 @@ MODULE_LICENSE("GPL");
 static int protocol = 2;        /* EURO-ISDN Default */
 module_param(protocol, int, 0);
 
-static int teles_cs_config(struct pcmcia_device *link) __devinit;
+static int teles_cs_config(struct pcmcia_device *link);
 static void teles_cs_release(struct pcmcia_device *link);
 static void teles_detach(struct pcmcia_device *p_dev) __devexit;
 
@@ -53,7 +53,7 @@ typedef struct local_info_t {
 	int			cardnr;
 } local_info_t;
 
-static int __devinit teles_probe(struct pcmcia_device *link)
+static int teles_probe(struct pcmcia_device *link)
 {
 	local_info_t *local;
 
@@ -108,7 +108,7 @@ static int teles_cs_configcheck(struct pcmcia_device *p_dev, void *priv_data)
 	return -ENODEV;
 }
 
-static int __devinit teles_cs_config(struct pcmcia_device *link)
+static int teles_cs_config(struct pcmcia_device *link)
 {
 	int i;
 	IsdnCard_t icard;
diff --git a/drivers/isdn/hisax/telespci.c b/drivers/isdn/hisax/telespci.c
index 9c002c9..87d0678 100644
--- a/drivers/isdn/hisax/telespci.c
+++ b/drivers/isdn/hisax/telespci.c
@@ -285,7 +285,7 @@ TelesPCI_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 
 static struct pci_dev *dev_tel __devinitdata = NULL;
 
-int __devinit
+int
 setup_telespci(struct IsdnCard *card)
 {
 	struct IsdnCardState *cs = card->cs;
diff --git a/drivers/isdn/hisax/w6692.c b/drivers/isdn/hisax/w6692.c
index 0f0d094..6b44081 100644
--- a/drivers/isdn/hisax/w6692.c
+++ b/drivers/isdn/hisax/w6692.c
@@ -993,7 +993,7 @@ static int id_idx;
 
 static struct pci_dev *dev_w6692 __devinitdata = NULL;
 
-int __devinit
+int
 setup_w6692(struct IsdnCard *card)
 {
 	struct IsdnCardState *cs = card->cs;
diff --git a/drivers/isdn/hysdn/hysdn_init.c b/drivers/isdn/hysdn/hysdn_init.c
index c103c28..f2603aa 100644
--- a/drivers/isdn/hysdn/hysdn_init.c
+++ b/drivers/isdn/hysdn/hysdn_init.c
@@ -56,7 +56,7 @@ static hysdn_card *card_last = NULL;	/* pointer to first card */
 /* is assumed and the module will not be kept in memory.                    */
 /****************************************************************************/
 
-static int __devinit hysdn_pci_init_one(struct pci_dev *akt_pcidev,
+static int hysdn_pci_init_one(struct pci_dev *akt_pcidev,
 					const struct pci_device_id *ent)
 {
 	hysdn_card *card;
-- 
1.8.0
