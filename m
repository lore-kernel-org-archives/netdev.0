From: Ralf Baechle <ralf@linux-mips.org>
Subject: [NET] Nuke SET_NETDEV_DEVICE macro
Date: Wed, 12 Sep 2007 17:27:13 +0100
Message-ID: <20070912162713.GA15519@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:56797 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765031AbXILQ1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 12:27:25 -0400
Received: from localhost.localdomain ([127.0.0.1]:59018 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20023543AbXILQ1Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 17:27:16 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's been a useless no-op for long enough in 2.6 so I figured it's time to
remove it.  The number of people that could object because they're
maintaining unified 2.4 and 2.6 drivers is probably rather small.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

---

 drivers/ieee1394/eth1394.c                   |    1 -
 drivers/infiniband/hw/amso1100/c2.c          |    1 -
 drivers/infiniband/hw/amso1100/c2_provider.c |    1 -
 drivers/infiniband/ulp/ipoib/ipoib_main.c    |    2 --
 drivers/message/fusion/mptlan.c              |    2 --
 drivers/net/3c501.c                          |    2 --
 drivers/net/3c503.c                          |    2 --
 drivers/net/3c505.c                          |    2 --
 drivers/net/3c507.c                          |    2 --
 drivers/net/3c509.c                          |    6 ------
 drivers/net/3c515.c                          |    2 --
 drivers/net/3c523.c                          |    1 -
 drivers/net/3c527.c                          |    2 --
 drivers/net/3c59x.c                          |    1 -
 drivers/net/8139cp.c                         |    1 -
 drivers/net/8139too.c                        |    1 -
 drivers/net/82596.c                          |    1 -
 drivers/net/a2065.c                          |    1 -
 drivers/net/ac3200.c                         |    2 --
 drivers/net/acenic.c                         |    1 -
 drivers/net/amd8111e.c                       |    1 -
 drivers/net/apne.c                           |    1 -
 drivers/net/appletalk/cops.c                 |    2 --
 drivers/net/appletalk/ipddp.c                |    1 -
 drivers/net/appletalk/ltpc.c                 |    2 --
 drivers/net/arcnet/com90io.c                 |    2 --
 drivers/net/ariadne.c                        |    1 -
 drivers/net/arm/at91_ether.c                 |    1 -
 drivers/net/arm/ether1.c                     |    1 -
 drivers/net/arm/ether3.c                     |    1 -
 drivers/net/arm/etherh.c                     |    1 -
 drivers/net/at1700.c                         |    2 --
 drivers/net/atarilance.c                     |    1 -
 drivers/net/atl1/atl1_main.c                 |    1 -
 drivers/net/atp.c                            |    1 -
 drivers/net/b44.c                            |    1 -
 drivers/net/bfin_mac.c                       |    1 -
 drivers/net/bmac.c                           |    1 -
 drivers/net/bnx2.c                           |    1 -
 drivers/net/bonding/bond_main.c              |    2 --
 drivers/net/cassini.c                        |    1 -
 drivers/net/chelsio/cxgb2.c                  |    1 -
 drivers/net/cs89x0.c                         |    1 -
 drivers/net/cxgb3/cxgb3_main.c               |    1 -
 drivers/net/de600.c                          |    1 -
 drivers/net/de620.c                          |    2 --
 drivers/net/defxx.c                          |    1 -
 drivers/net/dgrs.c                           |    2 --
 drivers/net/dl2k.c                           |    1 -
 drivers/net/dm9000.c                         |    1 -
 drivers/net/dummy.c                          |    1 -
 drivers/net/e100.c                           |    1 -
 drivers/net/e1000/e1000_main.c               |    1 -
 drivers/net/e2100.c                          |    2 --
 drivers/net/eepro.c                          |    4 ----
 drivers/net/eepro100.c                       |    1 -
 drivers/net/eexpress.c                       |    2 --
 drivers/net/ehea/ehea_main.c                 |    2 --
 drivers/net/epic100.c                        |    1 -
 drivers/net/eql.c                            |    2 --
 drivers/net/es3210.c                         |    2 --
 drivers/net/eth16i.c                         |    2 --
 drivers/net/ewrk3.c                          |    1 -
 drivers/net/fealnx.c                         |    1 -
 drivers/net/fec_8xx/fec_main.c               |    1 -
 drivers/net/forcedeth.c                      |    1 -
 drivers/net/fs_enet/fs_enet-main.c           |    1 -
 drivers/net/gianfar.c                        |    1 -
 drivers/net/hamachi.c                        |    1 -
 drivers/net/hamradio/6pack.c                 |    2 --
 drivers/net/hp-plus.c                        |    2 --
 drivers/net/hp.c                             |    2 --
 drivers/net/hp100.c                          |    5 -----
 drivers/net/hydra.c                          |    1 -
 drivers/net/ibm_emac/ibm_emac_core.c         |    1 -
 drivers/net/ibmlana.c                        |    2 --
 drivers/net/ibmveth.c                        |    4 ----
 drivers/net/ifb.c                            |    1 -
 drivers/net/ioc3-eth.c                       |    1 -
 drivers/net/irda/ali-ircc.c                  |    4 ----
 drivers/net/irda/donauboe.c                  |    1 -
 drivers/net/irda/irda-usb.c                  |    1 -
 drivers/net/irda/irport.c                    |    2 --
 drivers/net/irda/kingsun-sir.c               |    1 -
 drivers/net/irda/mcs7780.c                   |    2 --
 drivers/net/irda/nsc-ircc.c                  |    1 -
 drivers/net/irda/sir_dev.c                   |    2 --
 drivers/net/irda/smsc-ircc2.c                |    2 --
 drivers/net/irda/stir4200.c                  |    1 -
 drivers/net/irda/via-ircc.c                  |    3 ---
 drivers/net/irda/vlsi_ir.c                   |    2 --
 drivers/net/irda/w83977af_ir.c               |    3 ---
 drivers/net/isa-skeleton.c                   |    2 --
 drivers/net/ixgb/ixgb_main.c                 |    1 -
 drivers/net/ixp2000/enp2611.c                |    1 -
 drivers/net/jazzsonic.c                      |    1 -
 drivers/net/lance.c                          |    1 -
 drivers/net/lguest_net.c                     |    2 --
 drivers/net/lne390.c                         |    2 --
 drivers/net/mac8390.c                        |    2 --
 drivers/net/mac89x0.c                        |    2 --
 drivers/net/macb.c                           |    1 -
 drivers/net/mace.c                           |    1 -
 drivers/net/macmace.c                        |    1 -
 drivers/net/macsonic.c                       |    1 -
 drivers/net/mv643xx_eth.c                    |    1 -
 drivers/net/mvme147.c                        |    2 --
 drivers/net/myri_sbus.c                      |    1 -
 drivers/net/natsemi.c                        |    1 -
 drivers/net/ne-h8300.c                       |    2 --
 drivers/net/ne.c                             |    2 --
 drivers/net/ne2.c                            |    2 --
 drivers/net/ne2k-pci.c                       |    1 -
 drivers/net/ne3210.c                         |    1 -
 drivers/net/netx-eth.c                       |    1 -
 drivers/net/netxen/netxen_nic_main.c         |    1 -
 drivers/net/ni5010.c                         |    2 --
 drivers/net/ni52.c                           |    2 --
 drivers/net/ni65.c                           |    1 -
 drivers/net/ns83820.c                        |    1 -
 drivers/net/pasemi_mac.c                     |    1 -
 drivers/net/pci-skeleton.c                   |    1 -
 drivers/net/pcmcia/3c589_cs.c                |    1 -
 drivers/net/pcmcia/axnet_cs.c                |    3 ---
 drivers/net/pcmcia/fmvj18x_cs.c              |    1 -
 drivers/net/pcmcia/nmclan_cs.c               |    1 -
 drivers/net/pcmcia/pcnet_cs.c                |    1 -
 drivers/net/pcmcia/smc91c92_cs.c             |    1 -
 drivers/net/pcmcia/xirc2ps_cs.c              |    1 -
 drivers/net/pcnet32.c                        |    1 -
 drivers/net/plip.c                           |    1 -
 drivers/net/ps3_gelic_net.c                  |    1 -
 drivers/net/qla3xxx.c                        |    1 -
 drivers/net/r8169.c                          |    1 -
 drivers/net/rionet.c                         |    2 --
 drivers/net/rrunner.c                        |    1 -
 drivers/net/s2io.c                           |    1 -
 drivers/net/sb1000.c                         |    1 -
 drivers/net/shaper.c                         |    2 --
 drivers/net/sis190.c                         |    1 -
 drivers/net/sis900.c                         |    1 -
 drivers/net/skfp/skfddi.c                    |    1 -
 drivers/net/skge.c                           |    1 -
 drivers/net/sky2.c                           |    1 -
 drivers/net/slip.c                           |    2 --
 drivers/net/smc-mca.c                        |    1 -
 drivers/net/smc-ultra.c                      |    2 --
 drivers/net/smc-ultra32.c                    |    2 --
 drivers/net/smc911x.c                        |    1 -
 drivers/net/smc9194.c                        |    2 --
 drivers/net/smc91x.c                         |    1 -
 drivers/net/spider_net.c                     |    1 -
 drivers/net/starfire.c                       |    1 -
 drivers/net/stnic.c                          |    1 -
 drivers/net/sun3_82586.c                     |    1 -
 drivers/net/sun3lance.c                      |    1 -
 drivers/net/sunbmac.c                        |    1 -
 drivers/net/sundance.c                       |    1 -
 drivers/net/sungem.c                         |    1 -
 drivers/net/sunhme.c                         |    2 --
 drivers/net/sunlance.c                       |    1 -
 drivers/net/sunqe.c                          |    1 -
 drivers/net/tc35815.c                        |    1 -
 drivers/net/tg3.c                            |    1 -
 drivers/net/tlan.c                           |    1 -
 drivers/net/tokenring/3c359.c                |    1 -
 drivers/net/tokenring/abyss.c                |    2 --
 drivers/net/tokenring/lanstreamer.c          |    1 -
 drivers/net/tokenring/madgemc.c              |    1 -
 drivers/net/tokenring/olympic.c              |    1 -
 drivers/net/tokenring/proteon.c              |    1 -
 drivers/net/tokenring/skisa.c                |    1 -
 drivers/net/tokenring/smctr.c                |    2 --
 drivers/net/tokenring/tmspci.c               |    1 -
 drivers/net/tsi108_eth.c                     |    1 -
 drivers/net/tulip/de2104x.c                  |    1 -
 drivers/net/tulip/de4x5.c                    |    1 -
 drivers/net/tulip/dmfe.c                     |    1 -
 drivers/net/tulip/tulip_core.c               |    1 -
 drivers/net/tulip/uli526x.c                  |    1 -
 drivers/net/tulip/winbond-840.c              |    1 -
 drivers/net/tulip/xircom_cb.c                |    1 -
 drivers/net/tulip/xircom_tulip_cb.c          |    1 -
 drivers/net/tun.c                            |    1 -
 drivers/net/typhoon.c                        |    1 -
 drivers/net/ucc_geth.c                       |    1 -
 drivers/net/usb/kaweth.c                     |    2 --
 drivers/net/usb/pegasus.c                    |    1 -
 drivers/net/usb/rtl8150.c                    |    1 -
 drivers/net/usb/usbnet.c                     |    1 -
 drivers/net/via-rhine.c                      |    1 -
 drivers/net/via-velocity.c                   |    1 -
 drivers/net/wan/c101.c                       |    1 -
 drivers/net/wan/cycx_x25.c                   |    1 -
 drivers/net/wan/dscc4.c                      |    1 -
 drivers/net/wan/hostess_sv11.c               |    2 --
 drivers/net/wan/lapbether.c                  |    1 -
 drivers/net/wan/lmc/lmc_main.c               |    1 -
 drivers/net/wan/n2.c                         |    1 -
 drivers/net/wan/pc300too.c                   |    1 -
 drivers/net/wan/pci200syn.c                  |    1 -
 drivers/net/wan/sbni.c                       |    2 --
 drivers/net/wan/sdla.c                       |    1 -
 drivers/net/wan/wanxl.c                      |    1 -
 drivers/net/wd.c                             |    2 --
 drivers/net/wireless/airo.c                  |    1 -
 drivers/net/wireless/airport.c               |    1 -
 drivers/net/wireless/arlan-main.c            |    2 --
 drivers/net/wireless/atmel.c                 |    1 -
 drivers/net/wireless/bcm43xx/bcm43xx_main.c  |    1 -
 drivers/net/wireless/ipw2100.c               |    2 --
 drivers/net/wireless/ipw2200.c               |    1 -
 drivers/net/wireless/libertas/main.c         |    4 ----
 drivers/net/wireless/netwave_cs.c            |    1 -
 drivers/net/wireless/orinoco_cs.c            |    1 -
 drivers/net/wireless/orinoco_nortel.c        |    1 -
 drivers/net/wireless/orinoco_pci.c           |    1 -
 drivers/net/wireless/orinoco_plx.c           |    1 -
 drivers/net/wireless/orinoco_tmd.c           |    1 -
 drivers/net/wireless/prism54/islpci_dev.c    |    1 -
 drivers/net/wireless/ray_cs.c                |    1 -
 drivers/net/wireless/spectrum_cs.c           |    1 -
 drivers/net/wireless/strip.c                 |    2 --
 drivers/net/wireless/wavelan.c               |    1 -
 drivers/net/wireless/wavelan_cs.c            |    1 -
 drivers/net/wireless/wl3501_cs.c             |    2 --
 drivers/net/wireless/zd1211rw/zd_netdev.c    |    1 -
 drivers/net/xen-netfront.c                   |    1 -
 drivers/net/yellowfin.c                      |    1 -
 drivers/net/znet.c                           |    2 --
 drivers/net/zorro8390.c                      |    1 -
 drivers/s390/net/claw.c                      |    1 -
 drivers/s390/net/ctcmain.c                   |    1 -
 drivers/s390/net/lcs.c                       |    1 -
 drivers/s390/net/netiucv.c                   |    1 -
 drivers/s390/net/qeth_main.c                 |    1 -
 drivers/usb/gadget/ether.c                   |    1 -
 include/linux/netdevice.h                    |    1 -
 net/8021q/vlan.c                             |    2 --
 net/bridge/br_device.c                       |    1 -
 net/ipv4/ip_gre.c                            |    1 -
 net/ipv4/ipip.c                              |    2 --
 net/ipv6/ip6_tunnel.c                        |    1 -
 net/ipv6/sit.c                               |    1 -
 net/irda/irlan/irlan_eth.c                   |    2 --
 net/sched/sch_teql.c                         |    1 -
 246 files changed, 336 deletions(-)

diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index 3b807b4..a88dbd7 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -13,7 +13,7 @@ config ZONE_DMA
 
 choice
 	prompt "System type"
-	default SGI_IP22
+	default MIPS_MALTA
 
 config MACH_ALCHEMY
 	bool "Alchemy processor based machines"
diff --git a/drivers/ieee1394/eth1394.c b/drivers/ieee1394/eth1394.c
index 3a9d7e2..33b8081 100644
--- a/drivers/ieee1394/eth1394.c
+++ b/drivers/ieee1394/eth1394.c
@@ -598,7 +598,6 @@ static void ether1394_add_host(struct hpsb_host *host)
 		goto out;
 	}
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &host->device);
 
 	priv = netdev_priv(dev);
diff --git a/drivers/infiniband/hw/amso1100/c2.c b/drivers/infiniband/hw/amso1100/c2.c
index 0aecea6..f283a9f 100644
--- a/drivers/infiniband/hw/amso1100/c2.c
+++ b/drivers/infiniband/hw/amso1100/c2.c
@@ -886,7 +886,6 @@ static struct net_device *c2_devinit(struct c2_dev *c2dev,
 		return NULL;
 	}
 
-	SET_MODULE_OWNER(netdev);
 	SET_NETDEV_DEV(netdev, &c2dev->pcidev->dev);
 
 	netdev->open = c2_up;
