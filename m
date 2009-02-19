From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCH 06/12]Replace all DMA_32BIT_MASK micro with DMA_BIT_MASK(32)
Date: Thu, 19 Feb 2009 14:46:46 +0800
Message-ID: <499D0056.5090900@cn.fujitsu.com>
References: <499CFDC8.1070600@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Borislav Petkov <petkovbb@googlemail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59072 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751556AbZBSGp0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 01:45:26 -0500
In-Reply-To: <499CFDC8.1070600@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace all DMA_32BIT_MASK micro with DMA_BIT_MASK(32)

Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

---
 arch/arm/mach-davinci/board-evm.c             |    4 +-
 arch/arm/mach-davinci/usb.c                   |    4 +-
 arch/arm/mach-kirkwood/common.c               |    2 +-
 arch/arm/mach-orion5x/common.c                |    2 +-
 arch/arm/plat-iop/adma.c                      |    2 +-
 arch/avr32/boards/hammerhead/flash.c          |    4 +-
 arch/avr32/mach-at32ap/at32ap700x.c           |    8 +++---
 arch/ia64/kernel/pci-dma.c                    |    2 +-
 arch/mips/alchemy/common/platform.c           |   30 ++++++++++++------------
 arch/mips/alchemy/devboards/pb1200/platform.c |    4 +-
 arch/mips/nxp/pnx833x/common/platform.c       |   12 +++++-----
 arch/mips/nxp/pnx8550/common/platform.c       |    8 +++---
 arch/mips/pmc-sierra/msp71xx/msp_usb.c        |    8 +++---
 arch/powerpc/kernel/dma.c                     |    2 +-
 arch/powerpc/kernel/of_platform.c             |    2 +-
 arch/powerpc/platforms/iseries/iommu.c        |    4 +-
 arch/powerpc/platforms/ps3/system-bus.c       |    2 +-
 arch/x86/include/asm/dma-mapping.h            |    4 +-
 arch/x86/kernel/pci-dma.c                     |    4 +-
 arch/x86/kernel/pci-nommu.c                   |    2 +-
 drivers/ata/ahci.c                            |    6 ++--
 drivers/ata/pata_cs5520.c                     |    4 +-
 drivers/ata/pata_ixp4xx_cf.c                  |    2 +-
 drivers/ata/pdc_adma.c                        |    4 +-
 drivers/ata/sata_inic162x.c                   |    4 +-
 drivers/ata/sata_mv.c                         |    6 ++--
 drivers/ata/sata_qstor.c                      |    6 ++--
 drivers/ata/sata_sil24.c                      |    6 ++--
 drivers/ata/sata_vsc.c                        |    4 +-
 drivers/atm/he.c                              |    2 +-
 drivers/atm/lanai.c                           |    4 +-
 drivers/block/DAC960.c                        |    8 +++---
 drivers/block/cciss.c                         |    2 +-
 drivers/block/sx8.c                           |    2 +-
 drivers/block/umem.c                          |    2 +-
 drivers/crypto/hifn_795x.c                    |    2 +-
 drivers/crypto/ixp4xx_crypto.c                |    2 +-
 drivers/dma/ioat.c                            |    4 +-
 drivers/firmware/dcdbas.c                     |    2 +-
 drivers/ide/cs5520.c                          |    2 +-
 drivers/ide/setup-pci.c                       |    2 +-
 drivers/ieee1394/pcilynx.c                    |    2 +-
 drivers/infiniband/hw/amso1100/c2.c           |    2 +-
 drivers/infiniband/hw/ipath/ipath_driver.c    |    4 +-
 drivers/infiniband/hw/mthca/mthca_main.c      |    4 +-
 drivers/infiniband/hw/nes/nes.c               |    4 +-
 drivers/media/dvb/dm1105/dm1105.c             |    2 +-
 drivers/media/dvb/pluto2/pluto2.c             |    2 +-
 drivers/media/video/bt8xx/bttv-driver.c       |    2 +-
 drivers/media/video/cx88/cx88-alsa.c          |    2 +-
 drivers/media/video/cx88/cx88-mpeg.c          |    2 +-
 drivers/media/video/cx88/cx88-video.c         |    2 +-
 drivers/media/video/meye.c                    |    2 +-
 drivers/media/video/saa7134/saa7134-core.c    |    2 +-
 drivers/memstick/host/jmb38x_ms.c             |    2 +-
 drivers/message/fusion/mptbase.c              |    4 +-
 drivers/message/i2o/memory.c                  |    2 +-
 drivers/message/i2o/pci.c                     |    2 +-
 drivers/misc/tifm_7xx1.c                      |    2 +-
 drivers/mmc/host/sdhci-pci.c                  |    2 +-
 drivers/net/8139cp.c                          |    6 ++--
 drivers/net/acenic.c                          |    2 +-
 drivers/net/amd8111e.c                        |    2 +-
 drivers/net/atl1e/atl1e_main.c                |    4 +-
 drivers/net/atlx/atl1.c                       |    2 +-
 drivers/net/atlx/atl2.c                       |    4 +-
 drivers/net/bnx2.c                            |    2 +-
 drivers/net/bnx2x_main.c                      |    2 +-
 drivers/net/cassini.c                         |    2 +-
 drivers/net/chelsio/cxgb2.c                   |    2 +-
 drivers/net/cxgb3/cxgb3_main.c                |    2 +-
 drivers/net/e100.c                            |    2 +-
 drivers/net/e1000/e1000_main.c                |    4 +-
 drivers/net/e1000e/netdev.c                   |    8 +++---
 drivers/net/enic/enic_main.c                  |    4 +-
 drivers/net/hp100.c                           |    2 +-
 drivers/net/igb/igb_main.c                    |    4 +-
 drivers/net/ioc3-eth.c                        |    2 +-
 drivers/net/ipg.c                             |    2 +-
 drivers/net/ixgb/ixgb_main.c                  |    4 +-
 drivers/net/ixgbe/ixgbe_main.c                |   10 ++++----
 drivers/net/jme.c                             |    4 +-
 drivers/net/mlx4/main.c                       |    4 +-
 drivers/net/myri10ge/myri10ge.c               |    4 +-
 drivers/net/netxen/netxen_nic_main.c          |   12 +++++-----
 drivers/net/niu.c                             |    4 +-
 drivers/net/ns83820.c                         |    2 +-
 drivers/net/qla3xxx.c                         |    4 +-
 drivers/net/qlge/qlge_main.c                  |    4 +-
 drivers/net/r6040.c                           |    4 +-
 drivers/net/r8169.c                           |    8 +++---
 drivers/net/s2io.c                            |    2 +-
 drivers/net/sc92031.c                         |    4 +-
 drivers/net/sis190.c                          |    2 +-
 drivers/net/sis900.c                          |    2 +-
 drivers/net/skge.c                            |    4 +-
 drivers/net/sky2.c                            |    2 +-
 drivers/net/smsc9420.c                        |    2 +-
 drivers/net/sungem.c                          |    2 +-
 drivers/net/tehuti.c                          |    4 +-
 drivers/net/tehuti.h                          |    4 ---
 drivers/net/tg3.c                             |   10 ++++----
 drivers/net/tlan.c                            |    2 +-
 drivers/net/tokenring/lanstreamer.c           |    2 +-
 drivers/net/tulip/dmfe.c                      |    2 +-
 drivers/net/tulip/uli526x.c                   |    2 +-
 drivers/net/tulip/winbond-840.c               |    2 +-
 drivers/net/typhoon.c                         |    2 +-
 drivers/net/via-rhine.c                       |    2 +-
 drivers/net/wan/wanxl.c                       |    4 +-
 drivers/net/wireless/adm8211.c                |    4 +-
 drivers/net/wireless/ath5k/base.c             |    2 +-
 drivers/net/wireless/ath9k/main.c             |    4 +-
 drivers/net/wireless/b43/dma.c                |    8 +++---
 drivers/net/wireless/b43legacy/dma.c          |    8 +++---
 drivers/net/wireless/ipw2x00/ipw2100.c        |    2 +-
 drivers/net/wireless/ipw2x00/ipw2200.c        |    4 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c   |    4 +-
 drivers/net/wireless/p54/p54pci.c             |    4 +-
 drivers/net/wireless/prism54/islpci_hotplug.c |    2 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c       |    2 +-
 drivers/pci/intel-iommu.c                     |    8 +++---
 drivers/rapidio/rio-scan.c                    |    4 +-
 drivers/scsi/3w-9xxx.c                        |    4 +-
 drivers/scsi/3w-xxxx.h                        |    2 +-
 drivers/scsi/BusLogic.c                       |    6 ++--
 drivers/scsi/a100u2w.c                        |    2 +-
 drivers/scsi/aacraid/aachba.c                 |    4 +-
 drivers/scsi/aacraid/commsup.c                |    6 ++--
 drivers/scsi/aacraid/linit.c                  |    6 ++--
 drivers/scsi/aic7xxx/aic79xx_osm_pci.c        |    6 ++--
 drivers/scsi/aic7xxx/aic7xxx_osm_pci.c        |    4 +-
 drivers/scsi/aic94xx/aic94xx_init.c           |    4 +-
 drivers/scsi/arcmsr/arcmsr_hba.c              |    2 +-
 drivers/scsi/atp870u.c                        |    2 +-
 drivers/scsi/dpt_i2o.c                        |    6 ++--
 drivers/scsi/eata.c                           |    2 +-
 drivers/scsi/gdth.c                           |    4 +-
 drivers/scsi/hptiop.c                         |    2 +-
 drivers/scsi/initio.c                         |    2 +-
 drivers/scsi/ipr.c                            |    2 +-
 drivers/scsi/ips.c                            |    2 +-
 drivers/scsi/lasi700.c                        |    2 +-
 drivers/scsi/lpfc/lpfc_init.c                 |    2 +-
 drivers/scsi/megaraid.c                       |    4 +-
 drivers/scsi/megaraid/megaraid_mbox.c         |    4 +-
 drivers/scsi/megaraid/megaraid_sas.c          |    4 +-
 drivers/scsi/mvsas.c                          |    6 ++--
 drivers/scsi/nsp32.c                          |    2 +-
 drivers/scsi/qla1280.c                        |    4 +-
 drivers/scsi/qla2xxx/qla_os.c                 |    4 +-
 drivers/scsi/qla4xxx/ql4_os.c                 |    4 +-
 drivers/scsi/sni_53c710.c                     |    2 +-
 drivers/scsi/stex.c                           |    4 +-
 drivers/scsi/sym53c8xx_2/sym_glue.c           |    2 +-
 drivers/scsi/sym53c8xx_2/sym_hipd.h           |    2 +-
 drivers/staging/agnx/pci.c                    |    4 +-
 drivers/staging/altpciechdma/altpciechdma.c   |    4 +-
 drivers/staging/benet/be_init.c               |    2 +-
 drivers/staging/slicoss/slicoss.c             |    4 +-
 drivers/staging/sxg/sxg.c                     |    4 +-
 drivers/usb/host/ehci-ps3.c                   |    2 +-
 drivers/usb/host/ohci-ps3.c                   |    2 +-
 drivers/uwb/whci.c                            |    4 +-
 include/linux/dma-mapping.h                   |    2 +-
 lib/swiotlb.c                                 |    2 +-
 sound/pci/ad1889.c                            |    4 +-
 sound/pci/au88x0/au88x0.c                     |    4 +-
 sound/pci/aw2/aw2-alsa.c                      |    4 +-
 sound/pci/ca0106/ca0106_main.c                |    4 +-
 sound/pci/cs5535audio/cs5535audio.c           |    4 +-
 sound/pci/mixart/mixart.c                     |    2 +-
 sound/pci/pcxhr/pcxhr.c                       |    2 +-
 sound/soc/blackfin/bf5xx-ac97-pcm.c           |    4 +-
 sound/soc/blackfin/bf5xx-i2s-pcm.c            |    4 +-
 sound/soc/omap/omap-pcm.c                     |    2 +-
 sound/soc/pxa/pxa2xx-pcm.c                    |    4 +-
 sound/soc/s3c24xx/s3c24xx-pcm.c               |    2 +-
 178 files changed, 323 insertions(+), 327 deletions(-)

diff --git a/arch/arm/mach-davinci/board-evm.c b/arch/arm/mach-davinci/board-evm.c
index a957d23..4fa1ea5 100644
--- a/arch/arm/mach-davinci/board-evm.c
+++ b/arch/arm/mach-davinci/board-evm.c
@@ -118,7 +118,7 @@ static struct resource ide_resources[] = {
 	},
 };
 
-static u64 ide_dma_mask = DMA_32BIT_MASK;
+static u64 ide_dma_mask = DMA_BIT_MASK(32);
 
 static struct platform_device ide_dev = {
 	.name           = "palm_bk3710",
@@ -127,7 +127,7 @@ static struct platform_device ide_dev = {
 	.num_resources  = ARRAY_SIZE(ide_resources),
 	.dev = {
 		.dma_mask		= &ide_dma_mask,
-		.coherent_dma_mask      = DMA_32BIT_MASK,
+		.coherent_dma_mask      = DMA_BIT_MASK(32),
 	},
 };
 
diff --git a/arch/arm/mach-davinci/usb.c b/arch/arm/mach-davinci/usb.c
index 867ead2..a090eac 100644
--- a/arch/arm/mach-davinci/usb.c
+++ b/arch/arm/mach-davinci/usb.c
@@ -63,7 +63,7 @@ static struct resource usb_resources[] = {
 	},
 };
 
