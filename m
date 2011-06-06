From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH net-next] net: remove interrupt.h inclusion from netdevice.h
Date: Mon, 6 Jun 2011 23:43:46 +0300
Message-ID: <20110606204346.GA24175@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:43903 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932072Ab1FFUnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 16:43:53 -0400
Received: by bwz15 with SMTP id 15so3635027bwz.19
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2011 13:43:51 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* remove interrupt.g inclusion from netdevice.h -- not needed
* fixup fallout, add interrupt.h and hardirq.h back where needed.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/atm/eni.h                             |    1 +
 drivers/atm/firestream.c                      |    1 +
 drivers/atm/horizon.c                         |    1 +
 drivers/atm/idt77252.c                        |    1 +
 drivers/atm/iphase.c                          |    1 +
 drivers/atm/zatm.c                            |    1 +
 drivers/infiniband/hw/amso1100/c2.c           |    1 +
 drivers/infiniband/ulp/iser/iscsi_iser.h      |    1 +
 drivers/isdn/hardware/mISDN/avmfritz.c        |    1 +
 drivers/isdn/hardware/mISDN/hfcmulti.c        |    1 +
 drivers/isdn/hardware/mISDN/hfcpci.c          |    1 +
 drivers/isdn/hardware/mISDN/mISDNinfineon.c   |    1 +
 drivers/isdn/hardware/mISDN/mISDNipac.c       |    1 +
 drivers/isdn/hardware/mISDN/netjet.c          |    1 +
 drivers/isdn/hardware/mISDN/speedfax.c        |    1 +
 drivers/isdn/hardware/mISDN/w6692.c           |    1 +
 drivers/isdn/hisax/hisax.h                    |    1 +
 drivers/isdn/hisax/hisax_fcpcipnp.c           |    1 +
 drivers/media/dvb/b2c2/flexcop-common.h       |    1 +
 drivers/media/dvb/dm1105/dm1105.c             |    1 +
 drivers/media/dvb/mantis/mantis_common.h      |    1 +
 drivers/media/dvb/pluto2/pluto2.c             |    1 +
 drivers/net/3c503.c                           |    1 +
 drivers/net/8139cp.c                          |    1 +
 drivers/net/8139too.c                         |    1 +
 drivers/net/8390.h                            |    1 +
 drivers/net/ac3200.c                          |    1 +
 drivers/net/acenic.h                          |    1 +
 drivers/net/amd8111e.c                        |    1 +
 drivers/net/arcnet/arc-rimi.c                 |    1 +
 drivers/net/arcnet/com20020-isa.c             |    1 +
 drivers/net/arcnet/com20020-pci.c             |    1 +
 drivers/net/arcnet/com20020.c                 |    1 +
 drivers/net/arcnet/com90io.c                  |    1 +
 drivers/net/arcnet/com90xx.c                  |    1 +
 drivers/net/arm/at91_ether.c                  |    1 +
 drivers/net/arm/ep93xx_eth.c                  |    1 +
 drivers/net/arm/ks8695net.c                   |    1 +
 drivers/net/atl1c/atl1c.h                     |    1 +
 drivers/net/atl1e/atl1e.h                     |    1 +
 drivers/net/b44.c                             |    1 +
 drivers/net/bmac.c                            |    1 +
 drivers/net/bnx2x/bnx2x_cmn.c                 |    1 +
 drivers/net/caif/caif_serial.c                |    1 +
 drivers/net/can/sja1000/sja1000.h             |    1 +
 drivers/net/cassini.c                         |    1 +
 drivers/net/cxgb4vf/adapter.h                 |    1 +
 drivers/net/dm9000.c                          |    1 +
 drivers/net/dnet.c                            |    1 +
 drivers/net/e100.c                            |    2 ++
 drivers/net/e1000e/ethtool.c                  |    1 +
 drivers/net/e1000e/netdev.c                   |    1 +
 drivers/net/e2100.c                           |    1 +
 drivers/net/enic/enic_main.c                  |    1 +
 drivers/net/es3210.c                          |    1 +
 drivers/net/ethoc.c                           |    1 +
 drivers/net/fec_mpc52xx.c                     |    1 +
 drivers/net/greth.c                           |    1 +
 drivers/net/hamradio/baycom_ser_fdx.c         |    1 +
 drivers/net/hamradio/baycom_ser_hdx.c         |    1 +
 drivers/net/hp-plus.c                         |    1 +
 drivers/net/hp.c                              |    1 +
 drivers/net/ibmveth.c                         |    1 +
 drivers/net/ifb.c                             |    1 +
 drivers/net/ipg.c                             |    1 +
 drivers/net/irda/ali-ircc.c                   |    1 +
 drivers/net/irda/donauboe.c                   |    1 +
 drivers/net/irda/nsc-ircc.c                   |    1 +
 drivers/net/irda/pxaficp_ir.c                 |    1 +
 drivers/net/irda/sir_dev.c                    |    1 +
 drivers/net/irda/smsc-ircc2.c                 |    1 +
 drivers/net/irda/via-ircc.c                   |    1 +
 drivers/net/irda/vlsi_ir.c                    |    1 +
 drivers/net/irda/w83977af_ir.c                |    1 +
 drivers/net/ixgbe/ixgbe_ethtool.c             |    1 +
 drivers/net/ixgbe/ixgbe_main.c                |    1 +
 drivers/net/ixp2000/ixpdev.c                  |    1 +
 drivers/net/jme.h                             |    1 +
 drivers/net/ks8842.c                          |    1 +
 drivers/net/ks8851.c                          |    1 +
 drivers/net/ks8851_mll.c                      |    1 +
 drivers/net/ksz884x.c                         |    1 +
 drivers/net/lne390.c                          |    1 +
 drivers/net/macb.c                            |    1 +
 drivers/net/mace.c                            |    1 +
 drivers/net/netx-eth.c                        |    1 +
 drivers/net/niu.c                             |    1 +
 drivers/net/ns83820.c                         |    1 +
 drivers/net/ppp_async.c                       |    1 +
 drivers/net/ppp_synctty.c                     |    1 +
 drivers/net/ps3_gelic_net.c                   |    1 +
 drivers/net/qlge/qlge.h                       |    1 +
 drivers/net/r8169.c                           |    1 +
 drivers/net/sc92031.c                         |    1 +
 drivers/net/sfc/nic.c                         |    1 +
 drivers/net/sis190.c                          |    1 +
 drivers/net/skge.h                            |    1 +
 drivers/net/sky2.c                            |    1 +
 drivers/net/smc-mca.c                         |    1 +
 drivers/net/smc-ultra.c                       |    1 +
 drivers/net/smsc911x.c                        |    1 +
 drivers/net/smsc9420.c                        |    1 +
 drivers/net/spider_net.c                      |    1 +
 drivers/net/starfire.c                        |    1 +
 drivers/net/stmmac/stmmac_ethtool.c           |    1 +
 drivers/net/tg3.c                             |    1 +
 drivers/net/tlan.c                            |    2 ++
 drivers/net/tokenring/ibmtr.c                 |    1 +
 drivers/net/tsi108_eth.c                      |    1 +
 drivers/net/tulip/de2104x.c                   |    1 +
 drivers/net/tulip/pnic.c                      |    1 +
 drivers/net/tulip/tulip_core.c                |    1 +
 drivers/net/vxge/vxge-config.h                |    1 +
 drivers/net/vxge/vxge-main.c                  |    1 +
 drivers/net/wan/cycx_main.c                   |    1 +
 drivers/net/wan/dscc4.c                       |    1 +
 drivers/net/wan/farsync.c                     |    1 +
 drivers/net/wan/wanxl.c                       |    1 +
 drivers/net/wireless/adm8211.c                |    1 +
 drivers/net/wireless/ath/ath9k/ath9k.h        |    1 +
 drivers/net/wireless/atmel.c                  |    1 +
 drivers/net/wireless/hostap/hostap_wlan.h     |    1 +
 drivers/net/wireless/ipw2x00/ipw2200.h        |    1 +
 drivers/net/wireless/ipw2x00/libipw_wx.c      |    1 +
 drivers/net/wireless/iwlegacy/iwl-dev.h       |    1 +
 drivers/net/wireless/iwlwifi/iwl-dev.h        |    1 +
 drivers/net/wireless/libertas/cfg.c           |    1 +
 drivers/net/wireless/libertas/cmd.c           |    1 +
 drivers/net/wireless/libertas/cmdresp.c       |    1 +
 drivers/net/wireless/libertas/debugfs.c       |    1 +
 drivers/net/wireless/libertas/ethtool.c       |    1 +
 drivers/net/wireless/libertas/if_spi.c        |    2 ++
 drivers/net/wireless/libertas/main.c          |    1 +
 drivers/net/wireless/libertas/mesh.c          |    1 +
 drivers/net/wireless/libertas/rx.c            |    1 +
 drivers/net/wireless/libertas/tx.c            |    1 +
 drivers/net/wireless/libertas_tf/cmd.c        |    1 +
 drivers/net/wireless/libertas_tf/main.c       |    1 +
 drivers/net/wireless/mwl8k.c                  |    1 +
 drivers/net/wireless/p54/p54pci.h             |    1 +
 drivers/net/wireless/prism54/islpci_dev.c     |    1 +
 drivers/net/wireless/prism54/islpci_dev.h     |    1 +
 drivers/net/wireless/prism54/islpci_hotplug.c |    1 +
 drivers/net/wireless/rt2x00/rt2x00.h          |    1 +
 drivers/net/wireless/rtl818x/rtl8180/dev.c    |    1 +
 drivers/net/wireless/wl1251/sdio.c            |    1 +
 drivers/net/wireless/wl1251/spi.c             |    1 +
 drivers/net/wireless/wl12xx/io.h              |    1 +
 drivers/net/wireless/wl12xx/spi.c             |    1 +
 drivers/s390/net/ctcm_mpc.h                   |    1 +
 include/linux/arcdevice.h                     |    1 +
 include/linux/dccp.h                          |    1 +
 include/linux/netdevice.h                     |    1 -
 include/net/bluetooth/hci_core.h              |    1 +
 include/net/sock.h                            |    1 +
 net/atm/pppoatm.c                             |    1 +
 net/caif/chnl_net.c                           |    1 +
 net/can/bcm.c                                 |    1 +
 net/rds/ib.h                                  |    1 +
 net/rds/iw.h                                  |    1 +
 net/sched/sch_atm.c                           |    1 +
 net/sunrpc/xprtrdma/svc_rdma_transport.c      |    1 +
 net/sunrpc/xprtrdma/verbs.c                   |    1 +
 163 files changed, 165 insertions(+), 1 deletion(-)

