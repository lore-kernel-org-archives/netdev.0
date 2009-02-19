From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCHv2 01/11]Replace all DMA_64BIT_MASK macro with DMA_BIT_MASK(64)
Date: Thu, 19 Feb 2009 17:36:36 +0800
Message-ID: <499D2824.1000000@cn.fujitsu.com>
References: <499CFDC8.1070600@cn.fujitsu.com> <499D0221.9090407@cn.fujitsu.com> <20090219081403.GA5400@elte.hu> <499D1ED9.4040005@cn.fujitsu.com> <499D2728.1080208@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Borislav Petkov <petkovbb@googlemail.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54647 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751989AbZBSJfL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 04:35:11 -0500
In-Reply-To: <499D2728.1080208@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace all DMA_64BIT_MASK macro with DMA_BIT_MASK(64)

Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

---
 arch/arm/mach-iop13xx/setup.c               |    8 ++++----
 arch/arm/mach-iop13xx/tpmi.c                |   10 +++++-----
 arch/arm/mach-kirkwood/common.c             |    8 ++++----
 arch/arm/mach-orion5x/common.c              |    4 ++--
 arch/arm/plat-iop/adma.c                    |    6 +++---
 arch/ia64/sn/pci/pci_dma.c                  |    2 +-
 arch/powerpc/platforms/cell/iommu.c         |    2 +-
 drivers/ata/ahci.c                          |    4 ++--
 drivers/ata/sata_mv.c                       |    4 ++--
 drivers/ata/sata_qstor.c                    |    4 ++--
 drivers/ata/sata_sil24.c                    |    4 ++--
 drivers/block/DAC960.c                      |    4 ++--
 drivers/block/cciss.c                       |    2 +-
 drivers/block/sx8.c                         |    4 ++--
 drivers/block/umem.c                        |    2 +-
 drivers/dma/ioat.c                          |    4 ++--
 drivers/idle/i7300_idle.c                   |    2 +-
 drivers/infiniband/hw/amso1100/c2.c         |    2 +-
 drivers/infiniband/hw/ipath/ipath_driver.c  |    4 ++--
 drivers/infiniband/hw/mthca/mthca_main.c    |    4 ++--
 drivers/infiniband/hw/nes/nes.c             |    4 ++--
 drivers/message/fusion/mptbase.c            |    4 ++--
 drivers/message/i2o/memory.c                |    4 ++--
 drivers/message/i2o/pci.c                   |    2 +-
 drivers/net/8139cp.c                        |    4 ++--
 drivers/net/acenic.c                        |    2 +-
 drivers/net/bnx2.c                          |    2 +-
 drivers/net/bnx2x_main.c                    |    4 ++--
 drivers/net/cassini.c                       |    4 ++--
 drivers/net/chelsio/cxgb2.c                 |    4 ++--
 drivers/net/cxgb3/cxgb3_main.c              |    4 ++--
 drivers/net/e1000/e1000_main.c              |    4 ++--
 drivers/net/e1000e/netdev.c                 |    4 ++--
 drivers/net/igb/igb_main.c                  |    4 ++--
 drivers/net/ioc3-eth.c                      |    4 ++--
 drivers/net/ixgb/ixgb_main.c                |    4 ++--
 drivers/net/ixgbe/ixgbe_main.c              |    4 ++--
 drivers/net/mlx4/main.c                     |    4 ++--
 drivers/net/myri10ge/myri10ge.c             |    4 ++--
 drivers/net/netxen/netxen_nic_main.c        |    2 +-
 drivers/net/ns83820.c                       |    2 +-
 drivers/net/qla3xxx.c                       |    4 ++--
 drivers/net/qlge/qlge_main.c                |    4 ++--
 drivers/net/r8169.c                         |    2 +-
 drivers/net/s2io.c                          |    4 ++--
 drivers/net/skge.c                          |    4 ++--
 drivers/net/sky2.c                          |    4 ++--
 drivers/net/sungem.c                        |    2 +-
 drivers/net/tehuti.c                        |    4 ++--
 drivers/net/tehuti.h                        |    5 +----
 drivers/net/tg3.c                           |    4 ++--
 drivers/net/usb/usbnet.c                    |    2 +-
 drivers/net/wireless/b43/dma.c              |    6 +++---
 drivers/net/wireless/b43legacy/dma.c        |    6 +++---
 drivers/pci/intel-iommu.c                   |    2 +-
 drivers/scsi/3w-9xxx.c                      |    4 ++--
 drivers/scsi/aacraid/aachba.c               |    4 ++--
 drivers/scsi/aic7xxx/aic79xx_osm_pci.c      |    2 +-
 drivers/scsi/aic94xx/aic94xx_init.c         |    4 ++--
 drivers/scsi/arcmsr/arcmsr_hba.c            |    2 +-
 drivers/scsi/dpt_i2o.c                      |    2 +-
 drivers/scsi/gdth.c                         |    2 +-
 drivers/scsi/hptiop.c                       |    2 +-
 drivers/scsi/ips.c                          |    2 +-
 drivers/scsi/lpfc/lpfc_init.c               |    2 +-
 drivers/scsi/megaraid.c                     |    2 +-
 drivers/scsi/megaraid/megaraid_mbox.c       |    2 +-
 drivers/scsi/megaraid/megaraid_sas.c        |    2 +-
 drivers/scsi/mvsas.c                        |    4 ++--
 drivers/scsi/qla1280.c                      |    2 +-
 drivers/scsi/qla2xxx/qla_os.c               |    4 ++--
 drivers/scsi/qla4xxx/ql4_os.c               |    4 ++--
 drivers/scsi/stex.c                         |    4 ++--
 drivers/scsi/sym53c8xx_2/sym_hipd.h         |    2 +-
 drivers/sn/ioc3.c                           |    4 ++--
 drivers/staging/altpciechdma/altpciechdma.c |    4 ++--
 drivers/staging/benet/be_init.c             |    2 +-
 drivers/staging/slicoss/slicoss.c           |    4 ++--
 drivers/staging/sxg/sxg.c                   |    4 ++--
 drivers/usb/host/ehci-hcd.c                 |    2 +-
 drivers/uwb/whci.c                          |    4 ++--
 sound/pci/hda/hda_intel.c                   |    4 ++--
 82 files changed, 144 insertions(+), 147 deletions(-)

diff --git a/arch/arm/mach-iop13xx/setup.c b/arch/arm/mach-iop13xx/setup.c
index cfd4d2e..bee42c6 100644
--- a/arch/arm/mach-iop13xx/setup.c
+++ b/arch/arm/mach-iop13xx/setup.c
@@ -307,7 +307,7 @@ static struct resource iop13xx_adma_2_resources[] = {
 	}
 };
 
-static u64 iop13xx_adma_dmamask = DMA_64BIT_MASK;
+static u64 iop13xx_adma_dmamask = DMA_BIT_MASK(64);
 static struct iop_adma_platform_data iop13xx_adma_0_data = {
 	.hw_id = 0,
 	.pool_size = PAGE_SIZE,
@@ -331,7 +331,7 @@ static struct platform_device iop13xx_adma_0_channel = {
 	.resource = iop13xx_adma_0_resources,
 	.dev = {
 		.dma_mask = &iop13xx_adma_dmamask,
-		.coherent_dma_mask = DMA_64BIT_MASK,
+		.coherent_dma_mask = DMA_BIT_MASK(64),
 		.platform_data = (void *) &iop13xx_adma_0_data,
 	},
 };
@@ -343,7 +343,7 @@ static struct platform_device iop13xx_adma_1_channel = {
 	.resource = iop13xx_adma_1_resources,
 	.dev = {
 		.dma_mask = &iop13xx_adma_dmamask,
-		.coherent_dma_mask = DMA_64BIT_MASK,
+		.coherent_dma_mask = DMA_BIT_MASK(64),
 		.platform_data = (void *) &iop13xx_adma_1_data,
 	},
 };
@@ -355,7 +355,7 @@ static struct platform_device iop13xx_adma_2_channel = {
 	.resource = iop13xx_adma_2_resources,
 	.dev = {
 		.dma_mask = &iop13xx_adma_dmamask,
-		.coherent_dma_mask = DMA_64BIT_MASK,
+		.coherent_dma_mask = DMA_BIT_MASK(64),
 		.platform_data = (void *) &iop13xx_adma_2_data,
 	},
 };
diff --git a/arch/arm/mach-iop13xx/tpmi.c b/arch/arm/mach-iop13xx/tpmi.c
index c6af1e1..6fdad7a 100644
--- a/arch/arm/mach-iop13xx/tpmi.c
+++ b/arch/arm/mach-iop13xx/tpmi.c
@@ -151,7 +151,7 @@ static struct resource iop13xx_tpmi_3_resources[] = {
 	}
 };
 
