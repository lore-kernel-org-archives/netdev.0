From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH] drivers/net: delete non-required instances of include <linux/init.h>
Date: Wed, 8 Jan 2014 15:32:47 -0500
Message-ID: <1389213167-720-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:50223 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752717AbaAHUcx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 15:32:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

None of these files are actually using any __init type directives
and hence don't need to include <linux/init.h>.   Most are just a
left over from __devinit and __cpuinit removal, or simply due to
code getting copied from one driver to the next.

This covers everything under drivers/net except for wireless, which
has been submitted separately.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---

[build tested drivers/net allyes/modconfig for x86-64, x86, ARM,
 ppc, sparc on todays net-next - v3.13-rc6-1503-g80077935cad2]

 drivers/net/arcnet/com20020_cs.c                      | 1 -
 drivers/net/caif/caif_spi_slave.c                     | 1 -
 drivers/net/can/at91_can.c                            | 1 -
 drivers/net/can/bfin_can.c                            | 1 -
 drivers/net/can/janz-ican3.c                          | 1 -
 drivers/net/can/pch_can.c                             | 1 -
 drivers/net/can/softing/softing_main.c                | 1 -
 drivers/net/can/ti_hecc.c                             | 1 -
 drivers/net/can/usb/ems_usb.c                         | 1 -
 drivers/net/can/usb/esd_usb2.c                        | 1 -
 drivers/net/can/usb/kvaser_usb.c                      | 1 -
 drivers/net/can/usb/usb_8dev.c                        | 1 -
 drivers/net/ethernet/3com/3c574_cs.c                  | 1 -
 drivers/net/ethernet/3com/3c589_cs.c                  | 1 -
 drivers/net/ethernet/8390/ax88796.c                   | 1 -
 drivers/net/ethernet/8390/axnet_cs.c                  | 1 -
 drivers/net/ethernet/8390/mcf8390.c                   | 1 -
 drivers/net/ethernet/8390/pcnet_cs.c                  | 1 -
 drivers/net/ethernet/aeroflex/greth.c                 | 1 -
 drivers/net/ethernet/allwinner/sun4i-emac.c           | 1 -
 drivers/net/ethernet/alteon/acenic.c                  | 1 -
 drivers/net/ethernet/amd/7990.c                       | 1 -
 drivers/net/ethernet/amd/amd8111e.c                   | 1 -
 drivers/net/ethernet/amd/au1000_eth.c                 | 1 -
 drivers/net/ethernet/amd/nmclan_cs.c                  | 1 -
 drivers/net/ethernet/amd/sunlance.c                   | 1 -
 drivers/net/ethernet/atheros/atl1c/atl1c.h            | 1 -
 drivers/net/ethernet/atheros/atl1e/atl1e.h            | 1 -
 drivers/net/ethernet/broadcom/bnx2.c                  | 1 -
 drivers/net/ethernet/broadcom/sb1250-mac.c            | 1 -
 drivers/net/ethernet/broadcom/tg3.c                   | 1 -
 drivers/net/ethernet/calxeda/xgmac.c                  | 1 -
 drivers/net/ethernet/chelsio/cxgb/common.h            | 1 -
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c             | 1 -
 drivers/net/ethernet/chelsio/cxgb/sge.c               | 1 -
 drivers/net/ethernet/chelsio/cxgb3/common.h           | 1 -
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c            | 1 -
 drivers/net/ethernet/cirrus/ep93xx_eth.c              | 1 -
 drivers/net/ethernet/davicom/dm9000.c                 | 1 -
 drivers/net/ethernet/dec/tulip/eeprom.c               | 1 -
 drivers/net/ethernet/dec/tulip/media.c                | 1 -
 drivers/net/ethernet/dec/tulip/xircom_cb.c            | 1 -
 drivers/net/ethernet/dlink/dl2k.h                     | 1 -
 drivers/net/ethernet/dnet.c                           | 1 -
 drivers/net/ethernet/faraday/ftgmac100.c              | 1 -
 drivers/net/ethernet/freescale/fec_main.c             | 1 -
 drivers/net/ethernet/freescale/fec_ptp.c              | 1 -
 drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c | 1 -
 drivers/net/ethernet/freescale/fs_enet/mac-fcc.c      | 1 -
 drivers/net/ethernet/freescale/fs_enet/mac-fec.c      | 1 -
 drivers/net/ethernet/freescale/fs_enet/mac-scc.c      | 1 -
 drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c  | 1 -
 drivers/net/ethernet/freescale/fs_enet/mii-fec.c      | 1 -
 drivers/net/ethernet/freescale/fsl_pq_mdio.c          | 1 -
 drivers/net/ethernet/freescale/gianfar.c              | 1 -
 drivers/net/ethernet/freescale/gianfar.h              | 1 -
 drivers/net/ethernet/freescale/gianfar_ethtool.c      | 1 -
 drivers/net/ethernet/freescale/gianfar_ptp.c          | 1 -
 drivers/net/ethernet/freescale/gianfar_sysfs.c        | 1 -
 drivers/net/ethernet/freescale/ucc_geth_ethtool.c     | 1 -
 drivers/net/ethernet/fujitsu/fmvj18x_cs.c             | 1 -
 drivers/net/ethernet/i825xx/lasi_82596.c              | 1 -
 drivers/net/ethernet/i825xx/lib82596.c                | 1 -
 drivers/net/ethernet/i825xx/sni_82596.c               | 1 -
 drivers/net/ethernet/ibm/emac/core.h                  | 1 -
 drivers/net/ethernet/icplus/ipg.h                     | 1 -
 drivers/net/ethernet/intel/e1000/e1000.h              | 1 -
 drivers/net/ethernet/intel/i40e/i40e.h                | 1 -
 drivers/net/ethernet/intel/ixgb/ixgb.h                | 1 -
 drivers/net/ethernet/korina.c                         | 1 -
 drivers/net/ethernet/marvell/mvmdio.c                 | 1 -
 drivers/net/ethernet/marvell/pxa168_eth.c             | 1 -
 drivers/net/ethernet/mellanox/mlx4/cq.c               | 1 -
 drivers/net/ethernet/mellanox/mlx4/eq.c               | 1 -
 drivers/net/ethernet/mellanox/mlx4/mr.c               | 1 -
 drivers/net/ethernet/mellanox/mlx4/pd.c               | 1 -
 drivers/net/ethernet/mellanox/mlx4/qp.c               | 1 -
 drivers/net/ethernet/mellanox/mlx4/srq.c              | 1 -
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c         | 1 -
 drivers/net/ethernet/micrel/ks8695net.c               | 1 -
 drivers/net/ethernet/moxa/moxart_ether.c              | 1 -
 drivers/net/ethernet/natsemi/jazzsonic.c              | 1 -
 drivers/net/ethernet/natsemi/macsonic.c               | 1 -
 drivers/net/ethernet/nvidia/forcedeth.c               | 1 -
 drivers/net/ethernet/nxp/lpc_eth.c                    | 1 -
 drivers/net/ethernet/pasemi/pasemi_mac.c              | 1 -
 drivers/net/ethernet/qlogic/qla3xxx.c                 | 1 -
 drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c       | 1 -
 drivers/net/ethernet/qlogic/qlge/qlge_main.c          | 1 -
 drivers/net/ethernet/rdc/r6040.c                      | 1 -
 drivers/net/ethernet/realtek/r8169.c                  | 1 -
 drivers/net/ethernet/renesas/sh_eth.c                 | 1 -
 drivers/net/ethernet/s6gmac.c                         | 1 -
 drivers/net/ethernet/seeq/sgiseeq.c                   | 1 -
 drivers/net/ethernet/sgi/ioc3-eth.c                   | 1 -
 drivers/net/ethernet/sgi/meth.c                       | 1 -
 drivers/net/ethernet/smsc/smc911x.c                   | 1 -
 drivers/net/ethernet/smsc/smc91c92_cs.c               | 1 -
 drivers/net/ethernet/smsc/smc91x.c                    | 1 -
 drivers/net/ethernet/stmicro/stmmac/common.h          | 1 -
 drivers/net/ethernet/sun/sunbmac.c                    | 1 -
 drivers/net/ethernet/sun/sungem.c                     | 1 -
 drivers/net/ethernet/ti/cpmac.c                       | 1 -
 drivers/net/ethernet/toshiba/tc35815.c                | 1 -
 drivers/net/ethernet/tundra/tsi108_eth.c              | 1 -
 drivers/net/ethernet/xilinx/ll_temac_main.c           | 1 -
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c     | 1 -
 drivers/net/ethernet/xilinx/xilinx_emaclite.c         | 1 -
 drivers/net/fddi/defxx.c                              | 1 -
 drivers/net/fddi/skfp/h/targetos.h                    | 1 -
 drivers/net/hippi/rrunner.c                           | 1 -
 drivers/net/irda/au1k_ir.c                            | 1 -
 drivers/net/irda/irda-usb.c                           | 1 -
 drivers/net/irda/kingsun-sir.c                        | 1 -
 drivers/net/irda/ks959-sir.c                          | 1 -
 drivers/net/irda/ksdazzle-sir.c                       | 1 -
 drivers/net/irda/mcs7780.c                            | 1 -
 drivers/net/irda/sir_dongle.c                         | 1 -
 drivers/net/irda/stir4200.c                           | 1 -
 drivers/net/loopback.c                                | 1 -
 drivers/net/macvtap.c                                 | 1 -
 drivers/net/phy/mdio-gpio.c                           | 1 -
 drivers/net/phy/mdio-moxart.c                         | 1 -
 drivers/net/phy/mdio-mux-gpio.c                       | 1 -
 drivers/net/phy/mdio-mux-mmioreg.c                    | 1 -
 drivers/net/phy/mdio-octeon.c                         | 1 -
 drivers/net/phy/mdio-sun4i.c                          | 1 -
 drivers/net/phy/phy.c                                 | 1 -
 drivers/net/phy/spi_ks8995.c                          | 1 -
 drivers/net/usb/asix.h                                | 1 -
 drivers/net/usb/catc.c                                | 1 -
 drivers/net/usb/cdc_eem.c                             | 1 -
 drivers/net/usb/cdc_ether.c                           | 1 -
 drivers/net/usb/cdc_ncm.c                             | 1 -
 drivers/net/usb/cdc_subset.c                          | 1 -
 drivers/net/usb/cx82310_eth.c                         | 1 -
 drivers/net/usb/dm9601.c                              | 1 -
 drivers/net/usb/gl620a.c                              | 1 -
 drivers/net/usb/ipheth.c                              | 1 -
 drivers/net/usb/kalmia.c                              | 1 -
 drivers/net/usb/kaweth.c                              | 1 -
 drivers/net/usb/mcs7830.c                             | 1 -
 drivers/net/usb/net1080.c                             | 1 -
 drivers/net/usb/plusb.c                               | 1 -
 drivers/net/usb/r8152.c                               | 1 -
 drivers/net/usb/rndis_host.c                          | 1 -
 drivers/net/usb/rtl8150.c                             | 1 -
 drivers/net/usb/smsc75xx.c                            | 1 -
 drivers/net/usb/smsc95xx.c                            | 1 -
 drivers/net/usb/sr9700.c                              | 1 -
 drivers/net/usb/zaurus.c                              | 1 -
 drivers/net/vmxnet3/vmxnet3_int.h                     | 1 -
 drivers/net/wan/hd64570.c                             | 1 -
 drivers/net/wan/hd64572.c                             | 1 -
 drivers/net/wan/lmc/lmc_main.c                        | 1 -
 155 files changed, 155 deletions(-)