--- a/drivers/atm/eni.h
+++ b/drivers/atm/eni.h
@@ -8,6 +8,7 @@
 
 #include <linux/atm.h>
 #include <linux/atmdev.h>
+#include <linux/interrupt.h>
 #include <linux/sonet.h>
 #include <linux/skbuff.h>
 #include <linux/time.h>
--- a/drivers/atm/firestream.c
+++ b/drivers/atm/firestream.c
@@ -44,6 +44,7 @@
 #include <linux/ioport.h> /* for request_region */
 #include <linux/uio.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/capability.h>
 #include <linux/bitops.h>
 #include <linux/slab.h>
--- a/drivers/atm/horizon.c
+++ b/drivers/atm/horizon.c
@@ -38,6 +38,7 @@
 #include <linux/delay.h>
 #include <linux/uio.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/ioport.h>
 #include <linux/wait.h>
 #include <linux/slab.h>
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -37,6 +37,7 @@
 #include <linux/atm.h>
 #include <linux/delay.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/bitops.h>
 #include <linux/wait.h>
 #include <linux/jiffies.h>
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -53,6 +53,7 @@
 #include <linux/delay.h>  
 #include <linux/uio.h>  
 #include <linux/init.h>  
+#include <linux/interrupt.h>
 #include <linux/wait.h>
 #include <linux/slab.h>
 #include <asm/system.h>  
--- a/drivers/atm/zatm.c
+++ b/drivers/atm/zatm.c
@@ -16,6 +16,7 @@
 #include <linux/delay.h>
 #include <linux/uio.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/dma-mapping.h>
 #include <linux/atm_zatm.h>
 #include <linux/capability.h>