diff --git a/drivers/infiniband/hw/amso1100/c2_provider.c b/drivers/infiniband/hw/amso1100/c2_provider.c
index 997cf15..7a6cece 100644
--- a/drivers/infiniband/hw/amso1100/c2_provider.c
+++ b/drivers/infiniband/hw/amso1100/c2_provider.c
@@ -715,7 +715,6 @@ static int c2_pseudo_change_mtu(struct net_device *netdev, int new_mtu)
 
 static void setup(struct net_device *netdev)
 {
-	SET_MODULE_OWNER(netdev);
 	netdev->open = c2_pseudo_up;
 	netdev->stop = c2_pseudo_down;
 	netdev->hard_start_xmit = c2_pseudo_xmit_frame;
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 894b1dc..d3bca04 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -973,8 +973,6 @@ static void ipoib_setup(struct net_device *dev)
 
 	netif_carrier_off(dev);
 
-	SET_MODULE_OWNER(dev);
-
 	priv->dev = dev;
 
 	spin_lock_init(&priv->lock);
diff --git a/drivers/message/fusion/mptlan.c b/drivers/message/fusion/mptlan.c
index 01fc397..3da4c37 100644
--- a/drivers/message/fusion/mptlan.c
+++ b/drivers/message/fusion/mptlan.c
@@ -1427,8 +1427,6 @@ mpt_register_lan_device (MPT_ADAPTER *mpt_dev, int pnum)
 	dlprintk((KERN_INFO MYNAM ": Finished registering dev "
 		"and setting initial values\n"));
 
-	SET_MODULE_OWNER(dev);
-
 	if (register_netdev(dev) != 0) {
 		free_netdev(dev);
 		dev = NULL;
diff --git a/drivers/net/3c501.c b/drivers/net/3c501.c
index 4bee99b..98e0bc4 100644
--- a/drivers/net/3c501.c
+++ b/drivers/net/3c501.c
@@ -174,8 +174,6 @@ struct net_device * __init el1_probe(int unit)
 		mem_start = dev->mem_start & 7;
 	}
 
-	SET_MODULE_OWNER(dev);
-
 	if (io > 0x1ff) {	/* Check a single specified location. */
 		err = el1_probe1(dev, io);
 	} else if (io != 0) {
diff --git a/drivers/net/3c503.c b/drivers/net/3c503.c
index bc7e906..f9e7ffb 100644
--- a/drivers/net/3c503.c
+++ b/drivers/net/3c503.c
@@ -95,8 +95,6 @@ static int __init do_el2_probe(struct net_device *dev)
     int base_addr = dev->base_addr;
     int irq = dev->irq;
 
-    SET_MODULE_OWNER(dev);
-
     if (base_addr > 0x1ff)	/* Check a single specified location. */
 	return el2_probe1(dev, base_addr);
     else if (base_addr != 0)		/* Don't probe at all. */
diff --git a/drivers/net/3c505.c b/drivers/net/3c505.c
index e985a85..feefbec 100644
--- a/drivers/net/3c505.c
+++ b/drivers/net/3c505.c
@@ -1402,8 +1402,6 @@ static int __init elplus_setup(struct net_device *dev)
 	unsigned long cookie = 0;
 	int err = -ENODEV;
 
-	SET_MODULE_OWNER(dev);
-
 	/*
 	 *  setup adapter structure
 	 */
diff --git a/drivers/net/3c507.c b/drivers/net/3c507.c
index eed4299..fac6edf 100644
--- a/drivers/net/3c507.c
+++ b/drivers/net/3c507.c
@@ -327,8 +327,6 @@ struct net_device * __init el16_probe(int unit)
 		mem_start = dev->mem_start & 15;
 	}
 
-	SET_MODULE_OWNER(dev);
-
 	if (io > 0x1ff) 	/* Check a single specified location. */
 		err = el16_probe1(dev, io);
 	else if (io != 0)
diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
index 127f608..7466987 100644
--- a/drivers/net/3c509.c
+++ b/drivers/net/3c509.c
@@ -432,7 +432,6 @@ __again:
 					return -ENOMEM;
 			}
 
-			SET_MODULE_OWNER(dev);
 			SET_NETDEV_DEV(dev, &idev->dev);
 			pnp_cards++;
 
@@ -524,8 +523,6 @@ no_pnp:
 	if (!dev)
 		return -ENOMEM;
 
-	SET_MODULE_OWNER(dev);
-
 	netdev_boot_setup_check(dev);
 
 	/* Set passed-in IRQ or I/O Addr. */
@@ -644,7 +641,6 @@ static int __init el3_mca_probe(struct device *device)
 			return -ENOMEM;
 	}
 
-	SET_MODULE_OWNER(dev);
 	netdev_boot_setup_check(dev);
 
 	memcpy(dev->dev_addr, phys_addr, sizeof(phys_addr));
@@ -704,8 +700,6 @@ static int __init el3_eisa_probe (struct device *device)
 		return -ENOMEM;
 	}
 
-	SET_MODULE_OWNER(dev);
-
 	netdev_boot_setup_check(dev);
 
 	memcpy(dev->dev_addr, phys_addr, sizeof(phys_addr));
diff --git a/drivers/net/3c515.c b/drivers/net/3c515.c
index 290166d..38a2ebe 100644
--- a/drivers/net/3c515.c
+++ b/drivers/net/3c515.c
@@ -501,8 +501,6 @@ static struct net_device *corkscrew_scan(int unit)
 		netdev_boot_setup_check(dev);
 	}
 
-	SET_MODULE_OWNER(dev);
-
 #ifdef __ISAPNP__
 	if(nopnp == 1)
 		goto no_pnp;
diff --git a/drivers/net/3c523.c b/drivers/net/3c523.c
index ab18343..10852b2 100644
--- a/drivers/net/3c523.c
+++ b/drivers/net/3c523.c
@@ -423,7 +423,6 @@ static int __init do_elmc_probe(struct net_device *dev)
 	int retval;
 	struct priv *pr = dev->priv;
 
-	SET_MODULE_OWNER(dev);
 	if (MCA_bus == 0) {
 		return -ENODEV;
 	}
diff --git a/drivers/net/3c527.c b/drivers/net/3c527.c
index c7b571b..5b5f44c 100644
--- a/drivers/net/3c527.c
+++ b/drivers/net/3c527.c
@@ -257,8 +257,6 @@ struct net_device *__init mc32_probe(int unit)
 	if (unit >= 0)
 		sprintf(dev->name, "eth%d", unit);
 
-	SET_MODULE_OWNER(dev);
-
 	/* Do not check any supplied i/o locations.
 	   POS registers usually don't fail :) */
 
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index a8c0f43..9df0b0b 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -1033,7 +1033,6 @@ static int __devinit vortex_probe1(struct device *gendev,
 		printk (KERN_ERR PFX "unable to allocate etherdev, aborting\n");
 		goto out;
 	}
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, gendev);
 	vp = netdev_priv(dev);
 
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index a79f28c..c4c2be5 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -1840,7 +1840,6 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev = alloc_etherdev(sizeof(struct cp_private));
 	if (!dev)
 		return -ENOMEM;
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	cp = netdev_priv(dev);
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index f4e4298..aa214cf 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -770,7 +770,6 @@ static int __devinit rtl8139_init_board (struct pci_dev *pdev,
 		dev_err(&pdev->dev, "Unable to alloc new net device\n");
 		return -ENOMEM;
 	}
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	tp = netdev_priv(dev);
diff --git a/drivers/net/82596.c b/drivers/net/82596.c
index d915837..43dffdc 100644
--- a/drivers/net/82596.c
+++ b/drivers/net/82596.c
@@ -1234,7 +1234,6 @@ struct net_device * __init i82596_probe(int unit)
 	DEB(DEB_PROBE,printk(KERN_INFO "%s", version));
 
 	/* The 82596-specific entries in the device structure. */
-	SET_MODULE_OWNER(dev);
 	dev->open = i596_open;
 	dev->stop = i596_close;
 	dev->hard_start_xmit = i596_start_xmit;
diff --git a/drivers/net/a2065.c b/drivers/net/a2065.c
index a45de69..fa0c6cb 100644
--- a/drivers/net/a2065.c
+++ b/drivers/net/a2065.c
@@ -746,7 +746,6 @@ static int __devinit a2065_init_one(struct zorro_dev *z,
 		return -ENOMEM;
 	}
 
-	SET_MODULE_OWNER(dev);
 	priv = netdev_priv(dev);
 
 	r1->name = dev->name;
diff --git a/drivers/net/ac3200.c b/drivers/net/ac3200.c
index 644c408..65b2de5 100644
--- a/drivers/net/ac3200.c
+++ b/drivers/net/ac3200.c
@@ -103,8 +103,6 @@ static int __init do_ac3200_probe(struct net_device *dev)
 	int irq = dev->irq;
 	int mem_start = dev->mem_start;
 
-	SET_MODULE_OWNER(dev);
-
 	if (ioaddr > 0x1ff)		/* Check a single specified location. */
 		return ac_probe1(ioaddr, dev);
 	else if (ioaddr > 0)		/* Don't probe at all. */
diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index 62e660a..ca00f41 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -465,7 +465,6 @@ static int __devinit acenic_probe_one(struct pci_dev *pdev,
 		return -ENOMEM;
 	}
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	ap = dev->priv;
diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index a61b2f8..a2f5687 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -1983,7 +1983,6 @@ static int __devinit amd8111e_probe_one(struct pci_dev *pdev,
 		goto err_free_reg;
 	}
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 #if AMD8111E_VLAN_TAG_USED
diff --git a/drivers/net/apne.c b/drivers/net/apne.c
index 9541911..b073810 100644
--- a/drivers/net/apne.c
+++ b/drivers/net/apne.c
@@ -148,7 +148,6 @@ struct net_device * __init apne_probe(int unit)
 		sprintf(dev->name, "eth%d", unit);
 		netdev_boot_setup_check(dev);
 	}
-	SET_MODULE_OWNER(dev);
 
 	/* disable pcmcia irq for readtuple */
 	pcmcia_disable_irq();
diff --git a/drivers/net/appletalk/cops.c b/drivers/net/appletalk/cops.c
index da6ffa8..c4b560d 100644
--- a/drivers/net/appletalk/cops.c
+++ b/drivers/net/appletalk/cops.c
@@ -235,8 +235,6 @@ struct net_device * __init cops_probe(int unit)
 		base_addr = dev->base_addr = io;
 	}
 
-	SET_MODULE_OWNER(dev);
-
 	if (base_addr > 0x1ff) {    /* Check a single specified location. */
 		err = cops_probe1(dev, base_addr);
 	} else if (base_addr != 0) { /* Don't probe at all. */
diff --git a/drivers/net/appletalk/ipddp.c b/drivers/net/appletalk/ipddp.c
index f22e46d..56cb967 100644
--- a/drivers/net/appletalk/ipddp.c
+++ b/drivers/net/appletalk/ipddp.c
@@ -65,7 +65,6 @@ static struct net_device * __init ipddp_init(void)
 	if (!dev)
 		return ERR_PTR(-ENOMEM);
 
-	SET_MODULE_OWNER(dev);
 	strcpy(dev->name, "ipddp%d");
 
 	if (version_printed++ == 0)
diff --git a/drivers/net/appletalk/ltpc.c b/drivers/net/appletalk/ltpc.c
index 6a6cbd3..cb4744e 100644
--- a/drivers/net/appletalk/ltpc.c
+++ b/drivers/net/appletalk/ltpc.c
@@ -1046,8 +1046,6 @@ struct net_device * __init ltpc_probe(void)
 	if (!dev)
 		goto out;
 
-	SET_MODULE_OWNER(dev);
-
 	/* probe for the I/O port address */
 	
 	if (io != 0x240 && request_region(0x220,8,"ltpc")) {
diff --git a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
index 1f03027..6599f10 100644
--- a/drivers/net/arcnet/com90io.c
+++ b/drivers/net/arcnet/com90io.c
@@ -398,8 +398,6 @@ static int __init com90io_init(void)
 	if (!dev)
 		return -ENOMEM;
 
-	SET_MODULE_OWNER(dev);
-
 	dev->base_addr = io;
 	dev->irq = irq;
 	if (dev->irq == 2)
diff --git a/drivers/net/ariadne.c b/drivers/net/ariadne.c
index bc5a38a..2c020a3 100644
--- a/drivers/net/ariadne.c
+++ b/drivers/net/ariadne.c
@@ -183,7 +183,6 @@ static int __devinit ariadne_init_one(struct zorro_dev *z,
 	return -ENOMEM;
     }
 
-    SET_MODULE_OWNER(dev);
     priv = netdev_priv(dev);
 
     r1->name = dev->name;
diff --git a/drivers/net/arm/at91_ether.c b/drivers/net/arm/at91_ether.c
index ef2cc80..619810a 100644
--- a/drivers/net/arm/at91_ether.c
+++ b/drivers/net/arm/at91_ether.c
@@ -986,7 +986,6 @@ static int __init at91ether_setup(unsigned long phy_type, unsigned short phy_add
 
 	dev->base_addr = AT91_VA_BASE_EMAC;
 	dev->irq = AT91RM9200_ID_EMAC;
-	SET_MODULE_OWNER(dev);
 
 	/* Install the interrupt handler */
 	if (request_irq(dev->irq, at91ether_interrupt, 0, dev->name, dev)) {
diff --git a/drivers/net/arm/ether1.c b/drivers/net/arm/ether1.c
index 80f33b6..6ec8a58 100644
--- a/drivers/net/arm/ether1.c
+++ b/drivers/net/arm/ether1.c
@@ -1009,7 +1009,6 @@ ether1_probe(struct expansion_card *ec, const struct ecard_id *id)
 		goto release;
 	}
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &ec->dev);
 
 	dev->irq = ec->irq;
diff --git a/drivers/net/arm/ether3.c b/drivers/net/arm/ether3.c
index 3805506..4a91474 100644
--- a/drivers/net/arm/ether3.c
+++ b/drivers/net/arm/ether3.c
@@ -789,7 +789,6 @@ ether3_probe(struct expansion_card *ec, const struct ecard_id *id)
 		goto release;
 	}
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &ec->dev);
 
 	priv(dev)->base = ecardm_iomap(ec, ECARD_RES_MEMC, 0, 0);
diff --git a/drivers/net/arm/etherh.c b/drivers/net/arm/etherh.c
index 0d37d9d..5d093b3 100644
--- a/drivers/net/arm/etherh.c
+++ b/drivers/net/arm/etherh.c
@@ -661,7 +661,6 @@ etherh_probe(struct expansion_card *ec, const struct ecard_id *id)
 		goto release;
 	}
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &ec->dev);
 
 	dev->open		= etherh_open;
diff --git a/drivers/net/at1700.c b/drivers/net/at1700.c
index bed8e0e..d20148e 100644
--- a/drivers/net/at1700.c
+++ b/drivers/net/at1700.c
@@ -225,8 +225,6 @@ struct net_device * __init at1700_probe(int unit)
 		dev->irq = irq;
 	}
 
-	SET_MODULE_OWNER(dev);
-
 	if (io > 0x1ff) {	/* Check a single specified location. */
 		err = at1700_probe1(dev, io);
 	} else if (io != 0) {	/* Don't probe at all. */
diff --git a/drivers/net/atarilance.c b/drivers/net/atarilance.c
index dfa8b9b..97cca50 100644
--- a/drivers/net/atarilance.c
+++ b/drivers/net/atarilance.c
@@ -390,7 +390,6 @@ struct net_device * __init atarilance_probe(int unit)
 		sprintf(dev->name, "eth%d", unit);
 		netdev_boot_setup_check(dev);
 	}