diff --git a/drivers/net/arcnet/com20020_cs.c b/drivers/net/arcnet/com20020_cs.c
index 74dc1875f9cd..326a612a2730 100644
--- a/drivers/net/arcnet/com20020_cs.c
+++ b/drivers/net/arcnet/com20020_cs.c
@@ -32,7 +32,6 @@
  * **********************
  */
 #include <linux/kernel.h>
-#include <linux/init.h>
 #include <linux/ptrace.h>
 #include <linux/slab.h>
 #include <linux/string.h>
diff --git a/drivers/net/caif/caif_spi_slave.c b/drivers/net/caif/caif_spi_slave.c
index ee92ad5a6cf8..39ba2f892ad6 100644
--- a/drivers/net/caif/caif_spi_slave.c
+++ b/drivers/net/caif/caif_spi_slave.c
@@ -3,7 +3,6 @@
  * Author:  Daniel Martensson
  * License terms: GNU General Public License (GPL) version 2.
  */
-#include <linux/init.h>
 #include <linux/module.h>
 #include <linux/device.h>
 #include <linux/platform_device.h>
diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index cf0f63e14e53..6efe27458116 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -22,7 +22,6 @@
 #include <linux/clk.h>
 #include <linux/errno.h>
 #include <linux/if_arp.h>
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
index 8a0b515b33ea..8d2b89a12e09 100644
--- a/drivers/net/can/bfin_can.c
+++ b/drivers/net/can/bfin_can.c
@@ -9,7 +9,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/bitops.h>
 #include <linux/interrupt.h>
diff --git a/drivers/net/can/janz-ican3.c b/drivers/net/can/janz-ican3.c
index ab5909a7bae9..e24e6690d672 100644
--- a/drivers/net/can/janz-ican3.c
+++ b/drivers/net/can/janz-ican3.c
@@ -11,7 +11,6 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/delay.h>
 #include <linux/platform_device.h>
diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 79e8699fd35a..6c077eb87b5e 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -21,7 +21,6 @@
 #include <linux/module.h>
 #include <linux/sched.h>
 #include <linux/pci.h>
-#include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/errno.h>
diff --git a/drivers/net/can/softing/softing_main.c b/drivers/net/can/softing/softing_main.c
index 1b8212783640..9ea0dcde94ce 100644
--- a/drivers/net/can/softing/softing_main.c
+++ b/drivers/net/can/softing/softing_main.c
@@ -17,7 +17,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <asm/io.h>
 
diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index 60d95b44d0f7..65a75bb257eb 100644
--- a/drivers/net/can/ti_hecc.c
+++ b/drivers/net/can/ti_hecc.c
@@ -37,7 +37,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/interrupt.h>
diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_usb.c
index 8aeec0b4601a..52c42fd49510 100644
--- a/drivers/net/can/usb/ems_usb.c
+++ b/drivers/net/can/usb/ems_usb.c
@@ -16,7 +16,6 @@
  * with this program; if not, write to the Free Software Foundation, Inc.,
  * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
  */
-#include <linux/init.h>
 #include <linux/signal.h>
 #include <linux/slab.h>
 #include <linux/module.h>
diff --git a/drivers/net/can/usb/esd_usb2.c b/drivers/net/can/usb/esd_usb2.c
index ac6177d3befc..7fbe85935f1d 100644
--- a/drivers/net/can/usb/esd_usb2.c
+++ b/drivers/net/can/usb/esd_usb2.c
@@ -16,7 +16,6 @@
  * with this program; if not, write to the Free Software Foundation, Inc.,
  * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
  */
-#include <linux/init.h>
 #include <linux/signal.h>
 #include <linux/slab.h>
 #include <linux/module.h>
diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index 4b2d5ed62b11..6c859bba8b65 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -12,7 +12,6 @@
  * Copyright (C) 2012 Olivier Sobrie <olivier@sobrie.be>
  */
 
-#include <linux/init.h>
 #include <linux/completion.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
diff --git a/drivers/net/can/usb/usb_8dev.c b/drivers/net/can/usb/usb_8dev.c
index 8becd3d838b5..a0fa1fd5092b 100644
--- a/drivers/net/can/usb/usb_8dev.c
+++ b/drivers/net/can/usb/usb_8dev.c
@@ -23,7 +23,6 @@
  * who were very cooperative and answered my questions.
  */
 
-#include <linux/init.h>
 #include <linux/signal.h>
 #include <linux/slab.h>
 #include <linux/module.h>