--- a/drivers/infiniband/hw/amso1100/c2.c
+++ b/drivers/infiniband/hw/amso1100/c2.c
@@ -36,6 +36,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/inetdevice.h>
+#include <linux/interrupt.h>
 #include <linux/delay.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
--- a/drivers/infiniband/ulp/iser/iscsi_iser.h
+++ b/drivers/infiniband/ulp/iser/iscsi_iser.h
@@ -45,6 +45,7 @@
 #include <scsi/libiscsi.h>
 #include <scsi/scsi_transport_iscsi.h>
 
+#include <linux/interrupt.h>
 #include <linux/wait.h>
 #include <linux/sched.h>
 #include <linux/list.h>
--- a/drivers/isdn/hardware/mISDN/avmfritz.c
+++ b/drivers/isdn/hardware/mISDN/avmfritz.c
@@ -20,6 +20,7 @@
  * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  *
  */
+#include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -152,6 +152,7 @@
 
 #define HFC_MULTI_VERSION	"2.03"
 
+#include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/pci.h>
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -44,6 +44,7 @@
  *
  */
 
+#include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
--- a/drivers/isdn/hardware/mISDN/mISDNinfineon.c
+++ b/drivers/isdn/hardware/mISDN/mISDNinfineon.c
@@ -38,6 +38,7 @@
  *
  */
 
+#include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
--- a/drivers/isdn/hardware/mISDN/mISDNipac.c
+++ b/drivers/isdn/hardware/mISDN/mISDNipac.c
@@ -20,6 +20,7 @@
  *
  */
 
+#include <linux/irqreturn.h>
 #include <linux/slab.h>
 #include <linux/module.h>
 #include <linux/mISDNhw.h>
--- a/drivers/isdn/hardware/mISDN/netjet.c
+++ b/drivers/isdn/hardware/mISDN/netjet.c
@@ -20,6 +20,7 @@
  *
  */
 
+#include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
--- a/drivers/isdn/hardware/mISDN/speedfax.c
+++ b/drivers/isdn/hardware/mISDN/speedfax.c
@@ -22,6 +22,7 @@
  *
  */
 
+#include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/pci.h>
--- a/drivers/isdn/hardware/mISDN/w6692.c
+++ b/drivers/isdn/hardware/mISDN/w6692.c
@@ -21,6 +21,7 @@
  *
  */
 
+#include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
--- a/drivers/isdn/hisax/hisax.h
+++ b/drivers/isdn/hisax/hisax.h
@@ -16,6 +16,7 @@
 #include <linux/slab.h>
 #include <linux/mm.h>
 #include <linux/mman.h>
+#include <linux/interrupt.h>
 #include <linux/ioport.h>
 #include <linux/timer.h>
 #include <linux/wait.h>
--- a/drivers/isdn/hisax/hisax_fcpcipnp.c
+++ b/drivers/isdn/hisax/hisax_fcpcipnp.c
@@ -25,6 +25,7 @@
 
 #include <linux/module.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/isapnp.h>
 #include <linux/kmod.h>
--- a/drivers/media/dvb/b2c2/flexcop-common.h
+++ b/drivers/media/dvb/b2c2/flexcop-common.h
@@ -6,6 +6,7 @@
 #ifndef __FLEXCOP_COMMON_H__
 #define __FLEXCOP_COMMON_H__
 
+#include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/mutex.h>
 
--- a/drivers/media/dvb/dm1105/dm1105.c
+++ b/drivers/media/dvb/dm1105/dm1105.c
@@ -22,6 +22,7 @@
 #include <linux/i2c.h>
 #include <linux/i2c-algo-bit.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/proc_fs.h>
--- a/drivers/media/dvb/mantis/mantis_common.h
+++ b/drivers/media/dvb/mantis/mantis_common.h
@@ -21,6 +21,7 @@
 #ifndef __MANTIS_COMMON_H
 #define __MANTIS_COMMON_H
 
+#include <linux/interrupt.h>
 #include <linux/mutex.h>
 #include <linux/workqueue.h>
 
--- a/drivers/media/dvb/pluto2/pluto2.c
+++ b/drivers/media/dvb/pluto2/pluto2.c
@@ -26,6 +26,7 @@
 #include <linux/i2c.h>
 #include <linux/i2c-algo-bit.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/pci.h>
--- a/drivers/net/3c503.c
+++ b/drivers/net/3c503.c
@@ -49,6 +49,7 @@ static const char version[] =
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/ethtool.h>
 
 #include <asm/uaccess.h>
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -60,6 +60,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/dma-mapping.h>
 #include <linux/delay.h>
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -100,6 +100,7 @@
 #include <linux/compiler.h>
 #include <linux/pci.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/rtnetlink.h>
--- a/drivers/net/8390.h
+++ b/drivers/net/8390.h
@@ -9,6 +9,7 @@
 
 #include <linux/if_ether.h>
 #include <linux/ioport.h>
+#include <linux/irqreturn.h>
 #include <linux/skbuff.h>
 
 #define TX_PAGES 12	/* Two Tx slots */
--- a/drivers/net/ac3200.c
+++ b/drivers/net/ac3200.c
@@ -32,6 +32,7 @@ static const char version[] =
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 
 #include <asm/system.h>
 #include <asm/io.h>
--- a/drivers/net/acenic.h
+++ b/drivers/net/acenic.h
@@ -1,5 +1,6 @@
 #ifndef _ACENIC_H_
 #define _ACENIC_H_