-static u64 usb_dmamask = DMA_32BIT_MASK;
+static u64 usb_dmamask = DMA_BIT_MASK(32);
 
 static struct platform_device usb_dev = {
 	.name           = "musb_hdrc",
@@ -71,7 +71,7 @@ static struct platform_device usb_dev = {
 	.dev = {
 		.platform_data		= &usb_data,
 		.dma_mask		= &usb_dmamask,
-		.coherent_dma_mask      = DMA_32BIT_MASK,
+		.coherent_dma_mask      = DMA_BIT_MASK(32),
 	},
 	.resource       = usb_resources,
 	.num_resources  = ARRAY_SIZE(usb_resources),
diff --git a/arch/arm/mach-kirkwood/common.c b/arch/arm/mach-kirkwood/common.c
index 25b41dc..f91ae72 100644
--- a/arch/arm/mach-kirkwood/common.c
+++ b/arch/arm/mach-kirkwood/common.c
@@ -420,7 +420,7 @@ static struct mv_xor_platform_shared_data kirkwood_xor_shared_data = {
 	.dram		= &kirkwood_mbus_dram_info,
 };
 
-static u64 kirkwood_xor_dmamask = DMA_32BIT_MASK;
+static u64 kirkwood_xor_dmamask = DMA_BIT_MASK(32);
 
 
 /*****************************************************************************
diff --git a/arch/arm/mach-orion5x/common.c b/arch/arm/mach-orion5x/common.c
index 19cbe34..9c24061 100644
--- a/arch/arm/mach-orion5x/common.c
+++ b/arch/arm/mach-orion5x/common.c
@@ -452,7 +452,7 @@ static struct platform_device orion5x_xor_shared = {
 	.resource	= orion5x_xor_shared_resources,
 };
 
-static u64 orion5x_xor_dmamask = DMA_32BIT_MASK;
+static u64 orion5x_xor_dmamask = DMA_BIT_MASK(32);
 
 static struct resource orion5x_xor0_resources[] = {
 	[0] = {
diff --git a/arch/arm/plat-iop/adma.c b/arch/arm/plat-iop/adma.c
index a2a94f6..3c127aa 100644
--- a/arch/arm/plat-iop/adma.c
+++ b/arch/arm/plat-iop/adma.c
@@ -119,7 +119,7 @@ static struct resource iop3xx_aau_resources[] = {
 	}
 };
 
-static u64 iop3xx_adma_dmamask = DMA_32BIT_MASK;
+static u64 iop3xx_adma_dmamask = DMA_BIT_MASK(32);
 
 static struct iop_adma_platform_data iop3xx_dma_0_data = {
 	.hw_id = DMA0_ID,
diff --git a/arch/avr32/boards/hammerhead/flash.c b/arch/avr32/boards/hammerhead/flash.c
index a98c6dd..548165b 100644
--- a/arch/avr32/boards/hammerhead/flash.c
+++ b/arch/avr32/boards/hammerhead/flash.c
@@ -281,13 +281,13 @@ static struct resource hh_fpga0_resource[] = {
 	},
 };
 
-static u64 hh_fpga0_dma_mask = DMA_32BIT_MASK;
+static u64 hh_fpga0_dma_mask = DMA_BIT_MASK(32);
 static struct platform_device hh_fpga0_device = {
 	.name		= "hh_fpga",
 	.id		= 0,
 	.dev		= {
 		.dma_mask = &hh_fpga0_dma_mask,
-		.coherent_dma_mask = DMA_32BIT_MASK,
+		.coherent_dma_mask = DMA_BIT_MASK(32),
 	},
 	.resource	= hh_fpga0_resource,
 	.num_resources	= ARRAY_SIZE(hh_fpga0_resource),
diff --git a/arch/avr32/mach-at32ap/at32ap700x.c b/arch/avr32/mach-at32ap/at32ap700x.c
index 3fbfd1e..dcb2474 100644
--- a/arch/avr32/mach-at32ap/at32ap700x.c
+++ b/arch/avr32/mach-at32ap/at32ap700x.c
@@ -57,26 +57,26 @@
  * don't ... tc, smc, pio, rtc, watchdog, pwm, ps2, and more.
  */
 #define DEFINE_DEV(_name, _id)					\
-static u64 _name##_id##_dma_mask = DMA_32BIT_MASK;		\
+static u64 _name##_id##_dma_mask = DMA_BIT_MASK(32);		\
 static struct platform_device _name##_id##_device = {		\
 	.name		= #_name,				\
 	.id		= _id,					\
 	.dev		= {					\
 		.dma_mask = &_name##_id##_dma_mask,		\
-		.coherent_dma_mask = DMA_32BIT_MASK,		\
+		.coherent_dma_mask = DMA_BIT_MASK(32),		\
 	},							\
 	.resource	= _name##_id##_resource,		\
 	.num_resources	= ARRAY_SIZE(_name##_id##_resource),	\
 }
 #define DEFINE_DEV_DATA(_name, _id)				\
-static u64 _name##_id##_dma_mask = DMA_32BIT_MASK;		\
+static u64 _name##_id##_dma_mask = DMA_BIT_MASK(32);		\
 static struct platform_device _name##_id##_device = {		\
 	.name		= #_name,				\
 	.id		= _id,					\
 	.dev		= {					\
 		.dma_mask = &_name##_id##_dma_mask,		\
 		.platform_data	= &_name##_id##_data,		\
-		.coherent_dma_mask = DMA_32BIT_MASK,		\
+		.coherent_dma_mask = DMA_BIT_MASK(32),		\
 	},							\
 	.resource	= _name##_id##_resource,		\
 	.num_resources	= ARRAY_SIZE(_name##_id##_resource),	\
diff --git a/arch/ia64/kernel/pci-dma.c b/arch/ia64/kernel/pci-dma.c
index 885707a..0fce76f 100644
--- a/arch/ia64/kernel/pci-dma.c
+++ b/arch/ia64/kernel/pci-dma.c
@@ -40,7 +40,7 @@ int iommu_detected __read_mostly;
    to i386. */
 struct device fallback_dev = {
 	.init_name = "fallback device",
-	.coherent_dma_mask = DMA_32BIT_MASK,
+	.coherent_dma_mask = DMA_BIT_MASK(32),
 	.dma_mask = &fallback_dev.coherent_dma_mask,
 };
 
diff --git a/arch/mips/alchemy/common/platform.c b/arch/mips/alchemy/common/platform.c
index 5c76c64..117f99f 100644
--- a/arch/mips/alchemy/common/platform.c
+++ b/arch/mips/alchemy/common/platform.c
@@ -80,14 +80,14 @@ static struct resource au1xxx_usb_ohci_resources[] = {
 };
 
 /* The dmamask must be set for OHCI to work */
-static u64 ohci_dmamask = DMA_32BIT_MASK;
+static u64 ohci_dmamask = DMA_BIT_MASK(32);
 
 static struct platform_device au1xxx_usb_ohci_device = {
 	.name		= "au1xxx-ohci",
 	.id		= 0,
 	.dev = {
 		.dma_mask		= &ohci_dmamask,
-		.coherent_dma_mask	= DMA_32BIT_MASK,
+		.coherent_dma_mask	= DMA_BIT_MASK(32),
 	},
 	.num_resources	= ARRAY_SIZE(au1xxx_usb_ohci_resources),
 	.resource	= au1xxx_usb_ohci_resources,
@@ -109,14 +109,14 @@ static struct resource au1100_lcd_resources[] = {
 	}
 };
 
-static u64 au1100_lcd_dmamask = DMA_32BIT_MASK;
+static u64 au1100_lcd_dmamask = DMA_BIT_MASK(32);
 
 static struct platform_device au1100_lcd_device = {
 	.name           = "au1100-lcd",
 	.id             = 0,
 	.dev = {
 		.dma_mask               = &au1100_lcd_dmamask,
-		.coherent_dma_mask      = DMA_32BIT_MASK,
+		.coherent_dma_mask      = DMA_BIT_MASK(32),
 	},
 	.num_resources  = ARRAY_SIZE(au1100_lcd_resources),
 	.resource       = au1100_lcd_resources,
@@ -138,14 +138,14 @@ static struct resource au1xxx_usb_ehci_resources[] = {
 	},
 };
 
-static u64 ehci_dmamask = DMA_32BIT_MASK;
+static u64 ehci_dmamask = DMA_BIT_MASK(32);
 
 static struct platform_device au1xxx_usb_ehci_device = {
 	.name		= "au1xxx-ehci",
 	.id		= 0,
 	.dev = {
 		.dma_mask		= &ehci_dmamask,
-		.coherent_dma_mask	= DMA_32BIT_MASK,
+		.coherent_dma_mask	= DMA_BIT_MASK(32),
 	},
 	.num_resources	= ARRAY_SIZE(au1xxx_usb_ehci_resources),
 	.resource	= au1xxx_usb_ehci_resources,
@@ -165,14 +165,14 @@ static struct resource au1xxx_usb_gdt_resources[] = {
 	},
 };
 
-static u64 udc_dmamask = DMA_32BIT_MASK;
+static u64 udc_dmamask = DMA_BIT_MASK(32);
 
 static struct platform_device au1xxx_usb_gdt_device = {
 	.name		= "au1xxx-udc",
 	.id		= 0,
 	.dev = {
 		.dma_mask		= &udc_dmamask,
-		.coherent_dma_mask	= DMA_32BIT_MASK,
+		.coherent_dma_mask	= DMA_BIT_MASK(32),
 	},
 	.num_resources	= ARRAY_SIZE(au1xxx_usb_gdt_resources),
 	.resource	= au1xxx_usb_gdt_resources,
@@ -192,14 +192,14 @@ static struct resource au1xxx_usb_otg_resources[] = {
 	},
 };
 
-static u64 uoc_dmamask = DMA_32BIT_MASK;
+static u64 uoc_dmamask = DMA_BIT_MASK(32);
 
 static struct platform_device au1xxx_usb_otg_device = {
 	.name		= "au1xxx-uoc",
 	.id		= 0,
 	.dev = {
 		.dma_mask		= &uoc_dmamask,
-		.coherent_dma_mask	= DMA_32BIT_MASK,
+		.coherent_dma_mask	= DMA_BIT_MASK(32),
 	},
 	.num_resources	= ARRAY_SIZE(au1xxx_usb_otg_resources),
 	.resource	= au1xxx_usb_otg_resources,
@@ -218,20 +218,20 @@ static struct resource au1200_lcd_resources[] = {
 	}
 };
 
-static u64 au1200_lcd_dmamask = DMA_32BIT_MASK;
+static u64 au1200_lcd_dmamask = DMA_BIT_MASK(32);
 
 static struct platform_device au1200_lcd_device = {
 	.name           = "au1200-lcd",
 	.id             = 0,
 	.dev = {
 		.dma_mask               = &au1200_lcd_dmamask,
-		.coherent_dma_mask      = DMA_32BIT_MASK,
+		.coherent_dma_mask      = DMA_BIT_MASK(32),
 	},
 	.num_resources  = ARRAY_SIZE(au1200_lcd_resources),
 	.resource       = au1200_lcd_resources,
 };
 
-static u64 au1xxx_mmc_dmamask =  DMA_32BIT_MASK;
+static u64 au1xxx_mmc_dmamask =  DMA_BIT_MASK(32);
 
 extern struct au1xmmc_platform_data au1xmmc_platdata[2];
 
@@ -263,7 +263,7 @@ static struct platform_device au1200_mmc0_device = {
 	.id = 0,
 	.dev = {
 		.dma_mask		= &au1xxx_mmc_dmamask,
-		.coherent_dma_mask	= DMA_32BIT_MASK,
+		.coherent_dma_mask	= DMA_BIT_MASK(32),
 		.platform_data		= &au1xmmc_platdata[0],
 	},
 	.num_resources	= ARRAY_SIZE(au1200_mmc0_resources),
@@ -299,7 +299,7 @@ static struct platform_device au1200_mmc1_device = {
 	.id = 1,
 	.dev = {
 		.dma_mask		= &au1xxx_mmc_dmamask,
-		.coherent_dma_mask	= DMA_32BIT_MASK,
+		.coherent_dma_mask	= DMA_BIT_MASK(32),
 		.platform_data		= &au1xmmc_platdata[1],
 	},
 	.num_resources	= ARRAY_SIZE(au1200_mmc1_resources),
diff --git a/arch/mips/alchemy/devboards/pb1200/platform.c b/arch/mips/alchemy/devboards/pb1200/platform.c
index 9530329..1434b31 100644
--- a/arch/mips/alchemy/devboards/pb1200/platform.c
+++ b/arch/mips/alchemy/devboards/pb1200/platform.c
@@ -118,14 +118,14 @@ static struct resource ide_resources[] = {
 	}
 };
 
-static u64 ide_dmamask = DMA_32BIT_MASK;
+static u64 ide_dmamask = DMA_BIT_MASK(32);
 
 static struct platform_device ide_device = {
 	.name		= "au1200-ide",
 	.id		= 0,
 	.dev = {
 		.dma_mask 		= &ide_dmamask,
-		.coherent_dma_mask	= DMA_32BIT_MASK,
+		.coherent_dma_mask	= DMA_BIT_MASK(32),
 	},
 	.num_resources	= ARRAY_SIZE(ide_resources),
 	.resource	= ide_resources
diff --git a/arch/mips/nxp/pnx833x/common/platform.c b/arch/mips/nxp/pnx833x/common/platform.c
index b1ccbcc..01f8345 100644
--- a/arch/mips/nxp/pnx833x/common/platform.c
+++ b/arch/mips/nxp/pnx833x/common/platform.c
@@ -42,7 +42,7 @@
 #include <irq-mapping.h>
 #include <pnx833x.h>
 
-static u64 uart_dmamask     = DMA_32BIT_MASK;
+static u64 uart_dmamask     = DMA_BIT_MASK(32);
 
 static struct resource pnx833x_uart_resources[] = {
 	[0] = {
@@ -101,14 +101,14 @@ static struct platform_device pnx833x_uart_device = {
 	.id		= -1,
 	.dev = {
 		.dma_mask		= &uart_dmamask,
-		.coherent_dma_mask	= DMA_32BIT_MASK,
+		.coherent_dma_mask	= DMA_BIT_MASK(32),
 		.platform_data		= pnx8xxx_ports,
 	},
 	.num_resources	= ARRAY_SIZE(pnx833x_uart_resources),
 	.resource	= pnx833x_uart_resources,
 };
 
-static u64 ehci_dmamask     = DMA_32BIT_MASK;
+static u64 ehci_dmamask     = DMA_BIT_MASK(32);
 
 static struct resource pnx833x_usb_ehci_resources[] = {
 	[0] = {
@@ -128,7 +128,7 @@ static struct platform_device pnx833x_usb_ehci_device = {
 	.id		= -1,
 	.dev = {
 		.dma_mask		= &ehci_dmamask,
-		.coherent_dma_mask	= DMA_32BIT_MASK,
+		.coherent_dma_mask	= DMA_BIT_MASK(32),
 	},
 	.num_resources	= ARRAY_SIZE(pnx833x_usb_ehci_resources),
 	.resource	= pnx833x_usb_ehci_resources,
@@ -198,7 +198,7 @@ static struct platform_device pnx833x_i2c1_device = {
 };
 #endif
 
-static u64 ethernet_dmamask = DMA_32BIT_MASK;
+static u64 ethernet_dmamask = DMA_BIT_MASK(32);
 
 static struct resource pnx833x_ethernet_resources[] = {
 	[0] = {
@@ -218,7 +218,7 @@ static struct platform_device pnx833x_ethernet_device = {
 	.id   = -1,
 	.dev  = {
 		.dma_mask          = &ethernet_dmamask,
-		.coherent_dma_mask = DMA_32BIT_MASK,
+		.coherent_dma_mask = DMA_BIT_MASK(32),
 	},
 	.num_resources = ARRAY_SIZE(pnx833x_ethernet_resources),
 	.resource      = pnx833x_ethernet_resources,
diff --git a/arch/mips/nxp/pnx8550/common/platform.c b/arch/mips/nxp/pnx8550/common/platform.c
index 21d2955..5264cc0 100644
--- a/arch/mips/nxp/pnx8550/common/platform.c
+++ b/arch/mips/nxp/pnx8550/common/platform.c
@@ -92,16 +92,16 @@ struct pnx8xxx_port pnx8xxx_ports[] = {
 };
 
 /* The dmamask must be set for OHCI to work */
-static u64 ohci_dmamask = DMA_32BIT_MASK;
+static u64 ohci_dmamask = DMA_BIT_MASK(32);
 
-static u64 uart_dmamask = DMA_32BIT_MASK;
+static u64 uart_dmamask = DMA_BIT_MASK(32);
 
 static struct platform_device pnx8550_usb_ohci_device = {
 	.name		= "pnx8550-ohci",
 	.id		= -1,
 	.dev = {
 		.dma_mask		= &ohci_dmamask,
-		.coherent_dma_mask	= DMA_32BIT_MASK,
+		.coherent_dma_mask	= DMA_BIT_MASK(32),
 	},
 	.num_resources	= ARRAY_SIZE(pnx8550_usb_ohci_resources),
 	.resource	= pnx8550_usb_ohci_resources,
@@ -112,7 +112,7 @@ static struct platform_device pnx8550_uart_device = {
 	.id		= -1,
 	.dev = {
 		.dma_mask		= &uart_dmamask,
-		.coherent_dma_mask	= DMA_32BIT_MASK,
+		.coherent_dma_mask	= DMA_BIT_MASK(32),
 		.platform_data = pnx8xxx_ports,
 	},
 	.num_resources	= ARRAY_SIZE(pnx8550_uart_resources),
diff --git a/arch/mips/pmc-sierra/msp71xx/msp_usb.c b/arch/mips/pmc-sierra/msp71xx/msp_usb.c
index f7ca4f5..0ee01e3 100644
--- a/arch/mips/pmc-sierra/msp71xx/msp_usb.c
+++ b/arch/mips/pmc-sierra/msp71xx/msp_usb.c
@@ -49,14 +49,14 @@ static struct resource msp_usbhost_resources [] = {
 	},
 };
 
-static u64 msp_usbhost_dma_mask = DMA_32BIT_MASK;
+static u64 msp_usbhost_dma_mask = DMA_BIT_MASK(32);
 
 static struct platform_device msp_usbhost_device = {
 	.name	= "pmcmsp-ehci",
 	.id	= 0,
 	.dev	= {
 		.dma_mask = &msp_usbhost_dma_mask,
-		.coherent_dma_mask = DMA_32BIT_MASK,
+		.coherent_dma_mask = DMA_BIT_MASK(32),
 	},
 	.num_resources 	= ARRAY_SIZE(msp_usbhost_resources),
 	.resource	= msp_usbhost_resources,
@@ -77,14 +77,14 @@ static struct resource msp_usbdev_resources [] = {
 	},
 };
 
-static u64 msp_usbdev_dma_mask = DMA_32BIT_MASK;
+static u64 msp_usbdev_dma_mask = DMA_BIT_MASK(32);
 
 static struct platform_device msp_usbdev_device = {
 	.name	= "msp71xx_udc",
 	.id	= 0,
 	.dev	= {
 		.dma_mask = &msp_usbdev_dma_mask,
-		.coherent_dma_mask = DMA_32BIT_MASK,
+		.coherent_dma_mask = DMA_BIT_MASK(32),
 	},
 	.num_resources	= ARRAY_SIZE(msp_usbdev_resources),
 	.resource	= msp_usbdev_resources,
diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
index 1c5c8a6..53c7788 100644
--- a/arch/powerpc/kernel/dma.c
+++ b/arch/powerpc/kernel/dma.c
@@ -94,7 +94,7 @@ static int dma_direct_dma_supported(struct device *dev, u64 mask)
 	 * done via some global so platforms can set the limit in case
 	 * they have limited DMA windows
 	 */
-	return mask >= DMA_32BIT_MASK;
+	return mask >= DMA_BIT_MASK(32);
 #else
 	return 1;
 #endif
diff --git a/arch/powerpc/kernel/of_platform.c b/arch/powerpc/kernel/of_platform.c
index 3f37a6e..87df428 100644
--- a/arch/powerpc/kernel/of_platform.c
+++ b/arch/powerpc/kernel/of_platform.c
@@ -76,7 +76,7 @@ struct of_device* of_platform_device_create(struct device_node *np,
 		return NULL;
 
 	dev->dma_mask = 0xffffffffUL;
-	dev->dev.coherent_dma_mask = DMA_32BIT_MASK;
+	dev->dev.coherent_dma_mask = DMA_BIT_MASK(32);
 
 	dev->dev.bus = &of_platform_bus_type;
 
diff --git a/arch/powerpc/platforms/iseries/iommu.c b/arch/powerpc/platforms/iseries/iommu.c
index 6ed75bf..ff43f1f 100644
--- a/arch/powerpc/platforms/iseries/iommu.c
+++ b/arch/powerpc/platforms/iseries/iommu.c
@@ -202,7 +202,7 @@ static struct iommu_table vio_iommu_table;
 void *iseries_hv_alloc(size_t size, dma_addr_t *dma_handle, gfp_t flag)
 {
 	return iommu_alloc_coherent(NULL, &vio_iommu_table, size, dma_handle,
-				DMA_32BIT_MASK, flag, -1);
+				DMA_BIT_MASK(32), flag, -1);
 }
 EXPORT_SYMBOL_GPL(iseries_hv_alloc);
 
@@ -217,7 +217,7 @@ dma_addr_t iseries_hv_map(void *vaddr, size_t size,
 {
 	return iommu_map_page(NULL, &vio_iommu_table, virt_to_page(vaddr),
 			      (unsigned long)vaddr % PAGE_SIZE, size,
-			      DMA_32BIT_MASK, direction, NULL);
+			      DMA_BIT_MASK(32), direction, NULL);
 }
 
 void iseries_hv_unmap(dma_addr_t dma_handle, size_t size,
diff --git a/arch/powerpc/platforms/ps3/system-bus.c b/arch/powerpc/platforms/ps3/system-bus.c
index 58311a8..8fd094d 100644
--- a/arch/powerpc/platforms/ps3/system-bus.c
+++ b/arch/powerpc/platforms/ps3/system-bus.c
@@ -689,7 +689,7 @@ static void ps3_ioc0_unmap_sg(struct device *_dev, struct scatterlist *sg,
 
 static int ps3_dma_supported(struct device *_dev, u64 mask)
 {
-	return mask >= DMA_32BIT_MASK;
+	return mask >= DMA_BIT_MASK(32);
 }
 
 static struct dma_mapping_ops ps3_sb_dma_ops = {
diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
index 132a134..0d49479 100644
--- a/arch/x86/include/asm/dma-mapping.h
+++ b/arch/x86/include/asm/dma-mapping.h
@@ -244,7 +244,7 @@ static inline unsigned long dma_alloc_coherent_mask(struct device *dev,
 
 	dma_mask = dev->coherent_dma_mask;
 	if (!dma_mask)
-		dma_mask = (gfp & GFP_DMA) ? DMA_24BIT_MASK : DMA_32BIT_MASK;
+		dma_mask = (gfp & GFP_DMA) ? DMA_24BIT_MASK : DMA_BIT_MASK(32);
 
 	return dma_mask;
 }
@@ -256,7 +256,7 @@ static inline gfp_t dma_alloc_coherent_gfp_flags(struct device *dev, gfp_t gfp)
 	if (dma_mask <= DMA_24BIT_MASK)
 		gfp |= GFP_DMA;
 #ifdef CONFIG_X86_64
-	if (dma_mask <= DMA_32BIT_MASK && !(gfp & GFP_DMA))
+	if (dma_mask <= DMA_BIT_MASK(32) && !(gfp & GFP_DMA))
 		gfp |= GFP_DMA32;
 #endif
        return gfp;
diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
index 5824b44..7aa572f 100644
--- a/arch/x86/kernel/pci-dma.c
+++ b/arch/x86/kernel/pci-dma.c
@@ -39,7 +39,7 @@ EXPORT_SYMBOL(bad_dma_address);
    to older i386. */
 struct device x86_dma_fallback_dev = {
 	.init_name = "fallback device",
-	.coherent_dma_mask = DMA_32BIT_MASK,
+	.coherent_dma_mask = DMA_BIT_MASK(32),
 	.dma_mask = &x86_dma_fallback_dev.coherent_dma_mask,
 };
 EXPORT_SYMBOL(x86_dma_fallback_dev);
@@ -144,7 +144,7 @@ again:
 	if (!is_buffer_dma_capable(dma_mask, addr, size)) {
 		__free_pages(page, get_order(size));
 
-		if (dma_mask < DMA_32BIT_MASK && !(flag & GFP_DMA)) {
+		if (dma_mask < DMA_BIT_MASK(32) && !(flag & GFP_DMA)) {
 			flag = (flag & ~GFP_DMA32) | GFP_DMA;
 			goto again;
 		}
diff --git a/arch/x86/kernel/pci-nommu.c b/arch/x86/kernel/pci-nommu.c
index c70ab5a..915edeb 100644
--- a/arch/x86/kernel/pci-nommu.c
+++ b/arch/x86/kernel/pci-nommu.c
@@ -15,7 +15,7 @@ static int
 check_addr(char *name, struct device *hwdev, dma_addr_t bus, size_t size)
 {
 	if (hwdev && !is_buffer_dma_capable(*hwdev->dma_mask, bus, size)) {
-		if (*hwdev->dma_mask >= DMA_32BIT_MASK)
+		if (*hwdev->dma_mask >= DMA_BIT_MASK(32))
 			printk(KERN_ERR
 			    "nommu_%s: overflow %Lx+%zu of device mask %Lx\n",
 				name, (long long)bus, size,
diff --git a/drivers/ata/ahci.c b/drivers/ata/ahci.c
index 163ac4b..663d9a7 100644
--- a/drivers/ata/ahci.c
+++ b/drivers/ata/ahci.c
@@ -2408,7 +2408,7 @@ static int ahci_configure_dma_masks(struct pci_dev *pdev, int using_dac)
 	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 		if (rc) {
-			rc = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+			rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 			if (rc) {
 				dev_printk(KERN_ERR, &pdev->dev,
 					   "64-bit DMA enable failed\n");
@@ -2416,13 +2416,13 @@ static int ahci_configure_dma_masks(struct pci_dev *pdev, int using_dac)
 			}
 		}
 	} else {
-		rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc) {
 			dev_printk(KERN_ERR, &pdev->dev,
 				   "32-bit DMA enable failed\n");
 			return rc;
 		}
-		rc = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+		rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc) {
 			dev_printk(KERN_ERR, &pdev->dev,
 				   "32-bit consistent DMA enable failed\n");
diff --git a/drivers/ata/pata_cs5520.c b/drivers/ata/pata_cs5520.c
index 1186bcd..e9cc100 100644
--- a/drivers/ata/pata_cs5520.c
+++ b/drivers/ata/pata_cs5520.c
@@ -203,11 +203,11 @@ static int __devinit cs5520_init_one(struct pci_dev *pdev, const struct pci_devi
 		return -ENODEV;
 	}
 
-	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
+	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
 		printk(KERN_ERR DRV_NAME ": unable to configure DMA mask.\n");
 		return -ENODEV;
 	}
-	if (pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK)) {
+	if (pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32))) {
 		printk(KERN_ERR DRV_NAME ": unable to configure consistent DMA mask.\n");
 		return -ENODEV;
 	}
diff --git a/drivers/ata/pata_ixp4xx_cf.c b/drivers/ata/pata_ixp4xx_cf.c
index b173c15..fa3a80a 100644
--- a/drivers/ata/pata_ixp4xx_cf.c
+++ b/drivers/ata/pata_ixp4xx_cf.c
@@ -157,7 +157,7 @@ static __devinit int ixp4xx_pata_probe(struct platform_device *pdev)
 		return -ENOMEM;
 
 	/* acquire resources and fill host */
-	pdev->dev.coherent_dma_mask = DMA_32BIT_MASK;
+	pdev->dev.coherent_dma_mask = DMA_BIT_MASK(32);
 
 	data->cs0 = devm_ioremap(&pdev->dev, cs0->start, 0x1000);
 	data->cs1 = devm_ioremap(&pdev->dev, cs1->start, 0x1000);
diff --git a/drivers/ata/pdc_adma.c b/drivers/ata/pdc_adma.c
index be53545..80a7997 100644
--- a/drivers/ata/pdc_adma.c
+++ b/drivers/ata/pdc_adma.c
@@ -605,13 +605,13 @@ static int adma_set_dma_masks(struct pci_dev *pdev, void __iomem *mmio_base)
 {
 	int rc;
 
-	rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (rc) {
 		dev_printk(KERN_ERR, &pdev->dev,
 			"32-bit DMA enable failed\n");
 		return rc;
 	}
-	rc = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+	rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (rc) {
 		dev_printk(KERN_ERR, &pdev->dev,
 			"32-bit consistent DMA enable failed\n");
diff --git a/drivers/ata/sata_inic162x.c b/drivers/ata/sata_inic162x.c
index fbbd87c..19f4053 100644
--- a/drivers/ata/sata_inic162x.c
+++ b/drivers/ata/sata_inic162x.c
@@ -861,14 +861,14 @@ static int inic_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	/* Set dma_mask.  This devices doesn't support 64bit addressing. */
-	rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (rc) {
 		dev_printk(KERN_ERR, &pdev->dev,
 			   "32-bit DMA enable failed\n");
 		return rc;
 	}
 
-	rc = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+	rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (rc) {
 		dev_printk(KERN_ERR, &pdev->dev,
 			   "32-bit consistent DMA enable failed\n");
diff --git a/drivers/ata/sata_mv.c b/drivers/ata/sata_mv.c
index 4a7ce88..70618e9 100644
--- a/drivers/ata/sata_mv.c
+++ b/drivers/ata/sata_mv.c
@@ -3302,7 +3302,7 @@ static int pci_go_64(struct pci_dev *pdev)
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 		if (rc) {
-			rc = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+			rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 			if (rc) {
 				dev_printk(KERN_ERR, &pdev->dev,
 					   "64-bit DMA enable failed\n");
@@ -3310,13 +3310,13 @@ static int pci_go_64(struct pci_dev *pdev)
 			}
 		}
 	} else {
-		rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc) {
 			dev_printk(KERN_ERR, &pdev->dev,
 				   "32-bit DMA enable failed\n");
 			return rc;
 		}
-		rc = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+		rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc) {
 			dev_printk(KERN_ERR, &pdev->dev,
 				   "32-bit consistent DMA enable failed\n");
diff --git a/drivers/ata/sata_qstor.c b/drivers/ata/sata_qstor.c
index f6498ee..b3bc8eb 100644
--- a/drivers/ata/sata_qstor.c
+++ b/drivers/ata/sata_qstor.c
@@ -586,7 +586,7 @@ static int qs_set_dma_masks(struct pci_dev *pdev, void __iomem *mmio_base)
 	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 		if (rc) {
-			rc = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+			rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 			if (rc) {
 				dev_printk(KERN_ERR, &pdev->dev,
 					   "64-bit DMA enable failed\n");
@@ -594,13 +594,13 @@ static int qs_set_dma_masks(struct pci_dev *pdev, void __iomem *mmio_base)
 			}
 		}
 	} else {
-		rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc) {
 			dev_printk(KERN_ERR, &pdev->dev,
 				"32-bit DMA enable failed\n");
 			return rc;
 		}
-		rc = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+		rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc) {
 			dev_printk(KERN_ERR, &pdev->dev,
 				"32-bit consistent DMA enable failed\n");
diff --git a/drivers/ata/sata_sil24.c b/drivers/ata/sata_sil24.c
index 8e3cefb..9a86bbb 100644
--- a/drivers/ata/sata_sil24.c
+++ b/drivers/ata/sata_sil24.c
@@ -1300,7 +1300,7 @@ static int sil24_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 		if (rc) {
-			rc = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+			rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 			if (rc) {
 				dev_printk(KERN_ERR, &pdev->dev,
 					   "64-bit DMA enable failed\n");
@@ -1308,13 +1308,13 @@ static int sil24_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 			}
 		}
 	} else {
-		rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc) {
 			dev_printk(KERN_ERR, &pdev->dev,
 				   "32-bit DMA enable failed\n");
 			return rc;
 		}
-		rc = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+		rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc) {
 			dev_printk(KERN_ERR, &pdev->dev,
 				   "32-bit consistent DMA enable failed\n");
diff --git a/drivers/ata/sata_vsc.c b/drivers/ata/sata_vsc.c
index c57cdff..e74e397 100644
--- a/drivers/ata/sata_vsc.c
+++ b/drivers/ata/sata_vsc.c
@@ -396,10 +396,10 @@ static int __devinit vsc_sata_init_one(struct pci_dev *pdev,
 	/*
 	 * Use 32 bit DMA mask, because 64 bit address support is poor.
 	 */
-	rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (rc)
 		return rc;
-	rc = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+	rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (rc)
 		return rc;
 
diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index bdbad7e..2de6406 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -358,7 +358,7 @@ he_init_one(struct pci_dev *pci_dev, const struct pci_device_id *pci_ent)
 
 	if (pci_enable_device(pci_dev))
 		return -EIO;
-	if (pci_set_dma_mask(pci_dev, DMA_32BIT_MASK) != 0) {
+	if (pci_set_dma_mask(pci_dev, DMA_BIT_MASK(32)) != 0) {
 		printk(KERN_WARNING "he: no suitable dma available\n");
 		err = -EIO;
 		goto init_one_failure;
diff --git a/drivers/atm/lanai.c b/drivers/atm/lanai.c
index 144a49f..7695259 100644
--- a/drivers/atm/lanai.c
+++ b/drivers/atm/lanai.c
@@ -1957,12 +1957,12 @@ static int __devinit lanai_pci_start(struct lanai_dev *lanai)
 		return -ENXIO;
 	}
 	pci_set_master(pci);
-	if (pci_set_dma_mask(pci, DMA_32BIT_MASK) != 0) {
+	if (pci_set_dma_mask(pci, DMA_BIT_MASK(32)) != 0) {
 		printk(KERN_WARNING DEV_LABEL
 		    "(itf %d): No suitable DMA available.\n", lanai->number);
 		return -EBUSY;
 	}
-	if (pci_set_consistent_dma_mask(pci, DMA_32BIT_MASK) != 0) {
+	if (pci_set_consistent_dma_mask(pci, DMA_BIT_MASK(32)) != 0) {
 		printk(KERN_WARNING DEV_LABEL
 		    "(itf %d): No suitable DMA available.\n", lanai->number);
 		return -EBUSY;
diff --git a/drivers/block/DAC960.c b/drivers/block/DAC960.c
index 5496865..f22ed6c 100644
--- a/drivers/block/DAC960.c
+++ b/drivers/block/DAC960.c
@@ -1169,9 +1169,9 @@ static bool DAC960_V1_EnableMemoryMailboxInterface(DAC960_Controller_T
   int i;
 
   
-  if (pci_set_dma_mask(Controller->PCIDevice, DMA_32BIT_MASK))
+  if (pci_set_dma_mask(Controller->PCIDevice, DMA_BIT_MASK(32)))
 	return DAC960_Failure(Controller, "DMA mask out of range");
-  Controller->BounceBufferLimit = DMA_32BIT_MASK;
+  Controller->BounceBufferLimit = DMA_BIT_MASK(32);
 
   if ((hw_type == DAC960_PD_Controller) || (hw_type == DAC960_P_Controller)) {
     CommandMailboxesSize =  0;
@@ -1374,8 +1374,8 @@ static bool DAC960_V2_EnableMemoryMailboxInterface(DAC960_Controller_T
 
 	if (!pci_set_dma_mask(Controller->PCIDevice, DMA_BIT_MASK(64)))
 		Controller->BounceBufferLimit = DMA_BIT_MASK(64);
-	else if (!pci_set_dma_mask(Controller->PCIDevice, DMA_32BIT_MASK))
-		Controller->BounceBufferLimit = DMA_32BIT_MASK;
+	else if (!pci_set_dma_mask(Controller->PCIDevice, DMA_BIT_MASK(32)))
+		Controller->BounceBufferLimit = DMA_BIT_MASK(32);
 	else
 		return DAC960_Failure(Controller, "DMA mask out of range");
 
diff --git a/drivers/block/cciss.c b/drivers/block/cciss.c
index 69475e4..921b4b5 100644
--- a/drivers/block/cciss.c
+++ b/drivers/block/cciss.c
@@ -3422,7 +3422,7 @@ static int __devinit cciss_init_one(struct pci_dev *pdev,
 	/* configure PCI DMA stuff */
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64)))
 		dac = 1;
-	else if (!pci_set_dma_mask(pdev, DMA_32BIT_MASK))
+	else if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(32)))
 		dac = 0;
 	else {
 		printk(KERN_ERR "cciss: no suitable DMA available\n");
diff --git a/drivers/block/sx8.c b/drivers/block/sx8.c
index db5783a..ff0448e 100644
--- a/drivers/block/sx8.c
+++ b/drivers/block/sx8.c
@@ -1597,7 +1597,7 @@ static int carm_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 		pci_dac = 1;
 	} else {
 #endif
-		rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc) {
 			printk(KERN_ERR DRV_NAME "(%s): DMA mask failure\n",
 				pci_name(pdev));
diff --git a/drivers/block/umem.c b/drivers/block/umem.c
index e93e99c..9744d59 100644
--- a/drivers/block/umem.c
+++ b/drivers/block/umem.c
@@ -830,7 +830,7 @@ static int __devinit mm_pci_probe(struct pci_dev *dev,
 	  "Micro Memory(tm) controller found (PCI Mem Module (Battery Backup))\n");
 
 	if (pci_set_dma_mask(dev, DMA_BIT_MASK(64)) &&
-	    pci_set_dma_mask(dev, DMA_32BIT_MASK)) {
+	    pci_set_dma_mask(dev, DMA_BIT_MASK(32))) {
 		dev_printk(KERN_WARNING, &dev->dev, "NO suitable DMA found\n");
 		return  -ENOMEM;
 	}
diff --git a/drivers/crypto/hifn_795x.c b/drivers/crypto/hifn_795x.c
index 0c79fe7..bc86308 100644
--- a/drivers/crypto/hifn_795x.c
+++ b/drivers/crypto/hifn_795x.c
@@ -2575,7 +2575,7 @@ static int hifn_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 		return err;
 	pci_set_master(pdev);
 
-	err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (err)
 		goto err_out_disable_pci_device;
 
diff --git a/drivers/crypto/ixp4xx_crypto.c b/drivers/crypto/ixp4xx_crypto.c
index 2d637e0..8aa6c92 100644
--- a/drivers/crypto/ixp4xx_crypto.c
+++ b/drivers/crypto/ixp4xx_crypto.c
@@ -212,7 +212,7 @@ static struct platform_device pseudo_dev = {
 	.id   = 0,
 	.num_resources = 0,
 	.dev  = {
-		.coherent_dma_mask = DMA_32BIT_MASK,
+		.coherent_dma_mask = DMA_BIT_MASK(32),
 		.release = dev_release,
 	}
 };
diff --git a/drivers/dma/ioat.c b/drivers/dma/ioat.c
index 6ccfaca..e1adb95 100644
--- a/drivers/dma/ioat.c
+++ b/drivers/dma/ioat.c
@@ -100,13 +100,13 @@ static int __devinit ioat_probe(struct pci_dev *pdev,
 
 	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (err)
-		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (err)
 		goto err_set_dma_mask;
 
 	err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (err)
-		err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (err)
 		goto err_set_dma_mask;
 
diff --git a/drivers/firmware/dcdbas.c b/drivers/firmware/dcdbas.c
index 777fba4..f7d2665 100644
--- a/drivers/firmware/dcdbas.c
+++ b/drivers/firmware/dcdbas.c
@@ -541,7 +541,7 @@ static int __devinit dcdbas_probe(struct platform_device *dev)
 	 * BIOS SMI calls require buffer addresses be in 32-bit address space.
 	 * This is done by setting the DMA mask below.
 	 */
-	dcdbas_pdev->dev.coherent_dma_mask = DMA_32BIT_MASK;
+	dcdbas_pdev->dev.coherent_dma_mask = DMA_BIT_MASK(32);
 	dcdbas_pdev->dev.dma_mask = &dcdbas_pdev->dev.coherent_dma_mask;
 
 	error = sysfs_create_group(&dev->dev.kobj, &dcdbas_attr_group);
diff --git a/drivers/ide/cs5520.c b/drivers/ide/cs5520.c
index d003bec..d8ac8c8 100644
--- a/drivers/ide/cs5520.c
+++ b/drivers/ide/cs5520.c
@@ -122,7 +122,7 @@ static int __devinit cs5520_init_one(struct pci_dev *dev, const struct pci_devic
 		return -ENODEV;
 	}
 	pci_set_master(dev);
-	if (pci_set_dma_mask(dev, DMA_32BIT_MASK)) {
+	if (pci_set_dma_mask(dev, DMA_BIT_MASK(32))) {
 		printk(KERN_WARNING "%s: No suitable DMA available.\n",
 			d->name);
 		return -ENODEV;
diff --git a/drivers/ide/setup-pci.c b/drivers/ide/setup-pci.c
index e85d1ed..d0499a8 100644
--- a/drivers/ide/setup-pci.c
+++ b/drivers/ide/setup-pci.c
@@ -208,7 +208,7 @@ static int ide_pci_enable(struct pci_dev *dev, const struct ide_port_info *d)
 	 * a DMA mask field to the struct ide_port_info if we need it
 	 * (or let lower level driver set the DMA mask)
 	 */
-	ret = pci_set_dma_mask(dev, DMA_32BIT_MASK);
+	ret = pci_set_dma_mask(dev, DMA_BIT_MASK(32));
 	if (ret < 0) {
 		printk(KERN_ERR "%s %s: can't set DMA mask\n",
 			d->name, pci_name(dev));
diff --git a/drivers/ieee1394/pcilynx.c b/drivers/ieee1394/pcilynx.c
index 38f7120..9555fd2 100644
--- a/drivers/ieee1394/pcilynx.c
+++ b/drivers/ieee1394/pcilynx.c
@@ -1171,7 +1171,7 @@ static int __devinit add_card(struct pci_dev *dev,
 
         error = -ENXIO;
 
-        if (pci_set_dma_mask(dev, DMA_32BIT_MASK))
+        if (pci_set_dma_mask(dev, DMA_BIT_MASK(32)))
                 FAIL("DMA address limits not supported for PCILynx hardware");
         if (pci_enable_device(dev))
                 FAIL("failed to enable PCILynx hardware");
diff --git a/drivers/infiniband/hw/amso1100/c2.c b/drivers/infiniband/hw/amso1100/c2.c
index d5021e4..fdd2b12 100644
--- a/drivers/infiniband/hw/amso1100/c2.c
+++ b/drivers/infiniband/hw/amso1100/c2.c
@@ -998,7 +998,7 @@ static int __devinit c2_probe(struct pci_dev *pcidev,
 			goto bail2;
 		}
 	} else {
-		ret = pci_set_dma_mask(pcidev, DMA_32BIT_MASK);
+		ret = pci_set_dma_mask(pcidev, DMA_BIT_MASK(32));
 		if (ret < 0) {
 			printk(KERN_ERR PFX "32b DMA configuration failed\n");
 			goto bail2;
diff --git a/drivers/infiniband/hw/ipath/ipath_driver.c b/drivers/infiniband/hw/ipath/ipath_driver.c
index 96fe383..c815365 100644
--- a/drivers/infiniband/hw/ipath/ipath_driver.c
+++ b/drivers/infiniband/hw/ipath/ipath_driver.c
@@ -477,7 +477,7 @@ static int __devinit ipath_init_one(struct pci_dev *pdev,
 		 * do not setup 64 bit maps on systems with 2GB or less
 		 * memory installed.
 		 */
-		ret = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		ret = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (ret) {
 			dev_info(&pdev->dev,
 				"Unable to set DMA mask for unit %u: %d\n",
@@ -486,7 +486,7 @@ static int __devinit ipath_init_one(struct pci_dev *pdev,
 		}
 		else {
 			ipath_dbg("No 64bit DMA mask, used 32 bit mask\n");
-			ret = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+			ret = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 			if (ret)
 				dev_info(&pdev->dev,
 					"Unable to set DMA consistent mask "
diff --git a/drivers/infiniband/hw/mthca/mthca_main.c b/drivers/infiniband/hw/mthca/mthca_main.c
index 5d23420..1d83cf7 100644
--- a/drivers/infiniband/hw/mthca/mthca_main.c
+++ b/drivers/infiniband/hw/mthca/mthca_main.c
@@ -1019,7 +1019,7 @@ static int __mthca_init_one(struct pci_dev *pdev, int hca_type)
 	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (err) {
 		dev_warn(&pdev->dev, "Warning: couldn't set 64-bit PCI DMA mask.\n");
-		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
 			dev_err(&pdev->dev, "Can't set PCI DMA mask, aborting.\n");
 			goto err_free_res;
@@ -1029,7 +1029,7 @@ static int __mthca_init_one(struct pci_dev *pdev, int hca_type)
 	if (err) {
 		dev_warn(&pdev->dev, "Warning: couldn't set 64-bit "
 			 "consistent PCI DMA mask.\n");
-		err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
 			dev_err(&pdev->dev, "Can't set consistent PCI DMA mask, "
 				"aborting.\n");
diff --git a/drivers/infiniband/hw/nes/nes.c b/drivers/infiniband/hw/nes/nes.c
index 2cf267c..62c77fd 100644
--- a/drivers/infiniband/hw/nes/nes.c
+++ b/drivers/infiniband/hw/nes/nes.c
@@ -489,12 +489,12 @@ static int __devinit nes_probe(struct pci_dev *pcidev, const struct pci_device_i
 			goto bail2;
 		}
 	} else {
-		ret = pci_set_dma_mask(pcidev, DMA_32BIT_MASK);
+		ret = pci_set_dma_mask(pcidev, DMA_BIT_MASK(32));
 		if (ret < 0) {
 			printk(KERN_ERR PFX "32b DMA mask configuration failed\n");
 			goto bail2;
 		}
-		ret = pci_set_consistent_dma_mask(pcidev, DMA_32BIT_MASK);
+		ret = pci_set_consistent_dma_mask(pcidev, DMA_BIT_MASK(32));
 		if (ret) {
 			printk(KERN_ERR PFX "32b DMA consistent mask configuration failed\n");
 			goto bail2;
diff --git a/drivers/media/dvb/dm1105/dm1105.c b/drivers/media/dvb/dm1105/dm1105.c
index f48f73a..a32d40a 100644
--- a/drivers/media/dvb/dm1105/dm1105.c
+++ b/drivers/media/dvb/dm1105/dm1105.c
@@ -721,7 +721,7 @@ static int __devinit dm1105_probe(struct pci_dev *pdev,
 	if (ret < 0)
 		goto err_kfree;
 
-	ret = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	ret = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (ret < 0)
 		goto err_pci_disable_device;
 
diff --git a/drivers/media/dvb/pluto2/pluto2.c b/drivers/media/dvb/pluto2/pluto2.c
index d101b30..ecd23c3 100644
--- a/drivers/media/dvb/pluto2/pluto2.c
+++ b/drivers/media/dvb/pluto2/pluto2.c
@@ -613,7 +613,7 @@ static int __devinit pluto2_probe(struct pci_dev *pdev,
 	/* enable interrupts */
 	pci_write_config_dword(pdev, 0x6c, 0x8000);
 
-	ret = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	ret = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (ret < 0)
 		goto err_pci_disable_device;
 
diff --git a/drivers/media/video/bt8xx/bttv-driver.c b/drivers/media/video/bt8xx/bttv-driver.c
index c71f394..d8ac945 100644
--- a/drivers/media/video/bt8xx/bttv-driver.c
+++ b/drivers/media/video/bt8xx/bttv-driver.c
@@ -4340,7 +4340,7 @@ static int __devinit bttv_probe(struct pci_dev *dev,
 		       btv->c.nr);
 		return -EIO;
 	}
-	if (pci_set_dma_mask(dev, DMA_32BIT_MASK)) {
+	if (pci_set_dma_mask(dev, DMA_BIT_MASK(32))) {
 		printk(KERN_WARNING "bttv%d: No suitable DMA available.\n",
 		       btv->c.nr);
 		return -EIO;
diff --git a/drivers/media/video/cx88/cx88-alsa.c b/drivers/media/video/cx88/cx88-alsa.c
index 66c755c..053b51a 100644
--- a/drivers/media/video/cx88/cx88-alsa.c
+++ b/drivers/media/video/cx88/cx88-alsa.c
@@ -745,7 +745,7 @@ static int __devinit snd_cx88_create(struct snd_card *card,
 		return err;
 	}
 
-	if (!pci_dma_supported(pci,DMA_32BIT_MASK)) {
+	if (!pci_dma_supported(pci,DMA_BIT_MASK(32))) {
 		dprintk(0, "%s/1: Oops: no 32bit PCI DMA ???\n",core->name);
 		err = -EIO;
 		cx88_core_put(core,pci);
diff --git a/drivers/media/video/cx88/cx88-mpeg.c b/drivers/media/video/cx88/cx88-mpeg.c
index b295b76..da4e391 100644
--- a/drivers/media/video/cx88/cx88-mpeg.c
+++ b/drivers/media/video/cx88/cx88-mpeg.c
@@ -455,7 +455,7 @@ static int cx8802_init_common(struct cx8802_dev *dev)
 	if (pci_enable_device(dev->pci))
 		return -EIO;
 	pci_set_master(dev->pci);
-	if (!pci_dma_supported(dev->pci,DMA_32BIT_MASK)) {
+	if (!pci_dma_supported(dev->pci,DMA_BIT_MASK(32))) {
 		printk("%s/2: Oops: no 32bit PCI DMA ???\n",dev->core->name);
 		return -EIO;
 	}
diff --git a/drivers/media/video/cx88/cx88-video.c b/drivers/media/video/cx88/cx88-video.c
index 791e69d..cd60981 100644
--- a/drivers/media/video/cx88/cx88-video.c
+++ b/drivers/media/video/cx88/cx88-video.c
@@ -1846,7 +1846,7 @@ static int __devinit cx8800_initdev(struct pci_dev *pci_dev,
 	       dev->pci_lat,(unsigned long long)pci_resource_start(pci_dev,0));
 
 	pci_set_master(pci_dev);
-	if (!pci_dma_supported(pci_dev,DMA_32BIT_MASK)) {
+	if (!pci_dma_supported(pci_dev,DMA_BIT_MASK(32))) {
 		printk("%s/0: Oops: no 32bit PCI DMA ???\n",core->name);
 		err = -EIO;
 		goto fail_core;
diff --git a/drivers/media/video/meye.c b/drivers/media/video/meye.c
index b76e33d..6d22dad 100644
--- a/drivers/media/video/meye.c
+++ b/drivers/media/video/meye.c
@@ -117,7 +117,7 @@ static int ptable_alloc(void)
 	memset(meye.mchip_ptable, 0, sizeof(meye.mchip_ptable));
 
 	/* give only 32 bit DMA addresses */
-	if (dma_set_mask(&meye.mchip_dev->dev, DMA_32BIT_MASK))
+	if (dma_set_mask(&meye.mchip_dev->dev, DMA_BIT_MASK(32)))
 		return -1;
 
 	meye.mchip_ptable_toc = dma_alloc_coherent(&meye.mchip_dev->dev,
diff --git a/drivers/media/video/saa7134/saa7134-core.c b/drivers/media/video/saa7134/saa7134-core.c
index 99221d7..2297949 100644
--- a/drivers/media/video/saa7134/saa7134-core.c
+++ b/drivers/media/video/saa7134/saa7134-core.c
@@ -909,7 +909,7 @@ static int __devinit saa7134_initdev(struct pci_dev *pci_dev,
 	       pci_name(pci_dev), dev->pci_rev, pci_dev->irq,
 	       dev->pci_lat,(unsigned long long)pci_resource_start(pci_dev,0));
 	pci_set_master(pci_dev);
-	if (!pci_dma_supported(pci_dev, DMA_32BIT_MASK)) {
+	if (!pci_dma_supported(pci_dev, DMA_BIT_MASK(32))) {
 		printk("%s: Oops: no 32bit PCI DMA ???\n",dev->name);
 		err = -EIO;
 		goto fail1;
diff --git a/drivers/memstick/host/jmb38x_ms.c b/drivers/memstick/host/jmb38x_ms.c
index 2fb95a5..f4a162a 100644
--- a/drivers/memstick/host/jmb38x_ms.c
+++ b/drivers/memstick/host/jmb38x_ms.c
@@ -877,7 +877,7 @@ static int jmb38x_ms_probe(struct pci_dev *pdev,
 	int pci_dev_busy = 0;
 	int rc, cnt;
 
-	rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (rc)
 		return rc;
 
diff --git a/drivers/message/fusion/mptbase.c b/drivers/message/fusion/mptbase.c
index 3bcc0ba..25aec2b 100644
--- a/drivers/message/fusion/mptbase.c
+++ b/drivers/message/fusion/mptbase.c
@@ -1539,8 +1539,8 @@ mpt_mapresources(MPT_ADAPTER *ioc)
 		dinitprintk(ioc, printk(MYIOC_s_INFO_FMT
 		    ": 64 BIT PCI BUS DMA ADDRESSING SUPPORTED\n",
 		    ioc->name));
-	} else if (!pci_set_dma_mask(pdev, DMA_32BIT_MASK)
-	    && !pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK)) {
+	} else if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(32))
+	    && !pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32))) {
 		dinitprintk(ioc, printk(MYIOC_s_INFO_FMT
 		    ": 32 BIT PCI BUS DMA ADDRESSING SUPPORTED\n",
 		    ioc->name));
diff --git a/drivers/message/i2o/memory.c b/drivers/message/i2o/memory.c
index 9a08d8e..292b41e 100644
--- a/drivers/message/i2o/memory.c
+++ b/drivers/message/i2o/memory.c
@@ -187,7 +187,7 @@ int i2o_dma_alloc(struct device *dev, struct i2o_dma *addr, size_t len)
 	mutex_lock(&mem_lock);
 	if ((sizeof(dma_addr_t) > 4) && (pdev->dma_mask == DMA_BIT_MASK(64))) {
 		dma_64 = 1;
-		if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
+		if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
 			mutex_unlock(&mem_lock);
 			return -ENOMEM;
 		}
diff --git a/drivers/message/i2o/pci.c b/drivers/message/i2o/pci.c
index ed17ac5..35ba2ae 100644
--- a/drivers/message/i2o/pci.c
+++ b/drivers/message/i2o/pci.c
@@ -334,7 +334,7 @@ static int __devinit i2o_pci_probe(struct pci_dev *pdev,
 		return rc;
 	}
 
-	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
+	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
 		printk(KERN_WARNING "i2o: no suitable DMA found for %s\n",
 		       pci_name(pdev));
 		rc = -ENODEV;
diff --git a/drivers/misc/tifm_7xx1.c b/drivers/misc/tifm_7xx1.c
index be5672a..a6ef182 100644
--- a/drivers/misc/tifm_7xx1.c
+++ b/drivers/misc/tifm_7xx1.c
@@ -324,7 +324,7 @@ static int tifm_7xx1_probe(struct pci_dev *dev,
 	int pci_dev_busy = 0;
 	int rc;
 
-	rc = pci_set_dma_mask(dev, DMA_32BIT_MASK);
+	rc = pci_set_dma_mask(dev, DMA_BIT_MASK(32));
 	if (rc)
 		return rc;
 
diff --git a/drivers/mmc/host/sdhci-pci.c b/drivers/mmc/host/sdhci-pci.c
index f07255c..a0f0583 100644
--- a/drivers/mmc/host/sdhci-pci.c
+++ b/drivers/mmc/host/sdhci-pci.c
@@ -380,7 +380,7 @@ static int sdhci_pci_enable_dma(struct sdhci_host *host)
 			"doesn't fully claim to support it.\n");
 	}
 
-	ret = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	ret = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (ret)
 		return ret;
 
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 430817c..c6813b6 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -1530,7 +1530,7 @@ static void cp_get_ethtool_stats (struct net_device *dev,
 
 	/* begin NIC statistics dump */
 	cpw32(StatsAddr + 4, (u64)dma >> 32);
-	cpw32(StatsAddr, ((u64)dma & DMA_32BIT_MASK) | DumpStats);
+	cpw32(StatsAddr, ((u64)dma & DMA_BIT_MASK(32)) | DumpStats);
 	cpr32(StatsAddr);
 
 	for (i = 0; i < 1000; i++) {
@@ -1913,13 +1913,13 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 	} else {
 		pci_using_dac = 0;
 
-		rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc) {
 			dev_err(&pdev->dev,
 				   "No usable DMA configuration, aborting.\n");
 			goto err_out_res;
 		}
-		rc = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+		rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc) {
 			dev_err(&pdev->dev,
 				   "No usable consistent DMA configuration, "
diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index 7acf9b6..643ea3a 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -1163,7 +1163,7 @@ static int __devinit ace_init(struct net_device *dev)
 	 */
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		ap->pci_using_dac = 1;
-	} else if (!pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
+	} else if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
 		ap->pci_using_dac = 0;
 	} else {
 		ecode = -ENODEV;
diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index 7709992..7a1bf8b 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -1871,7 +1871,7 @@ static int __devinit amd8111e_probe_one(struct pci_dev *pdev,
 	}
 
 	/* Initialize DMA */
-	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK) < 0) {
+	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) < 0) {
 		printk(KERN_ERR "amd8111e: DMA not supported,"
 			"exiting.\n");
 		goto err_free_reg;
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index bb9094d..0f31825 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -2326,8 +2326,8 @@ static int __devinit atl1e_probe(struct pci_dev *pdev,
 	 * various kernel subsystems to support the mechanics required by a
 	 * fixed-high-32-bit system.
 	 */
-	if ((pci_set_dma_mask(pdev, DMA_32BIT_MASK) != 0) ||
-	    (pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK) != 0)) {
+	if ((pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) != 0) ||
+	    (pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32)) != 0)) {
 		dev_err(&pdev->dev, "No usable DMA configuration,aborting\n");
 		goto err_dma;
 	}
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index c0ceee0..4fcf788 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2929,7 +2929,7 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	 * various kernel subsystems to support the mechanics required by a
 	 * fixed-high-32-bit system.
 	 */
-	err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (err) {
 		dev_err(&pdev->dev, "no usable DMA configuration\n");
 		goto err_dma;
diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index bc39449..9aef44c 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -1358,8 +1358,8 @@ static int __devinit atl2_probe(struct pci_dev *pdev,
 	 * until the kernel has the proper infrastructure to support 64-bit DMA
 	 * on these devices.
 	 */
-	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK) &&
-		pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK)) {
+	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) &&
+		pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32))) {
 		printk(KERN_ERR "atl2: No usable DMA configuration, aborting\n");
 		goto err_dma;
 	}
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index e12b65f..434949e 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7474,7 +7474,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 				"pci_set_consistent_dma_mask failed, aborting.\n");
 			goto err_out_unmap;
 		}
-	} else if ((rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK)) != 0) {
+	} else if ((rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) != 0) {
 		dev_err(&pdev->dev, "System does not support DMA, aborting.\n");
 		goto err_out_unmap;
 	}
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 9e94568..f88b3b1 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -10213,7 +10213,7 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 			goto err_out_release;
 		}
 
-	} else if (pci_set_dma_mask(pdev, DMA_32BIT_MASK) != 0) {
+	} else if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) != 0) {
 		printk(KERN_ERR PFX "System does not support DMA,"
 		       " aborting\n");
 		rc = -EIO;
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 1c7f401..b5b3858 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -5085,7 +5085,7 @@ static int __devinit cas_init_one(struct pci_dev *pdev,
 		}
 
 	} else {
-		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
 			dev_err(&pdev->dev, "No usable DMA configuration, "
 			       "aborting.\n");
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index 57cfbc3..fa06994 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -1066,7 +1066,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 			goto out_disable_pdev;
 		}
 
-	} else if ((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK)) != 0) {
+	} else if ((err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) != 0) {
 		CH_ERR("%s: no usable DMA configuration\n", pci_name(pdev));
 		goto out_disable_pdev;
 	}
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 7131187..ceeab09 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2898,7 +2898,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 			       "coherent allocations\n");
 			goto out_disable_device;
 		}
-	} else if ((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK)) != 0) {
+	} else if ((err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) != 0) {
 		dev_err(&pdev->dev, "no usable DMA configuration\n");
 		goto out_disable_device;
 	}
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 86bb876..43dfb08 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2565,7 +2565,7 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 		goto err_out_disable_pdev;
 	}
 
-	if ((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
+	if ((err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32)))) {
 		DPRINTK(PROBE, ERR, "No usable DMA configuration, aborting.\n");
 		goto err_out_free_res;
 	}
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index e448e70..9b58b79 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -949,9 +949,9 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	    !pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		pci_using_dac = 1;
 	} else {
-		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
-			err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+			err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 			if (err) {
 				E1000_ERR("No usable DMA configuration, "
 					  "aborting\n");
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index fe7917d..bf9972a 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2213,7 +2213,7 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 	/* Setup the HW Tx Head and Tail descriptor pointers */
 	tdba = tx_ring->dma;
 	tdlen = tx_ring->count * sizeof(struct e1000_tx_desc);
-	ew32(TDBAL, (tdba & DMA_32BIT_MASK));
+	ew32(TDBAL, (tdba & DMA_BIT_MASK(32)));
 	ew32(TDBAH, (tdba >> 32));
 	ew32(TDLEN, tdlen);
 	ew32(TDH, 0);
@@ -2469,7 +2469,7 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	 * the Base and Length of the Rx Descriptor Ring
 	 */
 	rdba = rx_ring->dma;
-	ew32(RDBAL, (rdba & DMA_32BIT_MASK));
+	ew32(RDBAL, (rdba & DMA_BIT_MASK(32)));
 	ew32(RDBAH, (rdba >> 32));
 	ew32(RDLEN, rdlen);
 	ew32(RDH, 0);
@@ -4795,10 +4795,10 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 		if (!err)
 			pci_using_dac = 1;
 	} else {
-		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
 			err = pci_set_consistent_dma_mask(pdev,
-							  DMA_32BIT_MASK);
+							  DMA_BIT_MASK(32));
 			if (err) {
 				dev_err(&pdev->dev, "No usable DMA "
 					"configuration, aborting\n");
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index c97f87d..f1e67ea 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1672,13 +1672,13 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 
 	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(40));
 	if (err) {
-		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
 			printk(KERN_ERR PFX
 				"No usable DMA configuration, aborting.\n");
 			goto err_out_release_regions;
 		}
-		err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
 			printk(KERN_ERR PFX
 				"Unable to obtain 32-bit DMA "
diff --git a/drivers/net/hp100.c b/drivers/net/hp100.c
index ad8be7e..de3f49f 100644
--- a/drivers/net/hp100.c
+++ b/drivers/net/hp100.c
@@ -580,7 +580,7 @@ static int __devinit hp100_probe1(struct net_device *dev, int ioaddr,
 			 * Also, we can have EISA Busmaster cards (not tested),
 			 * so beware !!! - Jean II */
 			if((bus == HP100_BUS_PCI) &&
-			   (pci_set_dma_mask(pci_dev, DMA_32BIT_MASK))) {
+			   (pci_set_dma_mask(pci_dev, DMA_BIT_MASK(32)))) {
 				/* Gracefully fallback to shared memory */
 				goto busmasterfail;
 			}
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 9ab4143..a1fb212 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1051,9 +1051,9 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		if (!err)
 			pci_using_dac = 1;
 	} else {
-		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
-			err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+			err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 			if (err) {
 				dev_err(&pdev->dev, "No usable DMA "
 					"configuration, aborting\n");
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index 43be0b0..cbc63ff 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -1236,7 +1236,7 @@ static int __devinit ioc3_probe(struct pci_dev *pdev,
 			goto out;
 		}
 	} else {
-		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
 			printk(KERN_ERR "%s: No usable DMA configuration, "
 			       "aborting.\n", pci_name(pdev));
diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index ed9ded9..4301946 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -2242,7 +2242,7 @@ static int __devinit ipg_probe(struct pci_dev *pdev,
 
 	rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(40));
 	if (rc < 0) {
-		rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc < 0) {
 			printk(KERN_ERR "%s: DMA config failed.\n",
 			       pci_name(pdev));
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index ca3524e..5377cb1 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -369,8 +369,8 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	    !(err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64)))) {
 		pci_using_dac = 1;
 	} else {
-		if ((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK)) ||
-		    (err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK))) {
+		if ((err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) ||
+		    (err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32)))) {
 			printk(KERN_ERR
 			 "ixgb: No usable DMA configuration, aborting\n");
 			goto err_dma_mask;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 194c5fb..642faf7 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1497,12 +1497,12 @@ static void ixgbe_configure_tx(struct ixgbe_adapter *adapter)
 		tdba = ring->dma;
 		tdlen = ring->count * sizeof(union ixgbe_adv_tx_desc);
 		IXGBE_WRITE_REG(hw, IXGBE_TDBAL(j),
-		                (tdba & DMA_32BIT_MASK));
+		                (tdba & DMA_BIT_MASK(32)));
 		IXGBE_WRITE_REG(hw, IXGBE_TDBAH(j), (tdba >> 32));
 		tdwba = ring->dma +
 		        (ring->count * sizeof(union ixgbe_adv_tx_desc));
 		tdwba |= IXGBE_TDWBAL_HEAD_WB_ENABLE;
-		IXGBE_WRITE_REG(hw, IXGBE_TDWBAL(j), tdwba & DMA_32BIT_MASK);
+		IXGBE_WRITE_REG(hw, IXGBE_TDWBAL(j), tdwba & DMA_BIT_MASK(32));
 		IXGBE_WRITE_REG(hw, IXGBE_TDWBAH(j), (tdwba >> 32));
 		IXGBE_WRITE_REG(hw, IXGBE_TDLEN(j), tdlen);
 		IXGBE_WRITE_REG(hw, IXGBE_TDH(j), 0);
@@ -1658,7 +1658,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		rdba = adapter->rx_ring[i].dma;
 		j = adapter->rx_ring[i].reg_idx;
-		IXGBE_WRITE_REG(hw, IXGBE_RDBAL(j), (rdba & DMA_32BIT_MASK));
+		IXGBE_WRITE_REG(hw, IXGBE_RDBAL(j), (rdba & DMA_BIT_MASK(32)));
 		IXGBE_WRITE_REG(hw, IXGBE_RDBAH(j), (rdba >> 32));
 		IXGBE_WRITE_REG(hw, IXGBE_RDLEN(j), rdlen);
 		IXGBE_WRITE_REG(hw, IXGBE_RDH(j), 0);
@@ -4017,9 +4017,9 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	    !pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		pci_using_dac = 1;
 	} else {
-		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
-			err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+			err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 			if (err) {
 				dev_err(&pdev->dev, "No usable DMA "
 				        "configuration, aborting\n");
diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 08b3405..10ea47e 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -2590,8 +2590,8 @@ static const struct ethtool_ops jme_ethtool_ops = {
 static int
 jme_pci_dma64(struct pci_dev *pdev)
 {
-	if (!pci_set_dma_mask(pdev, DMA_32BIT_MASK))
-		if (!pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK))
+	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(32)))
+		if (!pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32)))
 			return 0;
 
 	return -1;
diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index dbd24d3..35f7dde 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -1035,7 +1035,7 @@ static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (err) {
 		dev_warn(&pdev->dev, "Warning: couldn't set 64-bit PCI DMA mask.\n");
-		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
 			dev_err(&pdev->dev, "Can't set PCI DMA mask, aborting.\n");
 			goto err_release_bar2;
@@ -1045,7 +1045,7 @@ static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 	if (err) {
 		dev_warn(&pdev->dev, "Warning: couldn't set 64-bit "
 			 "consistent PCI DMA mask.\n");
-		err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
 			dev_err(&pdev->dev, "Can't set consistent PCI DMA mask, "
 				"aborting.\n");
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 12e9b94..265d1ae 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1130,7 +1130,7 @@ myri10ge_submit_8rx(struct mcp_kreq_ether_recv __iomem * dst,
 	__be32 low;
 
 	low = src->addr_low;
-	src->addr_low = htonl(DMA_32BIT_MASK);
+	src->addr_low = htonl(DMA_BIT_MASK(32));
 	myri10ge_pio_copy(dst, src, 4 * sizeof(*src));
 	mb();
 	myri10ge_pio_copy(dst + 4, src + 4, 4 * sizeof(*src));
@@ -3797,7 +3797,7 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev_err(&pdev->dev,
 			"64-bit pci address mask was refused, "
 			"trying 32-bit\n");
-		status = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		status = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	}
 	if (status != 0) {
 		dev_err(&pdev->dev, "Error %d setting DMA mask\n", status);
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 2d4e41b..679e293 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -173,7 +173,7 @@ static int nx_set_dma_mask(struct netxen_adapter *adapter, uint8_t revision_id)
 	uint64_t mask;
 
 #ifdef CONFIG_IA64
-	adapter->dma_mask = DMA_32BIT_MASK;
+	adapter->dma_mask = DMA_BIT_MASK(32);
 #else
 	if (revision_id >= NX_P3_B0) {
 		/* should go to DMA_BIT_MASK(64) */
@@ -186,8 +186,8 @@ static int nx_set_dma_mask(struct netxen_adapter *adapter, uint8_t revision_id)
 		adapter->dma_mask = DMA_BIT_MASK(35);
 		mask = DMA_BIT_MASK(35);
 	} else {
-		adapter->dma_mask = DMA_32BIT_MASK;
-		mask = DMA_32BIT_MASK;
+		adapter->dma_mask = DMA_BIT_MASK(32);
+		mask = DMA_BIT_MASK(32);
 		goto set_32_bit_mask;
 	}
 
@@ -197,16 +197,16 @@ static int nx_set_dma_mask(struct netxen_adapter *adapter, uint8_t revision_id)
 	 * come off this pool.
 	 */
 	if (pci_set_dma_mask(pdev, mask) == 0 &&
-		pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK) == 0) {
+		pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32)) == 0) {
 		adapter->pci_using_dac = 1;
 		return 0;
 	}
 set_32_bit_mask:
 #endif /* CONFIG_IA64 */
 
-	err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (!err)
-		err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (err) {
 		DPRINTK(ERR, "No usable DMA configuration, aborting:%d\n", err);
 		return err;
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 0c0b752..eac808f 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -9104,8 +9104,8 @@ static int __devinit niu_pci_init_one(struct pci_dev *pdev,
 			goto err_out_release_parent;
 		}
 	}
-	if (err || dma_mask == DMA_32BIT_MASK) {
-		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	if (err || dma_mask == DMA_BIT_MASK(32)) {
+		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
 			dev_err(&pdev->dev, PFX "No usable DMA configuration, "
 				"aborting.\n");
diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index a21528c..3e9ab1f 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -1976,7 +1976,7 @@ static int __devinit ns83820_init_one(struct pci_dev *pci_dev,
 	if (sizeof(dma_addr_t) == 8 &&
 	 	!pci_set_dma_mask(pci_dev, DMA_BIT_MASK(64))) {
 		using_dac = 1;
-	} else if (!pci_set_dma_mask(pci_dev, DMA_32BIT_MASK)) {
+	} else if (!pci_set_dma_mask(pci_dev, DMA_BIT_MASK(32))) {
 		using_dac = 0;
 	} else {
 		dev_warn(&pci_dev->dev, "pci_set_dma_mask failed!\n");
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 196a143..139d979 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -3937,9 +3937,9 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		pci_using_dac = 1;
 		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
-	} else if (!(err = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
+	} else if (!(err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32)))) {
 		pci_using_dac = 0;
-		err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 	}
 
 	if (err) {
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 0a5c2b4..2ae555d 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3608,9 +3608,9 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 		set_bit(QL_DMA64, &qdev->flags);
 		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 	} else {
-		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (!err)
-		       err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+		       err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 	}
 
 	if (err) {
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index b2dcdb5..780dee7 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -1085,13 +1085,13 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 		goto err_out;
 
 	/* this should always be supported */
-	err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (err) {
 		printk(KERN_ERR DRV_NAME ": 32-bit PCI DMA addresses"
 				"not supported by the card\n");
 		goto err_out;
 	}
-	err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+	err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (err) {
 		printk(KERN_ERR DRV_NAME ": 32-bit PCI DMA addresses"
 				"not supported by the card\n");
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 742d822..3f258bb 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1148,7 +1148,7 @@ static void rtl8169_update_counters(struct net_device *dev)
 		return;
 
 	RTL_W32(CounterAddrHigh, (u64)paddr >> 32);
-	cmd = (u64)paddr & DMA_32BIT_MASK;
+	cmd = (u64)paddr & DMA_BIT_MASK(32);
 	RTL_W32(CounterAddrLow, cmd);
 	RTL_W32(CounterAddrLow, cmd | CounterDump);
 
@@ -2050,7 +2050,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		tp->cp_cmd |= PCIDAC;
 		dev->features |= NETIF_F_HIGHDMA;
 	} else {
-		rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc < 0) {
 			if (netif_msg_probe(tp)) {
 				dev_err(&pdev->dev,
@@ -2342,9 +2342,9 @@ static void rtl_set_rx_tx_desc_registers(struct rtl8169_private *tp,
 	 * Switching from MMIO to I/O access fixes the issue as well.
 	 */
 	RTL_W32(TxDescStartAddrHigh, ((u64) tp->TxPhyAddr) >> 32);
-	RTL_W32(TxDescStartAddrLow, ((u64) tp->TxPhyAddr) & DMA_32BIT_MASK);
+	RTL_W32(TxDescStartAddrLow, ((u64) tp->TxPhyAddr) & DMA_BIT_MASK(32));
 	RTL_W32(RxDescAddrHigh, ((u64) tp->RxPhyAddr) >> 32);
-	RTL_W32(RxDescAddrLow, ((u64) tp->RxPhyAddr) & DMA_32BIT_MASK);
+	RTL_W32(RxDescAddrLow, ((u64) tp->RxPhyAddr) & DMA_BIT_MASK(32));
 }
 
 static u16 rtl_rw_cpluscmd(void __iomem *ioaddr)
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 892bf64..311dbda 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -7786,7 +7786,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 			pci_disable_device(pdev);
 			return -ENOMEM;
 		}
-	} else if (!pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
+	} else if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
 		DBG_PRINT(INIT_DBG, "s2io_init_nic: Using 32bit DMA\n");
 	} else {
 		pci_disable_device(pdev);
diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index 8b75bef..1debdba 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -1430,11 +1430,11 @@ static int __devinit sc92031_probe(struct pci_dev *pdev,
 
 	pci_set_master(pdev);
 
-	err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (unlikely(err < 0))
 		goto out_set_dma_mask;
 
-	err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+	err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (unlikely(err < 0))
 		goto out_set_dma_mask;
 
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index a973268..55ccd51 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -1467,7 +1467,7 @@ static struct net_device * __devinit sis190_init_board(struct pci_dev *pdev)
 		goto err_pci_disable_2;
 	}
 
-	rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (rc < 0) {
 		net_probe(tp, KERN_ERR "%s: DMA configuration failed.\n",
 			  pci_name(pdev));
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index be4465b..6718a76 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -432,7 +432,7 @@ static int __devinit sis900_probe(struct pci_dev *pci_dev,
 	ret = pci_enable_device(pci_dev);
 	if(ret) return ret;
 
-	i = pci_set_dma_mask(pci_dev, DMA_32BIT_MASK);
+	i = pci_set_dma_mask(pci_dev, DMA_BIT_MASK(32));
 	if(i){
 		printk(KERN_ERR "sis900.c: architecture does not support "
 			"32bit PCI busmaster DMA\n");
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index fce0219..3b23588 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -3915,9 +3915,9 @@ static int __devinit skge_probe(struct pci_dev *pdev,
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		using_dac = 1;
 		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
-	} else if (!(err = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
+	} else if (!(err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32)))) {
 		using_dac = 0;
-		err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 	}
 
 	if (err) {
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 9bfc946..71e1cf4 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -4320,7 +4320,7 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 			goto err_out_free_regions;
 		}
 	} else {
-		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
 			dev_err(&pdev->dev, "no usable DMA configuration\n");
 			goto err_out_free_regions;
diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index a1e4b38..e94521b 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -1594,7 +1594,7 @@ smsc9420_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 		goto out_free_netdev_2;
 	}
 
-	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
+	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
 		printk(KERN_ERR "No usable DMA configuration, aborting.\n");
 		goto out_free_regions_3;
 	}
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 271172a..682bdc3 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -3042,7 +3042,7 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		pci_using_dac = 1;
 	} else {
-		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
 			printk(KERN_ERR PFX "No usable DMA configuration, "
 			       "aborting.\n");
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 4d06a85..d05e9de 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -1940,8 +1940,8 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	    !(err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64)))) {
 		pci_using_dac = 1;
 	} else {
-		if ((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK)) ||
-		    (err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK))) {
+		if ((err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) ||
+		    (err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32)))) {
 			printk(KERN_ERR "tehuti: No usable DMA configuration"
 					", aborting\n");
 			goto err_dma;
diff --git a/drivers/net/tehuti.h b/drivers/net/tehuti.h
index 4a46f16..83730c9 100644
--- a/drivers/net/tehuti.h
+++ b/drivers/net/tehuti.h
@@ -98,10 +98,6 @@
 #define READ_REG(pp, reg)         readl(pp->pBdxRegs + reg)
 #define WRITE_REG(pp, reg, val)   writel(val, pp->pBdxRegs + reg)
 
-#ifndef DMA_32BIT_MASK
-#   define DMA_32BIT_MASK  0x00000000ffffffffULL
-#endif
-
 #ifndef NET_IP_ALIGN
 #   define NET_IP_ALIGN 2
 #endif
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index dd9164c..ed2cb7d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -13102,7 +13102,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	 * do DMA address check in tg3_start_xmit().
 	 */
 	if (tp->tg3_flags2 & TG3_FLG2_IS_5788)
-		persist_dma_mask = dma_mask = DMA_32BIT_MASK;
+		persist_dma_mask = dma_mask = DMA_BIT_MASK(32);
 	else if (tp->tg3_flags & TG3_FLAG_40BIT_DMA_BUG) {
 		persist_dma_mask = dma_mask = DMA_BIT_MASK(40);
 #ifdef CONFIG_HIGHMEM
@@ -13112,7 +13112,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		persist_dma_mask = dma_mask = DMA_BIT_MASK(64);
 
 	/* Configure DMA attributes. */
-	if (dma_mask > DMA_32BIT_MASK) {
+	if (dma_mask > DMA_BIT_MASK(32)) {
 		err = pci_set_dma_mask(pdev, dma_mask);
 		if (!err) {
 			dev->features |= NETIF_F_HIGHDMA;
@@ -13125,8 +13125,8 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 			}
 		}
 	}
-	if (err || dma_mask == DMA_32BIT_MASK) {
-		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	if (err || dma_mask == DMA_BIT_MASK(32)) {
+		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
 			printk(KERN_ERR PFX "No usable DMA configuration, "
 			       "aborting.\n");
@@ -13264,7 +13264,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	       (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) != 0);
 	printk(KERN_INFO "%s: dma_rwctrl[%08x] dma_mask[%d-bit]\n",
 	       dev->name, tp->dma_rwctrl,
-	       (pdev->dma_mask == DMA_32BIT_MASK) ? 32 :
+	       (pdev->dma_mask == DMA_BIT_MASK(32)) ? 32 :
 	        (((u64) pdev->dma_mask == DMA_BIT_MASK(40)) ? 40 : 64));
 
 	return 0;
diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index 68b967b..aa69649 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -570,7 +570,7 @@ static int __devinit TLan_probe1(struct pci_dev *pdev,
 
 		priv->adapter = &board_info[ent->driver_data];
 
-		rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc) {
 			printk(KERN_ERR "TLAN: No suitable PCI mapping available.\n");
 			goto err_out_free_dev;
diff --git a/drivers/net/tokenring/lanstreamer.c b/drivers/net/tokenring/lanstreamer.c
index 239c752..f011511 100644
--- a/drivers/net/tokenring/lanstreamer.c
+++ b/drivers/net/tokenring/lanstreamer.c
@@ -256,7 +256,7 @@ static int __devinit streamer_init_one(struct pci_dev *pdev,
 #endif
 #endif
 
-	rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (rc) {
 		printk(KERN_ERR "%s: No suitable PCI mapping available.\n",
 				dev->name);
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index 2e5c999..0cd9872 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -383,7 +383,7 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 		return -ENOMEM;
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
+	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
 		printk(KERN_WARNING DRV_NAME
 			": 32-bit PCI DMA not available.\n");
 		err = -ENODEV;
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index 030e02e..74b52ce 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -282,7 +282,7 @@ static int __devinit uli526x_init_one (struct pci_dev *pdev,
 		return -ENOMEM;
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
+	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
 		printk(KERN_WARNING DRV_NAME ": 32-bit PCI DMA not available.\n");
 		err = -ENODEV;
 		goto err_out_free;
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index f467bf8..33c6370 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -374,7 +374,7 @@ static int __devinit w840_probe1 (struct pci_dev *pdev,
 
 	irq = pdev->irq;
 
-	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
+	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
 		printk(KERN_WARNING "Winbond-840: Device %s disabled due to DMA limitations.\n",
 		       pci_name(pdev));
 		return -EIO;
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 3af9a95..d43913b 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -2348,7 +2348,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto error_out_disable;
 	}
 
-	err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if(err < 0) {
 		printk(ERR_PFX "%s: No usable DMA configuration\n",
 		       pci_name(pdev));
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 3b8e632..8a16b15 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -685,7 +685,7 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 		goto err_out;
 
 	/* this should always be supported */
-	rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (rc) {
 		printk(KERN_ERR "32-bit PCI DMA addresses not supported by "
 		       "the card!?\n");
diff --git a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
index 4bffb67..f1cef90 100644
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -624,8 +624,8 @@ static int __devinit wanxl_pci_init_one(struct pci_dev *pdev,
 	/* FIXME when PCI/DMA subsystems are fixed.
 	   We set both dma_mask and consistent_dma_mask back to 32 bits
 	   to indicate the card can do 32-bit DMA addressing */
-	if (pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK) ||
-	    pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
+	if (pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32)) ||
+	    pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
 		printk(KERN_ERR "wanXL: No usable DMA configuration\n");
 		wanxl_pci_remove_one(pdev);
 		return -EIO;
diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
index fc0897f..f718217 100644
--- a/drivers/net/wireless/adm8211.c
+++ b/drivers/net/wireless/adm8211.c
@@ -1804,8 +1804,8 @@ static int __devinit adm8211_probe(struct pci_dev *pdev,
 		return err; /* someone else grabbed it? don't disable it */
 	}
 
-	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK) ||
-	    pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK)) {
+	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) ||
+	    pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32))) {
 		printk(KERN_ERR "%s (adm8211): No suitable DMA available\n",
 		       pci_name(pdev));
 		goto err_free_reg;
diff --git a/drivers/net/wireless/ath5k/base.c b/drivers/net/wireless/ath5k/base.c
index 1d77ee9..93574c1 100644
--- a/drivers/net/wireless/ath5k/base.c
+++ b/drivers/net/wireless/ath5k/base.c
@@ -434,7 +434,7 @@ ath5k_pci_probe(struct pci_dev *pdev,
 	}
 
 	/* XXX 32-bit addressing only */
-	ret = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	ret = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (ret) {
 		dev_err(&pdev->dev, "32-bit DMA not available\n");
 		goto err_dis;
diff --git a/drivers/net/wireless/ath9k/main.c b/drivers/net/wireless/ath9k/main.c
index 727f067..c346f9d 100644
--- a/drivers/net/wireless/ath9k/main.c
+++ b/drivers/net/wireless/ath9k/main.c
@@ -2560,14 +2560,14 @@ static int ath_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	if (pci_enable_device(pdev))
 		return -EIO;
 
-	ret =  pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	ret =  pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 
 	if (ret) {
 		printk(KERN_ERR "ath9k: 32-bit DMA not available\n");
 		goto bad;
 	}
 
-	ret = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+	ret = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 
 	if (ret) {
 		printk(KERN_ERR "ath9k: 32-bit DMA consistent "
diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/dma.c
index a1276f6..87671d8 100644
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -774,7 +774,7 @@ static u64 supported_dma_mask(struct b43_wldev *dev)
 	b43_write32(dev, mmio_base + B43_DMA32_TXCTL, B43_DMA32_TXADDREXT_MASK);
 	tmp = b43_read32(dev, mmio_base + B43_DMA32_TXCTL);
 	if (tmp & B43_DMA32_TXADDREXT_MASK)
-		return DMA_32BIT_MASK;
+		return DMA_BIT_MASK(32);
 
 	return DMA_30BIT_MASK;
 }
@@ -783,7 +783,7 @@ static enum b43_dmatype dma_mask_to_engine_type(u64 dmamask)
 {
 	if (dmamask == DMA_30BIT_MASK)
 		return B43_DMA_30BIT;
-	if (dmamask == DMA_32BIT_MASK)
+	if (dmamask == DMA_BIT_MASK(32))
 		return B43_DMA_32BIT;
 	if (dmamask == DMA_BIT_MASK(64))
 		return B43_DMA_64BIT;
@@ -997,11 +997,11 @@ static int b43_dma_set_mask(struct b43_wldev *dev, u64 mask)
 		if (!err)
 			break;
 		if (mask == DMA_BIT_MASK(64)) {
-			mask = DMA_32BIT_MASK;
+			mask = DMA_BIT_MASK(32);
 			fallback = 1;
 			continue;
 		}
-		if (mask == DMA_32BIT_MASK) {
+		if (mask == DMA_BIT_MASK(32)) {
 			mask = DMA_30BIT_MASK;
 			fallback = 1;
 			continue;
diff --git a/drivers/net/wireless/b43legacy/dma.c b/drivers/net/wireless/b43legacy/dma.c
index 61bb912..1d3e0d2 100644
--- a/drivers/net/wireless/b43legacy/dma.c
+++ b/drivers/net/wireless/b43legacy/dma.c
@@ -854,7 +854,7 @@ static u64 supported_dma_mask(struct b43legacy_wldev *dev)
 	tmp = b43legacy_read32(dev, mmio_base +
 			       B43legacy_DMA32_TXCTL);
 	if (tmp & B43legacy_DMA32_TXADDREXT_MASK)
-		return DMA_32BIT_MASK;
+		return DMA_BIT_MASK(32);
 
 	return DMA_30BIT_MASK;
 }
@@ -863,7 +863,7 @@ static enum b43legacy_dmatype dma_mask_to_engine_type(u64 dmamask)
 {
 	if (dmamask == DMA_30BIT_MASK)
 		return B43legacy_DMA_30BIT;
-	if (dmamask == DMA_32BIT_MASK)
+	if (dmamask == DMA_BIT_MASK(32))
 		return B43legacy_DMA_32BIT;
 	if (dmamask == DMA_BIT_MASK(64))
 		return B43legacy_DMA_64BIT;
@@ -1043,11 +1043,11 @@ static int b43legacy_dma_set_mask(struct b43legacy_wldev *dev, u64 mask)
 		if (!err)
 			break;
 		if (mask == DMA_BIT_MASK(64)) {
-			mask = DMA_32BIT_MASK;
+			mask = DMA_BIT_MASK(32);
 			fallback = 1;
 			continue;
 		}
-		if (mask == DMA_32BIT_MASK) {
+		if (mask == DMA_BIT_MASK(32)) {
 			mask = DMA_30BIT_MASK;
 			fallback = 1;
 			continue;
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index 823c2bf..3805146 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -6191,7 +6191,7 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
 	pci_set_master(pci_dev);
 	pci_set_drvdata(pci_dev, priv);
 
-	err = pci_set_dma_mask(pci_dev, DMA_32BIT_MASK);
+	err = pci_set_dma_mask(pci_dev, DMA_BIT_MASK(32));
 	if (err) {
 		printk(KERN_WARNING DRV_NAME
 		       "Error calling pci_set_dma_mask.\n");
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 625f2cf..b2dc8dc 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -11607,9 +11607,9 @@ static int __devinit ipw_pci_probe(struct pci_dev *pdev,
 
 	pci_set_master(pdev);
 
-	err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (!err)
-		err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (err) {
 		printk(KERN_WARNING DRV_NAME ": No suitable DMA available.\n");
 		goto out_pci_disable_device;
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 93be74a..73cca38 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -7872,9 +7872,9 @@ static int iwl3945_pci_probe(struct pci_dev *pdev, const struct pci_device_id *e
 
 	pci_set_master(pdev);
 
-	err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (!err)
-		err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (err) {
 		printk(KERN_WARNING DRV_NAME ": No suitable DMA available.\n");
 		goto out_pci_disable_device;
diff --git a/drivers/net/wireless/p54/p54pci.c b/drivers/net/wireless/p54/p54pci.c
index aa367a0..beaa149 100644
--- a/drivers/net/wireless/p54/p54pci.c
+++ b/drivers/net/wireless/p54/p54pci.c
@@ -490,8 +490,8 @@ static int __devinit p54p_probe(struct pci_dev *pdev,
 		goto err_disable_dev;
 	}
 
-	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK) ||
-	    pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK)) {
+	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) ||
+	    pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32))) {
 		printk(KERN_ERR "%s (p54pci): No suitable DMA available\n",
 		       pci_name(pdev));
 		goto err_free_reg;
diff --git a/drivers/net/wireless/prism54/islpci_hotplug.c b/drivers/net/wireless/prism54/islpci_hotplug.c
index 9a72b1e..3087672 100644
--- a/drivers/net/wireless/prism54/islpci_hotplug.c
+++ b/drivers/net/wireless/prism54/islpci_hotplug.c
@@ -120,7 +120,7 @@ prism54_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	}
 
 	/* enable PCI DMA */
-	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
+	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
 		printk(KERN_ERR "%s: 32-bit PCI DMA not supported", DRV_NAME);
 		goto do_pci_disable_device;
         }
diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.c b/drivers/net/wireless/rt2x00/rt2x00pci.c
index d52b22b..3923979 100644
--- a/drivers/net/wireless/rt2x00/rt2x00pci.c
+++ b/drivers/net/wireless/rt2x00/rt2x00pci.c
@@ -288,7 +288,7 @@ int rt2x00pci_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
 	if (pci_set_mwi(pci_dev))
 		ERROR_PROBE("MWI not available.\n");
 
-	if (dma_set_mask(&pci_dev->dev, DMA_32BIT_MASK)) {
+	if (dma_set_mask(&pci_dev->dev, DMA_BIT_MASK(32))) {
 		ERROR_PROBE("PCI DMA not supported.\n");
 		retval = -EIO;
 		goto exit_disable_device;
diff --git a/drivers/pci/intel-iommu.c b/drivers/pci/intel-iommu.c
index 46715db..a5d5221 100644
--- a/drivers/pci/intel-iommu.c
+++ b/drivers/pci/intel-iommu.c
@@ -55,7 +55,7 @@
 #define DOMAIN_MAX_ADDR(gaw) ((((u64)1) << gaw) - 1)
 
 #define IOVA_PFN(addr)		((addr) >> PAGE_SHIFT)
-#define DMA_32BIT_PFN		IOVA_PFN(DMA_32BIT_MASK)
+#define DMA_32BIT_PFN		IOVA_PFN(DMA_BIT_MASK(32))
 #define DMA_64BIT_PFN		IOVA_PFN(DMA_BIT_MASK(64))
 
 /* global iommu list, set NULL for ignored DMAR units */
@@ -2171,15 +2171,15 @@ __intel_alloc_iova(struct device *dev, struct dmar_domain *domain,
 	struct pci_dev *pdev = to_pci_dev(dev);
 	struct iova *iova = NULL;
 
-	if (dma_mask <= DMA_32BIT_MASK || dmar_forcedac)
+	if (dma_mask <= DMA_BIT_MASK(32) || dmar_forcedac)
 		iova = iommu_alloc_iova(domain, size, dma_mask);
 	else {
 		/*
 		 * First try to allocate an io virtual address in
-		 * DMA_32BIT_MASK and if that fails then try allocating
+		 * DMA_BIT_MASK(32) and if that fails then try allocating
 		 * from higher range
 		 */
-		iova = iommu_alloc_iova(domain, size, DMA_32BIT_MASK);
+		iova = iommu_alloc_iova(domain, size, DMA_BIT_MASK(32));
 		if (!iova)
 			iova = iommu_alloc_iova(domain, size, dma_mask);
 	}
diff --git a/drivers/rapidio/rio-scan.c b/drivers/rapidio/rio-scan.c
index 5c13f61..74d0bfa 100644
--- a/drivers/rapidio/rio-scan.c
+++ b/drivers/rapidio/rio-scan.c
@@ -381,9 +381,9 @@ static struct rio_dev *rio_setup_device(struct rio_net *net,
 	rdev->dev.release = rio_release_dev;
 	rio_dev_get(rdev);
 
-	rdev->dma_mask = DMA_32BIT_MASK;
+	rdev->dma_mask = DMA_BIT_MASK(32);
 	rdev->dev.dma_mask = &rdev->dma_mask;
-	rdev->dev.coherent_dma_mask = DMA_32BIT_MASK;
+	rdev->dev.coherent_dma_mask = DMA_BIT_MASK(32);
 
 	if ((rdev->pef & RIO_PEF_INB_DOORBELL) &&
 	    (rdev->dst_ops & RIO_DST_OPS_DOORBELL))
diff --git a/drivers/scsi/3w-9xxx.c b/drivers/scsi/3w-9xxx.c
index 7d60bdc..7e6f656 100644
--- a/drivers/scsi/3w-9xxx.c
+++ b/drivers/scsi/3w-9xxx.c
@@ -2017,8 +2017,8 @@ static int __devinit twa_probe(struct pci_dev *pdev, const struct pci_device_id
 
 	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(64))
 	    || pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64)))
-		if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)
-		    || pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK)) {
+		if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))
+		    || pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32))) {
 			TW_PRINTK(host, TW_DRIVER, 0x23, "Failed to set dma mask");
 			retval = -ENODEV;
 			goto out_disable_device;
diff --git a/drivers/scsi/3w-xxxx.h b/drivers/scsi/3w-xxxx.h
index 0742e68..8e71e5e 100644
--- a/drivers/scsi/3w-xxxx.h
+++ b/drivers/scsi/3w-xxxx.h
@@ -234,7 +234,7 @@ static unsigned char tw_sense_table[][4] =
 #define TW_IOCTL_TIMEOUT                      25 /* 25 seconds */
 #define TW_IOCTL_CHRDEV_TIMEOUT               60 /* 60 seconds */
 #define TW_IOCTL_CHRDEV_FREE                  -1
-#define TW_DMA_MASK			      DMA_32BIT_MASK
+#define TW_DMA_MASK			      DMA_BIT_MASK(32)
 #define TW_MAX_CDB_LEN			      16
 
 /* Bitmask macros to eliminate bitfields */
diff --git a/drivers/scsi/BusLogic.c b/drivers/scsi/BusLogic.c
index 2d689af..1ddcf40 100644
--- a/drivers/scsi/BusLogic.c
+++ b/drivers/scsi/BusLogic.c
@@ -667,7 +667,7 @@ static int __init BusLogic_InitializeMultiMasterProbeInfo(struct BusLogic_HostAd
 		if (pci_enable_device(PCI_Device))
 			continue;
 
-		if (pci_set_dma_mask(PCI_Device, DMA_32BIT_MASK ))
+		if (pci_set_dma_mask(PCI_Device, DMA_BIT_MASK(32) ))
 			continue;
 
 		Bus = PCI_Device->bus->number;
@@ -834,7 +834,7 @@ static int __init BusLogic_InitializeMultiMasterProbeInfo(struct BusLogic_HostAd
 		if (pci_enable_device(PCI_Device))
 			continue;
 
-		if (pci_set_dma_mask(PCI_Device, DMA_32BIT_MASK))
+		if (pci_set_dma_mask(PCI_Device, DMA_BIT_MASK(32)))
 			continue;
 
 		Bus = PCI_Device->bus->number;
@@ -888,7 +888,7 @@ static int __init BusLogic_InitializeFlashPointProbeInfo(struct BusLogic_HostAda
 		if (pci_enable_device(PCI_Device))
 			continue;
 
-		if (pci_set_dma_mask(PCI_Device, DMA_32BIT_MASK))
+		if (pci_set_dma_mask(PCI_Device, DMA_BIT_MASK(32)))
 			continue;
 
 		Bus = PCI_Device->bus->number;
diff --git a/drivers/scsi/a100u2w.c b/drivers/scsi/a100u2w.c
index 964769f..208d6df 100644
--- a/drivers/scsi/a100u2w.c
+++ b/drivers/scsi/a100u2w.c
@@ -1094,7 +1094,7 @@ static int __devinit inia100_probe_one(struct pci_dev *pdev,
 
 	if (pci_enable_device(pdev))
 		goto out;
-	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
+	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
 		printk(KERN_WARNING "Unable to set 32bit DMA "
 				    "on inia100 adapter, ignoring.\n");
 		goto out_disable_device;
diff --git a/drivers/scsi/aacraid/aachba.c b/drivers/scsi/aacraid/aachba.c
index 7ad1964..e7aaa60 100644
--- a/drivers/scsi/aacraid/aachba.c
+++ b/drivers/scsi/aacraid/aachba.c
@@ -1388,8 +1388,8 @@ int aac_get_adapter_info(struct aac_dev* dev)
 			if (!dev->in_reset)
 				printk(KERN_INFO"%s%d: 64 Bit DAC enabled\n",
 					dev->name, dev->id);
-		} else if (!pci_set_dma_mask(dev->pdev, DMA_32BIT_MASK) &&
-			!pci_set_consistent_dma_mask(dev->pdev, DMA_32BIT_MASK)) {
+		} else if (!pci_set_dma_mask(dev->pdev, DMA_BIT_MASK(32)) &&
+			!pci_set_consistent_dma_mask(dev->pdev, DMA_BIT_MASK(32))) {
 			printk(KERN_INFO"%s%d: DMA mask set failed, 64 Bit DAC disabled\n",
 				dev->name, dev->id);
 			dev->dac_support = 0;
diff --git a/drivers/scsi/aacraid/commsup.c b/drivers/scsi/aacraid/commsup.c
index d24c267..3b69c2d 100644
--- a/drivers/scsi/aacraid/commsup.c
+++ b/drivers/scsi/aacraid/commsup.c
@@ -1210,14 +1210,14 @@ static int _aac_reset_adapter(struct aac_dev *aac, int forced)
 		  ((retval = pci_set_consistent_dma_mask(aac->pdev, DMA_31BIT_MASK))))
 			goto out;
 	} else {
-		if (((retval = pci_set_dma_mask(aac->pdev, DMA_32BIT_MASK))) ||
-		  ((retval = pci_set_consistent_dma_mask(aac->pdev, DMA_32BIT_MASK))))
+		if (((retval = pci_set_dma_mask(aac->pdev, DMA_BIT_MASK(32)))) ||
+		  ((retval = pci_set_consistent_dma_mask(aac->pdev, DMA_BIT_MASK(32)))))
 			goto out;
 	}
 	if ((retval = (*(aac_get_driver_ident(index)->init))(aac)))
 		goto out;
 	if (quirks & AAC_QUIRK_31BIT)
-		if ((retval = pci_set_dma_mask(aac->pdev, DMA_32BIT_MASK)))
+		if ((retval = pci_set_dma_mask(aac->pdev, DMA_BIT_MASK(32))))
 			goto out;
 	if (jafo) {
 		aac->thread = kthread_run(aac_command_thread, aac, aac->name);
diff --git a/drivers/scsi/aacraid/linit.c b/drivers/scsi/aacraid/linit.c
index 36d8aab..40c27ae 100644
--- a/drivers/scsi/aacraid/linit.c
+++ b/drivers/scsi/aacraid/linit.c
@@ -1089,8 +1089,8 @@ static int __devinit aac_probe_one(struct pci_dev *pdev,
 		goto out;
 	error = -ENODEV;
 
-	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK) ||
-			pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK))
+	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) ||
+			pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32)))
 		goto out_disable_pdev;
 	/*
 	 * If the quirk31 bit is set, the adapter needs adapter
@@ -1148,7 +1148,7 @@ static int __devinit aac_probe_one(struct pci_dev *pdev,
 	 * address space.
 	 */
 	if (aac_drivers[index].quirks & AAC_QUIRK_31BIT)
-		if (pci_set_dma_mask(pdev, DMA_32BIT_MASK))
+		if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32)))
 			goto out_deinit;
 
 	aac->maximum_num_channels = aac_drivers[index].channels;
diff --git a/drivers/scsi/aic7xxx/aic79xx_osm_pci.c b/drivers/scsi/aic7xxx/aic79xx_osm_pci.c
index c583d89..8f68612 100644
--- a/drivers/scsi/aic7xxx/aic79xx_osm_pci.c
+++ b/drivers/scsi/aic7xxx/aic79xx_osm_pci.c
@@ -197,13 +197,13 @@ ahd_linux_pci_dev_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		if (required_mask > DMA_BIT_MASK(39) &&
 		    dma_set_mask(dev, DMA_BIT_MASK(64)) == 0)
 			ahd->flags |= AHD_64BIT_ADDRESSING;
-		else if (required_mask > DMA_32BIT_MASK &&
+		else if (required_mask > DMA_BIT_MASK(32) &&
 			 dma_set_mask(dev, DMA_BIT_MASK(39)) == 0)
 			ahd->flags |= AHD_39BIT_ADDRESSING;
 		else
-			dma_set_mask(dev, DMA_32BIT_MASK);
+			dma_set_mask(dev, DMA_BIT_MASK(32));
 	} else {
-		dma_set_mask(dev, DMA_32BIT_MASK);
+		dma_set_mask(dev, DMA_BIT_MASK(32));
 	}
 	ahd->dev_softc = pci;
 	error = ahd_pci_config(ahd, entry);
diff --git a/drivers/scsi/aic7xxx/aic7xxx_osm_pci.c b/drivers/scsi/aic7xxx/aic7xxx_osm_pci.c
index 00f5b98..78fc70c 100644
--- a/drivers/scsi/aic7xxx/aic7xxx_osm_pci.c
+++ b/drivers/scsi/aic7xxx/aic7xxx_osm_pci.c
@@ -241,10 +241,10 @@ ahc_linux_pci_dev_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (sizeof(dma_addr_t) > 4
 	    && ahc->features & AHC_LARGE_SCBS
 	    && dma_set_mask(dev, mask_39bit) == 0
-	    && dma_get_required_mask(dev) > DMA_32BIT_MASK) {
+	    && dma_get_required_mask(dev) > DMA_BIT_MASK(32)) {
 		ahc->flags |= AHC_39BIT_ADDRESSING;
 	} else {
-		if (dma_set_mask(dev, DMA_32BIT_MASK)) {
+		if (dma_set_mask(dev, DMA_BIT_MASK(32))) {
 			ahc_free(ahc);
 			printk(KERN_WARNING "aic7xxx: No suitable DMA available.\n");
                 	return (-ENODEV);
diff --git a/drivers/scsi/aic94xx/aic94xx_init.c b/drivers/scsi/aic94xx/aic94xx_init.c
index 7edbe43..996f722 100644
--- a/drivers/scsi/aic94xx/aic94xx_init.c
+++ b/drivers/scsi/aic94xx/aic94xx_init.c
@@ -793,8 +793,8 @@ static int __devinit asd_pci_probe(struct pci_dev *dev,
 	if (!pci_set_dma_mask(dev, DMA_BIT_MASK(64))
 	    && !pci_set_consistent_dma_mask(dev, DMA_BIT_MASK(64)))
 		;
-	else if (!pci_set_dma_mask(dev, DMA_32BIT_MASK)
-		 && !pci_set_consistent_dma_mask(dev, DMA_32BIT_MASK))
+	else if (!pci_set_dma_mask(dev, DMA_BIT_MASK(32))
+		 && !pci_set_consistent_dma_mask(dev, DMA_BIT_MASK(32)))
 		;
 	else {
 		asd_printk("no suitable DMA mask for %s\n", pci_name(dev));
diff --git a/drivers/scsi/arcmsr/arcmsr_hba.c b/drivers/scsi/arcmsr/arcmsr_hba.c
index e95b72d..80aac01 100644
--- a/drivers/scsi/arcmsr/arcmsr_hba.c
+++ b/drivers/scsi/arcmsr/arcmsr_hba.c
@@ -395,7 +395,7 @@ static int arcmsr_probe(struct pci_dev *pdev,
 
 	error = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (error) {
-		error = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		error = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (error) {
 			printk(KERN_WARNING
 			       "scsi%d: No suitable DMA mask available\n",
diff --git a/drivers/scsi/atp870u.c b/drivers/scsi/atp870u.c
index 20ca0a6..b137e56 100644
--- a/drivers/scsi/atp870u.c
+++ b/drivers/scsi/atp870u.c
@@ -2568,7 +2568,7 @@ static int atp870u_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (pci_enable_device(pdev))
 		goto err_eio;
 
-        if (!pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
+        if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
                 printk(KERN_INFO "atp870u: use 32bit DMA mask.\n");
         } else {
                 printk(KERN_ERR "atp870u: DMA mask required but not available.\n");
diff --git a/drivers/scsi/dpt_i2o.c b/drivers/scsi/dpt_i2o.c
index 75a94e4..b6af63c 100644
--- a/drivers/scsi/dpt_i2o.c
+++ b/drivers/scsi/dpt_i2o.c
@@ -1015,14 +1015,14 @@ static int adpt_install_hba(struct scsi_host_template* sht, struct pci_dev* pDev
 	 */
 	if (sizeof(dma_addr_t) > 4 &&
 	    pci_set_dma_mask(pDev, DMA_BIT_MASK(64)) == 0) {
-		if (dma_get_required_mask(&pDev->dev) > DMA_32BIT_MASK)
+		if (dma_get_required_mask(&pDev->dev) > DMA_BIT_MASK(32))
 			dma64 = 1;
 	}
-	if (!dma64 && pci_set_dma_mask(pDev, DMA_32BIT_MASK) != 0)
+	if (!dma64 && pci_set_dma_mask(pDev, DMA_BIT_MASK(32)) != 0)
 		return -EINVAL;
 
 	/* adapter only supports message blocks below 4GB */
-	pci_set_consistent_dma_mask(pDev, DMA_32BIT_MASK);
+	pci_set_consistent_dma_mask(pDev, DMA_BIT_MASK(32));
 
 	base_addr0_phys = pci_resource_start(pDev,0);
 	hba_map0_area_size = pci_resource_len(pDev,0);
diff --git a/drivers/scsi/eata.c b/drivers/scsi/eata.c
index 976cdd5..be5099d 100644
--- a/drivers/scsi/eata.c
+++ b/drivers/scsi/eata.c
@@ -1426,7 +1426,7 @@ static int port_detect(unsigned long port_base, unsigned int j,
 
 	if (ha->pdev) {
 		pci_set_master(ha->pdev);
-		if (pci_set_dma_mask(ha->pdev, DMA_32BIT_MASK))
+		if (pci_set_dma_mask(ha->pdev, DMA_BIT_MASK(32)))
 			printk("%s: warning, pci_set_dma_mask failed.\n",
 			       ha->board_name);
 	}
diff --git a/drivers/scsi/gdth.c b/drivers/scsi/gdth.c
index 4982344..185e6bc 100644
--- a/drivers/scsi/gdth.c
+++ b/drivers/scsi/gdth.c
@@ -5023,7 +5023,7 @@ static int __devinit gdth_pci_probe_one(gdth_pci_str *pcistr,
 	/* 64-bit DMA only supported from FW >= x.43 */
 	if (!(ha->cache_feat & ha->raw_feat & ha->screen_feat & GDT_64BIT) ||
 	    !ha->dma64_support) {
-		if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
+		if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
 			printk(KERN_WARNING "GDT-PCI %d: "
 				"Unable to set 32-bit DMA\n", ha->hanum);
 				goto out_free_coal_stat;
@@ -5032,7 +5032,7 @@ static int __devinit gdth_pci_probe_one(gdth_pci_str *pcistr,
 		shp->max_cmd_len = 16;
 		if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 			printk("GDT-PCI %d: 64-bit DMA enabled\n", ha->hanum);
-		} else if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
+		} else if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
 			printk(KERN_WARNING "GDT-PCI %d: "
 				"Unable to set 64/32-bit DMA\n", ha->hanum);
 			goto out_free_coal_stat;
diff --git a/drivers/scsi/hptiop.c b/drivers/scsi/hptiop.c
index cc7a7a2..1653326 100644
--- a/drivers/scsi/hptiop.c
+++ b/drivers/scsi/hptiop.c
@@ -960,7 +960,7 @@ static int __devinit hptiop_probe(struct pci_dev *pcidev,
 
 	/* Enable 64bit DMA if possible */
 	if (pci_set_dma_mask(pcidev, DMA_BIT_MASK(64))) {
-		if (pci_set_dma_mask(pcidev, DMA_32BIT_MASK)) {
+		if (pci_set_dma_mask(pcidev, DMA_BIT_MASK(32))) {
 			printk(KERN_ERR "hptiop: fail to set dma_mask\n");
 			goto disable_pci_device;
 		}
diff --git a/drivers/scsi/initio.c b/drivers/scsi/initio.c
index 5529518..89a5948 100644
--- a/drivers/scsi/initio.c
+++ b/drivers/scsi/initio.c
@@ -2856,7 +2856,7 @@ static int initio_probe_one(struct pci_dev *pdev,
 		reg = 0;
 	bios_seg = (bios_seg << 8) + ((u16) ((reg & 0xFF00) >> 8));
 
-	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
+	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
 		printk(KERN_WARNING  "i91u: Could not set 32 bit DMA mask\n");
 		error = -ENODEV;
 		goto out_disable_device;
diff --git a/drivers/scsi/ipr.c b/drivers/scsi/ipr.c
index 0782900..5eec2c1 100644
--- a/drivers/scsi/ipr.c
+++ b/drivers/scsi/ipr.c
@@ -7490,7 +7490,7 @@ static int __devinit ipr_probe_ioa(struct pci_dev *pdev,
 
 	pci_set_master(pdev);
 
-	rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (rc < 0) {
 		dev_err(&pdev->dev, "Failed to set PCI DMA mask\n");
 		goto cleanup_nomem;
diff --git a/drivers/scsi/ips.c b/drivers/scsi/ips.c
index 0973c69..eafb3fe 100644
--- a/drivers/scsi/ips.c
+++ b/drivers/scsi/ips.c
@@ -7052,7 +7052,7 @@ ips_init_phase1(struct pci_dev *pci_dev, int *indexPtr)
 	    !pci_set_dma_mask(ha->pcidev, DMA_BIT_MASK(64))) {
 		(ha)->flags |= IPS_HA_ENH_SG;
 	} else {
-		if (pci_set_dma_mask(ha->pcidev, DMA_32BIT_MASK) != 0) {
+		if (pci_set_dma_mask(ha->pcidev, DMA_BIT_MASK(32)) != 0) {
 			printk(KERN_WARNING "Unable to set DMA Mask\n");
 			return ips_abort_init(ha, index);
 		}
diff --git a/drivers/scsi/lasi700.c b/drivers/scsi/lasi700.c
index 4a4e695..0da6973 100644
--- a/drivers/scsi/lasi700.c
+++ b/drivers/scsi/lasi700.c
@@ -108,7 +108,7 @@ lasi700_probe(struct parisc_device *dev)
 	}
 
 	hostdata->dev = &dev->dev;
-	dma_set_mask(&dev->dev, DMA_32BIT_MASK);
+	dma_set_mask(&dev->dev, DMA_BIT_MASK(32));
 	hostdata->base = ioremap_nocache(base, 0x100);
 	hostdata->differential = 0;
 
diff --git a/drivers/scsi/lpfc/lpfc_init.c b/drivers/scsi/lpfc/lpfc_init.c
index c255b4d..06874e6 100644
--- a/drivers/scsi/lpfc/lpfc_init.c
+++ b/drivers/scsi/lpfc/lpfc_init.c
@@ -2661,7 +2661,7 @@ lpfc_pci_probe_one(struct pci_dev *pdev, const struct pci_device_id *pid)
 	pci_try_set_mwi(pdev);
 
 	if (pci_set_dma_mask(phba->pcidev, DMA_BIT_MASK(64)) != 0)
-		if (pci_set_dma_mask(phba->pcidev, DMA_32BIT_MASK) != 0)
+		if (pci_set_dma_mask(phba->pcidev, DMA_BIT_MASK(32)) != 0)
 			goto out_idr_remove;
 
 	/*
diff --git a/drivers/scsi/megaraid.c b/drivers/scsi/megaraid.c
index 112991d..49eb061 100644
--- a/drivers/scsi/megaraid.c
+++ b/drivers/scsi/megaraid.c
@@ -2021,7 +2021,7 @@ make_local_pdev(adapter_t *adapter, struct pci_dev **pdev)
 
 	memcpy(*pdev, adapter->dev, sizeof(struct pci_dev));
 
-	if( pci_set_dma_mask(*pdev, DMA_32BIT_MASK) != 0 ) {
+	if( pci_set_dma_mask(*pdev, DMA_BIT_MASK(32)) != 0 ) {
 		kfree(*pdev);
 		return -1;
 	}
@@ -4796,7 +4796,7 @@ megaraid_probe_one(struct pci_dev *pdev, const struct pci_device_id *id)
 		pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 		adapter->has_64bit_addr = 1;
 	} else  {
-		pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		adapter->has_64bit_addr = 0;
 	}
 		
diff --git a/drivers/scsi/megaraid/megaraid_mbox.c b/drivers/scsi/megaraid/megaraid_mbox.c
index b2c1944..234f0b7 100644
--- a/drivers/scsi/megaraid/megaraid_mbox.c
+++ b/drivers/scsi/megaraid/megaraid_mbox.c
@@ -473,7 +473,7 @@ megaraid_probe_one(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	// Setup the default DMA mask. This would be changed later on
 	// depending on hardware capabilities
-	if (pci_set_dma_mask(adapter->pdev, DMA_32BIT_MASK) != 0) {
+	if (pci_set_dma_mask(adapter->pdev, DMA_BIT_MASK(32)) != 0) {
 
 		con_log(CL_ANN, (KERN_WARNING
 			"megaraid: pci_set_dma_mask failed:%d\n", __LINE__));
@@ -904,7 +904,7 @@ megaraid_init_mbox(adapter_t *adapter)
 			con_log(CL_ANN, (KERN_WARNING
 				"megaraid: DMA mask for 64-bit failed\n"));
 
-			if (pci_set_dma_mask (adapter->pdev, DMA_32BIT_MASK)) {
+			if (pci_set_dma_mask (adapter->pdev, DMA_BIT_MASK(32))) {
 				con_log(CL_ANN, (KERN_WARNING
 					"megaraid: 32-bit DMA mask failed\n"));
 				goto out_free_sysfs_res;
diff --git a/drivers/scsi/megaraid/megaraid_sas.c b/drivers/scsi/megaraid/megaraid_sas.c
index 713de85..7dc3d18 100644
--- a/drivers/scsi/megaraid/megaraid_sas.c
+++ b/drivers/scsi/megaraid/megaraid_sas.c
@@ -2499,11 +2499,11 @@ megasas_set_dma_mask(struct pci_dev *pdev)
 	if (IS_DMA64) {
 		if (pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) != 0) {
 
-			if (pci_set_dma_mask(pdev, DMA_32BIT_MASK) != 0)
+			if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) != 0)
 				goto fail_set_dma_mask;
 		}
 	} else {
-		if (pci_set_dma_mask(pdev, DMA_32BIT_MASK) != 0)
+		if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) != 0)
 			goto fail_set_dma_mask;
 	}
 	return 0;
diff --git a/drivers/scsi/mvsas.c b/drivers/scsi/mvsas.c
index d8093a2..e4acebd 100644
--- a/drivers/scsi/mvsas.c
+++ b/drivers/scsi/mvsas.c
@@ -878,7 +878,7 @@ static int pci_go_64(struct pci_dev *pdev)
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 		if (rc) {
-			rc = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+			rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 			if (rc) {
 				dev_printk(KERN_ERR, &pdev->dev,
 					   "64-bit DMA enable failed\n");
@@ -886,13 +886,13 @@ static int pci_go_64(struct pci_dev *pdev)
 			}
 		}
 	} else {
-		rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc) {
 			dev_printk(KERN_ERR, &pdev->dev,
 				   "32-bit DMA enable failed\n");
 			return rc;
 		}
-		rc = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+		rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc) {
 			dev_printk(KERN_ERR, &pdev->dev,
 				   "32-bit consistent DMA enable failed\n");
diff --git a/drivers/scsi/nsp32.c b/drivers/scsi/nsp32.c
index d06ec5a..2be7d5b 100644
--- a/drivers/scsi/nsp32.c
+++ b/drivers/scsi/nsp32.c
@@ -2672,7 +2672,7 @@ static int nsp32_detect(struct pci_dev *pdev)
 	/*
 	 * setup DMA 
 	 */
-	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK) != 0) {
+	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) != 0) {
 		nsp32_msg (KERN_ERR, "failed to set PCI DMA mask");
 		goto scsi_unregister;
 	}
diff --git a/drivers/scsi/qla1280.c b/drivers/scsi/qla1280.c
index f242614..5226fd2 100644
--- a/drivers/scsi/qla1280.c
+++ b/drivers/scsi/qla1280.c
@@ -4245,7 +4245,7 @@ qla1280_probe_one(struct pci_dev *pdev, const struct pci_device_id *id)
 
 #ifdef QLA_64BIT_PTR
 	if (pci_set_dma_mask(ha->pdev, DMA_BIT_MASK(64))) {
-		if (pci_set_dma_mask(ha->pdev, DMA_32BIT_MASK)) {
+		if (pci_set_dma_mask(ha->pdev, DMA_BIT_MASK(32))) {
 			printk(KERN_WARNING "scsi(%li): Unable to set a "
 			       "suitable DMA mask - aborting\n", ha->host_no);
 			error = -ENODEV;
@@ -4255,7 +4255,7 @@ qla1280_probe_one(struct pci_dev *pdev, const struct pci_device_id *id)
 		dprintk(2, "scsi(%li): 64 Bit PCI Addressing Enabled\n",
 			ha->host_no);
 #else
-	if (pci_set_dma_mask(ha->pdev, DMA_32BIT_MASK)) {
+	if (pci_set_dma_mask(ha->pdev, DMA_BIT_MASK(32))) {
 		printk(KERN_WARNING "scsi(%li): Unable to set a "
 		       "suitable DMA mask - aborting\n", ha->host_no);
 		error = -ENODEV;
diff --git a/drivers/scsi/qla2xxx/qla_os.c b/drivers/scsi/qla2xxx/qla_os.c
index 03ebebf..8e7b60d 100644
--- a/drivers/scsi/qla2xxx/qla_os.c
+++ b/drivers/scsi/qla2xxx/qla_os.c
@@ -1257,8 +1257,8 @@ qla2x00_config_dma_addressing(struct qla_hw_data *ha)
 		}
 	}
 
-	dma_set_mask(&ha->pdev->dev, DMA_32BIT_MASK);
-	pci_set_consistent_dma_mask(ha->pdev, DMA_32BIT_MASK);
+	dma_set_mask(&ha->pdev->dev, DMA_BIT_MASK(32));
+	pci_set_consistent_dma_mask(ha->pdev, DMA_BIT_MASK(32));
 }
 
 static void
diff --git a/drivers/scsi/qla4xxx/ql4_os.c b/drivers/scsi/qla4xxx/ql4_os.c
index d427fab..ec9da6c 100644
--- a/drivers/scsi/qla4xxx/ql4_os.c
+++ b/drivers/scsi/qla4xxx/ql4_os.c
@@ -1375,10 +1375,10 @@ static void qla4xxx_config_dma_addressing(struct scsi_qla_host *ha)
 				  "Failed to set 64 bit PCI consistent mask; "
 				   "using 32 bit.\n");
 			retval = pci_set_consistent_dma_mask(ha->pdev,
-							     DMA_32BIT_MASK);
+							     DMA_BIT_MASK(32));
 		}
 	} else
-		retval = pci_set_dma_mask(ha->pdev, DMA_32BIT_MASK);
+		retval = pci_set_dma_mask(ha->pdev, DMA_BIT_MASK(32));
 }
 
 static int qla4xxx_slave_alloc(struct scsi_device *sdev)
diff --git a/drivers/scsi/sni_53c710.c b/drivers/scsi/sni_53c710.c
index 77f0b2c..37b3359 100644
--- a/drivers/scsi/sni_53c710.c
+++ b/drivers/scsi/sni_53c710.c
@@ -83,7 +83,7 @@ static int __init snirm710_probe(struct platform_device *dev)
 	}
 
 	hostdata->dev = &dev->dev;
-	dma_set_mask(&dev->dev, DMA_32BIT_MASK);
+	dma_set_mask(&dev->dev, DMA_BIT_MASK(32));
 	hostdata->base = ioremap_nocache(base, 0x100);
 	hostdata->differential = 0;
 
diff --git a/drivers/scsi/stex.c b/drivers/scsi/stex.c
index 764c033..8f37295 100644
--- a/drivers/scsi/stex.c
+++ b/drivers/scsi/stex.c
@@ -1070,9 +1070,9 @@ static int stex_set_dma_mask(struct pci_dev * pdev)
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))
 		&& !pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64)))
 		return 0;
-	ret = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	ret = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (!ret)
-		ret = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+		ret = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 	return ret;
 }
 
diff --git a/drivers/scsi/sym53c8xx_2/sym_glue.c b/drivers/scsi/sym53c8xx_2/sym_glue.c
index f4e6cde..614cd16 100644
--- a/drivers/scsi/sym53c8xx_2/sym_glue.c
+++ b/drivers/scsi/sym53c8xx_2/sym_glue.c
@@ -1329,7 +1329,7 @@ static struct Scsi_Host * __devinit sym_attach(struct scsi_host_template *tpnt,
 	if ((SYM_CONF_DMA_ADDRESSING_MODE > 0) && (np->features & FE_DAC) &&
 			!pci_set_dma_mask(pdev, DMA_DAC_MASK)) {
 		set_dac(np);
-	} else if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
+	} else if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
 		printf_warning("%s: No suitable DMA available\n", sym_name(np));
 		goto attach_failed;
 	}
diff --git a/drivers/scsi/sym53c8xx_2/sym_hipd.h b/drivers/scsi/sym53c8xx_2/sym_hipd.h
index 61e8848..7788528 100644
--- a/drivers/scsi/sym53c8xx_2/sym_hipd.h
+++ b/drivers/scsi/sym53c8xx_2/sym_hipd.h
@@ -1076,7 +1076,7 @@ int sym_hcb_attach(struct Scsi_Host *shost, struct sym_fw *fw, struct sym_nvram
  */
 
 #if   SYM_CONF_DMA_ADDRESSING_MODE == 0
-#define DMA_DAC_MASK	DMA_32BIT_MASK
+#define DMA_DAC_MASK	DMA_BIT_MASK(32)
 #define sym_build_sge(np, data, badd, len)	\
 do {						\
 	(data)->addr = cpu_to_scr(badd);	\
diff --git a/drivers/staging/agnx/pci.c b/drivers/staging/agnx/pci.c
index 854630c..1629f4f 100644
--- a/drivers/staging/agnx/pci.c
+++ b/drivers/staging/agnx/pci.c
@@ -478,8 +478,8 @@ static int __devinit agnx_pci_probe(struct pci_dev *pdev,
 		return err;
 	}
 
-	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK) ||
-	    pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK)) {
+	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) ||
+	    pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32))) {
 		printk(KERN_ERR PFX "No suitable DMA available\n");
 		goto err_free_reg;
 	}
diff --git a/drivers/staging/altpciechdma/altpciechdma.c b/drivers/staging/altpciechdma/altpciechdma.c
index 3da8a52..ec692b5 100644
--- a/drivers/staging/altpciechdma/altpciechdma.c
+++ b/drivers/staging/altpciechdma/altpciechdma.c
@@ -853,9 +853,9 @@ static int __devinit probe(struct pci_dev *dev, const struct pci_device_id *id)
 		printk(KERN_DEBUG "Using a 64-bit DMA mask.\n");
 	} else
 #endif
-	if (!pci_set_dma_mask(dev, DMA_32BIT_MASK)) {
+	if (!pci_set_dma_mask(dev, DMA_BIT_MASK(32))) {
 		printk(KERN_DEBUG "Could not set 64-bit DMA mask.\n");
-		pci_set_consistent_dma_mask(dev, DMA_32BIT_MASK);
+		pci_set_consistent_dma_mask(dev, DMA_BIT_MASK(32));
 		/* use 32-bit DMA */
 		printk(KERN_DEBUG "Using a 32-bit DMA mask.\n");
 	} else {
diff --git a/drivers/staging/benet/be_init.c b/drivers/staging/benet/be_init.c
index 09c3cfc..96b28e2 100644
--- a/drivers/staging/benet/be_init.c
+++ b/drivers/staging/benet/be_init.c
@@ -1027,7 +1027,7 @@ static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 		adapter->dma_64bit_cap = true;
 	} else {
 		adapter->dma_64bit_cap = false;
-		status = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		status = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (status != 0) {
 			printk(KERN_ERR "Could not set PCI DMA Mask\n");
 			goto cleanup;
diff --git a/drivers/staging/slicoss/slicoss.c b/drivers/staging/slicoss/slicoss.c
index 16eed6f..7c3cefb 100644
--- a/drivers/staging/slicoss/slicoss.c
+++ b/drivers/staging/slicoss/slicoss.c
@@ -364,14 +364,14 @@ static int __devinit slic_entry_probe(struct pci_dev *pcidev,
 	if (!err) {
 		DBG_MSG("pci_set_dma_mask(DMA_BIT_MASK(64)) successful\n");
 	} else {
-		err = pci_set_dma_mask(pcidev, DMA_32BIT_MASK);
+		err = pci_set_dma_mask(pcidev, DMA_BIT_MASK(32));
 		if (err) {
 			DBG_MSG
 			    ("No usable DMA configuration, aborting  err[%x]\n",
 			     err);
 			return err;
 		}
-		DBG_MSG("pci_set_dma_mask(DMA_32BIT_MASK) successful\n");
+		DBG_MSG("pci_set_dma_mask(DMA_BIT_MASK(32)) successful\n");
 	}
 
 	DBG_MSG("Call pci_request_regions\n");
diff --git a/drivers/staging/sxg/sxg.c b/drivers/staging/sxg/sxg.c
index 2a7cc46..179edbd 100644
--- a/drivers/staging/sxg/sxg.c
+++ b/drivers/staging/sxg/sxg.c
@@ -660,13 +660,13 @@ static int sxg_entry_probe(struct pci_dev *pcidev,
 	if (!(err = pci_set_dma_mask(pcidev, DMA_BIT_MASK(64)))) {
 		DBG_ERROR("pci_set_dma_mask(DMA_BIT_MASK(64)) successful\n");
 	} else {
-		if ((err = pci_set_dma_mask(pcidev, DMA_32BIT_MASK))) {
+		if ((err = pci_set_dma_mask(pcidev, DMA_BIT_MASK(32)))) {
 			DBG_ERROR
 			    ("No usable DMA configuration, aborting  err[%x]\n",
 			     err);
 			return err;
 		}
-		DBG_ERROR("pci_set_dma_mask(DMA_32BIT_MASK) successful\n");
+		DBG_ERROR("pci_set_dma_mask(DMA_BIT_MASK(32)) successful\n");
 	}
 
 	DBG_ERROR("Call pci_request_regions\n");
diff --git a/drivers/usb/host/ehci-ps3.c b/drivers/usb/host/ehci-ps3.c
index 9c9da35..1ba9f9a 100644
--- a/drivers/usb/host/ehci-ps3.c
+++ b/drivers/usb/host/ehci-ps3.c
@@ -81,7 +81,7 @@ static int ps3_ehci_probe(struct ps3_system_bus_device *dev)
 	int result;
 	struct usb_hcd *hcd;
 	unsigned int virq;
-	static u64 dummy_mask = DMA_32BIT_MASK;
+	static u64 dummy_mask = DMA_BIT_MASK(32);
 
 	if (usb_disabled()) {
 		result = -ENODEV;
diff --git a/drivers/usb/host/ohci-ps3.c b/drivers/usb/host/ohci-ps3.c
index 3c1a3b5..3d19103 100644
--- a/drivers/usb/host/ohci-ps3.c
+++ b/drivers/usb/host/ohci-ps3.c
@@ -80,7 +80,7 @@ static int ps3_ohci_probe(struct ps3_system_bus_device *dev)
 	int result;
 	struct usb_hcd *hcd;
 	unsigned int virq;
-	static u64 dummy_mask = DMA_32BIT_MASK;
+	static u64 dummy_mask = DMA_BIT_MASK(32);
 
 	if (usb_disabled()) {
 		result = -ENODEV;
diff --git a/drivers/uwb/whci.c b/drivers/uwb/whci.c
index 79bb06c..2e27846 100644
--- a/drivers/uwb/whci.c
+++ b/drivers/uwb/whci.c
@@ -162,8 +162,8 @@ static int whci_probe(struct pci_dev *pci, const struct pci_device_id *id)
 	err = -ENXIO;
 	if (!pci_set_dma_mask(pci, DMA_BIT_MASK(64)))
 		pci_set_consistent_dma_mask(pci, DMA_BIT_MASK(64));
-	else if (!pci_set_dma_mask(pci, DMA_32BIT_MASK))
-		pci_set_consistent_dma_mask(pci, DMA_32BIT_MASK);
+	else if (!pci_set_dma_mask(pci, DMA_BIT_MASK(32)))
+		pci_set_consistent_dma_mask(pci, DMA_BIT_MASK(32));
 	else
 		goto error_dma;
 
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index ba9114e..f238c7e 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -67,7 +67,7 @@ static inline u64 dma_get_mask(struct device *dev)
 {
 	if (dev && dev->dma_mask && *dev->dma_mask)
 		return *dev->dma_mask;
-	return DMA_32BIT_MASK;
+	return DMA_BIT_MASK(32);
 }
 
 extern u64 dma_get_required_mask(struct device *dev);
diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index 1f991ac..2a56820 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -549,7 +549,7 @@ swiotlb_alloc_coherent(struct device *hwdev, size_t size,
 	dma_addr_t dev_addr;
 	void *ret;
 	int order = get_order(size);
-	u64 dma_mask = DMA_32BIT_MASK;
+	u64 dma_mask = DMA_BIT_MASK(32);
 
 	if (hwdev && hwdev->coherent_dma_mask)
 		dma_mask = hwdev->coherent_dma_mask;
diff --git a/sound/pci/ad1889.c b/sound/pci/ad1889.c
index a7f38e6..38a72b9 100644
--- a/sound/pci/ad1889.c
+++ b/sound/pci/ad1889.c
@@ -909,8 +909,8 @@ snd_ad1889_create(struct snd_card *card,
 		return err;
 
 	/* check PCI availability (32bit DMA) */
-	if (pci_set_dma_mask(pci, DMA_32BIT_MASK) < 0 ||
-	    pci_set_consistent_dma_mask(pci, DMA_32BIT_MASK) < 0) {
+	if (pci_set_dma_mask(pci, DMA_BIT_MASK(32)) < 0 ||
+	    pci_set_consistent_dma_mask(pci, DMA_BIT_MASK(32)) < 0) {
 		printk(KERN_ERR PFX "error setting 32-bit DMA mask.\n");
 		pci_disable_device(pci);
 		return -ENXIO;
diff --git a/sound/pci/au88x0/au88x0.c b/sound/pci/au88x0/au88x0.c
index a36d4d1..0e872cb 100644
--- a/sound/pci/au88x0/au88x0.c
+++ b/sound/pci/au88x0/au88x0.c
@@ -151,8 +151,8 @@ snd_vortex_create(struct snd_card *card, struct pci_dev *pci, vortex_t ** rchip)
 	// check PCI availability (DMA).
 	if ((err = pci_enable_device(pci)) < 0)
 		return err;
-	if (pci_set_dma_mask(pci, DMA_32BIT_MASK) < 0 ||
-	    pci_set_consistent_dma_mask(pci, DMA_32BIT_MASK) < 0) {
+	if (pci_set_dma_mask(pci, DMA_BIT_MASK(32)) < 0 ||
+	    pci_set_consistent_dma_mask(pci, DMA_BIT_MASK(32)) < 0) {
 		printk(KERN_ERR "error to set DMA mask\n");
 		pci_disable_device(pci);
 		return -ENXIO;
diff --git a/sound/pci/aw2/aw2-alsa.c b/sound/pci/aw2/aw2-alsa.c
index 3f00ddf..0d7aeae 100644
--- a/sound/pci/aw2/aw2-alsa.c
+++ b/sound/pci/aw2/aw2-alsa.c
@@ -279,8 +279,8 @@ static int __devinit snd_aw2_create(struct snd_card *card,
 	pci_set_master(pci);
 
 	/* check PCI availability (32bit DMA) */
-	if ((pci_set_dma_mask(pci, DMA_32BIT_MASK) < 0) ||
-	    (pci_set_consistent_dma_mask(pci, DMA_32BIT_MASK) < 0)) {
+	if ((pci_set_dma_mask(pci, DMA_BIT_MASK(32)) < 0) ||
+	    (pci_set_consistent_dma_mask(pci, DMA_BIT_MASK(32)) < 0)) {
 		printk(KERN_ERR "aw2: Impossible to set 32bit mask DMA\n");
 		pci_disable_device(pci);
 		return -ENXIO;
diff --git a/sound/pci/ca0106/ca0106_main.c b/sound/pci/ca0106/ca0106_main.c
index 0e62205..e57312c 100644
--- a/sound/pci/ca0106/ca0106_main.c
+++ b/sound/pci/ca0106/ca0106_main.c
@@ -1530,8 +1530,8 @@ static int __devinit snd_ca0106_create(int dev, struct snd_card *card,
 	err = pci_enable_device(pci);
 	if (err < 0)
 		return err;
-	if (pci_set_dma_mask(pci, DMA_32BIT_MASK) < 0 ||
-	    pci_set_consistent_dma_mask(pci, DMA_32BIT_MASK) < 0) {
+	if (pci_set_dma_mask(pci, DMA_BIT_MASK(32)) < 0 ||
+	    pci_set_consistent_dma_mask(pci, DMA_BIT_MASK(32)) < 0) {
 		printk(KERN_ERR "error to set 32bit mask DMA\n");
 		pci_disable_device(pci);
 		return -ENXIO;
diff --git a/sound/pci/cs5535audio/cs5535audio.c b/sound/pci/cs5535audio/cs5535audio.c
index 826e6de..51baa7e 100644
--- a/sound/pci/cs5535audio/cs5535audio.c
+++ b/sound/pci/cs5535audio/cs5535audio.c
@@ -285,8 +285,8 @@ static int __devinit snd_cs5535audio_create(struct snd_card *card,
 	if ((err = pci_enable_device(pci)) < 0)
 		return err;
 
-	if (pci_set_dma_mask(pci, DMA_32BIT_MASK) < 0 ||
-	    pci_set_consistent_dma_mask(pci, DMA_32BIT_MASK) < 0) {
+	if (pci_set_dma_mask(pci, DMA_BIT_MASK(32)) < 0 ||
+	    pci_set_consistent_dma_mask(pci, DMA_BIT_MASK(32)) < 0) {
 		printk(KERN_WARNING "unable to get 32bit dma\n");
 		err = -ENXIO;
 		goto pcifail;
diff --git a/sound/pci/mixart/mixart.c b/sound/pci/mixart/mixart.c
index f23a735..c88d8eb 100644
--- a/sound/pci/mixart/mixart.c
+++ b/sound/pci/mixart/mixart.c
@@ -1290,7 +1290,7 @@ static int __devinit snd_mixart_probe(struct pci_dev *pci,
 	pci_set_master(pci);
 
 	/* check if we can restrict PCI DMA transfers to 32 bits */
-	if (pci_set_dma_mask(pci, DMA_32BIT_MASK) < 0) {
+	if (pci_set_dma_mask(pci, DMA_BIT_MASK(32)) < 0) {
 		snd_printk(KERN_ERR "architecture does not support 32bit PCI busmaster DMA\n");
 		pci_disable_device(pci);
 		return -ENXIO;
diff --git a/sound/pci/pcxhr/pcxhr.c b/sound/pci/pcxhr/pcxhr.c
index 27cf2c2..ecb15d0 100644
--- a/sound/pci/pcxhr/pcxhr.c
+++ b/sound/pci/pcxhr/pcxhr.c
@@ -1408,7 +1408,7 @@ static int __devinit pcxhr_probe(struct pci_dev *pci,
 	pci_set_master(pci);
 
 	/* check if we can restrict PCI DMA transfers to 32 bits */
-	if (pci_set_dma_mask(pci, DMA_32BIT_MASK) < 0) {
+	if (pci_set_dma_mask(pci, DMA_BIT_MASK(32)) < 0) {
 		snd_printk(KERN_ERR "architecture does not support "
 			   "32bit PCI busmaster DMA\n");
 		pci_disable_device(pci);
diff --git a/sound/soc/blackfin/bf5xx-ac97-pcm.c b/sound/soc/blackfin/bf5xx-ac97-pcm.c
index 8067cfa..279ad20 100644
--- a/sound/soc/blackfin/bf5xx-ac97-pcm.c
+++ b/sound/soc/blackfin/bf5xx-ac97-pcm.c
@@ -413,7 +413,7 @@ static void bf5xx_pcm_free_dma_buffers(struct snd_pcm *pcm)
 		sport_done(sport_handle);
 }
 
-static u64 bf5xx_pcm_dmamask = DMA_32BIT_MASK;
+static u64 bf5xx_pcm_dmamask = DMA_BIT_MASK(32);
 
 int bf5xx_pcm_ac97_new(struct snd_card *card, struct snd_soc_dai *dai,
 	struct snd_pcm *pcm)
@@ -424,7 +424,7 @@ int bf5xx_pcm_ac97_new(struct snd_card *card, struct snd_soc_dai *dai,
 	if (!card->dev->dma_mask)
 		card->dev->dma_mask = &bf5xx_pcm_dmamask;
 	if (!card->dev->coherent_dma_mask)
-		card->dev->coherent_dma_mask = DMA_32BIT_MASK;
+		card->dev->coherent_dma_mask = DMA_BIT_MASK(32);
 
 	if (dai->playback.channels_min) {
 		ret = bf5xx_pcm_preallocate_dma_buffer(pcm,
diff --git a/sound/soc/blackfin/bf5xx-i2s-pcm.c b/sound/soc/blackfin/bf5xx-i2s-pcm.c
index 53d290b..02c21e1 100644
--- a/sound/soc/blackfin/bf5xx-i2s-pcm.c
+++ b/sound/soc/blackfin/bf5xx-i2s-pcm.c
@@ -245,7 +245,7 @@ static void bf5xx_pcm_free_dma_buffers(struct snd_pcm *pcm)
 		sport_done(sport_handle);
 }
 
-static u64 bf5xx_pcm_dmamask = DMA_32BIT_MASK;
+static u64 bf5xx_pcm_dmamask = DMA_BIT_MASK(32);
 
 int bf5xx_pcm_i2s_new(struct snd_card *card, struct snd_soc_dai *dai,
 	struct snd_pcm *pcm)
@@ -256,7 +256,7 @@ int bf5xx_pcm_i2s_new(struct snd_card *card, struct snd_soc_dai *dai,
 	if (!card->dev->dma_mask)
 		card->dev->dma_mask = &bf5xx_pcm_dmamask;
 	if (!card->dev->coherent_dma_mask)
-		card->dev->coherent_dma_mask = DMA_32BIT_MASK;
+		card->dev->coherent_dma_mask = DMA_BIT_MASK(32);
 
 	if (dai->playback.channels_min) {
 		ret = bf5xx_pcm_preallocate_dma_buffer(pcm,
diff --git a/sound/soc/omap/omap-pcm.c b/sound/soc/omap/omap-pcm.c
index dd3bb29..fd2e726 100644
--- a/sound/soc/omap/omap-pcm.c
+++ b/sound/soc/omap/omap-pcm.c
@@ -327,7 +327,7 @@ int omap_pcm_new(struct snd_card *card, struct snd_soc_dai *dai,
 	if (!card->dev->dma_mask)
 		card->dev->dma_mask = &omap_pcm_dmamask;
 	if (!card->dev->coherent_dma_mask)
-		card->dev->coherent_dma_mask = DMA_32BIT_MASK;
+		card->dev->coherent_dma_mask = DMA_BIT_MASK(32);
 
 	if (dai->playback.channels_min) {
 		ret = omap_pcm_preallocate_dma_buffer(pcm,
diff --git a/sound/soc/pxa/pxa2xx-pcm.c b/sound/soc/pxa/pxa2xx-pcm.c
index 53b9fb1..d38e395 100644
--- a/sound/soc/pxa/pxa2xx-pcm.c
+++ b/sound/soc/pxa/pxa2xx-pcm.c
@@ -81,7 +81,7 @@ static struct snd_pcm_ops pxa2xx_pcm_ops = {
 	.mmap		= pxa2xx_pcm_mmap,
 };
 
-static u64 pxa2xx_pcm_dmamask = DMA_32BIT_MASK;
+static u64 pxa2xx_pcm_dmamask = DMA_BIT_MASK(32);
 
 static int pxa2xx_soc_pcm_new(struct snd_card *card, struct snd_soc_dai *dai,
 	struct snd_pcm *pcm)
@@ -91,7 +91,7 @@ static int pxa2xx_soc_pcm_new(struct snd_card *card, struct snd_soc_dai *dai,
 	if (!card->dev->dma_mask)
 		card->dev->dma_mask = &pxa2xx_pcm_dmamask;
 	if (!card->dev->coherent_dma_mask)
-		card->dev->coherent_dma_mask = DMA_32BIT_MASK;
+		card->dev->coherent_dma_mask = DMA_BIT_MASK(32);
 
 	if (dai->playback.channels_min) {
 		ret = pxa2xx_pcm_preallocate_dma_buffer(pcm,
diff --git a/sound/soc/s3c24xx/s3c24xx-pcm.c b/sound/soc/s3c24xx/s3c24xx-pcm.c
index 7c64d31..8b57c79 100644
--- a/sound/soc/s3c24xx/s3c24xx-pcm.c
+++ b/sound/soc/s3c24xx/s3c24xx-pcm.c
@@ -426,7 +426,7 @@ static void s3c24xx_pcm_free_dma_buffers(struct snd_pcm *pcm)
 	}
 }
 
-static u64 s3c24xx_pcm_dmamask = DMA_32BIT_MASK;
+static u64 s3c24xx_pcm_dmamask = DMA_BIT_MASK(32);
 
 static int s3c24xx_pcm_new(struct snd_card *card,
 	struct snd_soc_dai *dai, struct snd_pcm *pcm)
-- 
1.6.0.3


-- 
Regards
Yang Hongyang