diff --git a/drivers/net/ethernet/3com/3c574_cs.c b/drivers/net/ethernet/3com/3c574_cs.c
index 6fc994fa4abe..b9948f00c5e9 100644
--- a/drivers/net/ethernet/3com/3c574_cs.c
+++ b/drivers/net/ethernet/3com/3c574_cs.c
@@ -73,7 +73,6 @@ earlier 3Com products.
 
 #include <linux/module.h>
 #include <linux/kernel.h>
-#include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/string.h>
 #include <linux/timer.h>
diff --git a/drivers/net/ethernet/3com/3c589_cs.c b/drivers/net/ethernet/3com/3c589_cs.c
index 078480aaa168..5992860a39c9 100644
--- a/drivers/net/ethernet/3com/3c589_cs.c
+++ b/drivers/net/ethernet/3com/3c589_cs.c
@@ -25,7 +25,6 @@
 #define DRV_VERSION	"1.162-ac"
 
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/ptrace.h>
 #include <linux/slab.h>
diff --git a/drivers/net/ethernet/8390/ax88796.c b/drivers/net/ethernet/8390/ax88796.c
index 8ed5b34d7553..455d4c399b52 100644
--- a/drivers/net/ethernet/8390/ax88796.c
+++ b/drivers/net/ethernet/8390/ax88796.c
@@ -15,7 +15,6 @@
 #include <linux/kernel.h>
 #include <linux/errno.h>
 #include <linux/isapnp.h>
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/io.h>
 #include <linux/platform_device.h>
diff --git a/drivers/net/ethernet/8390/axnet_cs.c b/drivers/net/ethernet/8390/axnet_cs.c
index 5698a4c85d8e..73c57a4a7b9e 100644
--- a/drivers/net/ethernet/8390/axnet_cs.c
+++ b/drivers/net/ethernet/8390/axnet_cs.c
@@ -28,7 +28,6 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/ptrace.h>
 #include <linux/string.h>
 #include <linux/timer.h>
diff --git a/drivers/net/ethernet/8390/mcf8390.c b/drivers/net/ethernet/8390/mcf8390.c
index df0ffca91c1c..38fcdcf7c4c7 100644
--- a/drivers/net/ethernet/8390/mcf8390.c
+++ b/drivers/net/ethernet/8390/mcf8390.c
@@ -13,7 +13,6 @@
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/errno.h>
-#include <linux/init.h>
 #include <linux/platform_device.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/ethernet/8390/pcnet_cs.c b/drivers/net/ethernet/8390/pcnet_cs.c
index eea33d667fb0..ca3c2b921cf6 100644
--- a/drivers/net/ethernet/8390/pcnet_cs.c
+++ b/drivers/net/ethernet/8390/pcnet_cs.c
@@ -32,7 +32,6 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/ptrace.h>
 #include <linux/string.h>
 #include <linux/timer.h>
diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index b20cbf0323e0..c5d75e7aeeb6 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -25,7 +25,6 @@
 #include <linux/dma-mapping.h>
 #include <linux/module.h>
 #include <linux/uaccess.h>
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
index 46dfb1378c17..0cc21437478c 100644
--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
@@ -16,7 +16,6 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/gpio.h>
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/irq.h>
 #include <linux/mii.h>
diff --git a/drivers/net/ethernet/alteon/acenic.c b/drivers/net/ethernet/alteon/acenic.c
index 219be1bf3cfc..1517e9df5ba1 100644
--- a/drivers/net/ethernet/alteon/acenic.c
+++ b/drivers/net/ethernet/alteon/acenic.c
@@ -61,7 +61,6 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
-#include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/mm.h>
 #include <linux/highmem.h>
diff --git a/drivers/net/ethernet/amd/7990.c b/drivers/net/ethernet/amd/7990.c
index 72cfff7d23a5..18e542f7853d 100644
--- a/drivers/net/ethernet/amd/7990.c
+++ b/drivers/net/ethernet/amd/7990.c
@@ -17,7 +17,6 @@
 #include <linux/errno.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
-#include <linux/init.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index d6beba0bc01f..2061b471fd16 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -72,7 +72,6 @@ Revision History:
 #include <linux/types.h>
 #include <linux/compiler.h>
 #include <linux/delay.h>
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/ioport.h>
 #include <linux/pci.h>
diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index 2eee5764805d..a2bd91e3d302 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -47,7 +47,6 @@
 #include <linux/bitops.h>
 #include <linux/slab.h>
 #include <linux/interrupt.h>
-#include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
diff --git a/drivers/net/ethernet/amd/nmclan_cs.c b/drivers/net/ethernet/amd/nmclan_cs.c
index d4ed89130c52..08569fe2b182 100644
--- a/drivers/net/ethernet/amd/nmclan_cs.c
+++ b/drivers/net/ethernet/amd/nmclan_cs.c
@@ -132,7 +132,6 @@ Include Files
 
 #include <linux/module.h>
 #include <linux/kernel.h>
-#include <linux/init.h>
 #include <linux/ptrace.h>
 #include <linux/slab.h>
 #include <linux/string.h>
diff --git a/drivers/net/ethernet/amd/sunlance.c b/drivers/net/ethernet/amd/sunlance.c
index ece56831a647..5e4273b7aa27 100644
--- a/drivers/net/ethernet/amd/sunlance.c
+++ b/drivers/net/ethernet/amd/sunlance.c
@@ -80,7 +80,6 @@ static char lancestr[] = "LANCE";
 #include <linux/in.h>
 #include <linux/string.h>
 #include <linux/delay.h>
-#include <linux/init.h>
 #include <linux/crc32.h>
 #include <linux/errno.h>
 #include <linux/socket.h> /* Used for the temporal inet entries and routing */
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c.h b/drivers/net/ethernet/atheros/atl1c/atl1c.h
index 7f9369a3b378..b9203d928938 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c.h
@@ -22,7 +22,6 @@
 #ifndef _ATL1C_H_
 #define _ATL1C_H_
 
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/types.h>
 #include <linux/errno.h>
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e.h b/drivers/net/ethernet/atheros/atl1e/atl1e.h
index 1b0fe2d04a0e..0212dac7e23a 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e.h
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e.h
@@ -23,7 +23,6 @@
 #ifndef _ATL1E_H_
 #define _ATL1E_H_
 
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/types.h>
 #include <linux/errno.h>
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 3f3cae288466..9d2dedadf2df 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -23,7 +23,6 @@
 #include <linux/vmalloc.h>
 #include <linux/interrupt.h>
 #include <linux/pci.h>
-#include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
diff --git a/drivers/net/ethernet/broadcom/sb1250-mac.c b/drivers/net/ethernet/broadcom/sb1250-mac.c
index 31a076d86709..b61c14ed9b8d 100644
--- a/drivers/net/ethernet/broadcom/sb1250-mac.c
+++ b/drivers/net/ethernet/broadcom/sb1250-mac.c
@@ -35,7 +35,6 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
-#include <linux/init.h>
 #include <linux/bitops.h>
 #include <linux/err.h>
 #include <linux/ethtool.h>
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index c37e9f27ff6d..e2ca03e23dc1 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -25,7 +25,6 @@
 #include <linux/slab.h>
 #include <linux/delay.h>
 #include <linux/in.h>
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/ioport.h>
 #include <linux/pci.h>
diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 4fc5c8ef5121..d2a183c3a6ce 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -14,7 +14,6 @@
  * this program.  If not, see <http://www.gnu.org/licenses/>.
  */
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/circ_buf.h>
 #include <linux/interrupt.h>
diff --git a/drivers/net/ethernet/chelsio/cxgb/common.h b/drivers/net/ethernet/chelsio/cxgb/common.h
index 5dd20f7285eb..53b1f9478383 100644
--- a/drivers/net/ethernet/chelsio/cxgb/common.h
+++ b/drivers/net/ethernet/chelsio/cxgb/common.h
@@ -49,7 +49,6 @@
 #include <linux/if_vlan.h>
 #include <linux/mdio.h>
 #include <linux/crc32.h>
-#include <linux/init.h>
 #include <linux/slab.h>
 #include <asm/io.h>
 #include <linux/pci_ids.h>