+#include <linux/interrupt.h>
 
 
 /*
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -75,6 +75,7 @@ Revision History:
 #include <linux/compiler.h>
 #include <linux/delay.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/ioport.h>
 #include <linux/pci.h>
 #include <linux/netdevice.h>
--- a/drivers/net/arcnet/arc-rimi.c
+++ b/drivers/net/arcnet/arc-rimi.c
@@ -32,6 +32,7 @@
 #include <linux/netdevice.h>
 #include <linux/bootmem.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <asm/io.h>
 #include <linux/arcdevice.h>
 
--- a/drivers/net/arcnet/com20020-isa.c
+++ b/drivers/net/arcnet/com20020-isa.c
@@ -34,6 +34,7 @@
 #include <linux/delay.h>
 #include <linux/netdevice.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/bootmem.h>
 #include <linux/arcdevice.h>
 #include <linux/com20020.h>
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -34,6 +34,7 @@
 #include <linux/errno.h>
 #include <linux/netdevice.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/arcdevice.h>
 #include <linux/com20020.h>
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -33,6 +33,7 @@
 #include <linux/delay.h>
 #include <linux/netdevice.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/arcdevice.h>
 #include <linux/com20020.h>
 
--- a/drivers/net/arcnet/com90io.c
+++ b/drivers/net/arcnet/com90io.c
@@ -33,6 +33,7 @@
 #include <linux/netdevice.h>
 #include <linux/bootmem.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <asm/io.h>
 #include <linux/arcdevice.h>
 
--- a/drivers/net/arcnet/com90xx.c
+++ b/drivers/net/arcnet/com90xx.c
@@ -27,6 +27,7 @@
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/ioport.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
--- a/drivers/net/arm/at91_ether.c
+++ b/drivers/net/arm/at91_ether.c
@@ -19,6 +19,7 @@
 
 #include <linux/module.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/mii.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
--- a/drivers/net/arm/ep93xx_eth.c
+++ b/drivers/net/arm/ep93xx_eth.c
@@ -19,6 +19,7 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/moduleparam.h>
 #include <linux/platform_device.h>
 #include <linux/delay.h>
--- a/drivers/net/arm/ks8695net.c
+++ b/drivers/net/arm/ks8695net.c
@@ -21,6 +21,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
 #include <linux/crc32.h>
--- a/drivers/net/atl1c/atl1c.h
+++ b/drivers/net/atl1c/atl1c.h
@@ -24,6 +24,7 @@
 
 #include <linux/version.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/types.h>
 #include <linux/errno.h>
 #include <linux/module.h>
--- a/drivers/net/atl1e/atl1e.h
+++ b/drivers/net/atl1e/atl1e.h
@@ -25,6 +25,7 @@
 
 #include <linux/version.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/types.h>
 #include <linux/errno.h>
 #include <linux/module.h>
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -25,6 +25,7 @@
 #include <linux/pci.h>
 #include <linux/delay.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/dma-mapping.h>
 #include <linux/ssb/ssb.h>
 #include <linux/slab.h>
--- a/drivers/net/bmac.c
+++ b/drivers/net/bmac.c
@@ -7,6 +7,7 @@
  * May 1999, Al Viro: proper release of /proc/net/bmac entry, switched to
  * dynamic procfs inode.
  */
+#include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -17,6 +17,7 @@
 
 #include <linux/etherdevice.h>
 #include <linux/if_vlan.h>
+#include <linux/interrupt.h>
 #include <linux/ip.h>
 #include <net/ipv6.h>
 #include <net/ip6_checksum.h>
--- a/drivers/net/caif/caif_serial.c
+++ b/drivers/net/caif/caif_serial.c
@@ -4,6 +4,7 @@
  * License terms: GNU General Public License (GPL) version 2
  */
 
+#include <linux/hardirq.h>
 #include <linux/init.h>
 #include <linux/version.h>
 #include <linux/module.h>
--- a/drivers/net/can/sja1000/sja1000.h
+++ b/drivers/net/can/sja1000/sja1000.h
@@ -47,6 +47,7 @@
 #ifndef SJA1000_DEV_H
 #define SJA1000_DEV_H
 
+#include <linux/irqreturn.h>
 #include <linux/can/dev.h>
 #include <linux/can/platform/sja1000.h>
 
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -75,6 +75,7 @@
 #include <linux/slab.h>
 #include <linux/delay.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/vmalloc.h>
 #include <linux/ioport.h>
 #include <linux/pci.h>
--- a/drivers/net/cxgb4vf/adapter.h
+++ b/drivers/net/cxgb4vf/adapter.h
@@ -40,6 +40,7 @@
 #ifndef __CXGB4VF_ADAPTER_H__
 #define __CXGB4VF_ADAPTER_H__
 
+#include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/spinlock.h>
 #include <linux/skbuff.h>
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -24,6 +24,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
 #include <linux/crc32.h>
--- a/drivers/net/dnet.c
+++ b/drivers/net/dnet.c
@@ -16,6 +16,7 @@
 #include <linux/slab.h>
 #include <linux/delay.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/dma-mapping.h>
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -149,6 +149,8 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
+#include <linux/hardirq.h>
+#include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/kernel.h>
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -28,6 +28,7 @@
 
 /* ethtool support for e1000 */
 
+#include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/ethtool.h>
 #include <linux/pci.h>
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -31,6 +31,7 @@
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/vmalloc.h>
 #include <linux/pagemap.h>
--- a/drivers/net/e2100.c
+++ b/drivers/net/e2100.c
@@ -44,6 +44,7 @@ static const char version[] =
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/delay.h>
 
 #include <asm/io.h>
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -23,6 +23,7 @@
 #include <linux/errno.h>
 #include <linux/types.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/workqueue.h>
 #include <linux/pci.h>
 #include <linux/netdevice.h>
--- a/drivers/net/es3210.c
+++ b/drivers/net/es3210.c
@@ -54,6 +54,7 @@ static const char version[] =
 #include <linux/errno.h>
 #include <linux/string.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -13,6 +13,7 @@
 
 #include <linux/etherdevice.h>
 #include <linux/crc32.h>
+#include <linux/interrupt.h>
 #include <linux/io.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -22,6 +22,7 @@
 #include <linux/slab.h>
 #include <linux/errno.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/crc32.h>
 #include <linux/hardirq.h>
 #include <linux/delay.h>
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -25,6 +25,7 @@
 #include <linux/module.h>
 #include <linux/uaccess.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
--- a/drivers/net/hamradio/baycom_ser_fdx.c
+++ b/drivers/net/hamradio/baycom_ser_fdx.c
@@ -76,6 +76,7 @@
 #include <linux/ioport.h>
 #include <linux/string.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/hdlcdrv.h>
 #include <linux/baycom.h>
 #include <linux/jiffies.h>