-	SET_MODULE_OWNER(dev);
 
 	for( i = 0; i < N_LANCE_ADDR; ++i ) {
 		if (lance_probe1( dev, &lance_addr_list[i] )) {
diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 3c1984e..cc73ced 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -2236,7 +2236,6 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 		err = -ENOMEM;
 		goto err_alloc_etherdev;
 	}
-	SET_MODULE_OWNER(netdev);
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
 	pci_set_drvdata(pdev, netdev);
diff --git a/drivers/net/atp.c b/drivers/net/atp.c
index 82d78ff..6020d5e 100644
--- a/drivers/net/atp.c
+++ b/drivers/net/atp.c
@@ -299,7 +299,6 @@ static int __init atp_probe1(long ioaddr)
 	dev = alloc_etherdev(sizeof(struct net_local));
 	if (!dev)
 		return -ENOMEM;
-	SET_MODULE_OWNER(dev);
 
 	/* Find the IRQ used by triggering an interrupt. */
 	write_reg_byte(ioaddr, CMR2, 0x01);			/* No accept mode, IRQ out. */
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 0795df2..c33261a 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -2162,7 +2162,6 @@ static int __devinit b44_init_one(struct pci_dev *pdev,
 		goto err_out_free_res;
 	}
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev,&pdev->dev);
 
 	/* No interesting netdevice features in this card... */
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 2bb97d4..7f5f4b4 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -946,7 +946,6 @@ static int bfin_mac_probe(struct platform_device *pdev)
 		return -ENOMEM;
 	}
 
-	SET_MODULE_OWNER(ndev);
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
 	platform_set_drvdata(pdev, ndev);
diff --git a/drivers/net/bmac.c b/drivers/net/bmac.c
index 9b8d7d9..3008d9b 100644
--- a/drivers/net/bmac.c
+++ b/drivers/net/bmac.c
@@ -1279,7 +1279,6 @@ static int __devinit bmac_probe(struct macio_dev *mdev, const struct of_device_i
 	}
 
 	bp = netdev_priv(dev);
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &mdev->ofdev.dev);
 	macio_set_drvdata(mdev, dev);
 
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 854d80c..9787611 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6476,7 +6476,6 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	u32 reg;
 	u64 dma_mask, persist_dma_mask;
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	bp = netdev_priv(dev);
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1afda32..80b4ef5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4667,8 +4667,6 @@ int bond_create(char *name, struct bond_params *params, struct bonding **newbond
 		goto out_netdev;
 	}
 
-	SET_MODULE_OWNER(bond_dev);
-
 	res = register_netdevice(bond_dev);
 	if (res < 0) {
 		goto out_bond;
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index f6e4030..14c8cd9 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -4899,7 +4899,6 @@ static int __devinit cas_init_one(struct pci_dev *pdev,
 		err = -ENOMEM;
 		goto err_out_disable_pdev;
 	}
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	err = pci_request_regions(pdev, dev->name);
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index 231ce43..e3e2b18 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -1032,7 +1032,6 @@ static int __devinit init_one(struct pci_dev *pdev,
 			goto out_free_dev;
 		}
 
-		SET_MODULE_OWNER(netdev);
 		SET_NETDEV_DEV(netdev, &pdev->dev);
 
 		if (!adapter) {
diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
index 9774bb1..2b4c921 100644
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -517,7 +517,6 @@ cs89x0_probe1(struct net_device *dev, int ioaddr, int modular)
 	int eeprom_buff[CHKSUM_LEN];
 	int retval;
 
-	SET_MODULE_OWNER(dev);
 	/* Initialize the device structure. */
 	if (!modular) {
 		memset(lp, 0, sizeof(*lp));
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 5ab319c..0037f70 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2490,7 +2490,6 @@ static int __devinit init_one(struct pci_dev *pdev,
 			goto out_free_dev;
 		}
 
-		SET_MODULE_OWNER(netdev);
 		SET_NETDEV_DEV(netdev, &pdev->dev);
 
 		adapter->port[i] = netdev;
diff --git a/drivers/net/de600.c b/drivers/net/de600.c
index dae97b8..5dd0d9c 100644
--- a/drivers/net/de600.c
+++ b/drivers/net/de600.c
@@ -394,7 +394,6 @@ static struct net_device * __init de600_probe(void)
 	if (!dev)
 		return ERR_PTR(-ENOMEM);
 
-	SET_MODULE_OWNER(dev);
 
 	if (!request_region(DE600_IO, 3, "de600")) {
 		printk(KERN_WARNING "DE600: port 0x%x busy\n", DE600_IO);
diff --git a/drivers/net/de620.c b/drivers/net/de620.c
index dc48924..a92c207 100644
--- a/drivers/net/de620.c
+++ b/drivers/net/de620.c
@@ -823,8 +823,6 @@ struct net_device * __init de620_probe(int unit)
 	if (!dev)
 		goto out;
 
-	SET_MODULE_OWNER(dev);
-
 	spin_lock_init(&de620_lock);
 
 	/*
diff --git a/drivers/net/defxx.c b/drivers/net/defxx.c
index 9c8e3f9..b07613e 100644
--- a/drivers/net/defxx.c
+++ b/drivers/net/defxx.c
@@ -539,7 +539,6 @@ static int __devinit dfx_register(struct device *bdev)
 		goto err_out;
 	}
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, bdev);
 
 	bp = netdev_priv(dev);
diff --git a/drivers/net/dgrs.c b/drivers/net/dgrs.c
index df62c02..ddedb76 100644
--- a/drivers/net/dgrs.c
+++ b/drivers/net/dgrs.c
@@ -1272,7 +1272,6 @@ dgrs_found_device(
 	priv->chan = 1;
 	priv->devtbl[0] = dev;
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, pdev);
 
 	ret = dgrs_probe1(dev);
@@ -1320,7 +1319,6 @@ dgrs_found_device(
 		if (ret)
 			goto fail;
 
-		SET_MODULE_OWNER(devN);
 		SET_NETDEV_DEV(dev, pdev);
 
 		ret = register_netdev(devN);
diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index 04e3710..df65139 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -116,7 +116,6 @@ rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
 		err = -ENOMEM;
 		goto err_out_res;
 	}
-	SET_MODULE_OWNER (dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 #ifdef MEM_MAPPING
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 738aa59..857eb36 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -416,7 +416,6 @@ dm9000_probe(struct platform_device *pdev)
 		return -ENOMEM;
 	}
 
-	SET_MODULE_OWNER(ndev);
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
 	PRINTK2("dm9000_probe()");
diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 756a6bc..84e14f3 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -71,7 +71,6 @@ static void dummy_setup(struct net_device *dev)
 	dev->change_mtu = NULL;
 	dev->flags |= IFF_NOARP;
 	dev->flags &= ~IFF_MULTICAST;
-	SET_MODULE_OWNER(dev);
 	random_ether_addr(dev->dev_addr);
 }
 
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 280313b..1f7136e 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2607,7 +2607,6 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 		goto err_out_free_res;
 	}
 
-	SET_MODULE_OWNER(netdev);
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
 	if (use_io)
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 4a22595..01732c9 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -896,7 +896,6 @@ e1000_probe(struct pci_dev *pdev,
 	if (!netdev)
 		goto err_alloc_etherdev;
 
-	SET_MODULE_OWNER(netdev);
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
 	pci_set_drvdata(pdev, netdev);
diff --git a/drivers/net/e2100.c b/drivers/net/e2100.c
index b2b0a96..6390f51 100644
--- a/drivers/net/e2100.c
+++ b/drivers/net/e2100.c
@@ -124,8 +124,6 @@ static int  __init do_e2100_probe(struct net_device *dev)
 	int base_addr = dev->base_addr;
 	int irq = dev->irq;
 
-	SET_MODULE_OWNER(dev);
-
 	if (base_addr > 0x1ff)		/* Check a single specified location. */
 		return e21_probe1(dev, base_addr);
 	else if (base_addr != 0)	/* Don't probe at all. */
diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
index 4768023..6eb84f1 100644
--- a/drivers/net/eepro.c
+++ b/drivers/net/eepro.c
@@ -537,8 +537,6 @@ static int __init do_eepro_probe(struct net_device *dev)
 	int base_addr = dev->base_addr;
 	int irq = dev->irq;
 
-	SET_MODULE_OWNER(dev);
-
 #ifdef PnPWakeup
 	/* XXXX for multiple cards should this only be run once? */
 
@@ -594,8 +592,6 @@ struct net_device * __init eepro_probe(int unit)
 	if (!dev)
 		return ERR_PTR(-ENODEV);
 
-	SET_MODULE_OWNER(dev);
-
 	sprintf(dev->name, "eth%d", unit);
 	netdev_boot_setup_check(dev);
 
diff --git a/drivers/net/eepro100.c b/drivers/net/eepro100.c
index 3c54014..f8b69ce 100644
--- a/drivers/net/eepro100.c
+++ b/drivers/net/eepro100.c
@@ -635,7 +635,6 @@ static int __devinit speedo_found1(struct pci_dev *pdev,
 		return -1;
 	}
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	if (dev->mem_start > 0)
diff --git a/drivers/net/eexpress.c b/drivers/net/eexpress.c
index 7934ea3..6c91bfa 100644
--- a/drivers/net/eexpress.c
+++ b/drivers/net/eexpress.c
@@ -341,8 +341,6 @@ static int __init do_express_probe(struct net_device *dev)
 	int dev_irq = dev->irq;
 	int err;
 
-	SET_MODULE_OWNER(dev);
-
 	dev->if_port = 0xff; /* not set */
 
 #ifdef CONFIG_MCA_LEGACY
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index db57474..53f9d39 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -2627,8 +2627,6 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 	SET_NETDEV_DEV(dev, port_dev);
 
 	/* initialize net_device structure */
-	SET_MODULE_OWNER(dev);
-
 	memcpy(dev->dev_addr, &port->mac_addr, ETH_ALEN);
 
 	dev->open = ehea_open;
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 1197784..5c54a44 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -351,7 +351,6 @@ static int __devinit epic_init_one (struct pci_dev *pdev,
 		dev_err(&pdev->dev, "no memory for eth device\n");
 		goto err_out_free_res;
 	}
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 #ifdef USE_IO_OPS
diff --git a/drivers/net/eql.c b/drivers/net/eql.c
index 102218c..23346b1 100644
--- a/drivers/net/eql.c
+++ b/drivers/net/eql.c
@@ -166,8 +166,6 @@ static void __init eql_setup(struct net_device *dev)
 {
 	equalizer_t *eql = netdev_priv(dev);
 
-	SET_MODULE_OWNER(dev);
-
 	init_timer(&eql->timer);
 	eql->timer.data     	= (unsigned long) eql;
 	eql->timer.expires  	= jiffies + EQL_DEFAULT_RESCHED_IVAL;
diff --git a/drivers/net/es3210.c b/drivers/net/es3210.c
index 822e5bf..238fa8a 100644
--- a/drivers/net/es3210.c
+++ b/drivers/net/es3210.c
@@ -130,8 +130,6 @@ static int __init do_es_probe(struct net_device *dev)
 	int irq = dev->irq;
 	int mem_start = dev->mem_start;
 
-	SET_MODULE_OWNER(dev);
-
 	if (ioaddr > 0x1ff)		/* Check a single specified location. */
 		return es_probe1(dev, ioaddr);
 	else if (ioaddr > 0)		/* Don't probe at all. */
diff --git a/drivers/net/eth16i.c b/drivers/net/eth16i.c
index 04abf59..0e3b337 100644
--- a/drivers/net/eth16i.c
+++ b/drivers/net/eth16i.c
@@ -436,8 +436,6 @@ static int __init do_eth16i_probe(struct net_device *dev)
 	int ioaddr;
 	int base_addr = dev->base_addr;
 
-	SET_MODULE_OWNER(dev);
-
 	if(eth16i_debug > 4)
 		printk(KERN_DEBUG "Probing started for %s\n", cardname);
 
diff --git a/drivers/net/ewrk3.c b/drivers/net/ewrk3.c
index cb0792c..6a5d043 100644
--- a/drivers/net/ewrk3.c
+++ b/drivers/net/ewrk3.c
@@ -356,7 +356,6 @@ struct net_device * __init ewrk3_probe(int unit)
 		sprintf(dev->name, "eth%d", unit);
 		netdev_boot_setup_check(dev);
 	}
-	SET_MODULE_OWNER(dev);
 
 	err = ewrk3_probe1(dev, dev->base_addr, dev->irq);
 	if (err)
diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
index ff9f177..e935307 100644
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -527,7 +527,6 @@ static int __devinit fealnx_init_one(struct pci_dev *pdev,
 		err = -ENOMEM;
 		goto err_out_unmap;
 	}
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	/* read ethernet id */
diff --git a/drivers/net/fec_8xx/fec_main.c b/drivers/net/fec_8xx/fec_main.c
index e5502af..d53fce6 100644
--- a/drivers/net/fec_8xx/fec_main.c
+++ b/drivers/net/fec_8xx/fec_main.c
@@ -1104,7 +1104,6 @@ int fec_8xx_init_one(const struct fec_platform_info *fpi,
 		err = -ENOMEM;
 		goto err;
 	}
-	SET_MODULE_OWNER(dev);
 
 	fep = netdev_priv(dev);
 
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 1938d6d..ef53ca0 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -4996,7 +4996,6 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	np = netdev_priv(dev);
 	np->pci_dev = pci_dev;
 	spin_lock_init(&np->lock);
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pci_dev->dev);
 
 	init_timer(&np->oom_kick);
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index a4a2a0e..01594fe 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -961,7 +961,6 @@ static struct net_device *fs_init_instance(struct device *dev,
 		err = -ENOMEM;
 		goto err;
 	}
-	SET_MODULE_OWNER(ndev);
 
 	fep = netdev_priv(ndev);
 	memset(fep, 0, privsize);	/* clear everything */
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index f926905..3bbe92e 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -253,7 +253,6 @@ static int gfar_probe(struct platform_device *pdev)
 	/* Set the dev->base_addr to the gfar reg region */
 	dev->base_addr = (unsigned long) (priv->regs);
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	/* Fill in the dev structure */
diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index 15254dc..da12b3d 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -613,7 +613,6 @@ static int __devinit hamachi_init_one (struct pci_dev *pdev,
 	if (!dev)
 		goto err_out_iounmap;
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 #ifdef TX_CHECKSUM
diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 760d04a..0a84732 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -345,8 +345,6 @@ static void sp_setup(struct net_device *dev)
 	memcpy(dev->broadcast, &ax25_bcast, AX25_ADDR_LEN);
 	memcpy(dev->dev_addr, &ax25_defaddr, AX25_ADDR_LEN);
 
-	SET_MODULE_OWNER(dev);
-
 	dev->flags		= 0;
 }
 
diff --git a/drivers/net/hp-plus.c b/drivers/net/hp-plus.c
index 99a36cc..8d4f810 100644
--- a/drivers/net/hp-plus.c
+++ b/drivers/net/hp-plus.c
@@ -122,8 +122,6 @@ static int __init do_hpp_probe(struct net_device *dev)
 	int base_addr = dev->base_addr;
 	int irq = dev->irq;
 
-	SET_MODULE_OWNER(dev);
-
 	if (base_addr > 0x1ff)		/* Check a single specified location. */
 		return hpp_probe1(dev, base_addr);
 	else if (base_addr != 0)	/* Don't probe at all. */
diff --git a/drivers/net/hp.c b/drivers/net/hp.c
index 635b13c..1f11126 100644
--- a/drivers/net/hp.c
+++ b/drivers/net/hp.c
@@ -86,8 +86,6 @@ static int __init do_hp_probe(struct net_device *dev)
 	int base_addr = dev->base_addr;
 	int irq = dev->irq;
 
-	SET_MODULE_OWNER(dev);
-
 	if (base_addr > 0x1ff)		/* Check a single specified location. */
 		return hp_probe1(dev, base_addr);
 	else if (base_addr != 0)	/* Don't probe at all. */
diff --git a/drivers/net/hp100.c b/drivers/net/hp100.c
index 8caa591..406d652 100644
--- a/drivers/net/hp100.c
+++ b/drivers/net/hp100.c
@@ -404,8 +404,6 @@ struct net_device * __init hp100_probe(int unit)
 	if (!dev)
 		return ERR_PTR(-ENODEV);
 
-	SET_MODULE_OWNER(dev);
-
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4200, TRACE);
 	printk("hp100: %s: probe\n", dev->name);
@@ -2843,7 +2841,6 @@ static int __init hp100_eisa_probe (struct device *gendev)
 	if (!dev)
 		return -ENOMEM;
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &edev->dev);
 
 	err = hp100_probe1(dev, edev->base_addr + 0xC38, HP100_BUS_EISA, NULL);
@@ -2896,7 +2893,6 @@ static int __devinit hp100_pci_probe (struct pci_dev *pdev,
 		goto out0;
 	}
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	pci_read_config_word(pdev, PCI_COMMAND, &pci_command);
@@ -2993,7 +2989,6 @@ static int __init hp100_isa_init(void)
 
 			return -ENOMEM;
 		}