diff --git a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
index e5987139a1ae..0fe7ff750d77 100644
--- a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
+++ b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
@@ -37,7 +37,6 @@
 
 #include "common.h"
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/pci.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/ethernet/chelsio/cxgb/sge.c b/drivers/net/ethernet/chelsio/cxgb/sge.c
index 0341537cdd37..4c5879389003 100644
--- a/drivers/net/ethernet/chelsio/cxgb/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb/sge.c
@@ -46,7 +46,6 @@
 #include <linux/etherdevice.h>
 #include <linux/if_vlan.h>
 #include <linux/skbuff.h>
-#include <linux/init.h>
 #include <linux/mm.h>
 #include <linux/tcp.h>
 #include <linux/ip.h>
diff --git a/drivers/net/ethernet/chelsio/cxgb3/common.h b/drivers/net/ethernet/chelsio/cxgb3/common.h
index 8c82248ce416..442480982d3f 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/common.h
+++ b/drivers/net/ethernet/chelsio/cxgb3/common.h
@@ -36,7 +36,6 @@
 #include <linux/types.h>
 #include <linux/ctype.h>
 #include <linux/delay.h>
-#include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/ethtool.h>
 #include <linux/mdio.h>
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index a3964753935c..2c109343d570 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -32,7 +32,6 @@
  * SOFTWARE.
  */
 
-#include <linux/init.h>
 #include <linux/delay.h>
 #include "cxgb4.h"
 #include "t4_regs.h"
diff --git a/drivers/net/ethernet/cirrus/ep93xx_eth.c b/drivers/net/ethernet/cirrus/ep93xx_eth.c
index ec88de4ac162..2be2a99c5ea3 100644
--- a/drivers/net/ethernet/cirrus/ep93xx_eth.c
+++ b/drivers/net/ethernet/cirrus/ep93xx_eth.c
@@ -18,7 +18,6 @@
 #include <linux/mii.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/moduleparam.h>
 #include <linux/platform_device.h>
diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 7080ad6c4014..25683db4c03d 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -23,7 +23,6 @@
 #include <linux/ioport.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
diff --git a/drivers/net/ethernet/dec/tulip/eeprom.c b/drivers/net/ethernet/dec/tulip/eeprom.c
index df5a892fb49c..1812f4916917 100644
--- a/drivers/net/ethernet/dec/tulip/eeprom.c
+++ b/drivers/net/ethernet/dec/tulip/eeprom.c
@@ -13,7 +13,6 @@
 #include <linux/pci.h>
 #include <linux/slab.h>
 #include "tulip.h"
-#include <linux/init.h>
 #include <asm/unaligned.h>
 
 
diff --git a/drivers/net/ethernet/dec/tulip/media.c b/drivers/net/ethernet/dec/tulip/media.c
index 93a4afaa09f1..0d0ba725341a 100644
--- a/drivers/net/ethernet/dec/tulip/media.c
+++ b/drivers/net/ethernet/dec/tulip/media.c
@@ -12,7 +12,6 @@
 
 #include <linux/kernel.h>
 #include <linux/mii.h>
-#include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/pci.h>
 #include "tulip.h"
diff --git a/drivers/net/ethernet/dec/tulip/xircom_cb.c b/drivers/net/ethernet/dec/tulip/xircom_cb.c
index ab7ebac6fbea..6204cdfe43a6 100644
--- a/drivers/net/ethernet/dec/tulip/xircom_cb.c
+++ b/drivers/net/ethernet/dec/tulip/xircom_cb.c
@@ -28,7 +28,6 @@
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
 #include <linux/delay.h>
-#include <linux/init.h>
 #include <linux/bitops.h>
 
 #include <asm/uaccess.h>
diff --git a/drivers/net/ethernet/dlink/dl2k.h b/drivers/net/ethernet/dlink/dl2k.h
index 3699565704c7..7d07a0f5320d 100644
--- a/drivers/net/ethernet/dlink/dl2k.h
+++ b/drivers/net/ethernet/dlink/dl2k.h
@@ -25,7 +25,6 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
-#include <linux/init.h>
 #include <linux/crc32.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index f3d60eb13c3a..8a79a32a5674 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -15,7 +15,6 @@
 #include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/delay.h>
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 212f44b3a773..24d87898209b 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -24,7 +24,6 @@
 #include <linux/dma-mapping.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/io.h>
 #include <linux/module.h>
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 6530177d53e7..d4782b42401b 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -29,7 +29,6 @@
 #include <linux/ioport.h>
 #include <linux/slab.h>
 #include <linux/interrupt.h>
-#include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index 3a74ea48fd40..89ccb5b08708 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -28,7 +28,6 @@
 #include <linux/slab.h>
 #include <linux/interrupt.h>
 #include <linux/pci.h>
-#include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index 56f2f608a9f4..62f042d4aaa9 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -24,7 +24,6 @@
 #include <linux/ioport.h>
 #include <linux/slab.h>
 #include <linux/interrupt.h>
-#include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/ethernet/freescale/fs_enet/mac-fcc.c b/drivers/net/ethernet/freescale/fs_enet/mac-fcc.c
index f8b92864fc52..f5383abbf399 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mac-fcc.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mac-fcc.c
@@ -20,7 +20,6 @@
 #include <linux/errno.h>
 #include <linux/ioport.h>
 #include <linux/interrupt.h>
-#include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/ethernet/freescale/fs_enet/mac-fec.c b/drivers/net/ethernet/freescale/fs_enet/mac-fec.c
index a9a00f39521a..fc5413488496 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mac-fec.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mac-fec.c
@@ -20,7 +20,6 @@
 #include <linux/errno.h>
 #include <linux/ioport.h>
 #include <linux/interrupt.h>
-#include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/ethernet/freescale/fs_enet/mac-scc.c b/drivers/net/ethernet/freescale/fs_enet/mac-scc.c
index d37cd4ebac65..b4bf02f57d43 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mac-scc.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mac-scc.c
@@ -20,7 +20,6 @@
 #include <linux/errno.h>
 #include <linux/ioport.h>
 #include <linux/interrupt.h>
-#include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c b/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
index 67caaacd19ec..3d3fde66c2cc 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
@@ -15,7 +15,6 @@
 #include <linux/module.h>
 #include <linux/ioport.h>
 #include <linux/slab.h>
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/ethernet/freescale/fs_enet/mii-fec.c b/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
index ac5d447ff8c4..7e69c983d12a 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
@@ -21,7 +21,6 @@
 #include <linux/ioport.h>
 #include <linux/slab.h>
 #include <linux/interrupt.h>
-#include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index c4f65067cf7c..583e71ab7f51 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -20,7 +20,6 @@
 #include <linux/string.h>
 #include <linux/errno.h>
 #include <linux/slab.h>
-#include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/module.h>
 #include <linux/mii.h>
diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 365342d293e8..ad5a5aadc7e1 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -70,7 +70,6 @@
 #include <linux/unistd.h>
 #include <linux/slab.h>
 #include <linux/interrupt.h>
-#include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 114c58f9d8d2..52bb2b0195cc 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -29,7 +29,6 @@
 #include <linux/errno.h>
 #include <linux/slab.h>
 #include <linux/interrupt.h>
-#include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index d3d7ede27ef1..fc4b8a8d7b46 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -22,7 +22,6 @@
 #include <linux/string.h>
 #include <linux/errno.h>
 #include <linux/interrupt.h>
-#include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
index e006a09ba899..f564564d502e 100644
--- a/drivers/net/ethernet/freescale/gianfar_ptp.c
+++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
@@ -22,7 +22,6 @@
 
 #include <linux/device.h>
 #include <linux/hrtimer.h>
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
diff --git a/drivers/net/ethernet/freescale/gianfar_sysfs.c b/drivers/net/ethernet/freescale/gianfar_sysfs.c
index acb55af7e3f3..e02dd1378751 100644
--- a/drivers/net/ethernet/freescale/gianfar_sysfs.c
+++ b/drivers/net/ethernet/freescale/gianfar_sysfs.c
@@ -24,7 +24,6 @@
 #include <linux/string.h>
 #include <linux/errno.h>
 #include <linux/unistd.h>
-#include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/etherdevice.h>
 #include <linux/spinlock.h>