--- a/drivers/net/hamradio/baycom_ser_hdx.c
+++ b/drivers/net/hamradio/baycom_ser_hdx.c
@@ -66,6 +66,7 @@
 #include <linux/ioport.h>
 #include <linux/string.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <asm/uaccess.h>
 #include <asm/io.h>
 #include <linux/hdlcdrv.h>
--- a/drivers/net/hp-plus.c
+++ b/drivers/net/hp-plus.c
@@ -30,6 +30,7 @@ static const char version[] =
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/delay.h>
 
 #include <asm/system.h>
--- a/drivers/net/hp.c
+++ b/drivers/net/hp.c
@@ -30,6 +30,7 @@ static const char version[] =
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/delay.h>
 
 #include <asm/system.h>
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -34,6 +34,7 @@
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/mm.h>
 #include <linux/pm.h>
 #include <linux/ethtool.h>
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -32,6 +32,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/moduleparam.h>
 #include <net/pkt_sched.h>
 #include <net/net_namespace.h>
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -22,6 +22,7 @@
  */
 #include <linux/crc32.h>
 #include <linux/ethtool.h>
+#include <linux/interrupt.h>
 #include <linux/gfp.h>
 #include <linux/mii.h>
 #include <linux/mutex.h>
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -31,6 +31,7 @@
 #include <linux/ioport.h>
 #include <linux/delay.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/rtnetlink.h>
 #include <linux/serial_reg.h>
 #include <linux/dma-mapping.h>
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -152,6 +152,7 @@
 #include <linux/delay.h>
 #include <linux/slab.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/rtnetlink.h>
 
--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -52,6 +52,7 @@
 #include <linux/ioport.h>
 #include <linux/delay.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/rtnetlink.h>
 #include <linux/dma-mapping.h>
 #include <linux/pnp.h>
--- a/drivers/net/irda/pxaficp_ir.c
+++ b/drivers/net/irda/pxaficp_ir.c
@@ -12,6 +12,7 @@
  * Infra-red driver (SIR/FIR) for the PXA2xx embedded microprocessor
  *
  */
+#include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
--- a/drivers/net/irda/sir_dev.c
+++ b/drivers/net/irda/sir_dev.c
@@ -11,6 +11,7 @@
  *
  ********************************************************************/    
 
+#include <linux/hardirq.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/slab.h>
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -49,6 +49,7 @@
 #include <linux/ioport.h>
 #include <linux/delay.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/rtnetlink.h>
 #include <linux/serial_reg.h>
 #include <linux/dma-mapping.h>
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -46,6 +46,7 @@ F02 Oct/28/02: Add SB device ID for 3147 and 3177.
 #include <linux/ioport.h>
 #include <linux/delay.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/rtnetlink.h>
 #include <linux/pci.h>
 #include <linux/dma-mapping.h>
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -36,6 +36,7 @@ MODULE_LICENSE("GPL");
 
 #include <linux/kernel.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/slab.h>
 #include <linux/netdevice.h>
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -47,6 +47,7 @@
 #include <linux/ioport.h>
 #include <linux/delay.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/rtnetlink.h>
 #include <linux/dma-mapping.h>
 #include <linux/gfp.h>
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -27,6 +27,7 @@
 
 /* ethtool support for ixgbe */
 
+#include <linux/interrupt.h>
 #include <linux/types.h>
 #include <linux/module.h>
 #include <linux/slab.h>
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -32,6 +32,7 @@
 #include <linux/vmalloc.h>
 #include <linux/string.h>
 #include <linux/in.h>
+#include <linux/interrupt.h>
 #include <linux/ip.h>
 #include <linux/tcp.h>
 #include <linux/pkt_sched.h>
--- a/drivers/net/ixp2000/ixpdev.c
+++ b/drivers/net/ixp2000/ixpdev.c
@@ -14,6 +14,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/moduleparam.h>
 #include <linux/gfp.h>
 #include <asm/hardware/uengine.h>
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -24,6 +24,7 @@
 
 #ifndef __JME_H_INCLUDED__
 #define __JME_H_INCLUDED__
+#include <linux/interrupt.h>
 
 #define DRV_NAME	"jme"
 #define DRV_VERSION	"1.0.8"
--- a/drivers/net/ks8842.c
+++ b/drivers/net/ks8842.c
@@ -23,6 +23,7 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
+#include <linux/interrupt.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/platform_device.h>
--- a/drivers/net/ks8851.c
+++ b/drivers/net/ks8851.c
@@ -13,6 +13,7 @@
 
 #define DEBUG
 
+#include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
--- a/drivers/net/ks8851_mll.c
+++ b/drivers/net/ks8851_mll.c
@@ -23,6 +23,7 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
+#include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
--- a/drivers/net/ksz884x.c
+++ b/drivers/net/ksz884x.c
@@ -17,6 +17,7 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/ioport.h>
--- a/drivers/net/lne390.c
+++ b/drivers/net/lne390.c
@@ -41,6 +41,7 @@ static const char *version =
 #include <linux/string.h>
 #include <linux/delay.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -15,6 +15,7 @@
 #include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/dma-mapping.h>
--- a/drivers/net/mace.c
+++ b/drivers/net/mace.c
@@ -13,6 +13,7 @@
 #include <linux/string.h>
 #include <linux/timer.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/crc32.h>
 #include <linux/spinlock.h>
 #include <linux/bitrev.h>
--- a/drivers/net/netx-eth.c
+++ b/drivers/net/netx-eth.c
@@ -18,6 +18,7 @@
  */
 
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/delay.h>
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -7,6 +7,7 @@
 
 #include <linux/module.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/dma-mapping.h>
 #include <linux/netdevice.h>
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -106,6 +106,7 @@
 #include <linux/delay.h>
 #include <linux/workqueue.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/ip.h>	/* for iph */
 #include <linux/in.h>	/* for IPPROTO_... */
 #include <linux/compiler.h>
--- a/drivers/net/ppp_async.c
+++ b/drivers/net/ppp_async.c
@@ -30,6 +30,7 @@
 #include <linux/ppp_channel.h>
 #include <linux/spinlock.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/jiffies.h>
 #include <linux/slab.h>
 #include <asm/unaligned.h>