-u64 iop13xx_tpmi_mask = DMA_64BIT_MASK;
+u64 iop13xx_tpmi_mask = DMA_BIT_MASK(64);
 static struct platform_device iop13xx_tpmi_0_device = {
 	.name = "iop-tpmi",
 	.id = 0,
@@ -159,7 +159,7 @@ static struct platform_device iop13xx_tpmi_0_device = {
 	.resource = iop13xx_tpmi_0_resources,
 	.dev = {
 		.dma_mask          = &iop13xx_tpmi_mask,
-		.coherent_dma_mask = DMA_64BIT_MASK,
+		.coherent_dma_mask = DMA_BIT_MASK(64),
 	},
 };
 
@@ -170,7 +170,7 @@ static struct platform_device iop13xx_tpmi_1_device = {
 	.resource = iop13xx_tpmi_1_resources,
 	.dev = {
 		.dma_mask          = &iop13xx_tpmi_mask,
-		.coherent_dma_mask = DMA_64BIT_MASK,
+		.coherent_dma_mask = DMA_BIT_MASK(64),
 	},
 };
 
@@ -181,7 +181,7 @@ static struct platform_device iop13xx_tpmi_2_device = {
 	.resource = iop13xx_tpmi_2_resources,
 	.dev = {
 		.dma_mask          = &iop13xx_tpmi_mask,
-		.coherent_dma_mask = DMA_64BIT_MASK,
+		.coherent_dma_mask = DMA_BIT_MASK(64),
 	},
 };
 
@@ -192,7 +192,7 @@ static struct platform_device iop13xx_tpmi_3_device = {
 	.resource = iop13xx_tpmi_3_resources,
 	.dev = {
 		.dma_mask          = &iop13xx_tpmi_mask,
-		.coherent_dma_mask = DMA_64BIT_MASK,
+		.coherent_dma_mask = DMA_BIT_MASK(64),
 	},
 };
 
diff --git a/arch/arm/mach-kirkwood/common.c b/arch/arm/mach-kirkwood/common.c
index b3404b7..25b41dc 100644
--- a/arch/arm/mach-kirkwood/common.c
+++ b/arch/arm/mach-kirkwood/common.c
@@ -471,7 +471,7 @@ static struct platform_device kirkwood_xor00_channel = {
 	.resource	= kirkwood_xor00_resources,
 	.dev		= {
 		.dma_mask		= &kirkwood_xor_dmamask,
-		.coherent_dma_mask	= DMA_64BIT_MASK,
+		.coherent_dma_mask	= DMA_BIT_MASK(64),
 		.platform_data		= (void *)&kirkwood_xor00_data,
 	},
 };
@@ -497,7 +497,7 @@ static struct platform_device kirkwood_xor01_channel = {
 	.resource	= kirkwood_xor01_resources,
 	.dev		= {
 		.dma_mask		= &kirkwood_xor_dmamask,
-		.coherent_dma_mask	= DMA_64BIT_MASK,
+		.coherent_dma_mask	= DMA_BIT_MASK(64),
 		.platform_data		= (void *)&kirkwood_xor01_data,
 	},
 };
@@ -569,7 +569,7 @@ static struct platform_device kirkwood_xor10_channel = {
 	.resource	= kirkwood_xor10_resources,
 	.dev		= {
 		.dma_mask		= &kirkwood_xor_dmamask,
-		.coherent_dma_mask	= DMA_64BIT_MASK,
+		.coherent_dma_mask	= DMA_BIT_MASK(64),
 		.platform_data		= (void *)&kirkwood_xor10_data,
 	},
 };
@@ -595,7 +595,7 @@ static struct platform_device kirkwood_xor11_channel = {
 	.resource	= kirkwood_xor11_resources,
 	.dev		= {
 		.dma_mask		= &kirkwood_xor_dmamask,
-		.coherent_dma_mask	= DMA_64BIT_MASK,
+		.coherent_dma_mask	= DMA_BIT_MASK(64),
 		.platform_data		= (void *)&kirkwood_xor11_data,
 	},
 };
diff --git a/arch/arm/mach-orion5x/common.c b/arch/arm/mach-orion5x/common.c
index 0a62337..19cbe34 100644
--- a/arch/arm/mach-orion5x/common.c
+++ b/arch/arm/mach-orion5x/common.c
@@ -475,7 +475,7 @@ static struct platform_device orion5x_xor0_channel = {
 	.resource	= orion5x_xor0_resources,
 	.dev		= {
 		.dma_mask		= &orion5x_xor_dmamask,
-		.coherent_dma_mask	= DMA_64BIT_MASK,
+		.coherent_dma_mask	= DMA_BIT_MASK(64),
 		.platform_data		= (void *)&orion5x_xor0_data,
 	},
 };
@@ -501,7 +501,7 @@ static struct platform_device orion5x_xor1_channel = {
 	.resource	= orion5x_xor1_resources,
 	.dev		= {
 		.dma_mask		= &orion5x_xor_dmamask,
-		.coherent_dma_mask	= DMA_64BIT_MASK,
+		.coherent_dma_mask	= DMA_BIT_MASK(64),
 		.platform_data		= (void *)&orion5x_xor1_data,
 	},
 };
diff --git a/arch/arm/plat-iop/adma.c b/arch/arm/plat-iop/adma.c
index f724208..a2a94f6 100644
--- a/arch/arm/plat-iop/adma.c
+++ b/arch/arm/plat-iop/adma.c
@@ -143,7 +143,7 @@ struct platform_device iop3xx_dma_0_channel = {
 	.resource = iop3xx_dma_0_resources,
 	.dev = {
 		.dma_mask = &iop3xx_adma_dmamask,
-		.coherent_dma_mask = DMA_64BIT_MASK,
+		.coherent_dma_mask = DMA_BIT_MASK(64),
 		.platform_data = (void *) &iop3xx_dma_0_data,
 	},
 };
@@ -155,7 +155,7 @@ struct platform_device iop3xx_dma_1_channel = {
 	.resource = iop3xx_dma_1_resources,
 	.dev = {
 		.dma_mask = &iop3xx_adma_dmamask,
-		.coherent_dma_mask = DMA_64BIT_MASK,
+		.coherent_dma_mask = DMA_BIT_MASK(64),
 		.platform_data = (void *) &iop3xx_dma_1_data,
 	},
 };
@@ -167,7 +167,7 @@ struct platform_device iop3xx_aau_channel = {
 	.resource = iop3xx_aau_resources,
 	.dev = {
 		.dma_mask = &iop3xx_adma_dmamask,
-		.coherent_dma_mask = DMA_64BIT_MASK,
+		.coherent_dma_mask = DMA_BIT_MASK(64),
 		.platform_data = (void *) &iop3xx_aau_data,
 	},
 };
diff --git a/arch/ia64/sn/pci/pci_dma.c b/arch/ia64/sn/pci/pci_dma.c
index 863f501..82025c5 100644
--- a/arch/ia64/sn/pci/pci_dma.c
+++ b/arch/ia64/sn/pci/pci_dma.c
@@ -358,7 +358,7 @@ EXPORT_SYMBOL(sn_dma_mapping_error);
 
 u64 sn_dma_get_required_mask(struct device *dev)
 {
-	return DMA_64BIT_MASK;
+	return DMA_BIT_MASK(64);
 }
 EXPORT_SYMBOL_GPL(sn_dma_get_required_mask);
 
diff --git a/arch/powerpc/platforms/cell/iommu.c b/arch/powerpc/platforms/cell/iommu.c
index ee5033e..35818bf 100644
--- a/arch/powerpc/platforms/cell/iommu.c
+++ b/arch/powerpc/platforms/cell/iommu.c
@@ -643,7 +643,7 @@ static void dma_fixed_unmap_sg(struct device *dev, struct scatterlist *sg,
 
 static int dma_fixed_dma_supported(struct device *dev, u64 mask)
 {
-	return mask == DMA_64BIT_MASK;
+	return mask == DMA_BIT_MASK(64);
 }
 
 static int dma_set_mask_and_switch(struct device *dev, u64 dma_mask);
diff --git a/drivers/ata/ahci.c b/drivers/ata/ahci.c
index a603bbf..163ac4b 100644
--- a/drivers/ata/ahci.c
+++ b/drivers/ata/ahci.c
@@ -2405,8 +2405,8 @@ static int ahci_configure_dma_masks(struct pci_dev *pdev, int using_dac)
 	int rc;
 
 	if (using_dac &&
-	    !pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
-		rc = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
+	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
+		rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 		if (rc) {
 			rc = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
 			if (rc) {
diff --git a/drivers/ata/sata_mv.c b/drivers/ata/sata_mv.c
index 4ae1a41..4a7ce88 100644
--- a/drivers/ata/sata_mv.c
+++ b/drivers/ata/sata_mv.c
@@ -3299,8 +3299,8 @@ static int pci_go_64(struct pci_dev *pdev)
 {
 	int rc;
 
-	if (!pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
-		rc = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
+	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
+		rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 		if (rc) {
 			rc = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
 			if (rc) {
diff --git a/drivers/ata/sata_qstor.c b/drivers/ata/sata_qstor.c
index a000c86..f6498ee 100644
--- a/drivers/ata/sata_qstor.c
+++ b/drivers/ata/sata_qstor.c
@@ -583,8 +583,8 @@ static int qs_set_dma_masks(struct pci_dev *pdev, void __iomem *mmio_base)
 	int rc, have_64bit_bus = (bus_info & QS_HPHY_64BIT);
 
 	if (have_64bit_bus &&
-	    !pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
-		rc = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
+	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
+		rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 		if (rc) {
 			rc = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
 			if (rc) {
diff --git a/drivers/ata/sata_sil24.c b/drivers/ata/sata_sil24.c
index 2590c22..8e3cefb 100644
--- a/drivers/ata/sata_sil24.c
+++ b/drivers/ata/sata_sil24.c
@@ -1297,8 +1297,8 @@ static int sil24_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	host->iomap = iomap;
 
 	/* configure and activate the device */
-	if (!pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
-		rc = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
+	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
+		rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 		if (rc) {
 			rc = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
 			if (rc) {
diff --git a/drivers/block/DAC960.c b/drivers/block/DAC960.c
index f6a337c..5496865 100644
--- a/drivers/block/DAC960.c
+++ b/drivers/block/DAC960.c
@@ -1372,8 +1372,8 @@ static bool DAC960_V2_EnableMemoryMailboxInterface(DAC960_Controller_T
   dma_addr_t	CommandMailboxDMA;
   DAC960_V2_CommandStatus_T CommandStatus;
 
-	if (!pci_set_dma_mask(Controller->PCIDevice, DMA_64BIT_MASK))
-		Controller->BounceBufferLimit = DMA_64BIT_MASK;
+	if (!pci_set_dma_mask(Controller->PCIDevice, DMA_BIT_MASK(64)))
+		Controller->BounceBufferLimit = DMA_BIT_MASK(64);
 	else if (!pci_set_dma_mask(Controller->PCIDevice, DMA_32BIT_MASK))
 		Controller->BounceBufferLimit = DMA_32BIT_MASK;
 	else
diff --git a/drivers/block/cciss.c b/drivers/block/cciss.c
index 01e6938..69475e4 100644
--- a/drivers/block/cciss.c
+++ b/drivers/block/cciss.c
@@ -3420,7 +3420,7 @@ static int __devinit cciss_init_one(struct pci_dev *pdev,
 	hba[i]->pdev = pdev;
 
 	/* configure PCI DMA stuff */
-	if (!pci_set_dma_mask(pdev, DMA_64BIT_MASK))
+	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64)))
 		dac = 1;
 	else if (!pci_set_dma_mask(pdev, DMA_32BIT_MASK))
 		dac = 0;
diff --git a/drivers/block/sx8.c b/drivers/block/sx8.c
index a18e1ca..db5783a 100644
--- a/drivers/block/sx8.c
+++ b/drivers/block/sx8.c
@@ -1586,9 +1586,9 @@ static int carm_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out;
 
 #ifdef IF_64BIT_DMA_IS_POSSIBLE /* grrrr... */
-	rc = pci_set_dma_mask(pdev, DMA_64BIT_MASK);
+	rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (!rc) {
-		rc = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
+		rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 		if (rc) {
 			printk(KERN_ERR DRV_NAME "(%s): consistent DMA mask failure\n",
 				pci_name(pdev));
diff --git a/drivers/block/umem.c b/drivers/block/umem.c
index c24e1bd..e93e99c 100644
--- a/drivers/block/umem.c
+++ b/drivers/block/umem.c
@@ -829,7 +829,7 @@ static int __devinit mm_pci_probe(struct pci_dev *dev,
 	dev_printk(KERN_INFO, &dev->dev,
 	  "Micro Memory(tm) controller found (PCI Mem Module (Battery Backup))\n");
 
-	if (pci_set_dma_mask(dev, DMA_64BIT_MASK) &&
+	if (pci_set_dma_mask(dev, DMA_BIT_MASK(64)) &&
 	    pci_set_dma_mask(dev, DMA_32BIT_MASK)) {
 		dev_printk(KERN_WARNING, &dev->dev, "NO suitable DMA found\n");
 		return  -ENOMEM;
diff --git a/drivers/dma/ioat.c b/drivers/dma/ioat.c
index 4105d65..6ccfaca 100644
--- a/drivers/dma/ioat.c
+++ b/drivers/dma/ioat.c
@@ -98,13 +98,13 @@ static int __devinit ioat_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_request_regions;
 
-	err = pci_set_dma_mask(pdev, DMA_64BIT_MASK);
+	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (err)
 		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 	if (err)
 		goto err_set_dma_mask;
 
-	err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
+	err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (err)
 		err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
 	if (err)
diff --git a/drivers/idle/i7300_idle.c b/drivers/idle/i7300_idle.c
index 17e8ddd..bf74039 100644
--- a/drivers/idle/i7300_idle.c
+++ b/drivers/idle/i7300_idle.c
@@ -178,7 +178,7 @@ static int __init i7300_idle_ioat_selftest(u8 *ctl,
 
 static struct device dummy_dma_dev = {
 	.init_name = "fallback device",
-	.coherent_dma_mask = DMA_64BIT_MASK,
+	.coherent_dma_mask = DMA_BIT_MASK(64),
 	.dma_mask = &dummy_dma_dev.coherent_dma_mask,
 };
 
diff --git a/drivers/infiniband/hw/amso1100/c2.c b/drivers/infiniband/hw/amso1100/c2.c
index 113f3c0..d5021e4 100644
--- a/drivers/infiniband/hw/amso1100/c2.c
+++ b/drivers/infiniband/hw/amso1100/c2.c
@@ -992,7 +992,7 @@ static int __devinit c2_probe(struct pci_dev *pcidev,
 	}
 
 	if ((sizeof(dma_addr_t) > 4)) {
-		ret = pci_set_dma_mask(pcidev, DMA_64BIT_MASK);
+		ret = pci_set_dma_mask(pcidev, DMA_BIT_MASK(64));
 		if (ret < 0) {
 			printk(KERN_ERR PFX "64b DMA configuration failed\n");
 			goto bail2;
diff --git a/drivers/infiniband/hw/ipath/ipath_driver.c b/drivers/infiniband/hw/ipath/ipath_driver.c
index 69c0ce3..96fe383 100644
--- a/drivers/infiniband/hw/ipath/ipath_driver.c
+++ b/drivers/infiniband/hw/ipath/ipath_driver.c
@@ -470,7 +470,7 @@ static int __devinit ipath_init_one(struct pci_dev *pdev,
 		goto bail_disable;
 	}
 
-	ret = pci_set_dma_mask(pdev, DMA_64BIT_MASK);
+	ret = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (ret) {
 		/*
 		 * if the 64 bit setup fails, try 32 bit.  Some systems
@@ -496,7 +496,7 @@ static int __devinit ipath_init_one(struct pci_dev *pdev,
 		}
 	}
 	else {
-		ret = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
+		ret = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 		if (ret)
 			dev_info(&pdev->dev,
 				"Unable to set DMA consistent mask "
diff --git a/drivers/infiniband/hw/mthca/mthca_main.c b/drivers/infiniband/hw/mthca/mthca_main.c
index 52f60f4..5d23420 100644
--- a/drivers/infiniband/hw/mthca/mthca_main.c
+++ b/drivers/infiniband/hw/mthca/mthca_main.c
@@ -1016,7 +1016,7 @@ static int __mthca_init_one(struct pci_dev *pdev, int hca_type)
 
 	pci_set_master(pdev);
 
-	err = pci_set_dma_mask(pdev, DMA_64BIT_MASK);
+	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (err) {
 		dev_warn(&pdev->dev, "Warning: couldn't set 64-bit PCI DMA mask.\n");
 		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
@@ -1025,7 +1025,7 @@ static int __mthca_init_one(struct pci_dev *pdev, int hca_type)
 			goto err_free_res;
 		}
 	}
-	err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
+	err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (err) {
 		dev_warn(&pdev->dev, "Warning: couldn't set 64-bit "
 			 "consistent PCI DMA mask.\n");
diff --git a/drivers/infiniband/hw/nes/nes.c b/drivers/infiniband/hw/nes/nes.c
index b9611ad..2cf267c 100644
--- a/drivers/infiniband/hw/nes/nes.c
+++ b/drivers/infiniband/hw/nes/nes.c
@@ -478,12 +478,12 @@ static int __devinit nes_probe(struct pci_dev *pcidev, const struct pci_device_i
 	}
 
 	if ((sizeof(dma_addr_t) > 4)) {
-		ret = pci_set_dma_mask(pcidev, DMA_64BIT_MASK);
+		ret = pci_set_dma_mask(pcidev, DMA_BIT_MASK(64));
 		if (ret < 0) {
 			printk(KERN_ERR PFX "64b DMA mask configuration failed\n");
 			goto bail2;
 		}
-		ret = pci_set_consistent_dma_mask(pcidev, DMA_64BIT_MASK);
+		ret = pci_set_consistent_dma_mask(pcidev, DMA_BIT_MASK(64));
 		if (ret) {
 			printk(KERN_ERR PFX "64b DMA consistent mask configuration failed\n");
 			goto bail2;
diff --git a/drivers/message/fusion/mptbase.c b/drivers/message/fusion/mptbase.c
index 96ac883..3bcc0ba 100644
--- a/drivers/message/fusion/mptbase.c
+++ b/drivers/message/fusion/mptbase.c
@@ -1534,8 +1534,8 @@ mpt_mapresources(MPT_ADAPTER *ioc)
 
 	pci_read_config_byte(pdev, PCI_CLASS_REVISION, &revision);
 
-	if (!pci_set_dma_mask(pdev, DMA_64BIT_MASK)
-	    && !pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK)) {
+	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))
+	    && !pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		dinitprintk(ioc, printk(MYIOC_s_INFO_FMT
 		    ": 64 BIT PCI BUS DMA ADDRESSING SUPPORTED\n",
 		    ioc->name));
diff --git a/drivers/message/i2o/memory.c b/drivers/message/i2o/memory.c
index f5cc95c..9a08d8e 100644
--- a/drivers/message/i2o/memory.c
+++ b/drivers/message/i2o/memory.c
@@ -185,7 +185,7 @@ int i2o_dma_alloc(struct device *dev, struct i2o_dma *addr, size_t len)
 	int dma_64 = 0;
 
 	mutex_lock(&mem_lock);
-	if ((sizeof(dma_addr_t) > 4) && (pdev->dma_mask == DMA_64BIT_MASK)) {
+	if ((sizeof(dma_addr_t) > 4) && (pdev->dma_mask == DMA_BIT_MASK(64))) {
 		dma_64 = 1;
 		if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
 			mutex_unlock(&mem_lock);
@@ -196,7 +196,7 @@ int i2o_dma_alloc(struct device *dev, struct i2o_dma *addr, size_t len)
 	addr->virt = dma_alloc_coherent(dev, len, &addr->phys, GFP_KERNEL);
 
 	if ((sizeof(dma_addr_t) > 4) && dma_64)
-		if (pci_set_dma_mask(pdev, DMA_64BIT_MASK))
+		if (pci_set_dma_mask(pdev, DMA_BIT_MASK(64)))
 			printk(KERN_WARNING "i2o: unable to set 64-bit DMA");
 	mutex_unlock(&mem_lock);
 
diff --git a/drivers/message/i2o/pci.c b/drivers/message/i2o/pci.c
index 25d6f23..ed17ac5 100644
--- a/drivers/message/i2o/pci.c
+++ b/drivers/message/i2o/pci.c
@@ -397,7 +397,7 @@ static int __devinit i2o_pci_probe(struct pci_dev *pdev,
 		}
 #ifdef CONFIG_I2O_EXT_ADAPTEC_DMA64
 		if (sizeof(dma_addr_t) > 4) {
-			if (pci_set_dma_mask(pdev, DMA_64BIT_MASK))
+			if (pci_set_dma_mask(pdev, DMA_BIT_MASK(64)))
 				printk(KERN_INFO "%s: 64-bit DMA unavailable\n",
 				       c->name);
 			else {
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 4e19ae3..430817c 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -1907,8 +1907,8 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* Configure DMA attributes. */
 	if ((sizeof(dma_addr_t) > 4) &&
-	    !pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK) &&
-	    !pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
+	    !pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64)) &&
+	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		pci_using_dac = 1;
 	} else {
 		pci_using_dac = 0;
diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index 9589d62..7acf9b6 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -1161,7 +1161,7 @@ static int __devinit ace_init(struct net_device *dev)
 	/*
 	 * Configure DMA attributes.
 	 */
-	if (!pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
+	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		ap->pci_using_dac = 1;
 	} else if (!pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
 		ap->pci_using_dac = 0;
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 6500b7c..696e7bf 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7463,7 +7463,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	if (CHIP_NUM(bp) == CHIP_NUM_5708)
 		persist_dma_mask = dma_mask = DMA_40BIT_MASK;
 	else
-		persist_dma_mask = dma_mask = DMA_64BIT_MASK;
+		persist_dma_mask = dma_mask = DMA_BIT_MASK(64);
 
 	/* Configure DMA attributes. */
 	if (pci_set_dma_mask(pdev, dma_mask) == 0) {
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index d3e7775..9e94568 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -10204,9 +10204,9 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 		goto err_out_release;
 	}
 
-	if (pci_set_dma_mask(pdev, DMA_64BIT_MASK) == 0) {
+	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) == 0) {
 		bp->flags |= USING_DAC_FLAG;
-		if (pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK) != 0) {
+		if (pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64)) != 0) {
 			printk(KERN_ERR PFX "pci_set_consistent_dma_mask"
 			       " failed, aborting\n");
 			rc = -EIO;
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index bbbc3bb..1c7f401 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -5074,10 +5074,10 @@ static int __devinit cas_init_one(struct pci_dev *pdev,
 
 
 	/* Configure DMA attributes. */
-	if (!pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
+	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		pci_using_dac = 1;
 		err = pci_set_consistent_dma_mask(pdev,
-						  DMA_64BIT_MASK);
+						  DMA_BIT_MASK(64));
 		if (err < 0) {
 			dev_err(&pdev->dev, "Unable to obtain 64-bit DMA "
 			       "for consistent allocations\n");
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index 9b6011e..57cfbc3 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -1056,10 +1056,10 @@ static int __devinit init_one(struct pci_dev *pdev,
 		goto out_disable_pdev;
 	}
 
-	if (!pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
+	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		pci_using_dac = 1;
 
-		if (pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK)) {
+		if (pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64))) {
 			CH_ERR("%s: unable to obtain 64-bit DMA for "
 			       "consistent allocations\n", pci_name(pdev));
 			err = -ENODEV;
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 0089746..7131187 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2890,9 +2890,9 @@ static int __devinit init_one(struct pci_dev *pdev,
 		goto out_release_regions;
 	}
 
-	if (!pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
+	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		pci_using_dac = 1;
-		err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
+		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 		if (err) {
 			dev_err(&pdev->dev, "unable to obtain 64-bit DMA for "
 			       "coherent allocations\n");
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 6bd63cc..e448e70 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -945,8 +945,8 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	if (err)
 		return err;
 
-	if (!pci_set_dma_mask(pdev, DMA_64BIT_MASK) &&
-	    !pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK)) {
+	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) &&
+	    !pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		pci_using_dac = 1;
 	} else {
 		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 91817d0..fe7917d 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4789,9 +4789,9 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 		return err;
 
 	pci_using_dac = 0;
-	err = pci_set_dma_mask(pdev, DMA_64BIT_MASK);
+	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (!err) {
-		err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
+		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 		if (!err)
 			pci_using_dac = 1;
 	} else {
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index a50db53..9ab4143 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1045,9 +1045,9 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		return err;
 
 	pci_using_dac = 0;
-	err = pci_set_dma_mask(pdev, DMA_64BIT_MASK);
+	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (!err) {
-		err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
+		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 		if (!err)
 			pci_using_dac = 1;
 	} else {
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index 170b12d..43be0b0 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -1226,10 +1226,10 @@ static int __devinit ioc3_probe(struct pci_dev *pdev,
 	int err, pci_using_dac;
 
 	/* Configure DMA attributes. */
-	err = pci_set_dma_mask(pdev, DMA_64BIT_MASK);
+	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (!err) {
 		pci_using_dac = 1;
-		err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
+		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 		if (err < 0) {
 			printk(KERN_ERR "%s: Unable to obtain 64 bit DMA "
 			       "for consistent allocations\n", pci_name(pdev));
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index eee28d3..ca3524e 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -365,8 +365,8 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		return err;
 
-	if (!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK)) &&
-	    !(err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK))) {
+	if (!(err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) &&
+	    !(err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64)))) {
 		pci_using_dac = 1;
 	} else {
 		if ((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK)) ||
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index d2f4d5f..194c5fb 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4013,8 +4013,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (err)
 		return err;
 
-	if (!pci_set_dma_mask(pdev, DMA_64BIT_MASK) &&
-	    !pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK)) {
+	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) &&
+	    !pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		pci_using_dac = 1;
 	} else {
 		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 6ef2490..dbd24d3 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -1032,7 +1032,7 @@ static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	pci_set_master(pdev);
 
-	err = pci_set_dma_mask(pdev, DMA_64BIT_MASK);
+	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (err) {
 		dev_warn(&pdev->dev, "Warning: couldn't set 64-bit PCI DMA mask.\n");
 		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
@@ -1041,7 +1041,7 @@ static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 			goto err_release_bar2;
 		}
 	}
-	err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
+	err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (err) {
 		dev_warn(&pdev->dev, "Warning: couldn't set 64-bit "
 			 "consistent PCI DMA mask.\n");
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index e9c1296..12e9b94 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -3791,7 +3791,7 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_set_master(pdev);
 	dac_enabled = 1;
-	status = pci_set_dma_mask(pdev, DMA_64BIT_MASK);
+	status = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (status != 0) {
 		dac_enabled = 0;
 		dev_err(&pdev->dev,
@@ -3803,7 +3803,7 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev_err(&pdev->dev, "Error %d setting DMA mask\n", status);
 		goto abort_with_enabled;
 	}
-	(void)pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
+	(void)pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 	mgp->cmd = dma_alloc_coherent(&pdev->dev, sizeof(*mgp->cmd),
 				      &mgp->cmd_bus, GFP_KERNEL);
 	if (mgp->cmd == NULL)
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 9f33e44..285e725 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -176,7 +176,7 @@ static int nx_set_dma_mask(struct netxen_adapter *adapter, uint8_t revision_id)
 	adapter->dma_mask = DMA_32BIT_MASK;
 #else
 	if (revision_id >= NX_P3_B0) {
-		/* should go to DMA_64BIT_MASK */
+		/* should go to DMA_BIT_MASK(64) */
 		adapter->dma_mask = DMA_39BIT_MASK;
 		mask = DMA_39BIT_MASK;
 	} else if (revision_id == NX_P3_A2) {
diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index e80294d..a21528c 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -1974,7 +1974,7 @@ static int __devinit ns83820_init_one(struct pci_dev *pci_dev,
 
 	/* See if we can set the dma mask early on; failure is fatal. */
 	if (sizeof(dma_addr_t) == 8 &&
-	 	!pci_set_dma_mask(pci_dev, DMA_64BIT_MASK)) {
+	 	!pci_set_dma_mask(pci_dev, DMA_BIT_MASK(64))) {
 		using_dac = 1;
 	} else if (!pci_set_dma_mask(pci_dev, DMA_32BIT_MASK)) {
 		using_dac = 0;
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 189ec29..196a143 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -3934,9 +3934,9 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 
 	pci_set_master(pdev);
 
-	if (!pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
+	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		pci_using_dac = 1;
-		err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
+		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 	} else if (!(err = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
 		pci_using_dac = 0;
 		err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 8ea72dc..0a5c2b4 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3604,9 +3604,9 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 	}
 
 	pci_set_master(pdev);
-	if (!pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
+	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		set_bit(QL_DMA64, &qdev->flags);
-		err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
+		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 	} else {
 		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 		if (!err)
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 0771eb6..742d822 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2046,7 +2046,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->cp_cmd = PCIMulRW | RxChkSum;
 
 	if ((sizeof(dma_addr_t) > 4) &&
-	    !pci_set_dma_mask(pdev, DMA_64BIT_MASK) && use_dac) {
+	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) && use_dac) {
 		tp->cp_cmd |= PCIDAC;
 		dev->features |= NETIF_F_HIGHDMA;
 	} else {
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index f5c57c0..892bf64 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -7775,11 +7775,11 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 		return ret;
 	}
 
-	if (!pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
+	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		DBG_PRINT(INIT_DBG, "s2io_init_nic: Using 64bit DMA\n");
 		dma_flag = TRUE;
 		if (pci_set_consistent_dma_mask
-		    (pdev, DMA_64BIT_MASK)) {
+		    (pdev, DMA_BIT_MASK(64))) {
 			DBG_PRINT(ERR_DBG,
 				  "Unable to obtain 64bit DMA for \
 					consistent allocations\n");
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index c9dbb06..fce0219 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -3912,9 +3912,9 @@ static int __devinit skge_probe(struct pci_dev *pdev,
 
 	pci_set_master(pdev);
 
-	if (!pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
+	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		using_dac = 1;
-		err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
+		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 	} else if (!(err = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
 		using_dac = 0;
 		err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 994703c..9bfc946 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -4311,9 +4311,9 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 	pci_set_master(pdev);
 
 	if (sizeof(dma_addr_t) > sizeof(u32) &&
-	    !(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK))) {
+	    !(err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64)))) {
 		using_dac = 1;
-		err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
+		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 		if (err < 0) {
 			dev_err(&pdev->dev, "unable to obtain 64 bit DMA "
 				"for consistent allocations\n");
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 4918763..271172a 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -3039,7 +3039,7 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 	 */
 	if (pdev->vendor == PCI_VENDOR_ID_SUN &&
 	    pdev->device == PCI_DEVICE_ID_SUN_GEM &&
-	    !pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
+	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		pci_using_dac = 1;
 	} else {
 		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index a7a4dc4..4d06a85 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -1936,8 +1936,8 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if ((err = pci_enable_device(pdev)))	/* it trigers interrupt, dunno why. */
 		goto err_pci;			/* it's not a problem though */
 
-	if (!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK)) &&
-	    !(err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK))) {
+	if (!(err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) &&
+	    !(err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64)))) {
 		pci_using_dac = 1;
 	} else {
 		if ((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK)) ||
diff --git a/drivers/net/tehuti.h b/drivers/net/tehuti.h
index efaf84d..4a46f16 100644
--- a/drivers/net/tehuti.h
+++ b/drivers/net/tehuti.h
@@ -30,6 +30,7 @@
 #include <linux/interrupt.h>
 #include <linux/vmalloc.h>
 #include <asm/byteorder.h>
+#include <linux/dma-mapping.h>
 
 /* Compile Time Switches */
 /* start */
@@ -97,10 +98,6 @@
 #define READ_REG(pp, reg)         readl(pp->pBdxRegs + reg)
 #define WRITE_REG(pp, reg, val)   writel(val, pp->pBdxRegs + reg)
 
-#ifndef DMA_64BIT_MASK
-#   define DMA_64BIT_MASK  0xffffffffffffffffULL
-#endif
-
 #ifndef DMA_32BIT_MASK
 #   define DMA_32BIT_MASK  0x00000000ffffffffULL
 #endif
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4595962..488ecb7 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -13106,10 +13106,10 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	else if (tp->tg3_flags & TG3_FLAG_40BIT_DMA_BUG) {
 		persist_dma_mask = dma_mask = DMA_40BIT_MASK;
 #ifdef CONFIG_HIGHMEM
-		dma_mask = DMA_64BIT_MASK;
+		dma_mask = DMA_BIT_MASK(64);
 #endif
 	} else
-		persist_dma_mask = dma_mask = DMA_64BIT_MASK;
+		persist_dma_mask = dma_mask = DMA_BIT_MASK(64);
 
 	/* Configure DMA attributes. */
 	if (dma_mask > DMA_32BIT_MASK) {
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index aa31490..81f2c00 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1175,7 +1175,7 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 #if 0
 // dma_supported() is deeply broken on almost all architectures
 	// possible with some EHCI controllers
-	if (dma_supported (&udev->dev, DMA_64BIT_MASK))
+	if (dma_supported (&udev->dev, DMA_BIT_MASK(64)))
 		net->features |= NETIF_F_HIGHDMA;
 #endif
 
diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/dma.c
index 6d65a02..a1276f6 100644
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -769,7 +769,7 @@ static u64 supported_dma_mask(struct b43_wldev *dev)
 
 	tmp = b43_read32(dev, SSB_TMSHIGH);
 	if (tmp & SSB_TMSHIGH_DMA64)
-		return DMA_64BIT_MASK;
+		return DMA_BIT_MASK(64);
 	mmio_base = b43_dmacontroller_base(0, 0);
 	b43_write32(dev, mmio_base + B43_DMA32_TXCTL, B43_DMA32_TXADDREXT_MASK);
 	tmp = b43_read32(dev, mmio_base + B43_DMA32_TXCTL);
@@ -785,7 +785,7 @@ static enum b43_dmatype dma_mask_to_engine_type(u64 dmamask)
 		return B43_DMA_30BIT;
 	if (dmamask == DMA_32BIT_MASK)
 		return B43_DMA_32BIT;
-	if (dmamask == DMA_64BIT_MASK)
+	if (dmamask == DMA_BIT_MASK(64))
 		return B43_DMA_64BIT;
 	B43_WARN_ON(1);
 	return B43_DMA_30BIT;
@@ -996,7 +996,7 @@ static int b43_dma_set_mask(struct b43_wldev *dev, u64 mask)
 		err = ssb_dma_set_mask(dev->dev, mask);
 		if (!err)
 			break;
-		if (mask == DMA_64BIT_MASK) {
+		if (mask == DMA_BIT_MASK(64)) {
 			mask = DMA_32BIT_MASK;
 			fallback = 1;
 			continue;
diff --git a/drivers/net/wireless/b43legacy/dma.c b/drivers/net/wireless/b43legacy/dma.c
index 3649fc3..61bb912 100644
--- a/drivers/net/wireless/b43legacy/dma.c
+++ b/drivers/net/wireless/b43legacy/dma.c
@@ -846,7 +846,7 @@ static u64 supported_dma_mask(struct b43legacy_wldev *dev)
 
 	tmp = b43legacy_read32(dev, SSB_TMSHIGH);
 	if (tmp & SSB_TMSHIGH_DMA64)
-		return DMA_64BIT_MASK;
+		return DMA_BIT_MASK(64);
 	mmio_base = b43legacy_dmacontroller_base(0, 0);
 	b43legacy_write32(dev,
 			mmio_base + B43legacy_DMA32_TXCTL,
@@ -865,7 +865,7 @@ static enum b43legacy_dmatype dma_mask_to_engine_type(u64 dmamask)
 		return B43legacy_DMA_30BIT;
 	if (dmamask == DMA_32BIT_MASK)
 		return B43legacy_DMA_32BIT;
-	if (dmamask == DMA_64BIT_MASK)
+	if (dmamask == DMA_BIT_MASK(64))
 		return B43legacy_DMA_64BIT;
 	B43legacy_WARN_ON(1);
 	return B43legacy_DMA_30BIT;
@@ -1042,7 +1042,7 @@ static int b43legacy_dma_set_mask(struct b43legacy_wldev *dev, u64 mask)
 		err = ssb_dma_set_mask(dev->dev, mask);
 		if (!err)
 			break;
-		if (mask == DMA_64BIT_MASK) {
+		if (mask == DMA_BIT_MASK(64)) {
 			mask = DMA_32BIT_MASK;
 			fallback = 1;
 			continue;
diff --git a/drivers/pci/intel-iommu.c b/drivers/pci/intel-iommu.c
index f3f6865..46715db 100644
--- a/drivers/pci/intel-iommu.c
+++ b/drivers/pci/intel-iommu.c
@@ -56,7 +56,7 @@
 
 #define IOVA_PFN(addr)		((addr) >> PAGE_SHIFT)
 #define DMA_32BIT_PFN		IOVA_PFN(DMA_32BIT_MASK)
-#define DMA_64BIT_PFN		IOVA_PFN(DMA_64BIT_MASK)
+#define DMA_64BIT_PFN		IOVA_PFN(DMA_BIT_MASK(64))
 
 /* global iommu list, set NULL for ignored DMAR units */
 static struct intel_iommu **g_iommus;
diff --git a/drivers/scsi/3w-9xxx.c b/drivers/scsi/3w-9xxx.c
index 5311317..7d60bdc 100644
--- a/drivers/scsi/3w-9xxx.c
+++ b/drivers/scsi/3w-9xxx.c
@@ -2015,8 +2015,8 @@ static int __devinit twa_probe(struct pci_dev *pdev, const struct pci_device_id
 	pci_set_master(pdev);
 	pci_try_set_mwi(pdev);
 
-	if (pci_set_dma_mask(pdev, DMA_64BIT_MASK)
-	    || pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK))
+	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(64))
+	    || pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64)))
 		if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)
 		    || pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK)) {
 			TW_PRINTK(host, TW_DRIVER, 0x23, "Failed to set dma mask");
diff --git a/drivers/scsi/aacraid/aachba.c b/drivers/scsi/aacraid/aachba.c
index 90d1d08..7ad1964 100644
--- a/drivers/scsi/aacraid/aachba.c
+++ b/drivers/scsi/aacraid/aachba.c
@@ -1383,8 +1383,8 @@ int aac_get_adapter_info(struct aac_dev* dev)
 		dev->dac_support = (dacmode!=0);
 	}
 	if(dev->dac_support != 0) {
-		if (!pci_set_dma_mask(dev->pdev, DMA_64BIT_MASK) &&
-			!pci_set_consistent_dma_mask(dev->pdev, DMA_64BIT_MASK)) {
+		if (!pci_set_dma_mask(dev->pdev, DMA_BIT_MASK(64)) &&
+			!pci_set_consistent_dma_mask(dev->pdev, DMA_BIT_MASK(64))) {
 			if (!dev->in_reset)
 				printk(KERN_INFO"%s%d: 64 Bit DAC enabled\n",
 					dev->name, dev->id);
diff --git a/drivers/scsi/aic7xxx/aic79xx_osm_pci.c b/drivers/scsi/aic7xxx/aic79xx_osm_pci.c
index 6593056..032e2b1 100644
--- a/drivers/scsi/aic7xxx/aic79xx_osm_pci.c
+++ b/drivers/scsi/aic7xxx/aic79xx_osm_pci.c
@@ -195,7 +195,7 @@ ahd_linux_pci_dev_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		const u64 required_mask = dma_get_required_mask(dev);
 
 		if (required_mask > DMA_39BIT_MASK &&
-		    dma_set_mask(dev, DMA_64BIT_MASK) == 0)
+		    dma_set_mask(dev, DMA_BIT_MASK(64)) == 0)
 			ahd->flags |= AHD_64BIT_ADDRESSING;
 		else if (required_mask > DMA_32BIT_MASK &&
 			 dma_set_mask(dev, DMA_39BIT_MASK) == 0)
diff --git a/drivers/scsi/aic94xx/aic94xx_init.c b/drivers/scsi/aic94xx/aic94xx_init.c
index 2a730c4..7edbe43 100644
--- a/drivers/scsi/aic94xx/aic94xx_init.c
+++ b/drivers/scsi/aic94xx/aic94xx_init.c
@@ -790,8 +790,8 @@ static int __devinit asd_pci_probe(struct pci_dev *dev,
 		goto Err_remove;
 
 	err = -ENODEV;
-	if (!pci_set_dma_mask(dev, DMA_64BIT_MASK)
-	    && !pci_set_consistent_dma_mask(dev, DMA_64BIT_MASK))
+	if (!pci_set_dma_mask(dev, DMA_BIT_MASK(64))
+	    && !pci_set_consistent_dma_mask(dev, DMA_BIT_MASK(64)))
 		;
 	else if (!pci_set_dma_mask(dev, DMA_32BIT_MASK)
 		 && !pci_set_consistent_dma_mask(dev, DMA_32BIT_MASK))
diff --git a/drivers/scsi/arcmsr/arcmsr_hba.c b/drivers/scsi/arcmsr/arcmsr_hba.c
index 106c04d..e95b72d 100644
--- a/drivers/scsi/arcmsr/arcmsr_hba.c
+++ b/drivers/scsi/arcmsr/arcmsr_hba.c
@@ -393,7 +393,7 @@ static int arcmsr_probe(struct pci_dev *pdev,
 	acb = (struct AdapterControlBlock *)host->hostdata;
 	memset(acb, 0, sizeof (struct AdapterControlBlock));
 
-	error = pci_set_dma_mask(pdev, DMA_64BIT_MASK);
+	error = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (error) {
 		error = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 		if (error) {
diff --git a/drivers/scsi/dpt_i2o.c b/drivers/scsi/dpt_i2o.c
index 6194ed5..75a94e4 100644
--- a/drivers/scsi/dpt_i2o.c
+++ b/drivers/scsi/dpt_i2o.c
@@ -1014,7 +1014,7 @@ static int adpt_install_hba(struct scsi_host_template* sht, struct pci_dev* pDev
 	 *	See if we should enable dma64 mode.
 	 */
 	if (sizeof(dma_addr_t) > 4 &&
-	    pci_set_dma_mask(pDev, DMA_64BIT_MASK) == 0) {
+	    pci_set_dma_mask(pDev, DMA_BIT_MASK(64)) == 0) {
 		if (dma_get_required_mask(&pDev->dev) > DMA_32BIT_MASK)
 			dma64 = 1;
 	}
diff --git a/drivers/scsi/gdth.c b/drivers/scsi/gdth.c
index fb247fd..4982344 100644
--- a/drivers/scsi/gdth.c
+++ b/drivers/scsi/gdth.c
@@ -5030,7 +5030,7 @@ static int __devinit gdth_pci_probe_one(gdth_pci_str *pcistr,
 		}
 	} else {
 		shp->max_cmd_len = 16;
-		if (!pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
+		if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 			printk("GDT-PCI %d: 64-bit DMA enabled\n", ha->hanum);
 		} else if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
 			printk(KERN_WARNING "GDT-PCI %d: "
diff --git a/drivers/scsi/hptiop.c b/drivers/scsi/hptiop.c
index a48e499..cc7a7a2 100644
--- a/drivers/scsi/hptiop.c
+++ b/drivers/scsi/hptiop.c
@@ -959,7 +959,7 @@ static int __devinit hptiop_probe(struct pci_dev *pcidev,
 	pci_set_master(pcidev);
 
 	/* Enable 64bit DMA if possible */
-	if (pci_set_dma_mask(pcidev, DMA_64BIT_MASK)) {
+	if (pci_set_dma_mask(pcidev, DMA_BIT_MASK(64))) {
 		if (pci_set_dma_mask(pcidev, DMA_32BIT_MASK)) {
 			printk(KERN_ERR "hptiop: fail to set dma_mask\n");
 			goto disable_pci_device;
diff --git a/drivers/scsi/ips.c b/drivers/scsi/ips.c
index ef683f0..0973c69 100644
--- a/drivers/scsi/ips.c
+++ b/drivers/scsi/ips.c
@@ -7049,7 +7049,7 @@ ips_init_phase1(struct pci_dev *pci_dev, int *indexPtr)
 	 * are guaranteed to be < 4G.
 	 */
 	if (IPS_ENABLE_DMA64 && IPS_HAS_ENH_SGLIST(ha) &&
-	    !pci_set_dma_mask(ha->pcidev, DMA_64BIT_MASK)) {
+	    !pci_set_dma_mask(ha->pcidev, DMA_BIT_MASK(64))) {
 		(ha)->flags |= IPS_HA_ENH_SG;
 	} else {
 		if (pci_set_dma_mask(ha->pcidev, DMA_32BIT_MASK) != 0) {
diff --git a/drivers/scsi/lpfc/lpfc_init.c b/drivers/scsi/lpfc/lpfc_init.c
index 6c86731..c255b4d 100644
--- a/drivers/scsi/lpfc/lpfc_init.c
+++ b/drivers/scsi/lpfc/lpfc_init.c
@@ -2660,7 +2660,7 @@ lpfc_pci_probe_one(struct pci_dev *pdev, const struct pci_device_id *pid)
 	pci_save_state(pdev);
 	pci_try_set_mwi(pdev);
 
-	if (pci_set_dma_mask(phba->pcidev, DMA_64BIT_MASK) != 0)
+	if (pci_set_dma_mask(phba->pcidev, DMA_BIT_MASK(64)) != 0)
 		if (pci_set_dma_mask(phba->pcidev, DMA_32BIT_MASK) != 0)
 			goto out_idr_remove;
 
diff --git a/drivers/scsi/megaraid.c b/drivers/scsi/megaraid.c
index 9fdcd60..112991d 100644
--- a/drivers/scsi/megaraid.c
+++ b/drivers/scsi/megaraid.c
@@ -4793,7 +4793,7 @@ megaraid_probe_one(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	/* Set the Mode of addressing to 64 bit if we can */
 	if ((adapter->flag & BOARD_64BIT) && (sizeof(dma_addr_t) == 8)) {
-		pci_set_dma_mask(pdev, DMA_64BIT_MASK);
+		pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 		adapter->has_64bit_addr = 1;
 	} else  {
 		pci_set_dma_mask(pdev, DMA_32BIT_MASK);
diff --git a/drivers/scsi/megaraid/megaraid_mbox.c b/drivers/scsi/megaraid/megaraid_mbox.c
index 805bb61..b2c1944 100644
--- a/drivers/scsi/megaraid/megaraid_mbox.c
+++ b/drivers/scsi/megaraid/megaraid_mbox.c
@@ -900,7 +900,7 @@ megaraid_init_mbox(adapter_t *adapter)
 		adapter->pdev->device == PCI_DEVICE_ID_PERC4_DI_EVERGLADES) ||
 		(adapter->pdev->vendor == PCI_VENDOR_ID_DELL &&
 		adapter->pdev->device == PCI_DEVICE_ID_PERC4E_DI_KOBUK)) {
-		if (pci_set_dma_mask(adapter->pdev, DMA_64BIT_MASK)) {
+		if (pci_set_dma_mask(adapter->pdev, DMA_BIT_MASK(64))) {
 			con_log(CL_ANN, (KERN_WARNING
 				"megaraid: DMA mask for 64-bit failed\n"));
 
diff --git a/drivers/scsi/megaraid/megaraid_sas.c b/drivers/scsi/megaraid/megaraid_sas.c
index 17ce7ab..713de85 100644
--- a/drivers/scsi/megaraid/megaraid_sas.c
+++ b/drivers/scsi/megaraid/megaraid_sas.c
@@ -2497,7 +2497,7 @@ megasas_set_dma_mask(struct pci_dev *pdev)
 	 * All our contollers are capable of performing 64-bit DMA
 	 */
 	if (IS_DMA64) {
-		if (pci_set_dma_mask(pdev, DMA_64BIT_MASK) != 0) {
+		if (pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) != 0) {
 
 			if (pci_set_dma_mask(pdev, DMA_32BIT_MASK) != 0)
 				goto fail_set_dma_mask;
diff --git a/drivers/scsi/mvsas.c b/drivers/scsi/mvsas.c
index 23e5a87..d8093a2 100644
--- a/drivers/scsi/mvsas.c
+++ b/drivers/scsi/mvsas.c
@@ -875,8 +875,8 @@ static int pci_go_64(struct pci_dev *pdev)
 {
 	int rc;
 
-	if (!pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
-		rc = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
+	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
+		rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 		if (rc) {
 			rc = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
 			if (rc) {
diff --git a/drivers/scsi/qla1280.c b/drivers/scsi/qla1280.c
index df09820..f242614 100644
--- a/drivers/scsi/qla1280.c
+++ b/drivers/scsi/qla1280.c
@@ -4244,7 +4244,7 @@ qla1280_probe_one(struct pci_dev *pdev, const struct pci_device_id *id)
 	ha->devnum = devnum;	/* specifies microcode load address */
 
 #ifdef QLA_64BIT_PTR
-	if (pci_set_dma_mask(ha->pdev, DMA_64BIT_MASK)) {
+	if (pci_set_dma_mask(ha->pdev, DMA_BIT_MASK(64))) {
 		if (pci_set_dma_mask(ha->pdev, DMA_32BIT_MASK)) {
 			printk(KERN_WARNING "scsi(%li): Unable to set a "
 			       "suitable DMA mask - aborting\n", ha->host_no);
diff --git a/drivers/scsi/qla2xxx/qla_os.c b/drivers/scsi/qla2xxx/qla_os.c
index c11f872..03ebebf 100644
--- a/drivers/scsi/qla2xxx/qla_os.c
+++ b/drivers/scsi/qla2xxx/qla_os.c
@@ -1245,10 +1245,10 @@ qla2x00_config_dma_addressing(struct qla_hw_data *ha)
 	/* Assume a 32bit DMA mask. */
 	ha->flags.enable_64bit_addressing = 0;
 
-	if (!dma_set_mask(&ha->pdev->dev, DMA_64BIT_MASK)) {
+	if (!dma_set_mask(&ha->pdev->dev, DMA_BIT_MASK(64))) {
 		/* Any upper-dword bits set? */
 		if (MSD(dma_get_required_mask(&ha->pdev->dev)) &&
-		    !pci_set_consistent_dma_mask(ha->pdev, DMA_64BIT_MASK)) {
+		    !pci_set_consistent_dma_mask(ha->pdev, DMA_BIT_MASK(64))) {
 			/* Ok, a 64bit DMA mask is applicable. */
 			ha->flags.enable_64bit_addressing = 1;
 			ha->isp_ops->calc_req_entries = qla2x00_calc_iocbs_64;
diff --git a/drivers/scsi/qla4xxx/ql4_os.c b/drivers/scsi/qla4xxx/ql4_os.c
index eb3a414..d427fab 100644
--- a/drivers/scsi/qla4xxx/ql4_os.c
+++ b/drivers/scsi/qla4xxx/ql4_os.c
@@ -1369,8 +1369,8 @@ static void qla4xxx_config_dma_addressing(struct scsi_qla_host *ha)
 	int retval;
 
 	/* Update our PCI device dma_mask for full 64 bit mask */
-	if (pci_set_dma_mask(ha->pdev, DMA_64BIT_MASK) == 0) {
-		if (pci_set_consistent_dma_mask(ha->pdev, DMA_64BIT_MASK)) {
+	if (pci_set_dma_mask(ha->pdev, DMA_BIT_MASK(64)) == 0) {
+		if (pci_set_consistent_dma_mask(ha->pdev, DMA_BIT_MASK(64))) {
 			dev_dbg(&ha->pdev->dev,
 				  "Failed to set 64 bit PCI consistent mask; "
 				   "using 32 bit.\n");
diff --git a/drivers/scsi/stex.c b/drivers/scsi/stex.c
index a3a18ad..764c033 100644
--- a/drivers/scsi/stex.c
+++ b/drivers/scsi/stex.c
@@ -1067,8 +1067,8 @@ static struct scsi_host_template driver_template = {
 static int stex_set_dma_mask(struct pci_dev * pdev)
 {
 	int ret;
-	if (!pci_set_dma_mask(pdev, DMA_64BIT_MASK)
-		&& !pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK))
+	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))
+		&& !pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64)))
 		return 0;
 	ret = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 	if (!ret)
diff --git a/drivers/scsi/sym53c8xx_2/sym_hipd.h b/drivers/scsi/sym53c8xx_2/sym_hipd.h
index ad07880..a0c8f3a 100644
--- a/drivers/scsi/sym53c8xx_2/sym_hipd.h
+++ b/drivers/scsi/sym53c8xx_2/sym_hipd.h
@@ -1090,7 +1090,7 @@ do {									\
 	(data)->size = cpu_to_scr((((badd) >> 8) & 0xff000000) + len);	\
 } while (0)
 #elif SYM_CONF_DMA_ADDRESSING_MODE == 2
-#define DMA_DAC_MASK	DMA_64BIT_MASK
+#define DMA_DAC_MASK	DMA_BIT_MASK(64)
 int sym_lookup_dmap(struct sym_hcb *np, u32 h, int s);
 static __inline void 
 sym_build_sge(struct sym_hcb *np, struct sym_tblmove *data, u64 badd, int len)
diff --git a/drivers/sn/ioc3.c b/drivers/sn/ioc3.c
index a0aa33d..816d4c5 100644
--- a/drivers/sn/ioc3.c
+++ b/drivers/sn/ioc3.c
@@ -617,9 +617,9 @@ static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *pci_id)
 	pci_set_master(pdev);
 
 #ifdef USE_64BIT_DMA
-        ret = pci_set_dma_mask(pdev, DMA_64BIT_MASK);
+        ret = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
         if (!ret) {
-                ret = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
+                ret = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
                 if (ret < 0) {
                         printk(KERN_WARNING "%s: Unable to obtain 64 bit DMA "
                                "for consistent allocations\n",
diff --git a/drivers/staging/altpciechdma/altpciechdma.c b/drivers/staging/altpciechdma/altpciechdma.c
index f516140..3da8a52 100644
--- a/drivers/staging/altpciechdma/altpciechdma.c
+++ b/drivers/staging/altpciechdma/altpciechdma.c
@@ -847,8 +847,8 @@ static int __devinit probe(struct pci_dev *dev, const struct pci_device_id *id)
 #if 1 // @todo For now, disable 64-bit, because I do not understand the implications (DAC!)
 	/* query for DMA transfer */
 	/* @see Documentation/PCI/PCI-DMA-mapping.txt */
-	if (!pci_set_dma_mask(dev, DMA_64BIT_MASK)) {
-		pci_set_consistent_dma_mask(dev, DMA_64BIT_MASK);
+	if (!pci_set_dma_mask(dev, DMA_BIT_MASK(64))) {
+		pci_set_consistent_dma_mask(dev, DMA_BIT_MASK(64));
 		/* use 64-bit DMA */
 		printk(KERN_DEBUG "Using a 64-bit DMA mask.\n");
 	} else
diff --git a/drivers/staging/benet/be_init.c b/drivers/staging/benet/be_init.c
index 12a026c..09c3cfc 100644
--- a/drivers/staging/benet/be_init.c
+++ b/drivers/staging/benet/be_init.c
@@ -1022,7 +1022,7 @@ static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 	adapter->min_eqd = 0;
 	adapter->cur_eqd = 0;
 
-	status = pci_set_dma_mask(pdev, DMA_64BIT_MASK);
+	status = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (!status) {
 		adapter->dma_64bit_cap = true;
 	} else {
diff --git a/drivers/staging/slicoss/slicoss.c b/drivers/staging/slicoss/slicoss.c
index bf7da8f..16eed6f 100644
--- a/drivers/staging/slicoss/slicoss.c
+++ b/drivers/staging/slicoss/slicoss.c
@@ -360,9 +360,9 @@ static int __devinit slic_entry_probe(struct pci_dev *pcidev,
 		printk(slic_proc_version);
 	}
 
-	err = pci_set_dma_mask(pcidev, DMA_64BIT_MASK);
+	err = pci_set_dma_mask(pcidev, DMA_BIT_MASK(64));
 	if (!err) {
-		DBG_MSG("pci_set_dma_mask(DMA_64BIT_MASK) successful\n");
+		DBG_MSG("pci_set_dma_mask(DMA_BIT_MASK(64)) successful\n");
 	} else {
 		err = pci_set_dma_mask(pcidev, DMA_32BIT_MASK);
 		if (err) {
diff --git a/drivers/staging/sxg/sxg.c b/drivers/staging/sxg/sxg.c
index 1e0cfcd..2a7cc46 100644
--- a/drivers/staging/sxg/sxg.c
+++ b/drivers/staging/sxg/sxg.c
@@ -657,8 +657,8 @@ static int sxg_entry_probe(struct pci_dev *pcidev,
 		printk(KERN_INFO "%s\n", DRV_VERSION);
 	}
 
-	if (!(err = pci_set_dma_mask(pcidev, DMA_64BIT_MASK))) {
-		DBG_ERROR("pci_set_dma_mask(DMA_64BIT_MASK) successful\n");
+	if (!(err = pci_set_dma_mask(pcidev, DMA_BIT_MASK(64)))) {
+		DBG_ERROR("pci_set_dma_mask(DMA_BIT_MASK(64)) successful\n");
 	} else {
 		if ((err = pci_set_dma_mask(pcidev, DMA_32BIT_MASK))) {
 			DBG_ERROR
diff --git a/drivers/usb/host/ehci-hcd.c b/drivers/usb/host/ehci-hcd.c
index 4725d15..6df9153 100644
--- a/drivers/usb/host/ehci-hcd.c
+++ b/drivers/usb/host/ehci-hcd.c
@@ -584,7 +584,7 @@ static int ehci_run (struct usb_hcd *hcd)
 		ehci_writel(ehci, 0, &ehci->regs->segment);
 #if 0
 // this is deeply broken on almost all architectures
-		if (!dma_set_mask(hcd->self.controller, DMA_64BIT_MASK))
+		if (!dma_set_mask(hcd->self.controller, DMA_BIT_MASK(64)))
 			ehci_info(ehci, "enabled 64bit DMA\n");
 #endif
 	}
diff --git a/drivers/uwb/whci.c b/drivers/uwb/whci.c
index 1f8964e..79bb06c 100644
--- a/drivers/uwb/whci.c
+++ b/drivers/uwb/whci.c
@@ -160,8 +160,8 @@ static int whci_probe(struct pci_dev *pci, const struct pci_device_id *id)
 	pci_enable_msi(pci);
 	pci_set_master(pci);
 	err = -ENXIO;
-	if (!pci_set_dma_mask(pci, DMA_64BIT_MASK))
-		pci_set_consistent_dma_mask(pci, DMA_64BIT_MASK);
+	if (!pci_set_dma_mask(pci, DMA_BIT_MASK(64)))
+		pci_set_consistent_dma_mask(pci, DMA_BIT_MASK(64));
 	else if (!pci_set_dma_mask(pci, DMA_32BIT_MASK))
 		pci_set_consistent_dma_mask(pci, DMA_32BIT_MASK);
 	else
diff --git a/sound/pci/hda/hda_intel.c b/sound/pci/hda/hda_intel.c
index 11e791b..bb5986d 100644
--- a/sound/pci/hda/hda_intel.c
+++ b/sound/pci/hda/hda_intel.c
@@ -2212,8 +2212,8 @@ static int __devinit azx_create(struct snd_card *card, struct pci_dev *pci,
 	snd_printdd("chipset global capabilities = 0x%x\n", gcap);
 
 	/* allow 64bit DMA address if supported by H/W */
-	if ((gcap & 0x01) && !pci_set_dma_mask(pci, DMA_64BIT_MASK))
-		pci_set_consistent_dma_mask(pci, DMA_64BIT_MASK);
+	if ((gcap & 0x01) && !pci_set_dma_mask(pci, DMA_BIT_MASK(64)))
+		pci_set_consistent_dma_mask(pci, DMA_BIT_MASK(64));
 
 	/* read number of streams from GCAP register instead of using
 	 * hardcoded value
-- 
1.6.0.3


-- 
Regards
Yang Hongyang