diff --git a/drivers/net/ethernet/freescale/ucc_geth_ethtool.c b/drivers/net/ethernet/freescale/ucc_geth_ethtool.c
index e79aaf9ae52a..413329eff2ff 100644
--- a/drivers/net/ethernet/freescale/ucc_geth_ethtool.c
+++ b/drivers/net/ethernet/freescale/ucc_geth_ethtool.c
@@ -16,7 +16,6 @@
  */
 
 #include <linux/kernel.h>
-#include <linux/init.h>
 #include <linux/errno.h>
 #include <linux/stddef.h>
 #include <linux/interrupt.h>
diff --git a/drivers/net/ethernet/fujitsu/fmvj18x_cs.c b/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
index ef46b58cb4e9..7becab1aa3e4 100644
--- a/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
+++ b/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
@@ -35,7 +35,6 @@
 
 #include <linux/module.h>
 #include <linux/kernel.h>
-#include <linux/init.h>
 #include <linux/ptrace.h>
 #include <linux/slab.h>
 #include <linux/string.h>
diff --git a/drivers/net/ethernet/i825xx/lasi_82596.c b/drivers/net/ethernet/i825xx/lasi_82596.c
index f42f1b707733..d787fdd5db7b 100644
--- a/drivers/net/ethernet/i825xx/lasi_82596.c
+++ b/drivers/net/ethernet/i825xx/lasi_82596.c
@@ -79,7 +79,6 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
-#include <linux/init.h>
 #include <linux/types.h>
 #include <linux/bitops.h>
 #include <linux/dma-mapping.h>
diff --git a/drivers/net/ethernet/i825xx/lib82596.c b/drivers/net/ethernet/i825xx/lib82596.c
index 861fa15e1e81..17fca323c143 100644
--- a/drivers/net/ethernet/i825xx/lib82596.c
+++ b/drivers/net/ethernet/i825xx/lib82596.c
@@ -78,7 +78,6 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
-#include <linux/init.h>
 #include <linux/types.h>
 #include <linux/bitops.h>
 #include <linux/dma-mapping.h>
diff --git a/drivers/net/ethernet/i825xx/sni_82596.c b/drivers/net/ethernet/i825xx/sni_82596.c
index 4ceae9a30274..372fa8d1fda1 100644
--- a/drivers/net/ethernet/i825xx/sni_82596.c
+++ b/drivers/net/ethernet/i825xx/sni_82596.c
@@ -13,7 +13,6 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
-#include <linux/init.h>
 #include <linux/types.h>
 #include <linux/bitops.h>
 #include <linux/platform_device.h>
diff --git a/drivers/net/ethernet/ibm/emac/core.h b/drivers/net/ethernet/ibm/emac/core.h
index 70074792bdef..67f342a9f65e 100644
--- a/drivers/net/ethernet/ibm/emac/core.h
+++ b/drivers/net/ethernet/ibm/emac/core.h
@@ -26,7 +26,6 @@
 #define __IBM_NEWEMAC_CORE_H
 
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/list.h>
 #include <linux/kernel.h>
 #include <linux/interrupt.h>
diff --git a/drivers/net/ethernet/icplus/ipg.h b/drivers/net/ethernet/icplus/ipg.h
index abb300a31912..a21e4f5702b5 100644
--- a/drivers/net/ethernet/icplus/ipg.h
+++ b/drivers/net/ethernet/icplus/ipg.h
@@ -18,7 +18,6 @@
 #include <linux/types.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
-#include <linux/init.h>
 #include <linux/skbuff.h>
 #include <asm/bitops.h>
 
diff --git a/drivers/net/ethernet/intel/e1000/e1000.h b/drivers/net/ethernet/intel/e1000/e1000.h
index f9313b36c887..10a0f221b183 100644
--- a/drivers/net/ethernet/intel/e1000/e1000.h
+++ b/drivers/net/ethernet/intel/e1000/e1000.h
@@ -36,7 +36,6 @@
 #include <linux/module.h>
 #include <linux/types.h>
 #include <asm/byteorder.h>
-#include <linux/init.h>
 #include <linux/mm.h>
 #include <linux/errno.h>
 #include <linux/ioport.h>
diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 09d92d00cb13..dda3d7325db2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -30,7 +30,6 @@
 
 #include <net/tcp.h>
 #include <net/udp.h>
-#include <linux/init.h>
 #include <linux/types.h>
 #include <linux/errno.h>
 #include <linux/module.h>
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb.h b/drivers/net/ethernet/intel/ixgb/ixgb.h
index 2224cc2edf13..1180cd59b570 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb.h
+++ b/drivers/net/ethernet/intel/ixgb/ixgb.h
@@ -33,7 +33,6 @@
 #include <linux/module.h>
 #include <linux/types.h>
 #include <asm/byteorder.h>
-#include <linux/init.h>
 #include <linux/mm.h>
 #include <linux/errno.h>
 #include <linux/ioport.h>
diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 4a5e3b0f712e..d74f5f4e5782 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -39,7 +39,6 @@
 #include <linux/ctype.h>
 #include <linux/types.h>
 #include <linux/interrupt.h>
-#include <linux/init.h>
 #include <linux/ioport.h>
 #include <linux/in.h>
 #include <linux/slab.h>
diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index c4eeb69a5bee..fd409d76b811 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -17,7 +17,6 @@
  * warranty of any kind, whether express or implied.
  */
 
-#include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/mutex.h>
diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 452e81de33de..b358c2f6f4bd 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -22,7 +22,6 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
-#include <linux/init.h>
 #include <linux/dma-mapping.h>
 #include <linux/in.h>
 #include <linux/ip.h>
diff --git a/drivers/net/ethernet/mellanox/mlx4/cq.c b/drivers/net/ethernet/mellanox/mlx4/cq.c
index 34c5b87a1c2a..0487121e4a0f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cq.c
@@ -34,7 +34,6 @@
  * SOFTWARE.
  */
 
-#include <linux/init.h>
 #include <linux/hardirq.h>
 #include <linux/export.h>
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index ae5212f8f090..8992b38578d5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -31,7 +31,6 @@
  * SOFTWARE.
  */
 
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/slab.h>
 #include <linux/export.h>
diff --git a/drivers/net/ethernet/mellanox/mlx4/mr.c b/drivers/net/ethernet/mellanox/mlx4/mr.c
index 0558dddd81e5..24835853b753 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mr.c
@@ -32,7 +32,6 @@
  * SOFTWARE.
  */
 
-#include <linux/init.h>
 #include <linux/errno.h>
 #include <linux/export.h>
 #include <linux/slab.h>
diff --git a/drivers/net/ethernet/mellanox/mlx4/pd.c b/drivers/net/ethernet/mellanox/mlx4/pd.c
index c6af9619ce6d..74216071201f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/pd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/pd.c
@@ -31,7 +31,6 @@
  * SOFTWARE.
  */
 
-#include <linux/init.h>
 #include <linux/errno.h>
 #include <linux/export.h>
 #include <linux/io-mapping.h>
diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index 06b2d13d5310..61d64ebffd56 100644
--- a/drivers/net/ethernet/mellanox/mlx4/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
@@ -35,7 +35,6 @@
 
 #include <linux/gfp.h>
 #include <linux/export.h>
-#include <linux/init.h>
 
 #include <linux/mlx4/cmd.h>
 #include <linux/mlx4/qp.h>
diff --git a/drivers/net/ethernet/mellanox/mlx4/srq.c b/drivers/net/ethernet/mellanox/mlx4/srq.c
index 1d2f9d3862a7..98faf870b0b0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/srq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/srq.c
@@ -31,7 +31,6 @@
  * SOFTWARE.
  */
 
-#include <linux/init.h>
 
 #include <linux/mlx4/cmd.h>
 #include <linux/mlx4/srq.h>
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 8675d26a678b..405c4fbcd0ad 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -32,7 +32,6 @@
 
 #include <asm-generic/kmap_types.h>
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/errno.h>
 #include <linux/pci.h>
 #include <linux/dma-mapping.h>