--- a/drivers/net/ppp_synctty.c
+++ b/drivers/net/ppp_synctty.c
@@ -44,6 +44,7 @@
 #include <linux/spinlock.h>
 #include <linux/completion.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/slab.h>
 #include <asm/unaligned.h>
 #include <asm/uaccess.h>
--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -28,6 +28,7 @@
 
 #undef DEBUG
 
+#include <linux/interrupt.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/slab.h>
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -7,6 +7,7 @@
 #ifndef _QLGE_H_
 #define _QLGE_H_
 
+#include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -22,6 +22,7 @@
 #include <linux/ip.h>
 #include <linux/tcp.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/dma-mapping.h>
 #include <linux/pm_runtime.h>
 #include <linux/firmware.h>
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -22,6 +22,7 @@
  * matching, so you need to enable IFF_PROMISC when using it.
  */
 
+#include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/delay.h>
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -10,6 +10,7 @@
 
 #include <linux/bitops.h>
 #include <linux/delay.h>
+#include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/module.h>
 #include <linux/seq_file.h>
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -21,6 +21,7 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
+#include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/netdevice.h>
--- a/drivers/net/skge.h
+++ b/drivers/net/skge.h
@@ -3,6 +3,7 @@
  */
 #ifndef _SKGE_H
 #define _SKGE_H
+#include <linux/interrupt.h>
 
 /* PCI config registers */
 #define PCI_DEV_REG1	0x40
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -32,6 +32,7 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/pci.h>
+#include <linux/interrupt.h>
 #include <linux/ip.h>
 #include <linux/slab.h>
 #include <net/ip.h>
--- a/drivers/net/smc-mca.c
+++ b/drivers/net/smc-mca.c
@@ -42,6 +42,7 @@
 #include <linux/errno.h>
 #include <linux/string.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 
--- a/drivers/net/smc-ultra.c
+++ b/drivers/net/smc-ultra.c
@@ -62,6 +62,7 @@ static const char version[] =
 #include <linux/errno.h>
 #include <linux/string.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/isapnp.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -37,6 +37,7 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/ioport.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -19,6 +19,7 @@
  ***************************************************************************
  */
 
+#include <linux/interrupt.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -31,6 +31,7 @@
 #include <linux/if_vlan.h>
 #include <linux/in.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/gfp.h>
 #include <linux/ioport.h>
 #include <linux/ip.h>
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -30,6 +30,7 @@
 #define DRV_VERSION	"2.1"
 #define DRV_RELDATE	"July  6, 2008"
 
+#include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/pci.h>
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -24,6 +24,7 @@
 
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
+#include <linux/interrupt.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
 
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -26,6 +26,7 @@
 #include <linux/delay.h>
 #include <linux/in.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/ioport.h>
 #include <linux/pci.h>
 #include <linux/netdevice.h>
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -29,8 +29,10 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
+#include <linux/hardirq.h>
 #include <linux/module.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/ioport.h>
 #include <linux/eisa.h>
 #include <linux/pci.h>
--- a/drivers/net/tokenring/ibmtr.c
+++ b/drivers/net/tokenring/ibmtr.c
@@ -123,6 +123,7 @@ in the event that chatty debug messages are desired - jjs 12/30/98 */
 /* some 95 OS send many non UI frame; this allow removing the warning */
 #define TR_FILTERNONUI	1
 
+#include <linux/interrupt.h>
 #include <linux/ioport.h>
 #include <linux/netdevice.h>
 #include <linux/ip.h>
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -33,6 +33,7 @@
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/net.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -38,6 +38,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
 #include <linux/ethtool.h>
--- a/drivers/net/tulip/pnic.c
+++ b/drivers/net/tulip/pnic.c
@@ -13,6 +13,7 @@
 	Please submit bugs to http://bugzilla.kernel.org/ .
 */
 
+#include <linux/interrupt.h>
 #include <linux/kernel.h>
 #include <linux/jiffies.h>
 #include "tulip.h"
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -28,6 +28,7 @@
 #include <linux/slab.h>
 #include "tulip.h"
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/etherdevice.h>
 #include <linux/delay.h>
 #include <linux/mii.h>
--- a/drivers/net/vxge/vxge-config.h
+++ b/drivers/net/vxge/vxge-config.h
@@ -13,6 +13,7 @@
  ******************************************************************************/
 #ifndef VXGE_CONFIG_H
 #define VXGE_CONFIG_H
+#include <linux/hardirq.h>
 #include <linux/list.h>
 #include <linux/slab.h>
 
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -44,6 +44,7 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/if_vlan.h>
+#include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/slab.h>
 #include <linux/tcp.h>
--- a/drivers/net/wan/cycx_main.c
+++ b/drivers/net/wan/cycx_main.c
@@ -50,6 +50,7 @@
 #include <linux/wanrouter.h>	/* WAN router definitions */
 #include <linux/cyclomx.h>	/* cyclomx common user API definitions */
 #include <linux/init.h>         /* __init (when not using as a module) */
+#include <linux/interrupt.h>
 
 unsigned int cycx_debug;
 
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -99,6 +99,7 @@
 #include <asm/irq.h>
 
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/string.h>
 
 #include <linux/if_arp.h>
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -25,6 +25,7 @@
 #include <linux/slab.h>
 #include <linux/ioport.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/if.h>
 #include <linux/hdlc.h>
 #include <asm/io.h>
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -22,6 +22,7 @@
 #include <linux/string.h>
 #include <linux/errno.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/ioport.h>
 #include <linux/netdevice.h>
 #include <linux/hdlc.h>
--- a/drivers/net/wireless/adm8211.c
+++ b/drivers/net/wireless/adm8211.c
@@ -16,6 +16,7 @@
  */
 
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/if.h>
 #include <linux/skbuff.h>
 #include <linux/slab.h>
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -19,6 +19,7 @@
 
 #include <linux/etherdevice.h>
 #include <linux/device.h>
+#include <linux/interrupt.h>
 #include <linux/leds.h>
 #include <linux/completion.h>
 
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -40,6 +40,7 @@
 ******************************************************************************/
 
 #include <linux/init.h>
+#include <linux/interrupt.h>
 
 #include <linux/kernel.h>
 #include <linux/ptrace.h>