-		SET_MODULE_OWNER(dev);
 
 		err = hp100_isa_probe(dev, hp100_port[i]);
 		if (!err)
diff --git a/drivers/net/hydra.c b/drivers/net/hydra.c
index f970bfb..31300a9 100644
--- a/drivers/net/hydra.c
+++ b/drivers/net/hydra.c
@@ -112,7 +112,6 @@ static int __devinit hydra_init(struct zorro_dev *z)
     dev = ____alloc_ei_netdev(0);
     if (!dev)
 	return -ENOMEM;
-    SET_MODULE_OWNER(dev);
 
     for(j = 0; j < ETHER_ADDR_LEN; j++)
 	dev->dev_addr[j] = *((u8 *)(board + HYDRA_ADDRPROM + 2*j));
diff --git a/drivers/net/ibm_emac/ibm_emac_core.c b/drivers/net/ibm_emac/ibm_emac_core.c
index f752e5f..354616b 100644
--- a/drivers/net/ibm_emac/ibm_emac_core.c
+++ b/drivers/net/ibm_emac/ibm_emac_core.c
@@ -1962,7 +1962,6 @@ static int __init emac_probe(struct ocp_device *ocpdev)
 	dev->ndev = ndev;
 	dev->ldev = &ocpdev->dev;
 	dev->def = ocpdev->def;
-	SET_MODULE_OWNER(ndev);
 
 	/* Find MAL device we are connected to */
 	maldev =
diff --git a/drivers/net/ibmlana.c b/drivers/net/ibmlana.c
index fe85d6f..67d82fa 100644
--- a/drivers/net/ibmlana.c
+++ b/drivers/net/ibmlana.c
@@ -907,8 +907,6 @@ static int ibmlana_probe(struct net_device *dev)
 	ibmlana_priv *priv;
 	ibmlana_medium medium;
 
-	SET_MODULE_OWNER(dev);
-
 	/* can't work without an MCA bus ;-) */
 	if (MCA_bus == 0)
 		return -ENODEV;
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index acba90f..75b9f57 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -994,8 +994,6 @@ static int __devinit ibmveth_probe(struct vio_dev *dev, const struct vio_device_
 	if(!netdev)
 		return -ENOMEM;
 
-	SET_MODULE_OWNER(netdev);
-
 	adapter = netdev->priv;
 	dev->dev.driver_data = netdev;
 
@@ -1094,7 +1092,6 @@ static void ibmveth_proc_register_driver(void)
 {
 	ibmveth_proc_dir = proc_mkdir(IBMVETH_PROC_DIR, NULL);
 	if (ibmveth_proc_dir) {
-		SET_MODULE_OWNER(ibmveth_proc_dir);
 	}
 }
 
@@ -1195,7 +1192,6 @@ static void ibmveth_proc_register_adapter(struct ibmveth_adapter *adapter)
 		} else {
 			entry->data = (void *) adapter;
 			entry->proc_fops = &ibmveth_proc_fops;
-			SET_MODULE_OWNER(entry);
 		}
 	}
 	return;
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index f5c3598..e66d657 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -151,7 +151,6 @@ static void ifb_setup(struct net_device *dev)
 	dev->change_mtu = NULL;
 	dev->flags |= IFF_NOARP;
 	dev->flags &= ~IFF_MULTICAST;
-	SET_MODULE_OWNER(dev);
 	random_ether_addr(dev->dev_addr);
 }
 
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index c030030..05d2bc1 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -1273,7 +1273,6 @@ static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		goto out_free;
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	ip = netdev_priv(dev);
diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index f9c889c..9f58452 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -360,10 +360,6 @@ static int ali_ircc_open(int i, chipio_t *info)
 	self->tx_fifo.len = self->tx_fifo.ptr = self->tx_fifo.free = 0;
 	self->tx_fifo.tail = self->tx_buff.head;
 
-	
-	/* Keep track of module usage */
-	SET_MODULE_OWNER(dev);
-
 	/* Override the network functions we need to use */
 	dev->hard_start_xmit = ali_ircc_sir_hard_xmit;
 	dev->open            = ali_ircc_net_open;
diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index 3ca47bf..3e5eca1 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -1660,7 +1660,6 @@ toshoboe_open (struct pci_dev *pci_dev, const struct pci_device_id *pdid)
       }
 #endif
 
-  SET_MODULE_OWNER(dev);
   SET_NETDEV_DEV(dev, &pci_dev->dev);
   dev->hard_start_xmit = toshoboe_hard_xmit;
   dev->open = toshoboe_net_open;
diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index 3b0fd83..c6355c0 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -1635,7 +1635,6 @@ static int irda_usb_probe(struct usb_interface *intf,
 	if (!net) 
 		goto err_out;
 
-	SET_MODULE_OWNER(net);
 	SET_NETDEV_DEV(net, &intf->dev);
 	self = net->priv;
 	self->netdev = net;
diff --git a/drivers/net/irda/irport.c b/drivers/net/irda/irport.c
index 2073245..c79caa5 100644
--- a/drivers/net/irda/irport.c
+++ b/drivers/net/irda/irport.c
@@ -175,8 +175,6 @@ irport_open(int i, unsigned int iobase, unsigned int irq)
 	self->tx_buff.data = self->tx_buff.head;
 
 	self->netdev = dev;
-	/* Keep track of module usage */
-	SET_MODULE_OWNER(dev);
 
 	/* May be overridden by piggyback drivers */
 	self->interrupt    = irport_interrupt;
diff --git a/drivers/net/irda/kingsun-sir.c b/drivers/net/irda/kingsun-sir.c
index 4e5101a..d323f6b 100644
--- a/drivers/net/irda/kingsun-sir.c
+++ b/drivers/net/irda/kingsun-sir.c
@@ -488,7 +488,6 @@ static int kingsun_probe(struct usb_interface *intf,
 	if(!net)
 		goto err_out1;
 
-	SET_MODULE_OWNER(net);
 	SET_NETDEV_DEV(net, &intf->dev);
 	kingsun = netdev_priv(net);
 	kingsun->irlap = NULL;
diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
index 0de8672..e04718e 100644
--- a/drivers/net/irda/mcs7780.c
+++ b/drivers/net/irda/mcs7780.c
@@ -899,8 +899,6 @@ static int mcs_probe(struct usb_interface *intf,
 
 	IRDA_DEBUG(1, "MCS7780 USB-IrDA bridge found at %d.\n", udev->devnum);
 
-	/* what is it realy for? */
-	SET_MODULE_OWNER(ndev);
 	SET_NETDEV_DEV(ndev, &intf->dev);
 
 	ret = usb_reset_configuration(udev);
diff --git a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
index d96c897..12b9378 100644
--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -437,7 +437,6 @@ static int __init nsc_ircc_open(chipio_t *info)
 	self->tx_fifo.tail = self->tx_buff.head;
 
 	/* Override the network functions we need to use */
-	SET_MODULE_OWNER(dev);
 	dev->hard_start_xmit = nsc_ircc_hard_xmit_sir;
 	dev->open            = nsc_ircc_net_open;
 	dev->stop            = nsc_ircc_net_close;
diff --git a/drivers/net/irda/sir_dev.c b/drivers/net/irda/sir_dev.c
index 9d6c8f3..bbe4e09 100644
--- a/drivers/net/irda/sir_dev.c
+++ b/drivers/net/irda/sir_dev.c
@@ -913,8 +913,6 @@ struct sir_dev * sirdev_get_instance(const struct sir_driver *drv, const char *n
 	dev->drv = drv;
 	dev->netdev = ndev;
 
-	SET_MODULE_OWNER(ndev);
-
 	/* Override the network functions we need to use */
 	ndev->hard_start_xmit = sirdev_hard_xmit;
 	ndev->open = sirdev_open;
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index 36ab983..029fdde 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -519,8 +519,6 @@ static int __init smsc_ircc_open(unsigned int fir_base, unsigned int sir_base, u
 		goto err_out1;
 	}
 
-	SET_MODULE_OWNER(dev);
-
 	dev->hard_start_xmit = smsc_ircc_hard_xmit_sir;
 #if SMSC_IRCC2_C_NET_TIMEOUT
 	dev->tx_timeout	     = smsc_ircc_timeout;
diff --git a/drivers/net/irda/stir4200.c b/drivers/net/irda/stir4200.c
index 755aa44..1afaee0 100644
--- a/drivers/net/irda/stir4200.c
+++ b/drivers/net/irda/stir4200.c
@@ -1034,7 +1034,6 @@ static int stir_probe(struct usb_interface *intf,
 	if(!net)
 		goto err_out1;
 
-	SET_MODULE_OWNER(net);
 	SET_NETDEV_DEV(net, &intf->dev);
 	stir = netdev_priv(net);
 	stir->netdev = net;
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index ff53585..126ec7c 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -429,9 +429,6 @@ static __devinit int via_ircc_open(int i, chipio_t * info, unsigned int id)
 	self->tx_fifo.len = self->tx_fifo.ptr = self->tx_fifo.free = 0;
 	self->tx_fifo.tail = self->tx_buff.head;
 
-	/* Keep track of module usage */
-	SET_MODULE_OWNER(dev);
-
 	/* Override the network functions we need to use */
 	dev->hard_start_xmit = via_ircc_hard_xmit_sir;
 	dev->open = via_ircc_net_open;
diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index 0538ca9..acd082a 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -1584,8 +1584,6 @@ static int vlsi_irda_init(struct net_device *ndev)
 	vlsi_irda_dev_t *idev = ndev->priv;
 	struct pci_dev *pdev = idev->pdev;
 
-	SET_MODULE_OWNER(ndev);
-
 	ndev->irq = pdev->irq;
 	ndev->base_addr = pci_resource_start(pdev,0);
 
diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index 5182e80..9fd2451 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -232,9 +232,6 @@ int w83977af_open(int i, unsigned int iobase, unsigned int irq,
 	self->rx_buff.data = self->rx_buff.head;
 	self->netdev = dev;
 
-	/* Keep track of module usage */
-	SET_MODULE_OWNER(dev);
-
 	/* Override the network functions we need to use */
 	dev->hard_start_xmit = w83977af_hard_xmit;
 	dev->open            = w83977af_net_open;
diff --git a/drivers/net/isa-skeleton.c b/drivers/net/isa-skeleton.c
index 0343f12..5417811 100644
--- a/drivers/net/isa-skeleton.c
+++ b/drivers/net/isa-skeleton.c
@@ -133,8 +133,6 @@ static int __init do_netcard_probe(struct net_device *dev)
 	int base_addr = dev->base_addr;
 	int irq = dev->irq;
 
-	SET_MODULE_OWNER(dev);
-
 	if (base_addr > 0x1ff)    /* Check a single specified location. */
 		return netcard_probe1(dev, base_addr);
 	else if (base_addr != 0)  /* Don't probe at all. */
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 991c883..0b63186 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -382,7 +382,6 @@ ixgb_probe(struct pci_dev *pdev,
 		goto err_alloc_etherdev;
 	}
 
-	SET_MODULE_OWNER(netdev);
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
 	pci_set_drvdata(pdev, netdev);
diff --git a/drivers/net/ixp2000/enp2611.c b/drivers/net/ixp2000/enp2611.c
index d3f4235..b02a981 100644
--- a/drivers/net/ixp2000/enp2611.c
+++ b/drivers/net/ixp2000/enp2611.c
@@ -210,7 +210,6 @@ static int __init enp2611_init_module(void)
 			return -ENOMEM;
 		}
 
-		SET_MODULE_OWNER(nds[i]);
 		nds[i]->get_stats = enp2611_get_stats;
 		pm3386_init_port(i);
 		pm3386_get_mac(i, nds[i]->dev_addr);
diff --git a/drivers/net/jazzsonic.c b/drivers/net/jazzsonic.c
index 75f6f44..2cffb7b 100644
--- a/drivers/net/jazzsonic.c
+++ b/drivers/net/jazzsonic.c
@@ -231,7 +231,6 @@ static int __init jazz_sonic_probe(struct platform_device *pdev)
 	lp = netdev_priv(dev);
 	lp->device = &pdev->dev;
 	SET_NETDEV_DEV(dev, &pdev->dev);
- 	SET_MODULE_OWNER(dev);
 
 	netdev_boot_setup_check(dev);
 
diff --git a/drivers/net/lance.c b/drivers/net/lance.c
index a4e5fab..7b17212 100644
--- a/drivers/net/lance.c
+++ b/drivers/net/lance.c
@@ -521,7 +521,6 @@ static int __init lance_probe1(struct net_device *dev, int ioaddr, int irq, int
 
 	/* We can't allocate dev->priv from alloc_etherdev() because it must
 	   a ISA DMA-able region. */
-	SET_MODULE_OWNER(dev);
 	chipname = chip_table[lance_version].name;
 	printk("%s: %s at %#3x,", dev->name, chipname, ioaddr);
 
diff --git a/drivers/net/lguest_net.c b/drivers/net/lguest_net.c
index cab5791..7f34c92 100644
--- a/drivers/net/lguest_net.c
+++ b/drivers/net/lguest_net.c
@@ -460,8 +460,6 @@ static int lguestnet_probe(struct lguest_device *lgdev)
 	if (!dev)
 		return -ENOMEM;
 
-	SET_MODULE_OWNER(dev);
-
 	/* Ethernet defaults with some changes */
 	ether_setup(dev);
 	dev->set_mac_address = NULL;
diff --git a/drivers/net/lne390.c b/drivers/net/lne390.c
index 0a08d0c..2dd3969 100644
--- a/drivers/net/lne390.c
+++ b/drivers/net/lne390.c
@@ -111,8 +111,6 @@ static int __init do_lne390_probe(struct net_device *dev)
 	int mem_start = dev->mem_start;
 	int ret;
 
-	SET_MODULE_OWNER(dev);
-
 	if (ioaddr > 0x1ff) {		/* Check a single specified location. */
 		if (!request_region(ioaddr, LNE390_IO_EXTENT, DRV_NAME))
 			return -EBUSY;
diff --git a/drivers/net/mac8390.c b/drivers/net/mac8390.c
index 90b0c3e..9e70074 100644
--- a/drivers/net/mac8390.c
+++ b/drivers/net/mac8390.c
@@ -313,8 +313,6 @@ struct net_device * __init mac8390_probe(int unit)
 	if (unit >= 0)
 		sprintf(dev->name, "eth%d", unit);
 
- 	SET_MODULE_OWNER(dev);
-
 	while ((ndev = nubus_find_type(NUBUS_CAT_NETWORK, NUBUS_TYPE_ETHERNET, ndev))) {
 		/* Have we seen it already? */
 		if (slots & (1<<ndev->board->slot))
diff --git a/drivers/net/mac89x0.c b/drivers/net/mac89x0.c
index 62c1c62..f6f3fdf 100644
--- a/drivers/net/mac89x0.c
+++ b/drivers/net/mac89x0.c
@@ -191,8 +191,6 @@ struct net_device * __init mac89x0_probe(int unit)
 		netdev_boot_setup_check(dev);
 	}
 
-	SET_MODULE_OWNER(dev);
-
 	if (once_is_enough)
 		goto out;
 	once_is_enough = 1;
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index a4bb026..3c1b2f9 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -1088,7 +1088,6 @@ static int __devinit macb_probe(struct platform_device *pdev)
 		goto err_out;
 	}
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	/* TODO: Actually, we have some interesting features... */
diff --git a/drivers/net/mace.c b/drivers/net/mace.c
index 52b9332..de3b002 100644
--- a/drivers/net/mace.c
+++ b/drivers/net/mace.c
@@ -143,7 +143,6 @@ static int __devinit mace_probe(struct macio_dev *mdev, const struct of_device_i
 		rc = -ENOMEM;
 		goto err_release;
 	}
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &mdev->ofdev.dev);
 
 	mp = dev->priv;
diff --git a/drivers/net/macmace.c b/drivers/net/macmace.c
index 9a343b9..5d2daa2 100644
--- a/drivers/net/macmace.c
+++ b/drivers/net/macmace.c
@@ -210,7 +210,6 @@ static int __devinit mace_probe(struct platform_device *pdev)
 
 	mp->device = &pdev->dev;
 	SET_NETDEV_DEV(dev, &pdev->dev);
- 	SET_MODULE_OWNER(dev);
 
 	dev->base_addr = (u32)MACE_BASE;
 	mp->mace = (volatile struct mace *) MACE_BASE;
diff --git a/drivers/net/macsonic.c b/drivers/net/macsonic.c
index e9ecdbf..a55a839 100644
--- a/drivers/net/macsonic.c
+++ b/drivers/net/macsonic.c
@@ -576,7 +576,6 @@ static int __init mac_sonic_probe(struct platform_device *pdev)
 	lp = netdev_priv(dev);
 	lp->device = &pdev->dev;
 	SET_NETDEV_DEV(dev, &pdev->dev);
- 	SET_MODULE_OWNER(dev);
 
 	/* This will catch fatal stuff like -ENOMEM as well as success */
 	err = mac_onboard_sonic_probe(dev);
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 1799eee..f5fa185 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1432,7 +1432,6 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	mv643xx_eth_update_pscr(dev, &cmd);
 	mv643xx_set_settings(dev, &cmd);
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	err = register_netdev(dev);
 	if (err)
diff --git a/drivers/net/mvme147.c b/drivers/net/mvme147.c
index e246d00..837ad0f 100644
--- a/drivers/net/mvme147.c
+++ b/drivers/net/mvme147.c
@@ -79,8 +79,6 @@ struct net_device * __init mvme147lance_probe(int unit)
 	if (unit >= 0)
 		sprintf(dev->name, "eth%d", unit);
 
-	SET_MODULE_OWNER(dev);
-
 	/* Fill the dev fields */
 	dev->base_addr = (unsigned long)MVME147_LANCE_BASE;
 	dev->open = &m147lance_open;
diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index 13444da..331b76c 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -908,7 +908,6 @@ static int __devinit myri_ether_init(struct sbus_dev *sdev)
 	if (version_printed++ == 0)
 		printk(version);
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &sdev->ofdev.dev);
 
 	mp = (struct myri_eth *) dev->priv;
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index b47a12d..c5e68ed 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -835,7 +835,6 @@ static int __devinit natsemi_probe1 (struct pci_dev *pdev,
 	dev = alloc_etherdev(sizeof (struct netdev_private));
 	if (!dev)
 		return -ENOMEM;
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	i = pci_request_regions(pdev, DRV_NAME);
diff --git a/drivers/net/ne-h8300.c b/drivers/net/ne-h8300.c
index 38fd525..a0f3536 100644
--- a/drivers/net/ne-h8300.c
+++ b/drivers/net/ne-h8300.c
@@ -149,8 +149,6 @@ static int __init do_ne_probe(struct net_device *dev)
 {
 	unsigned int base_addr = dev->base_addr;
 
-	SET_MODULE_OWNER(dev);
-
 	/* First check any supplied i/o locations. User knows best. <cough> */
 	if (base_addr > 0x1ff)	/* Check a single specified location. */
 		return ne_probe1(dev, base_addr);
diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index c9f74bf..c81befc 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -191,8 +191,6 @@ static int __init do_ne_probe(struct net_device *dev)
 	int orig_irq = dev->irq;
 #endif
 
-	SET_MODULE_OWNER(dev);
-
 	/* First check any supplied i/o locations. User knows best. <cough> */
 	if (base_addr > 0x1ff)	/* Check a single specified location. */
 		return ne_probe1(dev, base_addr);
diff --git a/drivers/net/ne2.c b/drivers/net/ne2.c
index 089b5bb..d1a4b8d 100644
--- a/drivers/net/ne2.c
+++ b/drivers/net/ne2.c
@@ -251,8 +251,6 @@ static int __init do_ne2_probe(struct net_device *dev)
 	int i;
 	int adapter_found = 0;
 
-	SET_MODULE_OWNER(dev);
-
 	/* Do not check any supplied i/o locations.
 	   POS registers usually don't fail :) */
 
diff --git a/drivers/net/ne2k-pci.c b/drivers/net/ne2k-pci.c
index f81d939..230a0f1 100644
--- a/drivers/net/ne2k-pci.c
+++ b/drivers/net/ne2k-pci.c
@@ -265,7 +265,6 @@ static int __devinit ne2k_pci_init_one (struct pci_dev *pdev,
 		dev_err(&pdev->dev, "cannot allocate ethernet device\n");
 		goto err_out_free_res;
 	}
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	/* Reset card. Who knows what dain-bramaged state it was left in. */
diff --git a/drivers/net/ne3210.c b/drivers/net/ne3210.c
index 1a6fed7..b1bf833 100644
--- a/drivers/net/ne3210.c
+++ b/drivers/net/ne3210.c
@@ -106,7 +106,6 @@ static int __init ne3210_eisa_probe (struct device *device)
 		return -ENOMEM;
 	}
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, device);
 	device->driver_data = dev;
 	ioaddr = edev->base_addr;
diff --git a/drivers/net/netx-eth.c b/drivers/net/netx-eth.c
index 2b8da0a..6fee405 100644
--- a/drivers/net/netx-eth.c
+++ b/drivers/net/netx-eth.c
@@ -390,7 +390,6 @@ static int netx_eth_drv_probe(struct platform_device *pdev)
 		ret = -ENOMEM;
 		goto exit;
 	}
-	SET_MODULE_OWNER(ndev);
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
 	platform_set_drvdata(pdev, ndev);
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 3122d01..d42b96e 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -326,7 +326,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_free_res;
 	}
 
-	SET_MODULE_OWNER(netdev);
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
 	adapter = netdev->priv;
diff --git a/drivers/net/ni5010.c b/drivers/net/ni5010.c
index 22a3b3d..cc1d09a 100644
--- a/drivers/net/ni5010.c
+++ b/drivers/net/ni5010.c
@@ -135,8 +135,6 @@ struct net_device * __init ni5010_probe(int unit)
 
 	PRINTK2((KERN_DEBUG "%s: Entering ni5010_probe\n", dev->name));
 
-	SET_MODULE_OWNER(dev);
-
 	if (io > 0x1ff)	{	/* Check a single specified location. */
 		err = ni5010_probe1(dev, io);
 	} else if (io != 0) {	/* Don't probe at all. */
diff --git a/drivers/net/ni52.c b/drivers/net/ni52.c
index 5e7999d..6b3384a 100644
--- a/drivers/net/ni52.c
+++ b/drivers/net/ni52.c
@@ -382,8 +382,6 @@ struct net_device * __init ni52_probe(int unit)
 		memend = dev->mem_end;
 	}
 
-	SET_MODULE_OWNER(dev);
-
 	if (io > 0x1ff)	{	/* Check a single specified location. */
 		err = ni52_probe1(dev, io);
 	} else if (io > 0) {		/* Don't probe at all. */
diff --git a/drivers/net/ni65.c b/drivers/net/ni65.c
index 4ef5fe3..0976852 100644
--- a/drivers/net/ni65.c
+++ b/drivers/net/ni65.c
@@ -550,7 +550,6 @@ static int __init ni65_probe1(struct net_device *dev,int ioaddr)
 	}
 
 	dev->base_addr = ioaddr;
-	SET_MODULE_OWNER(dev);
 	dev->open		= ni65_open;
 	dev->stop		= ni65_close;
 	dev->hard_start_xmit	= ni65_send_packet;
diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index ea80e6c..055f197 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -1843,7 +1843,6 @@ static int __devinit ns83820_init_one(struct pci_dev *pci_dev, const struct pci_
 	spin_lock_init(&dev->misc_lock);
 	dev->pci_dev = pci_dev;
 
-	SET_MODULE_OWNER(ndev);
 	SET_NETDEV_DEV(ndev, &pci_dev->dev);
 
 	INIT_WORK(&dev->tq_refill, queue_refill);
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 0b3066a..4d6a7c8 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -1089,7 +1089,6 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto out_disable_device;
 	}
 
-	SET_MODULE_OWNER(dev);
 	pci_set_drvdata(pdev, dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index 3cdbe11..a4b1648 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -604,7 +604,6 @@ static int __devinit netdrv_init_board (struct pci_dev *pdev,
 		DPRINTK ("EXIT, returning -ENOMEM\n");
 		return -ENOMEM;
 	}
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	tp = dev->priv;
 
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 503f268..2136c80 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -197,7 +197,6 @@ static int tc589_probe(struct pcmcia_device *link)
     link->conf.ConfigIndex = 1;
 
     /* The EL3-specific entries in the device structure. */
-    SET_MODULE_OWNER(dev);
     dev->hard_start_xmit = &el3_start_xmit;
     dev->set_config = &el3_config;
     dev->get_stats = &el3_get_stats;
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 50dff1b..a9db59d 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -1728,9 +1728,6 @@ static void axdev_setup(struct net_device *dev)
 	if (ei_debug > 1)
 		printk(version_8390);
     
-	SET_MODULE_OWNER(dev);
-
-		
 	ei_local = (struct ei_device *)netdev_priv(dev);
 	spin_lock_init(&ei_local->page_lock);
     
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 85d5f2c..7f29e95 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -259,7 +259,6 @@ static int fmvj18x_probe(struct pcmcia_device *link)
     link->conf.IntType = INT_MEMORY_AND_IO;
 
     /* The FMVJ18x specific entries in the device structure. */
-    SET_MODULE_OWNER(dev);
     dev->hard_start_xmit = &fjn_start_xmit;
     dev->set_config = &fjn_config;
     dev->get_stats = &fjn_get_stats;
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index 997c2d0..1bb2ffa 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -474,7 +474,6 @@ static int nmclan_probe(struct pcmcia_device *link)
 
     lp->tx_free_frames=AM2150_MAX_TX_FRAMES;
 
-    SET_MODULE_OWNER(dev);
     dev->hard_start_xmit = &mace_start_xmit;
     dev->set_config = &mace_config;
     dev->get_stats = &mace_get_stats;
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 63de89e..49857c1 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -259,7 +259,6 @@ static int pcnet_probe(struct pcmcia_device *link)
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
 
-    SET_MODULE_OWNER(dev);
     dev->open = &pcnet_open;
     dev->stop = &pcnet_close;
     dev->set_config = &set_config;
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index af6728c..b25f198 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -336,7 +336,6 @@ static int smc91c92_probe(struct pcmcia_device *link)
     link->conf.IntType = INT_MEMORY_AND_IO;
 
     /* The SMC91c92-specific entries in the device structure. */
-    SET_MODULE_OWNER(dev);
     dev->hard_start_xmit = &smc_start_xmit;
     dev->get_stats = &smc_get_stats;
     dev->set_config = &s9k_config;
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index 258d6f3..d5c2d2c 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -580,7 +580,6 @@ xirc2ps_probe(struct pcmcia_device *link)
     link->irq.Instance = dev;
 
     /* Fill in card specific entries */
-    SET_MODULE_OWNER(dev);
     dev->hard_start_xmit = &do_start_xmit;
     dev->set_config = &do_config;
     dev->get_stats = &do_get_stats;
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index e6a6753..42c3b3d 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -1817,7 +1817,6 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 
 	spin_lock_init(&lp->lock);
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	lp->name = chipname;
 	lp->shared_irq = shared;
diff --git a/drivers/net/plip.c b/drivers/net/plip.c
index 8754cf3..2cfab4b 100644
--- a/drivers/net/plip.c
+++ b/drivers/net/plip.c
@@ -1278,7 +1278,6 @@ static void plip_attach (struct parport *port)
 
 		strcpy(dev->name, name);
 
-		SET_MODULE_OWNER(dev);
 		dev->irq = port->irq;
 		dev->base_addr = port->base;
 		if (port->irq == -1) {
diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ps3_gelic_net.c
index e565039..f6c1c8d 100644
--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -1382,7 +1382,6 @@ static int gelic_net_setup_netdev(struct gelic_net_card *card)
 	int status;
 	u64 v1, v2;
 
-	SET_MODULE_OWNER(netdev);
 	SET_NETDEV_DEV(netdev, &card->dev->core);
 	spin_lock_init(&card->tx_dma_lock);
 
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 69da95b..3fb2bcb 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -4009,7 +4009,6 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 		goto err_out_free_regions;
 	}
 
-	SET_MODULE_OWNER(ndev);
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
 	pci_set_drvdata(pdev, ndev);
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index b85ab4a..0170c07 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1502,7 +1502,6 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto out;
 	}
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	tp = netdev_priv(dev);
 	tp->dev = dev;
diff --git a/drivers/net/rionet.c b/drivers/net/rionet.c
index df6b738..25a9dd8 100644
--- a/drivers/net/rionet.c
+++ b/drivers/net/rionet.c
@@ -471,8 +471,6 @@ static int rionet_setup_netdev(struct rio_mport *mport)
 	ndev->features = NETIF_F_LLTX;
 	SET_ETHTOOL_OPS(ndev, &rionet_ethtool_ops);
 
-	SET_MODULE_OWNER(ndev);
-
 	spin_lock_init(&rnet->lock);
 	spin_lock_init(&rnet->tx_lock);
 
diff --git a/drivers/net/rrunner.c b/drivers/net/rrunner.c
index 5c2e41f..41f877d 100644
--- a/drivers/net/rrunner.c
+++ b/drivers/net/rrunner.c
@@ -109,7 +109,6 @@ static int __devinit rr_init_one(struct pci_dev *pdev,
 
 	rrpriv = netdev_priv(dev);
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	if (pci_request_regions(pdev, "rrunner")) {
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 24feb00..4e8e401 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -7076,7 +7076,6 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 
 	pci_set_master(pdev);
 	pci_set_drvdata(pdev, dev);
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	/*  Private member variable initialized to s2io NIC structure */
diff --git a/drivers/net/sb1000.c b/drivers/net/sb1000.c
index 1de3eec..aeaa75f 100644
--- a/drivers/net/sb1000.c
+++ b/drivers/net/sb1000.c
@@ -189,7 +189,6 @@ sb1000_probe_one(struct pnp_dev *pdev, const struct pnp_device_id *id)
 	 */
 	dev->flags = IFF_POINTOPOINT|IFF_NOARP;
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	if (sb1000_debug > 0)
diff --git a/drivers/net/shaper.c b/drivers/net/shaper.c
index 4c3d98f..700d39d 100644
--- a/drivers/net/shaper.c
+++ b/drivers/net/shaper.c
@@ -532,8 +532,6 @@ static void __init shaper_setup(struct net_device *dev)
 	 *	Set up the shaper.
 	 */
 
-	SET_MODULE_OWNER(dev);
-
 	shaper_init_priv(dev);
 
 	dev->open		= shaper_open;
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index d470b19..452cf93 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -1436,7 +1436,6 @@ static struct net_device * __devinit sis190_init_board(struct pci_dev *pdev)
 		goto err_out_0;
 	}
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	tp = netdev_priv(dev);
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index 7c6e480..e1930c3 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -430,7 +430,6 @@ static int __devinit sis900_probe(struct pci_dev *pci_dev,
 	net_dev = alloc_etherdev(sizeof(struct sis900_private));
 	if (!net_dev)
 		return -ENOMEM;
-	SET_MODULE_OWNER(net_dev);
 	SET_NETDEV_DEV(net_dev, &pci_dev->dev);
 
 	/* We do a request_region() to register /proc/ioports info. */
diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
index a7ef6c8..ca50870 100644
--- a/drivers/net/skfp/skfddi.c
+++ b/drivers/net/skfp/skfddi.c
@@ -262,7 +262,6 @@ static int skfp_init_one(struct pci_dev *pdev,
 	dev->do_ioctl = &skfp_ioctl;
 	dev->header_cache_update = NULL;	/* not supported */
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	/* Initialize board structure with bus-specific info */
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index e3d8520..babb1bf 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -3552,7 +3552,6 @@ static struct net_device *skge_devinit(struct skge_hw *hw, int port,
 		return NULL;
 	}
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &hw->pdev->dev);
 	dev->open = skge_up;
 	dev->stop = skge_down;
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index e6d937e..c557018 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -3756,7 +3756,6 @@ static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
 		return NULL;
 	}
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &hw->pdev->dev);
 	dev->irq = hw->pdev->irq;
 	dev->open = sky2_up;
diff --git a/drivers/net/slip.c b/drivers/net/slip.c
index 3fd4735..335b7cc 100644
--- a/drivers/net/slip.c
+++ b/drivers/net/slip.c
@@ -639,8 +639,6 @@ static void sl_setup(struct net_device *dev)
 	dev->addr_len		= 0;
 	dev->tx_queue_len	= 10;
 
-	SET_MODULE_OWNER(dev);
-
 	/* New-style flags. */
 	dev->flags		= IFF_NOARP|IFF_POINTOPOINT|IFF_MULTICAST;
 }
diff --git a/drivers/net/smc-mca.c b/drivers/net/smc-mca.c
index ae1ae34..3b43fa8 100644
--- a/drivers/net/smc-mca.c
+++ b/drivers/net/smc-mca.c
@@ -264,7 +264,6 @@ static int __init ultramca_probe(struct device *gen_dev)
 	if(!dev)
 		return -ENODEV;
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, gen_dev);
 	mca_device_set_name(mca_dev, smc_mca_adapter_names[adapter]);
 	mca_device_set_claim(mca_dev, 1);