diff --git a/drivers/net/ethernet/micrel/ks8695net.c b/drivers/net/ethernet/micrel/ks8695net.c
index 106eb972f2ac..16435b3cfa9f 100644
--- a/drivers/net/ethernet/micrel/ks8695net.c
+++ b/drivers/net/ethernet/micrel/ks8695net.c
@@ -21,7 +21,6 @@
 #include <linux/ioport.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index cbd013379252..5020fd47825d 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -13,7 +13,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
diff --git a/drivers/net/ethernet/natsemi/jazzsonic.c b/drivers/net/ethernet/natsemi/jazzsonic.c
index 79257f71c5d9..a5512a97cc4d 100644
--- a/drivers/net/ethernet/natsemi/jazzsonic.c
+++ b/drivers/net/ethernet/natsemi/jazzsonic.c
@@ -24,7 +24,6 @@
 #include <linux/fcntl.h>
 #include <linux/gfp.h>
 #include <linux/interrupt.h>
-#include <linux/init.h>
 #include <linux/ioport.h>
 #include <linux/in.h>
 #include <linux/string.h>
diff --git a/drivers/net/ethernet/natsemi/macsonic.c b/drivers/net/ethernet/natsemi/macsonic.c
index 346a4e025c34..da5a1b0db3c8 100644
--- a/drivers/net/ethernet/natsemi/macsonic.c
+++ b/drivers/net/ethernet/natsemi/macsonic.c
@@ -37,7 +37,6 @@
 #include <linux/fcntl.h>
 #include <linux/gfp.h>
 #include <linux/interrupt.h>
-#include <linux/init.h>
 #include <linux/ioport.h>
 #include <linux/in.h>
 #include <linux/string.h>
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 493a1125f54f..70cf97fe67f2 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -58,7 +58,6 @@
 #include <linux/skbuff.h>
 #include <linux/mii.h>
 #include <linux/random.h>
-#include <linux/init.h>
 #include <linux/if_vlan.h>
 #include <linux/dma-mapping.h>
 #include <linux/slab.h>
diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index ba3ca18611f7..422d9b51ac24 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -19,7 +19,6 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
-#include <linux/init.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index 0734758ff5ba..9abf70d74b31 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -16,7 +16,6 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
-#include <linux/init.h>
 #include <linux/module.h>
 #include <linux/pci.h>
 #include <linux/slab.h>
diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
index 0758b9435358..2eabd44f8914 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -8,7 +8,6 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/kernel.h>
-#include <linux/init.h>
 #include <linux/types.h>
 #include <linux/module.h>
 #include <linux/list.h>
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
index 8dee1beb9854..c3c514e332b5 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
@@ -1,5 +1,4 @@
 #include <linux/kernel.h>
-#include <linux/init.h>
 #include <linux/types.h>
 #include <linux/module.h>
 #include <linux/list.h>
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 449f506d2e8f..394c0a538e1c 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -6,7 +6,6 @@
  *                      Ron Mercer <ron.mercer@qlogic.com>
  */
 #include <linux/kernel.h>
-#include <linux/init.h>
 #include <linux/bitops.h>
 #include <linux/types.h>
 #include <linux/module.h>
diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 1e49ec5b2232..851376b7fc78 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -34,7 +34,6 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
-#include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/mii.h>
 #include <linux/ethtool.h>
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index c737f0ea5de7..91a67ae8f17b 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -21,7 +21,6 @@
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/tcp.h>
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/dma-mapping.h>
 #include <linux/pm_runtime.h>
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 888410737dbd..d60694730a1e 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -17,7 +17,6 @@
  *  the file called "COPYING".
  */
 
-#include <linux/init.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/spinlock.h>
diff --git a/drivers/net/ethernet/s6gmac.c b/drivers/net/ethernet/s6gmac.c
index a99739c5142c..1f4449ad8900 100644
--- a/drivers/net/ethernet/s6gmac.c
+++ b/drivers/net/ethernet/s6gmac.c
@@ -14,7 +14,6 @@
 #include <linux/interrupt.h>
 #include <linux/types.h>
 #include <linux/delay.h>
-#include <linux/init.h>
 #include <linux/spinlock.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/ethernet/seeq/sgiseeq.c b/drivers/net/ethernet/seeq/sgiseeq.c
index ced5b13d937f..69e4fd21adb4 100644
--- a/drivers/net/ethernet/seeq/sgiseeq.c
+++ b/drivers/net/ethernet/seeq/sgiseeq.c
@@ -11,7 +11,6 @@
 #include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/errno.h>
-#include <linux/init.h>
 #include <linux/types.h>
 #include <linux/interrupt.h>
 #include <linux/string.h>
diff --git a/drivers/net/ethernet/sgi/ioc3-eth.c b/drivers/net/ethernet/sgi/ioc3-eth.c
index ffa78432164d..7984ad05357d 100644
--- a/drivers/net/ethernet/sgi/ioc3-eth.c
+++ b/drivers/net/ethernet/sgi/ioc3-eth.c
@@ -30,7 +30,6 @@
 #define IOC3_NAME	"ioc3-eth"
 #define IOC3_VERSION	"2.6.3-4"
 
-#include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
diff --git a/drivers/net/ethernet/sgi/meth.c b/drivers/net/ethernet/sgi/meth.c
index 513ed8b1ba58..5564a5fa3385 100644
--- a/drivers/net/ethernet/sgi/meth.c
+++ b/drivers/net/ethernet/sgi/meth.c
@@ -10,7 +10,6 @@
  */
 #include <linux/delay.h>
 #include <linux/dma-mapping.h>
-#include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/platform_device.h>
diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
index 5a4278d1f7d0..c50fb08c9905 100644
--- a/drivers/net/ethernet/smsc/smc911x.c
+++ b/drivers/net/ethernet/smsc/smc911x.c
@@ -54,7 +54,6 @@ static const char version[] =
 			 )
 #endif
 
-#include <linux/init.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
diff --git a/drivers/net/ethernet/smsc/smc91c92_cs.c b/drivers/net/ethernet/smsc/smc91c92_cs.c
index 8ef70d9c20c1..c7a4868571f9 100644
--- a/drivers/net/ethernet/smsc/smc91c92_cs.c
+++ b/drivers/net/ethernet/smsc/smc91c92_cs.c
@@ -29,7 +29,6 @@
 
 #include <linux/module.h>
 #include <linux/kernel.h>
-#include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/string.h>
 #include <linux/timer.h>
diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 96f79f7c4395..f131981ab4ef 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -65,7 +65,6 @@ static const char version[] =
 #endif
 
 
-#include <linux/init.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index fc94f202a43e..5a60b3fb00b6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -29,7 +29,6 @@
 #include <linux/netdevice.h>
 #include <linux/phy.h>
 #include <linux/module.h>
-#include <linux/init.h>
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 #define STMMAC_VLAN_TAG_USED
 #include <linux/if_vlan.h>
diff --git a/drivers/net/ethernet/sun/sunbmac.c b/drivers/net/ethernet/sun/sunbmac.c
index 7217ee5d6273..206c1063815a 100644
--- a/drivers/net/ethernet/sun/sunbmac.c
+++ b/drivers/net/ethernet/sun/sunbmac.c
@@ -13,7 +13,6 @@
 #include <linux/in.h>
 #include <linux/string.h>
 #include <linux/delay.h>
-#include <linux/init.h>
 #include <linux/crc32.h>
 #include <linux/errno.h>
 #include <linux/ethtool.h>
diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index b5655b79bd3b..c2799dc46325 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -24,7 +24,6 @@
 #include <linux/sched.h>
 #include <linux/string.h>
 #include <linux/delay.h>
-#include <linux/init.h>
 #include <linux/errno.h>
 #include <linux/pci.h>
 #include <linux/dma-mapping.h>
diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index 2dc16b6efaf0..73f74f369437 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -17,7 +17,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/moduleparam.h>
 
diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index f6b3212ec339..88e9c73cebc0 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -38,7 +38,6 @@ static const char *version = "tc35815.c:v" DRV_VERSION "\n";
 #include <linux/string.h>
 #include <linux/spinlock.h>
 #include <linux/errno.h>