--- a/drivers/net/wireless/hostap/hostap_wlan.h
+++ b/drivers/net/wireless/hostap/hostap_wlan.h
@@ -1,6 +1,7 @@
 #ifndef HOSTAP_WLAN_H
 #define HOSTAP_WLAN_H
 
+#include <linux/interrupt.h>
 #include <linux/wireless.h>
 #include <linux/netdevice.h>
 #include <linux/mutex.h>
--- a/drivers/net/wireless/ipw2x00/ipw2200.h
+++ b/drivers/net/wireless/ipw2x00/ipw2200.h
@@ -32,6 +32,7 @@
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/mutex.h>
 
 #include <linux/pci.h>
--- a/drivers/net/wireless/ipw2x00/libipw_wx.c
+++ b/drivers/net/wireless/ipw2x00/libipw_wx.c
@@ -30,6 +30,7 @@
 
 ******************************************************************************/
 
+#include <linux/hardirq.h>
 #include <linux/kmod.h>
 #include <linux/slab.h>
 #include <linux/module.h>
--- a/drivers/net/wireless/iwlegacy/iwl-dev.h
+++ b/drivers/net/wireless/iwlegacy/iwl-dev.h
@@ -32,6 +32,7 @@
 #ifndef __iwl_legacy_dev_h__
 #define __iwl_legacy_dev_h__
 
+#include <linux/interrupt.h>
 #include <linux/pci.h> /* for struct pci_device_id */
 #include <linux/kernel.h>
 #include <linux/leds.h>
--- a/drivers/net/wireless/iwlwifi/iwl-dev.h
+++ b/drivers/net/wireless/iwlwifi/iwl-dev.h
@@ -31,6 +31,7 @@
 #ifndef __iwl_dev_h__
 #define __iwl_dev_h__
 
+#include <linux/interrupt.h>
 #include <linux/pci.h> /* for struct pci_device_id */
 #include <linux/kernel.h>
 #include <linux/wait.h>
--- a/drivers/net/wireless/libertas/cfg.c
+++ b/drivers/net/wireless/libertas/cfg.c
@@ -8,6 +8,7 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
+#include <linux/hardirq.h>
 #include <linux/sched.h>
 #include <linux/wait.h>
 #include <linux/slab.h>
--- a/drivers/net/wireless/libertas/cmd.c
+++ b/drivers/net/wireless/libertas/cmd.c
@@ -3,6 +3,7 @@
  * It prepares command and sends it to firmware when it is ready.
  */
 
+#include <linux/hardirq.h>
 #include <linux/kfifo.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
--- a/drivers/net/wireless/libertas/cmdresp.c
+++ b/drivers/net/wireless/libertas/cmdresp.c
@@ -3,6 +3,7 @@
  * responses as well as events generated by firmware.
  */
 
+#include <linux/hardirq.h>
 #include <linux/slab.h>
 #include <linux/delay.h>
 #include <linux/sched.h>
--- a/drivers/net/wireless/libertas/debugfs.c
+++ b/drivers/net/wireless/libertas/debugfs.c
@@ -1,6 +1,7 @@
 #include <linux/dcache.h>
 #include <linux/debugfs.h>
 #include <linux/delay.h>
+#include <linux/hardirq.h>
 #include <linux/mm.h>
 #include <linux/string.h>
 #include <linux/slab.h>
--- a/drivers/net/wireless/libertas/ethtool.c
+++ b/drivers/net/wireless/libertas/ethtool.c
@@ -1,3 +1,4 @@
+#include <linux/hardirq.h>
 #include <linux/netdevice.h>
 #include <linux/ethtool.h>
 #include <linux/delay.h>
--- a/drivers/net/wireless/libertas/if_spi.c
+++ b/drivers/net/wireless/libertas/if_spi.c
@@ -19,6 +19,8 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
+#include <linux/hardirq.h>
+#include <linux/interrupt.h>
 #include <linux/moduleparam.h>
 #include <linux/firmware.h>
 #include <linux/jiffies.h>
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -9,6 +9,7 @@
 #include <linux/moduleparam.h>
 #include <linux/delay.h>
 #include <linux/etherdevice.h>
+#include <linux/hardirq.h>
 #include <linux/netdevice.h>
 #include <linux/if_arp.h>
 #include <linux/kthread.h>
--- a/drivers/net/wireless/libertas/mesh.c
+++ b/drivers/net/wireless/libertas/mesh.c
@@ -2,6 +2,7 @@
 
 #include <linux/delay.h>
 #include <linux/etherdevice.h>
+#include <linux/hardirq.h>
 #include <linux/netdevice.h>
 #include <linux/if_ether.h>
 #include <linux/if_arp.h>
--- a/drivers/net/wireless/libertas/rx.c
+++ b/drivers/net/wireless/libertas/rx.c
@@ -5,6 +5,7 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/etherdevice.h>
+#include <linux/hardirq.h>
 #include <linux/slab.h>
 #include <linux/types.h>
 #include <net/cfg80211.h>
--- a/drivers/net/wireless/libertas/tx.c
+++ b/drivers/net/wireless/libertas/tx.c
@@ -1,6 +1,7 @@
 /*
  * This file contains the handling of TX in wlan driver.
  */
+#include <linux/hardirq.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/sched.h>
--- a/drivers/net/wireless/libertas_tf/cmd.c
+++ b/drivers/net/wireless/libertas_tf/cmd.c
@@ -9,6 +9,7 @@
  */
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
+#include <linux/hardirq.h>
 #include <linux/slab.h>
 
 #include "libertas_tf.h"
--- a/drivers/net/wireless/libertas_tf/main.c
+++ b/drivers/net/wireless/libertas_tf/main.c
@@ -9,6 +9,7 @@
  */
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
+#include <linux/hardirq.h>
 #include <linux/slab.h>
 
 #include <linux/etherdevice.h>
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -10,6 +10,7 @@
  */
 
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
--- a/drivers/net/wireless/p54/p54pci.h
+++ b/drivers/net/wireless/p54/p54pci.h
@@ -1,5 +1,6 @@
 #ifndef P54PCI_H
 #define P54PCI_H
