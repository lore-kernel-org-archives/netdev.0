From: Joe Perches <joe@perches.com>
Subject: [PATCH 00/16] treewide: Convert dev_printk(KERN_<LEVEL> to
	dev_<level>(
Date: Sun, 28 Oct 2012 01:05:38 -0700
Message-ID: <cover.1351411047.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-i2c@vger.kernel.org
To: linux-ide@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	dri-devel@lists.freedesktop.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org,
	linux-pcmcia@lists.infradead.org, linux-scsi@vger.kernel.org,
	devel@open-fcoe.org, virtualization@lists.linux-foundation.org,
	linux-watchdog@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

dev_<level> create smaller objects than dev_printk(KERN_<LEVEL>.
Convert non-debug calls to this form.

Joe Perches (16):
  tile: Convert dev_printk(KERN_<LEVEL> to dev_<level>(
  ata: Convert dev_printk(KERN_<LEVEL> to dev_<level>(
  drivers: base: Convert dev_printk(KERN_<LEVEL> to dev_<level>(
  block: Convert dev_printk(KERN_<LEVEL> to dev_<level>(
  pcmcia: Convert dev_printk(KERN_<LEVEL> to dev_<level>(
  dma: Convert dev_printk(KERN_<LEVEL> to dev_<level>(
  gpu: Convert dev_printk(KERN_<LEVEL> to dev_<level>(
  i2c: Convert dev_printk(KERN_<LEVEL> to dev_<level>(
  wireless: Convert dev_printk(KERN_<LEVEL> to dev_<level>(
  ethernet: Convert dev_printk(KERN_<LEVEL> to dev_<level>(
  pci: Convert dev_printk(KERN_<LEVEL> to dev_<level>(
  scsi: Convert dev_printk(KERN_<LEVEL> to dev_<level>(
  usb: Convert dev_printk(KERN_<LEVEL> to dev_<level>(
  tile: Convert dev_printk(KERN_<LEVEL> to dev_<level>(
  watchdog: Convert dev_printk(KERN_<LEVEL> to dev_<level>(
  tile: Convert dev_printk(KERN_<LEVEL> to dev_<level>(

 arch/tile/kernel/pci_gx.c                   |   15 ++---
 drivers/ata/pata_cmd64x.c                   |    6 +-
 drivers/base/attribute_container.c          |    2 +-
 drivers/base/devres.c                       |    4 +-
 drivers/block/umem.c                        |   97 ++++++++++++--------------
 drivers/char/pcmcia/cm4040_cs.c             |    5 +-
 drivers/dma/at_hdmac_regs.h                 |    8 +-
 drivers/dma/iop-adma.c                      |   45 ++++++------
 drivers/dma/mv_xor.c                        |   62 ++++++++----------
 drivers/gpu/drm/gma500/cdv_intel_crt.c      |    3 +-
 drivers/gpu/drm/gma500/cdv_intel_lvds.c     |    7 +-
 drivers/gpu/drm/gma500/psb_intel_lvds.c     |    7 +-
 drivers/gpu/drm/i915/intel_opregion.c       |    8 +-
 drivers/i2c/busses/i2c-piix4.c              |    5 +-
 drivers/net/ethernet/chelsio/cxgb3/common.h |    7 +-
 drivers/net/ethernet/marvell/pxa168_eth.c   |    7 +-
 drivers/net/wireless/at76c50x-usb.c         |   85 +++++++++++------------
 drivers/net/wireless/iwlegacy/common.h      |    5 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c   |   28 +++-----
 drivers/pci/irq.c                           |   10 ++--
 drivers/pci/pci-stub.c                      |    2 +-
 drivers/pci/pcie/aspm.c                     |    7 +--
 drivers/pcmcia/cistpl.c                     |   10 +--
 drivers/pcmcia/cs.c                         |   28 +++-----
 drivers/pcmcia/ds.c                         |   38 +++++------
 drivers/pcmcia/pcmcia_cis.c                 |    4 +-
 drivers/pcmcia/pcmcia_resource.c            |   11 +--
 drivers/pcmcia/rsrc_nonstatic.c             |   24 +++----
 drivers/pcmcia/ti113x.h                     |   80 +++++++++++------------
 drivers/pcmcia/yenta_socket.c               |   61 ++++++++---------
 drivers/scsi/53c700.c                       |    2 +-
 drivers/scsi/aic7xxx/aic79xx_osm_pci.c      |    4 +-
 drivers/scsi/aic7xxx/aic7xxx_osm_pci.c      |    4 +-
 drivers/scsi/aic94xx/aic94xx_tmf.c          |    4 +-
 drivers/scsi/bfa/bfad.c                     |   32 ++++-----
 drivers/scsi/fcoe/fcoe_sysfs.c              |    3 +-
 drivers/scsi/lasi700.c                      |    2 +-
 drivers/scsi/libsas/sas_task.c              |    9 +--
 drivers/scsi/lpfc/lpfc_attr.c               |    8 +-
 drivers/scsi/lpfc/lpfc_debugfs.h            |    6 +-
 drivers/scsi/lpfc/lpfc_hbadisc.c            |    4 +-
 drivers/scsi/lpfc/lpfc_init.c               |   45 ++++++-------
 drivers/scsi/mpt2sas/mpt2sas_transport.c    |   91 ++++++++++++-------------
 drivers/scsi/mvsas/mv_64xx.c                |    2 +-
 drivers/scsi/mvsas/mv_chips.h               |    8 +-
 drivers/scsi/mvsas/mv_init.c                |   14 ++--
 drivers/scsi/mvsas/mv_sas.c                 |    9 +--
 drivers/scsi/pm8001/pm8001_init.c           |   10 +--
 drivers/scsi/pm8001/pm8001_sas.c            |    4 +-
 drivers/scsi/raid_class.c                   |    8 +-
 drivers/scsi/scsi_scan.c                    |    3 +-
 drivers/scsi/scsi_transport_fc.c            |   31 ++++-----
 drivers/scsi/scsi_transport_sas.c           |    7 +-
 drivers/scsi/sni_53c710.c                   |    2 +-
 drivers/scsi/zalon.c                        |    4 +-
 drivers/usb/core/hub.c                      |    2 +-
 drivers/virtio/virtio_balloon.c             |    7 +-
 drivers/watchdog/mpcore_wdt.c               |   19 +++---
 sound/pci/asihpi/hpidspcd.c                 |   22 +++----
 sound/pci/asihpi/hpioctl.c                  |   17 ++---
 60 files changed, 485 insertions(+), 579 deletions(-)

-- 
1.7.8.112.g3fd21