-#include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
diff --git a/drivers/net/ethernet/tundra/tsi108_eth.c b/drivers/net/ethernet/tundra/tsi108_eth.c
index c4dbf981804b..47eeb3abf7f7 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.c
+++ b/drivers/net/ethernet/tundra/tsi108_eth.c
@@ -32,7 +32,6 @@
 
 #include <linux/module.h>
 #include <linux/types.h>
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/net.h>
 #include <linux/netdevice.h>
diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 2166e879a096..a4347508031c 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -29,7 +29,6 @@
 
 #include <linux/delay.h>
 #include <linux/etherdevice.h>
-#include <linux/init.h>
 #include <linux/mii.h>
 #include <linux/module.h>
 #include <linux/mutex.h>
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index f9293da19e26..1ec65feebb9e 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -22,7 +22,6 @@
 
 #include <linux/delay.h>
 #include <linux/etherdevice.h>
-#include <linux/init.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/of_mdio.h>
diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index fefb8cd5eb65..36052b98b3fc 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -14,7 +14,6 @@
 
 #include <linux/module.h>
 #include <linux/uaccess.h>
-#include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
diff --git a/drivers/net/fddi/defxx.c b/drivers/net/fddi/defxx.c
index 0344f71bf4a5..eb78203cd58e 100644
--- a/drivers/net/fddi/defxx.c
+++ b/drivers/net/fddi/defxx.c
@@ -206,7 +206,6 @@
 #include <linux/eisa.h>
 #include <linux/errno.h>
 #include <linux/fddidevice.h>
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/ioport.h>
 #include <linux/kernel.h>
diff --git a/drivers/net/fddi/skfp/h/targetos.h b/drivers/net/fddi/skfp/h/targetos.h
index 53bacc107160..355194251ff8 100644
--- a/drivers/net/fddi/skfp/h/targetos.h
+++ b/drivers/net/fddi/skfp/h/targetos.h
@@ -48,7 +48,6 @@
 #include <linux/fddidevice.h>
 #include <linux/skbuff.h>
 #include <linux/pci.h>
-#include <linux/init.h>
 
 // is redefined by linux, but we need our definition
 #undef ADDR
diff --git a/drivers/net/hippi/rrunner.c b/drivers/net/hippi/rrunner.c
index cd85f24637e1..e580583f196d 100644
--- a/drivers/net/hippi/rrunner.c
+++ b/drivers/net/hippi/rrunner.c
@@ -37,7 +37,6 @@
 #include <linux/netdevice.h>
 #include <linux/hippidevice.h>
 #include <linux/skbuff.h>
-#include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/mm.h>
 #include <linux/slab.h>
diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index 5b7a665c6d83..5f91e3e01c04 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -18,7 +18,6 @@
  *  with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
-#include <linux/init.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/interrupt.h>
diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index f9a86bdb12fa..925b78cc9797 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -58,7 +58,6 @@
 #include <linux/moduleparam.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
-#include <linux/init.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/slab.h>
diff --git a/drivers/net/irda/kingsun-sir.c b/drivers/net/irda/kingsun-sir.c
index 7b4833874ef5..96fe3659012d 100644
--- a/drivers/net/irda/kingsun-sir.c
+++ b/drivers/net/irda/kingsun-sir.c
@@ -64,7 +64,6 @@
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/errno.h>
-#include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/usb.h>
 #include <linux/device.h>
diff --git a/drivers/net/irda/ks959-sir.c b/drivers/net/irda/ks959-sir.c
index 5f3aeac3f86d..e6b3804edacd 100644
--- a/drivers/net/irda/ks959-sir.c
+++ b/drivers/net/irda/ks959-sir.c
@@ -116,7 +116,6 @@
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/errno.h>
-#include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/usb.h>
 #include <linux/device.h>
diff --git a/drivers/net/irda/ksdazzle-sir.c b/drivers/net/irda/ksdazzle-sir.c
index 2d4b6a1ab202..37f23a189b35 100644
--- a/drivers/net/irda/ksdazzle-sir.c
+++ b/drivers/net/irda/ksdazzle-sir.c
@@ -80,7 +80,6 @@
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/errno.h>
-#include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/usb.h>
 #include <linux/device.h>
diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
index 3f138ca88670..16f8ffb50e04 100644
--- a/drivers/net/irda/mcs7780.c
+++ b/drivers/net/irda/mcs7780.c
@@ -48,7 +48,6 @@
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/errno.h>
-#include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/usb.h>
 #include <linux/device.h>
diff --git a/drivers/net/irda/sir_dongle.c b/drivers/net/irda/sir_dongle.c
index 2a9930e6e2af..cfbabb63f5cc 100644
--- a/drivers/net/irda/sir_dongle.c
+++ b/drivers/net/irda/sir_dongle.c
@@ -13,7 +13,6 @@
 
 #include <linux/module.h>
 #include <linux/kernel.h>
-#include <linux/init.h>
 #include <linux/kmod.h>
 #include <linux/mutex.h>
 
diff --git a/drivers/net/irda/stir4200.c b/drivers/net/irda/stir4200.c
index 876e709b65ba..dd1bd1060ec9 100644
--- a/drivers/net/irda/stir4200.c
+++ b/drivers/net/irda/stir4200.c
@@ -41,7 +41,6 @@
 
 #include <linux/kernel.h>
 #include <linux/types.h>
-#include <linux/init.h>
 #include <linux/time.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index ac24c27b4b2d..c5011e078e1b 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -39,7 +39,6 @@
 #include <linux/errno.h>
 #include <linux/fcntl.h>
 #include <linux/in.h>
-#include <linux/init.h>
 
 #include <asm/uaccess.h>
 #include <asm/io.h>
diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index a2c3a897206e..ff111a89e17f 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -11,7 +11,6 @@
 #include <linux/sched.h>
 #include <linux/types.h>
 #include <linux/slab.h>
-#include <linux/init.h>
 #include <linux/wait.h>
 #include <linux/cdev.h>
 #include <linux/idr.h>
diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 8004acbef2c9..e701433bf52f 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -22,7 +22,6 @@
 
 #include <linux/module.h>
 #include <linux/slab.h>
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/platform_device.h>
 #include <linux/gpio.h>
diff --git a/drivers/net/phy/mdio-moxart.c b/drivers/net/phy/mdio-moxart.c
index a5741cb0304e..f1fc51f655d9 100644
--- a/drivers/net/phy/mdio-moxart.c
+++ b/drivers/net/phy/mdio-moxart.c
@@ -8,7 +8,6 @@
  */
 
 #include <linux/delay.h>
-#include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/mutex.h>
diff --git a/drivers/net/phy/mdio-mux-gpio.c b/drivers/net/phy/mdio-mux-gpio.c
index d2dd9e473e2c..096695163491 100644
--- a/drivers/net/phy/mdio-mux-gpio.c
+++ b/drivers/net/phy/mdio-mux-gpio.c
@@ -10,7 +10,6 @@
 #include <linux/device.h>
 #include <linux/of_mdio.h>
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/phy.h>
 #include <linux/mdio-mux.h>
 #include <linux/of_gpio.h>
diff --git a/drivers/net/phy/mdio-mux-mmioreg.c b/drivers/net/phy/mdio-mux-mmioreg.c
index f8e305d8da76..1656785ff339 100644
--- a/drivers/net/phy/mdio-mux-mmioreg.c
+++ b/drivers/net/phy/mdio-mux-mmioreg.c
@@ -15,7 +15,6 @@
 #include <linux/of_address.h>
 #include <linux/of_mdio.h>
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/phy.h>
 #include <linux/mdio-mux.h>
 
diff --git a/drivers/net/phy/mdio-octeon.c b/drivers/net/phy/mdio-octeon.c
index 6aee02ed97ac..a51ed92fbada 100644
--- a/drivers/net/phy/mdio-octeon.c
+++ b/drivers/net/phy/mdio-octeon.c
@@ -10,7 +10,6 @@
 #include <linux/of_mdio.h>
 #include <linux/delay.h>
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/gfp.h>
 #include <linux/phy.h>
 #include <linux/io.h>