+#include <linux/interrupt.h>
 
 /*
  * Defines for PCI based mac80211 Prism54 driver
--- a/drivers/net/wireless/prism54/islpci_dev.c
+++ b/drivers/net/wireless/prism54/islpci_dev.c
@@ -18,6 +18,7 @@
  *
  */
 
+#include <linux/hardirq.h>
 #include <linux/module.h>
 #include <linux/slab.h>
 
--- a/drivers/net/wireless/prism54/islpci_dev.h
+++ b/drivers/net/wireless/prism54/islpci_dev.h
@@ -22,6 +22,7 @@
 #ifndef _ISLPCI_DEV_H
 #define _ISLPCI_DEV_H
 
+#include <linux/irqreturn.h>
 #include <linux/netdevice.h>
 #include <linux/wireless.h>
 #include <net/iw_handler.h>
--- a/drivers/net/wireless/prism54/islpci_hotplug.c
+++ b/drivers/net/wireless/prism54/islpci_hotplug.c
@@ -17,6 +17,7 @@
  *
  */
 
+#include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
--- a/drivers/net/wireless/rt2x00/rt2x00.h
+++ b/drivers/net/wireless/rt2x00/rt2x00.h
@@ -29,6 +29,7 @@
 #define RT2X00_H
 
 #include <linux/bitops.h>
+#include <linux/interrupt.h>
 #include <linux/skbuff.h>
 #include <linux/workqueue.h>
 #include <linux/firmware.h>
--- a/drivers/net/wireless/rtl818x/rtl8180/dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8180/dev.c
@@ -16,6 +16,7 @@
  */
 
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/slab.h>
 #include <linux/delay.h>
--- a/drivers/net/wireless/wl1251/sdio.c
+++ b/drivers/net/wireless/wl1251/sdio.c
@@ -19,6 +19,7 @@
  * Copyright (C) 2008 Google Inc
  * Copyright (C) 2009 Bob Copeland (me@bobcopeland.com)
  */
+#include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/mod_devicetable.h>
 #include <linux/mmc/sdio_func.h>
--- a/drivers/net/wireless/wl1251/spi.c
+++ b/drivers/net/wireless/wl1251/spi.c
@@ -19,6 +19,7 @@
  *
  */
 
+#include <linux/interrupt.h>
 #include <linux/irq.h>
 #include <linux/module.h>
 #include <linux/slab.h>
--- a/drivers/net/wireless/wl12xx/io.h
+++ b/drivers/net/wireless/wl12xx/io.h
@@ -25,6 +25,7 @@
 #ifndef __IO_H__
 #define __IO_H__
 
+#include <linux/irqreturn.h>
 #include "reg.h"
 
 #define HW_ACCESS_MEMORY_MAX_RANGE	0x1FFC0
--- a/drivers/net/wireless/wl12xx/spi.c
+++ b/drivers/net/wireless/wl12xx/spi.c
@@ -21,6 +21,7 @@
  *
  */
 
+#include <linux/interrupt.h>
 #include <linux/irq.h>
 #include <linux/module.h>
 #include <linux/crc7.h>
--- a/drivers/s390/net/ctcm_mpc.h
+++ b/drivers/s390/net/ctcm_mpc.h
@@ -12,6 +12,7 @@
 #ifndef _CTC_MPC_H_
 #define _CTC_MPC_H_
 
+#include <linux/interrupt.h>
 #include <linux/skbuff.h>
 #include "fsm.h"
 
--- a/include/linux/arcdevice.h
+++ b/include/linux/arcdevice.h
@@ -20,6 +20,7 @@
 #include <linux/if_arcnet.h>
 
 #ifdef __KERNEL__
+#include  <linux/irqreturn.h>
 
 #ifndef bool
 #define bool int
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -236,6 +236,7 @@ enum dccp_packet_dequeueing_policy {
 #ifdef __KERNEL__
 
 #include <linux/in.h>
+#include <linux/interrupt.h>
 #include <linux/ktime.h>
 #include <linux/list.h>
 #include <linux/uio.h>
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1563,7 +1563,6 @@ struct packet_type {
 	struct list_head	list;
 };
 
-#include <linux/interrupt.h>
 #include <linux/notifier.h>
 
 extern rwlock_t				dev_base_lock;		/* Device list lock */
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -25,6 +25,7 @@
 #ifndef __HCI_CORE_H
 #define __HCI_CORE_H
 
+#include <linux/interrupt.h>
 #include <net/bluetooth/hci.h>
 
 /* HCI upper protocols */
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -40,6 +40,7 @@
 #ifndef _SOCK_H
 #define _SOCK_H
 
+#include <linux/hardirq.h>
 #include <linux/kernel.h>
 #include <linux/list.h>
 #include <linux/list_nulls.h>
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -37,6 +37,7 @@
 
 #include <linux/module.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/skbuff.h>
 #include <linux/slab.h>
 #include <linux/atm.h>
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -9,6 +9,7 @@
 
 #include <linux/version.h>
 #include <linux/fs.h>
+#include <linux/hardirq.h>
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -43,6 +43,7 @@
 
 #include <linux/module.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/hrtimer.h>
 #include <linux/list.h>
 #include <linux/proc_fs.h>
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -3,6 +3,7 @@
 
 #include <rdma/ib_verbs.h>
 #include <rdma/rdma_cm.h>
+#include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/slab.h>
 #include "rds.h"
--- a/net/rds/iw.h
+++ b/net/rds/iw.h
@@ -1,6 +1,7 @@
 #ifndef _RDS_IW_H
 #define _RDS_IW_H
 
+#include <linux/interrupt.h>
 #include <rdma/ib_verbs.h>
 #include <rdma/rdma_cm.h>
 #include "rds.h"
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -5,6 +5,7 @@
 #include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/string.h>
 #include <linux/errno.h>
 #include <linux/skbuff.h>
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -42,6 +42,7 @@
 #include <linux/sunrpc/svc_xprt.h>
 #include <linux/sunrpc/debug.h>
 #include <linux/sunrpc/rpc_rdma.h>
+#include <linux/interrupt.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -47,6 +47,7 @@
  *  o buffer memory
  */
 
+#include <linux/interrupt.h>
 #include <linux/pci.h>	/* for Tavor hack below */
 #include <linux/slab.h>
 