diff --git a/drivers/net/smc-ultra.c b/drivers/net/smc-ultra.c
index a52b22d..d02bd7b 100644
--- a/drivers/net/smc-ultra.c
+++ b/drivers/net/smc-ultra.c
@@ -142,8 +142,6 @@ static int __init do_ultra_probe(struct net_device *dev)
 	int base_addr = dev->base_addr;
 	int irq = dev->irq;
 
-	SET_MODULE_OWNER(dev);
-
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = &ultra_poll;
 #endif
diff --git a/drivers/net/smc-ultra32.c b/drivers/net/smc-ultra32.c
index 88a30e5..043a500 100644
--- a/drivers/net/smc-ultra32.c
+++ b/drivers/net/smc-ultra32.c
@@ -132,8 +132,6 @@ struct net_device * __init ultra32_probe(int unit)
 		netdev_boot_setup_check(dev);
 	}
 
-	SET_MODULE_OWNER(dev);
-
 	irq = dev->irq;
 
 	/* EISA spec allows for up to 16 slots, but 8 is typical. */
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index db43e42..5f03e44 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -2181,7 +2181,6 @@ static int smc911x_drv_probe(struct platform_device *pdev)
 		ret = -ENOMEM;
 		goto release_1;
 	}
-	SET_MODULE_OWNER(ndev);
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
 	ndev->dma = (unsigned char)-1;
diff --git a/drivers/net/smc9194.c b/drivers/net/smc9194.c
index 36c1eba..0a79516 100644
--- a/drivers/net/smc9194.c
+++ b/drivers/net/smc9194.c
@@ -744,8 +744,6 @@ struct net_device * __init smc_init(int unit)
 		irq = dev->irq;
 	}
 
-	SET_MODULE_OWNER(dev);
-
 	if (io > 0x1ff) {	/* Check a single specified location. */
 		err = smc_probe(dev, io);
 	} else if (io != 0) {	/* Don't probe at all. */
diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 01cc3c7..c5837ab 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -2212,7 +2212,6 @@ static int smc_drv_probe(struct platform_device *pdev)
 		ret = -ENOMEM;
 		goto out_release_io;
 	}
-	SET_MODULE_OWNER(ndev);
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
 	ndev->dma = (unsigned char)-1;
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 590b12c..4557e27 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -2337,7 +2337,6 @@ spider_net_setup_netdev(struct spider_net_card *card)
 	struct sockaddr addr;
 	const u8 *mac;
 
-	SET_MODULE_OWNER(netdev);
 	SET_NETDEV_DEV(netdev, &card->pdev->dev);
 
 	pci_set_drvdata(card->pdev, netdev);
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 8b64786..9c2a2dc 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -720,7 +720,6 @@ static int __devinit starfire_init_one(struct pci_dev *pdev,
 		printk(KERN_ERR DRV_NAME " %d: cannot alloc etherdev, aborting\n", card_idx);
 		return -ENOMEM;
 	}
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	irq = pdev->irq;
diff --git a/drivers/net/stnic.c b/drivers/net/stnic.c
index e6f9042..b65be5d 100644
--- a/drivers/net/stnic.c
+++ b/drivers/net/stnic.c
@@ -112,7 +112,6 @@ static int __init stnic_probe(void)
   dev = alloc_ei_netdev();
   if (!dev)
   	return -ENOMEM;
-  SET_MODULE_OWNER(dev);
 
 #ifdef CONFIG_SH_STANDARD_BIOS
   sh_bios_get_node_addr (stnic_eadr);
diff --git a/drivers/net/sun3_82586.c b/drivers/net/sun3_82586.c
index b77ab6e..9b2a7f7 100644
--- a/drivers/net/sun3_82586.c
+++ b/drivers/net/sun3_82586.c
@@ -311,7 +311,6 @@ struct net_device * __init sun3_82586_probe(int unit)
 		sprintf(dev->name, "eth%d", unit);
 		netdev_boot_setup_check(dev);
 	}
-	SET_MODULE_OWNER(dev);
 
 	dev->irq = IE_IRQ;
 	dev->base_addr = ioaddr;
diff --git a/drivers/net/sun3lance.c b/drivers/net/sun3lance.c
index f1548c0..c67632d 100644
--- a/drivers/net/sun3lance.c
+++ b/drivers/net/sun3lance.c
@@ -274,7 +274,6 @@ struct net_device * __init sun3lance_probe(int unit)
 		sprintf(dev->name, "eth%d", unit);
 		netdev_boot_setup_check(dev);
 	}
-	SET_MODULE_OWNER(dev);
 
 	if (!lance_probe(dev))
 		goto out;
diff --git a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
index b3e0158..4ba3e48 100644
--- a/drivers/net/sunbmac.c
+++ b/drivers/net/sunbmac.c
@@ -1087,7 +1087,6 @@ static int __init bigmac_ether_init(struct sbus_dev *qec_sdev)
 	dev = alloc_etherdev(sizeof(struct bigmac));
 	if (!dev)
 		return -ENOMEM;
-	SET_MODULE_OWNER(dev);
 
 	if (version_printed++ == 0)
 		printk(KERN_INFO "%s", version);
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index a8f2af8..3c553dc 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -485,7 +485,6 @@ static int __devinit sundance_probe1 (struct pci_dev *pdev,
 	dev = alloc_etherdev(sizeof(*np));
 	if (!dev)
 		return -ENOMEM;
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	if (pci_request_regions(pdev, DRV_NAME))
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 4328038..6839afe 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -3026,7 +3026,6 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 		err = -ENOMEM;
 		goto err_disable_device;
 	}
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	gp = dev->priv;
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index 8b35f13..170580c 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -2680,7 +2680,6 @@ static int __devinit happy_meal_sbus_probe_one(struct sbus_dev *sdev, int is_qfe
 	dev = alloc_etherdev(sizeof(struct happy_meal));
 	if (!dev)
 		goto err_out;
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &sdev->ofdev.dev);
 
 	if (hme_version_printed++ == 0)
@@ -3022,7 +3021,6 @@ static int __devinit happy_meal_pci_probe(struct pci_dev *pdev,
 	err = -ENOMEM;
 	if (!dev)
 		goto err_out;
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	if (hme_version_printed++ == 0)
diff --git a/drivers/net/sunlance.c b/drivers/net/sunlance.c
index 68e4f66..3a5a57f 100644
--- a/drivers/net/sunlance.c
+++ b/drivers/net/sunlance.c
@@ -1458,7 +1458,6 @@ no_link_test:
 		lp->dregs = NULL;
 
 	lp->dev = dev;
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &sdev->ofdev.dev);
 	dev->open = &lance_open;
 	dev->stop = &lance_close;