diff --git a/drivers/net/phy/mdio-sun4i.c b/drivers/net/phy/mdio-sun4i.c
index 18969b3ad8bb..bb88bc7d81fb 100644
--- a/drivers/net/phy/mdio-sun4i.c
+++ b/drivers/net/phy/mdio-sun4i.c
@@ -13,7 +13,6 @@
  */
 
 #include <linux/delay.h>
-#include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/mutex.h>
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 76e8936ab9e4..19c9eca0ef26 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -20,7 +20,6 @@
 #include <linux/errno.h>
 #include <linux/unistd.h>
 #include <linux/interrupt.h>
-#include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index 0ba431145a84..4cf5fb922e59 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -15,7 +15,6 @@
 
 #include <linux/types.h>
 #include <linux/kernel.h>
-#include <linux/init.h>
 #include <linux/module.h>
 #include <linux/delay.h>
 #include <linux/device.h>
diff --git a/drivers/net/usb/asix.h b/drivers/net/usb/asix.h
index bad857aacd1a..5d049d00c2d7 100644
--- a/drivers/net/usb/asix.h
+++ b/drivers/net/usb/asix.h
@@ -27,7 +27,6 @@
 
 #include <linux/module.h>
 #include <linux/kmod.h>
-#include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index da6b8a5dcc0d..630caf48f63a 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -31,7 +31,6 @@
  * Vojtech Pavlik, Simunkova 1594, Prague 8, 182 00 Czech Republic
  */
 
-#include <linux/init.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
diff --git a/drivers/net/usb/cdc_eem.c b/drivers/net/usb/cdc_eem.c
index 57fd7170ae60..f7180f8db39e 100644
--- a/drivers/net/usb/cdc_eem.c
+++ b/drivers/net/usb/cdc_eem.c
@@ -18,7 +18,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ctype.h>
diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 640406ac4358..b67c109c65c8 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -21,7 +21,6 @@
 // #define	VERBOSE			// more; success messages
 
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index e15ec2b12035..dbff290ed0e4 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -39,7 +39,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/ctype.h>
 #include <linux/ethtool.h>
diff --git a/drivers/net/usb/cdc_subset.c b/drivers/net/usb/cdc_subset.c
index 3b2593a7602b..91f0919fe278 100644
--- a/drivers/net/usb/cdc_subset.c
+++ b/drivers/net/usb/cdc_subset.c
@@ -18,7 +18,6 @@
 
 #include <linux/module.h>
 #include <linux/kmod.h>
-#include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
diff --git a/drivers/net/usb/cx82310_eth.c b/drivers/net/usb/cx82310_eth.c
index 5233e6d070ec..3eed708a6182 100644
--- a/drivers/net/usb/cx82310_eth.c
+++ b/drivers/net/usb/cx82310_eth.c
@@ -18,7 +18,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 14aa48fa8d7e..15e3f8e459f5 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -13,7 +13,6 @@
 #include <linux/module.h>
 #include <linux/sched.h>
 #include <linux/stddef.h>
-#include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
diff --git a/drivers/net/usb/gl620a.c b/drivers/net/usb/gl620a.c
index 3569da1135c1..e4a8a93fbaf7 100644
--- a/drivers/net/usb/gl620a.c
+++ b/drivers/net/usb/gl620a.c
@@ -21,7 +21,6 @@
 // #define	VERBOSE			// more; success messages
 
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
diff --git a/drivers/net/usb/ipheth.c b/drivers/net/usb/ipheth.c
index ff8594d8dd2d..421934c83f1c 100644
--- a/drivers/net/usb/ipheth.c
+++ b/drivers/net/usb/ipheth.c
@@ -45,7 +45,6 @@
 
 #include <linux/kernel.h>
 #include <linux/errno.h>
-#include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
diff --git a/drivers/net/usb/kalmia.c b/drivers/net/usb/kalmia.c
index 6866eae3e388..5662babf0583 100644
--- a/drivers/net/usb/kalmia.c
+++ b/drivers/net/usb/kalmia.c
@@ -15,7 +15,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ctype.h>
diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index 250fc21d9781..a359d3bb7c5b 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -45,7 +45,6 @@
 #include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/string.h>
-#include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index 36ff0019aa32..a305a7b2dae6 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -42,7 +42,6 @@
 #include <linux/crc32.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
-#include <linux/init.h>
 #include <linux/mii.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
index 8b2493f05a1c..0a85d9227775 100644
--- a/drivers/net/usb/net1080.c
+++ b/drivers/net/usb/net1080.c
@@ -20,7 +20,6 @@
 // #define	VERBOSE			// more; success messages
 
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
diff --git a/drivers/net/usb/plusb.c b/drivers/net/usb/plusb.c
index ee705b7bba08..3d18bb0eee85 100644
--- a/drivers/net/usb/plusb.c
+++ b/drivers/net/usb/plusb.c
@@ -20,7 +20,6 @@
 // #define	VERBOSE			// more; success messages
 
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index bf7d549ab511..6cc6d22335cd 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -7,7 +7,6 @@
  *
  */
 
-#include <linux/init.h>
 #include <linux/signal.h>
 #include <linux/slab.h>
 #include <linux/module.h>
diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index 72aee8516ca8..a48bc0f20c1a 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -16,7 +16,6 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index 6cbdac67f3a0..da2c4583bd2d 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -6,7 +6,6 @@
  * version 2 as published by the Free Software Foundation.
  */
 
-#include <linux/init.h>
 #include <linux/signal.h>
 #include <linux/slab.h>
 #include <linux/module.h>
diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 0217b282e7ec..f17b9e02dd34 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -19,7 +19,6 @@
 
 #include <linux/module.h>
 #include <linux/kmod.h>
-#include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 96f5eee20fa4..8dd54a0f7b29 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -19,7 +19,6 @@
 
 #include <linux/module.h>
 #include <linux/kmod.h>
-#include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
diff --git a/drivers/net/usb/sr9700.c b/drivers/net/usb/sr9700.c
index 7ec3e0ee0783..99b69af14274 100644
--- a/drivers/net/usb/sr9700.c
+++ b/drivers/net/usb/sr9700.c
@@ -13,7 +13,6 @@
 #include <linux/module.h>
 #include <linux/sched.h>
 #include <linux/stddef.h>
-#include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
diff --git a/drivers/net/usb/zaurus.c b/drivers/net/usb/zaurus.c
index 25d1e667a061..6aaa6eb9df72 100644
--- a/drivers/net/usb/zaurus.c
+++ b/drivers/net/usb/zaurus.c
@@ -20,7 +20,6 @@
 // #define	VERBOSE			// more; success messages
 
 #include <linux/module.h>
-#include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/ethtool.h>
 #include <linux/workqueue.h>
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 12040a35d95d..190569d02450 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -37,7 +37,6 @@
 #include <linux/spinlock.h>
 #include <linux/ioport.h>
 #include <linux/highmem.h>
-#include <linux/init.h>
 #include <linux/timer.h>
 #include <linux/skbuff.h>
 #include <linux/interrupt.h>
diff --git a/drivers/net/wan/hd64570.c b/drivers/net/wan/hd64570.c
index 62f01b74cbd6..dc334c85d966 100644
--- a/drivers/net/wan/hd64570.c
+++ b/drivers/net/wan/hd64570.c
@@ -29,7 +29,6 @@
 #include <linux/fcntl.h>
 #include <linux/hdlc.h>
 #include <linux/in.h>
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/ioport.h>
 #include <linux/jiffies.h>
diff --git a/drivers/net/wan/hd64572.c b/drivers/net/wan/hd64572.c
index 6269a09c7369..e92ecf1d3314 100644
--- a/drivers/net/wan/hd64572.c
+++ b/drivers/net/wan/hd64572.c
@@ -29,7 +29,6 @@
 #include <linux/fcntl.h>
 #include <linux/hdlc.h>
 #include <linux/in.h>
-#include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/ioport.h>
 #include <linux/jiffies.h>
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index c59b91f03660..8e3477058b9b 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -49,7 +49,6 @@
 #include <linux/pci.h>
 #include <linux/delay.h>
 #include <linux/hdlc.h>
-#include <linux/init.h>
 #include <linux/in.h>
 #include <linux/if_arp.h>
 #include <linux/netdevice.h>
-- 
1.8.5.2