diff --git a/drivers/net/sunqe.c b/drivers/net/sunqe.c
index 1b65ae8..b5c2974 100644
--- a/drivers/net/sunqe.c
+++ b/drivers/net/sunqe.c
@@ -898,7 +898,6 @@ static int __init qec_ether_init(struct sbus_dev *sdev)
 	/* Stop this QE. */
 	qe_stop(qe);
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &sdev->ofdev.dev);
 
 	dev->open = qe_open;
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index ec41469..1948ee4 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -682,7 +682,6 @@ static int __devinit tc35815_init_one (struct pci_dev *pdev,
 		dev_err(&pdev->dev, "unable to alloc new ethernet\n");
 		return -ENOMEM;
 	}
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	lp = dev->priv;
 
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 9034a05..36080ad 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -11833,7 +11833,6 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		goto err_out_free_res;
 	}
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 #if TG3_VLAN_TAG_USED
diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index 74eb121..c99ce74 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -556,7 +556,6 @@ static int __devinit TLan_probe1(struct pci_dev *pdev,
 		rc = -ENOMEM;
 		goto err_out_regions;
 	}
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	priv = netdev_priv(dev);
diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index 9f1b6ab..4306682 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -344,7 +344,6 @@ static int __devinit xl_probe(struct pci_dev *pdev,
 	dev->set_multicast_list=&xl_set_rx_mode;
 	dev->get_stats=&xl_get_stats ;
 	dev->set_mac_address=&xl_set_mac_address ; 
-	SET_MODULE_OWNER(dev); 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	pci_set_drvdata(pdev,dev) ; 
diff --git a/drivers/net/tokenring/abyss.c b/drivers/net/tokenring/abyss.c
index 1bdd3be..22fad51 100644
--- a/drivers/net/tokenring/abyss.c
+++ b/drivers/net/tokenring/abyss.c
@@ -116,8 +116,6 @@ static int __devinit abyss_attach(struct pci_dev *pdev, const struct pci_device_
 	if (!dev)
 		return -ENOMEM;
 
-	SET_MODULE_OWNER(dev);
-
 	if (!request_region(pci_ioaddr, ABYSS_IO_EXTENT, dev->name)) {
 		ret = -EBUSY;
 		goto err_out_trdev;
diff --git a/drivers/net/tokenring/lanstreamer.c b/drivers/net/tokenring/lanstreamer.c
index 5d849c0..a3476dc 100644
--- a/drivers/net/tokenring/lanstreamer.c
+++ b/drivers/net/tokenring/lanstreamer.c
@@ -244,7 +244,6 @@ static int __devinit streamer_init_one(struct pci_dev *pdev,
 		return -ENOMEM;
 	}
 
-	SET_MODULE_OWNER(dev);
 	streamer_priv = dev->priv;
 
 #if STREAMER_NETWORK_MONITOR
diff --git a/drivers/net/tokenring/madgemc.c b/drivers/net/tokenring/madgemc.c
index f8f4d74..b0d2311 100644
--- a/drivers/net/tokenring/madgemc.c
+++ b/drivers/net/tokenring/madgemc.c
@@ -168,7 +168,6 @@ static int __devinit madgemc_probe(struct device *device)
 		goto getout;
 	}
 
-	SET_MODULE_OWNER(dev);
 	dev->dma = 0;
 
 	card = kmalloc(sizeof(struct card_info), GFP_KERNEL);
diff --git a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olympic.c
index 09b3cfb..426fc25 100644
--- a/drivers/net/tokenring/olympic.c
+++ b/drivers/net/tokenring/olympic.c
@@ -260,7 +260,6 @@ static int __devinit olympic_probe(struct pci_dev *pdev, const struct pci_device
 	dev->set_multicast_list=&olympic_set_rx_mode;
 	dev->get_stats=&olympic_get_stats ;
 	dev->set_mac_address=&olympic_set_mac_address ;  
-	SET_MODULE_OWNER(dev) ; 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	pci_set_drvdata(pdev,dev) ; 
diff --git a/drivers/net/tokenring/proteon.c b/drivers/net/tokenring/proteon.c
index cb7dbb6..85d156d 100644
--- a/drivers/net/tokenring/proteon.c
+++ b/drivers/net/tokenring/proteon.c
@@ -126,7 +126,6 @@ static int __init setup_card(struct net_device *dev, struct device *pdev)
 	if (!dev)
 		return -ENOMEM;
 
-	SET_MODULE_OWNER(dev);
 	if (dev->base_addr)	/* probe specific location */
 		err = proteon_probe1(dev, dev->base_addr);
 	else {
diff --git a/drivers/net/tokenring/skisa.c b/drivers/net/tokenring/skisa.c
index 33afea3..ecbddc8 100644
--- a/drivers/net/tokenring/skisa.c
+++ b/drivers/net/tokenring/skisa.c
@@ -143,7 +143,6 @@ static int __init setup_card(struct net_device *dev, struct device *pdev)
 	if (!dev)
 		return -ENOMEM;
 
-	SET_MODULE_OWNER(dev);
 	if (dev->base_addr)	/* probe specific location */
 		err = sk_isa_probe1(dev, dev->base_addr);
 	else {
diff --git a/drivers/net/tokenring/smctr.c b/drivers/net/tokenring/smctr.c
index f83bb5c..93da3a3 100644
--- a/drivers/net/tokenring/smctr.c
+++ b/drivers/net/tokenring/smctr.c
@@ -3583,8 +3583,6 @@ struct net_device __init *smctr_probe(int unit)
 	if (!dev)
 		return ERR_PTR(-ENOMEM);
 
-	SET_MODULE_OWNER(dev);
-
 	if (unit >= 0) {
 		sprintf(dev->name, "tr%d", unit);
 		netdev_boot_setup_check(dev);
diff --git a/drivers/net/tokenring/tmspci.c b/drivers/net/tokenring/tmspci.c
index 3b2f00b..69a4c40 100644
--- a/drivers/net/tokenring/tmspci.c
+++ b/drivers/net/tokenring/tmspci.c
@@ -115,7 +115,6 @@ static int __devinit tms_pci_attach(struct pci_dev *pdev, const struct pci_devic
 	dev = alloc_trdev(sizeof(struct net_local));
 	if (!dev)
 		return -ENOMEM;
-	SET_MODULE_OWNER(dev);
 
 	if (!request_region(pci_ioaddr, TMS_PCI_IO_EXTENT, dev->name)) {
 		ret = -EBUSY;
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index 1aabc91..bb5b1eb 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -1610,7 +1610,6 @@ tsi108_init_one(struct platform_device *pdev)
 	 */
 
 	dev->features = NETIF_F_HIGHDMA;
-	SET_MODULE_OWNER(dev);
 
 	spin_lock_init(&data->txlock);
 	spin_lock_init(&data->misclock);
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index d380e0b..bd04e93 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -1944,7 +1944,6 @@ static int __devinit de_init_one (struct pci_dev *pdev,
 	if (!dev)
 		return -ENOMEM;
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	dev->open = de_open;
 	dev->stop = de_close;
diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index 0990289..ba7f47c 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -1261,7 +1261,6 @@ de4x5_hw_init(struct net_device *dev, u_long iobase, struct device *gendev)
     }
 
     /* The DE4X5-specific entries in the device structure. */
-    SET_MODULE_OWNER(dev);
     SET_NETDEV_DEV(dev, gendev);
     dev->open = &de4x5_open;
     dev->hard_start_xmit = &de4x5_queue_pkt;
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index dab74fe..e2596e9 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -372,7 +372,6 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 	dev = alloc_etherdev(sizeof(*db));
 	if (dev == NULL)
 		return -ENOMEM;
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index eca984f..6cf6877 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -1337,7 +1337,6 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 		return -ENOMEM;
 	}
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	if (pci_resource_len (pdev, 0) < tulip_tbl[chip_idx].io_size) {
 		printk (KERN_ERR PFX "%s: I/O region (0x%llx@0x%llx) too small, "
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index ca2548e..97809aa 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -268,7 +268,6 @@ static int __devinit uli526x_init_one (struct pci_dev *pdev,
 	dev = alloc_etherdev(sizeof(*db));
 	if (dev == NULL)
 		return -ENOMEM;
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index 5824f6a..396f845 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -370,7 +370,6 @@ static int __devinit w840_probe1 (struct pci_dev *pdev,
 	dev = alloc_etherdev(sizeof(*np));
 	if (!dev)
 		return -ENOMEM;
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	if (pci_request_regions(pdev, DRV_NAME))
diff --git a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
index 16a54e6..6b8fd05 100644
--- a/drivers/net/tulip/xircom_cb.c
+++ b/drivers/net/tulip/xircom_cb.c
@@ -252,7 +252,6 @@ static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_
 		goto tx_buf_fail;
 	}
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 
diff --git a/drivers/net/tulip/xircom_tulip_cb.c b/drivers/net/tulip/xircom_tulip_cb.c
index fc439f3..c3f8e30 100644
--- a/drivers/net/tulip/xircom_tulip_cb.c
+++ b/drivers/net/tulip/xircom_tulip_cb.c
@@ -547,7 +547,6 @@ static int __devinit xircom_init_one(struct pci_dev *pdev, const struct pci_devi
 		printk (KERN_ERR DRV_NAME "%d: cannot alloc etherdev, aborting\n", board_idx);
 		return -ENOMEM;
 	}
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	dev->base_addr = ioaddr;
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 62b2b30..6c58d45 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -434,7 +434,6 @@ static void tun_setup(struct net_device *dev)
 	tun->owner = -1;
 	tun->group = -1;
 
-	SET_MODULE_OWNER(dev);
 	dev->open = tun_net_open;
 	dev->hard_start_xmit = tun_net_xmit;
 	dev->stop = tun_net_close;
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 0358720..bfdd6c4 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -2340,7 +2340,6 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		err = -ENOMEM;
 		goto error_out;
 	}
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	err = pci_enable_device(pdev);
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 12e01b2..37f0d1c 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3954,7 +3954,6 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	/* Set the dev->base_addr to the gfar reg region */
 	dev->base_addr = (unsigned long)(ug_info->uf_info.regs);
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, device);
 
 	/* Fill in the dev structure */
diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index 524dc5f..58a53a6 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -1152,8 +1152,6 @@ err_fw:
 
 	INIT_DELAYED_WORK(&kaweth->lowmem_work, kaweth_resubmit_tl);
 
-	SET_MODULE_OWNER(netdev);
-
 	usb_set_intfdata(intf, kaweth);
 
 #if 0
diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index 04cba6b..e9419f6 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -1322,7 +1322,6 @@ static int pegasus_probe(struct usb_interface *intf,
 	pegasus->intf = intf;
 	pegasus->usb = dev;
 	pegasus->net = net;
-	SET_MODULE_OWNER(net);
 	net->open = pegasus_open;
 	net->stop = pegasus_close;
 	net->watchdog_timeo = PEGASUS_TX_TIMEOUT;
diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index fa598f0..5d350be 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -918,7 +918,6 @@ static int rtl8150_probe(struct usb_interface *intf,
 	
 	dev->udev = udev;
 	dev->netdev = netdev;
-	SET_MODULE_OWNER(netdev);
 	netdev->open = rtl8150_open;
 	netdev->stop = rtl8150_close;
 	netdev->do_ioctl = rtl8150_ioctl;
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 37bf4f2..a702b5f 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1158,7 +1158,6 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	init_timer (&dev->delay);
 	mutex_init (&dev->phy_mutex);
 
-	SET_MODULE_OWNER (net);
 	dev->net = net;
 	strcpy (net->name, "usb%d");
 	memcpy (net->dev_addr, node_id, sizeof node_id);
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index b56dff2..0a3ac01 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -703,7 +703,6 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 		printk(KERN_ERR "alloc_etherdev failed\n");
 		goto err_out;
 	}
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	rp = netdev_priv(dev);
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 93574ad..3b04c3e 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -712,7 +712,6 @@ static int __devinit velocity_found1(struct pci_dev *pdev, const struct pci_devi
 
 	/* Chain it all together */
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	vptr = netdev_priv(dev);
 
diff --git a/drivers/net/wan/c101.c b/drivers/net/wan/c101.c
index 8ead774..c4c8eab 100644
--- a/drivers/net/wan/c101.c
+++ b/drivers/net/wan/c101.c
@@ -363,7 +363,6 @@ static int __init c101_run(unsigned long irq, unsigned long winbase)
 	hdlc = dev_to_hdlc(dev);
 
 	spin_lock_init(&card->lock);
-	SET_MODULE_OWNER(dev);
 	dev->irq = irq;
 	dev->mem_start = winbase;
 	dev->mem_end = winbase + C101_MAPPED_RAM_SIZE - 1;
diff --git a/drivers/net/wan/cycx_x25.c b/drivers/net/wan/cycx_x25.c
index a8af28b..46e0531 100644
--- a/drivers/net/wan/cycx_x25.c
+++ b/drivers/net/wan/cycx_x25.c
@@ -508,7 +508,6 @@ static int cycx_netdevice_init(struct net_device *dev)
 
 	/* Set transmit buffer queue length */
 	dev->tx_queue_len	= 10;
-	SET_MODULE_OWNER(dev);
 
 	/* Initialize socket buffers */
 	cycx_x25_set_chan_state(dev, WAN_DISCONNECTED);
diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 50d2f91..33dc713 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -925,7 +925,6 @@ static int dscc4_found1(struct pci_dev *pdev, void __iomem *ioaddr)
 	        d->do_ioctl = dscc4_ioctl;
 		d->tx_timeout = dscc4_tx_timeout;
 		d->watchdog_timeo = TX_TIMEOUT;
-		SET_MODULE_OWNER(d);
 		SET_NETDEV_DEV(d, &pdev->dev);
 
 		dpriv->dev_id = i;
diff --git a/drivers/net/wan/hostess_sv11.c b/drivers/net/wan/hostess_sv11.c
index bf5f8d9..83dbc92 100644
--- a/drivers/net/wan/hostess_sv11.c
+++ b/drivers/net/wan/hostess_sv11.c
@@ -241,8 +241,6 @@ static struct sv11_device *sv11_init(int iobase, int irq)
 	if(!sv->netdev.dev)
 		goto fail2;
 
-	SET_MODULE_OWNER(sv->netdev.dev);
-
 	dev=&sv->sync;
 	
 	/*
diff --git a/drivers/net/wan/lapbether.c b/drivers/net/wan/lapbether.c
index 6c302e9..519489c 100644
--- a/drivers/net/wan/lapbether.c
+++ b/drivers/net/wan/lapbether.c
@@ -326,7 +326,6 @@ static void lapbeth_setup(struct net_device *dev)
 	dev->hard_header_len = 3;
 	dev->mtu             = 1000;
 	dev->addr_len        = 0;
-	SET_MODULE_OWNER(dev);
 }
 
 /*
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index ae132c1..5ea8772 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -883,7 +883,6 @@ static int __devinit lmc_init_one(struct pci_dev *pdev,
     dev->base_addr = pci_resource_start(pdev, 0);
     dev->irq = pdev->irq;
 
-    SET_MODULE_OWNER(dev);
     SET_NETDEV_DEV(dev, &pdev->dev);
 
     /*
diff --git a/drivers/net/wan/n2.c b/drivers/net/wan/n2.c
index cbdf0b7..0a566b0 100644
--- a/drivers/net/wan/n2.c
+++ b/drivers/net/wan/n2.c
@@ -459,7 +459,6 @@ static int __init n2_run(unsigned long io, unsigned long irq,
 			port->log_node = 1;
 
 		spin_lock_init(&port->lock);
-		SET_MODULE_OWNER(dev);
 		dev->irq = irq;
 		dev->mem_start = winbase;
 		dev->mem_end = winbase + USE_WINDOWSIZE - 1;
diff --git a/drivers/net/wan/pc300too.c b/drivers/net/wan/pc300too.c
index 6353cb5..bf1b015 100644
--- a/drivers/net/wan/pc300too.c
+++ b/drivers/net/wan/pc300too.c
@@ -468,7 +468,6 @@ static int __devinit pc300_pci_init_one(struct pci_dev *pdev,
 		port->phy_node = i;
 
 		spin_lock_init(&port->lock);
-		SET_MODULE_OWNER(dev);
 		dev->irq = card->irq;
 		dev->mem_start = ramphys;
 		dev->mem_end = ramphys + ramsize - 1;
diff --git a/drivers/net/wan/pci200syn.c b/drivers/net/wan/pci200syn.c
index 092e51d..b595b64 100644
--- a/drivers/net/wan/pci200syn.c
+++ b/drivers/net/wan/pci200syn.c
@@ -415,7 +415,6 @@ static int __devinit pci200_pci_init_one(struct pci_dev *pdev,
 		port->phy_node = i;
 
 		spin_lock_init(&port->lock);
-		SET_MODULE_OWNER(dev);
 		dev->irq = card->irq;
 		dev->mem_start = ramphys;
 		dev->mem_end = ramphys + ramsize - 1;
diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index 1cc18e7..13a17e8 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -215,8 +215,6 @@ static void __init sbni_devsetup(struct net_device *dev)
 	dev->get_stats		= &sbni_get_stats;
 	dev->set_multicast_list	= &set_multicast_list;
 	dev->do_ioctl		= &sbni_ioctl;
-
-	SET_MODULE_OWNER( dev );
 }
 
 int __init sbni_probe(int unit)
diff --git a/drivers/net/wan/sdla.c b/drivers/net/wan/sdla.c
index 792e588..b39a541 100644
--- a/drivers/net/wan/sdla.c
+++ b/drivers/net/wan/sdla.c
@@ -1603,7 +1603,6 @@ static void setup_sdla(struct net_device *dev)
 
 	netdev_boot_setup_check(dev);
 
-	SET_MODULE_OWNER(dev);
 	dev->flags		= 0;
 	dev->type		= 0xFFFF;
 	dev->hard_header_len	= 0;
diff --git a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
index 3c78f98..8e320b7 100644
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -779,7 +779,6 @@ static int __devinit wanxl_pci_init_one(struct pci_dev *pdev,
 		port->dev = dev;
 		hdlc = dev_to_hdlc(dev);
 		spin_lock_init(&port->lock);
-		SET_MODULE_OWNER(dev);
 		dev->tx_queue_len = 50;
 		dev->do_ioctl = wanxl_ioctl;
 		dev->open = wanxl_open;
diff --git a/drivers/net/wd.c b/drivers/net/wd.c
index a032681..cef3658 100644
--- a/drivers/net/wd.c
+++ b/drivers/net/wd.c
@@ -93,8 +93,6 @@ static int __init do_wd_probe(struct net_device *dev)
 	int mem_start = dev->mem_start;
 	int mem_end = dev->mem_end;
 
-	SET_MODULE_OWNER(dev);
-
 	if (base_addr > 0x1ff) {	/* Check a user specified location. */
 		r = request_region(base_addr, WD_IO_EXTENT, "wd-probe");
 		if ( r == NULL)
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index ee1cc14..1429706 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -2870,7 +2870,6 @@ static struct net_device *_init_airo_card( unsigned short irq, int port,
 	dev->base_addr = port;
 
 	SET_NETDEV_DEV(dev, dmdev);
-	SET_MODULE_OWNER(dev);
 
 	reset_card (dev, 1);
 	msleep(400);
diff --git a/drivers/net/wireless/airport.c b/drivers/net/wireless/airport.c
index 7d5b8c2..6f7eb9f 100644
--- a/drivers/net/wireless/airport.c
+++ b/drivers/net/wireless/airport.c
@@ -197,7 +197,6 @@ airport_attach(struct macio_dev *mdev, const struct of_device_id *match)
 		return -EBUSY;
 	}
 
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &mdev->ofdev.dev);
 
 	macio_set_drvdata(mdev, dev);
diff --git a/drivers/net/wireless/arlan-main.c b/drivers/net/wireless/arlan-main.c
index 498e848..3eaaab0 100644
--- a/drivers/net/wireless/arlan-main.c
+++ b/drivers/net/wireless/arlan-main.c
@@ -1792,8 +1792,6 @@ struct net_device * __init arlan_probe(int unit)
 	if (!dev)
 		return ERR_PTR(-ENOMEM);
 
-	SET_MODULE_OWNER(dev);
-
 	if (unit >= 0) {
 		sprintf(dev->name, "eth%d", unit);
 		netdev_boot_setup_check(dev);
diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index 51a7db5..47dbdf9 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -1603,7 +1603,6 @@ struct net_device *init_atmel_card(unsigned short irq, unsigned long port,
 	       dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
 	       dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5] );
 
-	SET_MODULE_OWNER(dev);
 	return dev;
 
 err_out_res:
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index c5d6753..618d1a2 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -4080,7 +4080,6 @@ static int __devinit bcm43xx_init_one(struct pci_dev *pdev,
 		goto out;
 	}
 	/* initialize the net_device struct */
-	SET_MODULE_OWNER(net_dev);
 	SET_NETDEV_DEV(net_dev, &pdev->dev);
 
 	net_dev->open = bcm43xx_net_open;
diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index 8990585..12a6887 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -6239,8 +6239,6 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
 
 	IPW_DEBUG_INFO("Attempting to register device...\n");
 
-	SET_MODULE_OWNER(dev);
-
 	printk(KERN_INFO DRV_NAME
 	       ": Detected Intel PRO/Wireless 2100 Network Connection\n");
 
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 61497c4..afad8bb 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -11625,7 +11625,6 @@ static int ipw_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto out_destroy_workqueue;
 	}
 
-	SET_MODULE_OWNER(net_dev);
 	SET_NETDEV_DEV(net_dev, &pdev->dev);
 
 	mutex_lock(&priv->mutex);
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 9f36624..74dc4d4 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -796,8 +796,6 @@ wlan_private *libertas_add_card(void *card, struct device *dmdev)
 	priv->mesh_open = 0;
 	priv->infra_open = 0;
 
-	SET_MODULE_OWNER(dev);
-
 	/* Setup the OS Interface to our functions */
 	dev->open = wlan_open;
 	dev->hard_start_xmit = wlan_pre_start_xmit;
@@ -915,8 +913,6 @@ int libertas_add_mesh(wlan_private *priv, struct device *dev)
 	mesh_dev->priv = priv;
 	priv->mesh_dev = mesh_dev;
 
-	SET_MODULE_OWNER(mesh_dev);
-
 	mesh_dev->open = mesh_open;
 	mesh_dev->hard_start_xmit = mesh_pre_start_xmit;
 	mesh_dev->stop = mesh_close;
diff --git a/drivers/net/wireless/netwave_cs.c b/drivers/net/wireless/netwave_cs.c
index 45b00e1..389fdd3 100644
--- a/drivers/net/wireless/netwave_cs.c
+++ b/drivers/net/wireless/netwave_cs.c
@@ -412,7 +412,6 @@ static int netwave_probe(struct pcmcia_device *link)
     spin_lock_init(&priv->spinlock);
 
     /* Netwave specific entries in the device structure */
-    SET_MODULE_OWNER(dev);
     dev->hard_start_xmit = &netwave_start_xmit;
     dev->get_stats  = &netwave_get_stats;
     dev->set_multicast_list = &set_multicast_list;
diff --git a/drivers/net/wireless/orinoco_cs.c b/drivers/net/wireless/orinoco_cs.c
index d1e5022..8b7f576 100644
--- a/drivers/net/wireless/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco_cs.c
@@ -313,7 +313,6 @@ orinoco_cs_config(struct pcmcia_device *link)
 	/* Ok, we have the configuration, prepare to register the netdev */
 	dev->base_addr = link->io.BasePort1;
 	dev->irq = link->irq.AssignedIRQ;
-	SET_MODULE_OWNER(dev);
 	card->node.major = card->node.minor = 0;
 
 	SET_NETDEV_DEV(dev, &handle_to_dev(link));
diff --git a/drivers/net/wireless/orinoco_nortel.c b/drivers/net/wireless/orinoco_nortel.c
index eaf3d13..35ec5fc 100644
--- a/drivers/net/wireless/orinoco_nortel.c
+++ b/drivers/net/wireless/orinoco_nortel.c
@@ -193,7 +193,6 @@ static int orinoco_nortel_init_one(struct pci_dev *pdev,
 	card = priv->card;
 	card->bridge_io = bridge_io;
 	card->attr_io = attr_io;
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	hermes_struct_init(&priv->hw, hermes_io, HERMES_16BIT_REGSPACING);
diff --git a/drivers/net/wireless/orinoco_pci.c b/drivers/net/wireless/orinoco_pci.c
index 97a8b4f..2547d5d 100644
--- a/drivers/net/wireless/orinoco_pci.c
+++ b/drivers/net/wireless/orinoco_pci.c
@@ -148,7 +148,6 @@ static int orinoco_pci_init_one(struct pci_dev *pdev,
 
 	priv = netdev_priv(dev);
 	card = priv->card;
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	hermes_struct_init(&priv->hw, hermes_io, HERMES_32BIT_REGSPACING);
diff --git a/drivers/net/wireless/orinoco_plx.c b/drivers/net/wireless/orinoco_plx.c
index 31162ac..98fe165 100644
--- a/drivers/net/wireless/orinoco_plx.c
+++ b/drivers/net/wireless/orinoco_plx.c
@@ -232,7 +232,6 @@ static int orinoco_plx_init_one(struct pci_dev *pdev,
 	card = priv->card;
 	card->bridge_io = bridge_io;
 	card->attr_io = attr_io;
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	hermes_struct_init(&priv->hw, hermes_io, HERMES_16BIT_REGSPACING);
diff --git a/drivers/net/wireless/orinoco_tmd.c b/drivers/net/wireless/orinoco_tmd.c
index 7c7b960..db781e8 100644
--- a/drivers/net/wireless/orinoco_tmd.c
+++ b/drivers/net/wireless/orinoco_tmd.c
@@ -134,7 +134,6 @@ static int orinoco_tmd_init_one(struct pci_dev *pdev,
 	priv = netdev_priv(dev);
 	card = priv->card;
 	card->bridge_io = bridge_io;
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	hermes_struct_init(&priv->hw, hermes_io, HERMES_16BIT_REGSPACING);
diff --git a/drivers/net/wireless/prism54/islpci_dev.c b/drivers/net/wireless/prism54/islpci_dev.c
index 0847953..219dd65 100644
--- a/drivers/net/wireless/prism54/islpci_dev.c
+++ b/drivers/net/wireless/prism54/islpci_dev.c
@@ -808,7 +808,6 @@ islpci_setup(struct pci_dev *pdev)
 	if (!ndev)
 		return ndev;
 
-	SET_MODULE_OWNER(ndev);
 	pci_set_drvdata(pdev, ndev);
 #if defined(SET_NETDEV_DEV)
 	SET_NETDEV_DEV(ndev, &pdev->dev);
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 3be6242..7bc2ffa 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -356,7 +356,6 @@ static int ray_probe(struct pcmcia_device *p_dev)
     dev->set_multicast_list = &set_multicast_list;
 
     DEBUG(2,"ray_cs ray_attach calling ether_setup.)\n");
-    SET_MODULE_OWNER(dev);
     dev->init = &ray_dev_init;
     dev->open = &ray_open;
     dev->stop = &ray_dev_close;
diff --git a/drivers/net/wireless/spectrum_cs.c b/drivers/net/wireless/spectrum_cs.c
index af70460..98df9bc 100644
--- a/drivers/net/wireless/spectrum_cs.c
+++ b/drivers/net/wireless/spectrum_cs.c
@@ -782,7 +782,6 @@ spectrum_cs_config(struct pcmcia_device *link)
 	/* Ok, we have the configuration, prepare to register the netdev */
 	dev->base_addr = link->io.BasePort1;
 	dev->irq = link->irq.AssignedIRQ;
-	SET_MODULE_OWNER(dev);
 	card->node.major = card->node.minor = 0;
 
 	/* Reset card and download firmware */
diff --git a/drivers/net/wireless/strip.c b/drivers/net/wireless/strip.c
index ef32a5c..7a3bf28 100644
--- a/drivers/net/wireless/strip.c
+++ b/drivers/net/wireless/strip.c
@@ -2507,8 +2507,6 @@ static void strip_dev_setup(struct net_device *dev)
 	 * Finish setting up the DEVICE info.
 	 */
 
-	SET_MODULE_OWNER(dev);
-
 	dev->trans_start = 0;
 	dev->last_rx = 0;
 	dev->tx_queue_len = 30;	/* Drop after 30 frames queued */
diff --git a/drivers/net/wireless/wavelan.c b/drivers/net/wireless/wavelan.c
index 1cf090d..b876bf6 100644
--- a/drivers/net/wireless/wavelan.c
+++ b/drivers/net/wireless/wavelan.c
@@ -4177,7 +4177,6 @@ static int __init wavelan_config(struct net_device *dev, unsigned short ioaddr)
 	/* Init spinlock */
 	spin_lock_init(&lp->spinlock);
 
-	SET_MODULE_OWNER(dev);
 	dev->open = wavelan_open;
 	dev->stop = wavelan_close;
 	dev->hard_start_xmit = wavelan_packet_xmit;
diff --git a/drivers/net/wireless/wavelan_cs.c b/drivers/net/wireless/wavelan_cs.c
index 5740d4d..1cc5180 100644
--- a/drivers/net/wireless/wavelan_cs.c
+++ b/drivers/net/wireless/wavelan_cs.c
@@ -4577,7 +4577,6 @@ wavelan_probe(struct pcmcia_device *p_dev)
   lp->dev = dev;
 
   /* wavelan NET3 callbacks */
-  SET_MODULE_OWNER(dev);
   dev->open = &wavelan_open;
   dev->stop = &wavelan_close;
   dev->hard_start_xmit = &wavelan_packet_xmit;
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index c8b5c22..b2f5b1b 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -2004,8 +2004,6 @@ static int wl3501_config(struct pcmcia_device *link)
 		goto failed;
 	}
 
-	SET_MODULE_OWNER(dev);
-
 	this = dev->priv;
 	/*
 	 * At this point, the dev_node_t structure(s) should be initialized and
diff --git a/drivers/net/wireless/zd1211rw/zd_netdev.c b/drivers/net/wireless/zd1211rw/zd_netdev.c
index 8bda48d..047cab3 100644
--- a/drivers/net/wireless/zd1211rw/zd_netdev.c
+++ b/drivers/net/wireless/zd1211rw/zd_netdev.c
@@ -233,7 +233,6 @@ struct net_device *zd_netdev_alloc(struct usb_interface *intf)
 		return NULL;
 	}
 
-	SET_MODULE_OWNER(netdev);
 	SET_NETDEV_DEV(netdev, &intf->dev);
 
 	dev_dbg_f(&intf->dev, "netdev->flags %#06hx\n", netdev->flags);
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 4445810..4c428b4 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1208,7 +1208,6 @@ static struct net_device * __devinit xennet_create_dev(struct xenbus_device *dev
 	netdev->features        = NETIF_F_IP_CSUM;
 
 	SET_ETHTOOL_OPS(netdev, &xennet_ethtool_ops);
-	SET_MODULE_OWNER(netdev);
 	SET_NETDEV_DEV(netdev, &dev->dev);
 
 	np->netdev = netdev;
diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index 870c539..29e9695 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -392,7 +392,6 @@ static int __devinit yellowfin_init_one(struct pci_dev *pdev,
 		printk (KERN_ERR PFX "cannot allocate ethernet device\n");
 		return -ENOMEM;
 	}
-	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	np = netdev_priv(dev);
diff --git a/drivers/net/znet.c b/drivers/net/znet.c
index 4032e9f..dcd4e1b 100644
--- a/drivers/net/znet.c
+++ b/drivers/net/znet.c
@@ -388,8 +388,6 @@ static int __init znet_probe (void)
 	if (!dev)
 		return -ENOMEM;
 
-	SET_MODULE_OWNER (dev);
-
 	znet = dev->priv;
 
 	netinfo = (struct netidblk *)p;
diff --git a/drivers/net/zorro8390.c b/drivers/net/zorro8390.c
index d85e2ea..a45f995 100644
--- a/drivers/net/zorro8390.c
+++ b/drivers/net/zorro8390.c
@@ -125,7 +125,6 @@ static int __devinit zorro8390_init_one(struct zorro_dev *z,
     dev = ____alloc_ei_netdev(0);
     if (!dev)
 	return -ENOMEM;
-    SET_MODULE_OWNER(dev);
     if (!request_mem_region(ioaddr, NE_IO_EXTENT*2, DRV_NAME)) {
 	free_netdev(dev);
 	return -EBUSY;
diff --git a/drivers/s390/net/claw.c b/drivers/s390/net/claw.c
index 023455a..399695f 100644
--- a/drivers/s390/net/claw.c
+++ b/drivers/s390/net/claw.c
@@ -3891,7 +3891,6 @@ claw_init_netdevice(struct net_device * dev)
 	dev->type = ARPHRD_SLIP;
 	dev->tx_queue_len = 1300;
 	dev->flags = IFF_POINTOPOINT | IFF_NOARP;
-	SET_MODULE_OWNER(dev);
 #ifdef FUNCTRACE
         printk(KERN_INFO "%s:%s Exit\n",dev->name,__FUNCTION__);
 #endif
diff --git a/drivers/s390/net/ctcmain.c b/drivers/s390/net/ctcmain.c
index 92e8a37..4499372 100644
--- a/drivers/s390/net/ctcmain.c
+++ b/drivers/s390/net/ctcmain.c
@@ -2823,7 +2823,6 @@ ctc_init_netdevice(struct net_device * dev, int alloc_device,
 	dev->type = ARPHRD_SLIP;
 	dev->tx_queue_len = 100;
 	dev->flags = IFF_POINTOPOINT | IFF_NOARP;
-	SET_MODULE_OWNER(dev);
 	return dev;
 }
 
diff --git a/drivers/s390/net/lcs.c b/drivers/s390/net/lcs.c
index 08a994f..e4b11af 100644
--- a/drivers/s390/net/lcs.c
+++ b/drivers/s390/net/lcs.c
@@ -2145,7 +2145,6 @@ lcs_new_device(struct ccwgroup_device *ccwgdev)
 	card->dev->stop = lcs_stop_device;
 	card->dev->hard_start_xmit = lcs_start_xmit;
 	card->dev->get_stats = lcs_getstats;
-	SET_MODULE_OWNER(dev);
 	memcpy(card->dev->dev_addr, card->mac, LCS_MAC_LENGTH);
 #ifdef CONFIG_IP_MULTICAST
 	if (!lcs_check_multicast_support(card))
diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index 2688894..4d18d64 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -1904,7 +1904,6 @@ static void netiucv_setup_netdevice(struct net_device *dev)
 	dev->type                = ARPHRD_SLIP;
 	dev->tx_queue_len        = NETIUCV_QUEUELEN_DEFAULT;
 	dev->flags	         = IFF_POINTOPOINT | IFF_NOARP;
-	SET_MODULE_OWNER(dev);
 }
 
 /**
diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index f3e6fbe..8c46978 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -6649,7 +6649,6 @@ qeth_netdev_init(struct net_device *dev)
 	dev->mtu = card->info.initial_mtu;
 	if (card->info.type != QETH_CARD_TYPE_OSN)
 		SET_ETHTOOL_OPS(dev, &qeth_ethtool_ops);
-	SET_MODULE_OWNER(dev);
 	return 0;
 }
 
diff --git a/drivers/usb/gadget/ether.c b/drivers/usb/gadget/ether.c
index 593e235..f700554 100644
--- a/drivers/usb/gadget/ether.c
+++ b/drivers/usb/gadget/ether.c
@@ -2484,7 +2484,6 @@ autoconf_fail:
 
 	/* network device setup */
 	dev->net = net;
-	SET_MODULE_OWNER (net);
 	strcpy (net->name, "usb%d");
 	dev->cdc = cdc;
 	dev->zlp = zlp;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e679b27..91b39c2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -587,7 +587,6 @@ static inline void *netdev_priv(const struct net_device *dev)
 	return dev->priv;
 }
 
-#define SET_MODULE_OWNER(dev) do { } while (0)
 /* Set the sysfs physical device reference for the network logical device
  * if set prior to registration will cause a symlink during initialization.
  */
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 1583c5e..1e96808 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -349,8 +349,6 @@ static int vlan_dev_init(struct net_device *dev)
 
 void vlan_setup(struct net_device *new_dev)
 {
-	SET_MODULE_OWNER(new_dev);
-
 	ether_setup(new_dev);
 
 	/* new_dev->ifindex = 0;  it will be set when added to
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 0eded17..293d25b 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -171,7 +171,6 @@ void br_dev_setup(struct net_device *dev)
 	dev->set_multicast_list = br_dev_set_multicast_list;
 	dev->change_mtu = br_change_mtu;
 	dev->destructor = free_netdev;
-	SET_MODULE_OWNER(dev);
 	SET_ETHTOOL_OPS(dev, &br_ethtool_ops);
 	dev->stop = br_dev_stop;
 	dev->tx_queue_len = 0;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 5c14ed6..4f83529 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1132,7 +1132,6 @@ static int ipgre_close(struct net_device *dev)
 
 static void ipgre_tunnel_setup(struct net_device *dev)
 {
-	SET_MODULE_OWNER(dev);
 	dev->uninit		= ipgre_tunnel_uninit;
 	dev->destructor 	= free_netdev;
 	dev->hard_start_xmit	= ipgre_tunnel_xmit;
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 3964372..33c8527 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -237,7 +237,6 @@ static struct ip_tunnel * ipip_tunnel_locate(struct ip_tunnel_parm *parms, int c
 		return NULL;
 
 	nt = netdev_priv(dev);
-	SET_MODULE_OWNER(dev);
 	dev->init = ipip_tunnel_init;
 	nt->parms = *parms;
 
@@ -775,7 +774,6 @@ static int ipip_tunnel_change_mtu(struct net_device *dev, int new_mtu)
 
 static void ipip_tunnel_setup(struct net_device *dev)
 {
-	SET_MODULE_OWNER(dev);
 	dev->uninit		= ipip_tunnel_uninit;
 	dev->hard_start_xmit	= ipip_tunnel_xmit;
 	dev->get_stats		= ipip_tunnel_get_stats;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index ca774d8..acb24cd 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1313,7 +1313,6 @@ ip6_tnl_change_mtu(struct net_device *dev, int new_mtu)
 
 static void ip6_tnl_dev_setup(struct net_device *dev)
 {
-	SET_MODULE_OWNER(dev);
 	dev->uninit = ip6_tnl_dev_uninit;
 	dev->destructor = free_netdev;
 	dev->hard_start_xmit = ip6_tnl_xmit;
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index eb20bb6..c904c52 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -714,7 +714,6 @@ static int ipip6_tunnel_change_mtu(struct net_device *dev, int new_mtu)
 
 static void ipip6_tunnel_setup(struct net_device *dev)
 {
-	SET_MODULE_OWNER(dev);
 	dev->uninit		= ipip6_tunnel_uninit;
 	dev->destructor 	= free_netdev;
 	dev->hard_start_xmit	= ipip6_tunnel_xmit;
diff --git a/net/irda/irlan/irlan_eth.c b/net/irda/irlan/irlan_eth.c
index c421521..340f04a 100644
--- a/net/irda/irlan/irlan_eth.c
+++ b/net/irda/irlan/irlan_eth.c
@@ -60,8 +60,6 @@ static void irlan_eth_setup(struct net_device *dev)
 	dev->set_multicast_list = irlan_eth_set_multicast_list;
 	dev->destructor		= free_netdev;
 
-	SET_MODULE_OWNER(dev);
-
 	ether_setup(dev);
 
 	/*
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 0968184..146f453 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -432,7 +432,6 @@ static __init void teql_master_setup(struct net_device *dev)
 	dev->tx_queue_len	= 100;
 	dev->flags		= IFF_NOARP;
 	dev->hard_header_len	= LL_MAX_HEADER;
-	SET_MODULE_OWNER(dev);
 }
 
 static LIST_HEAD(master_dev_list);
