From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 2/3] net: remove use of ndo_set_multicast_list in drivers
Date: Tue, 16 Aug 2011 18:29:01 +0200
Message-ID: <1313512142-3355-3-git-send-email-jpirko@redhat.com>
References: <1313512142-3355-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, kaber@trash.net, yoshfuji@linux-ipv6.org,
	rdunlap@xenotime.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	mirqus@gmail.com, jesse@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26758 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752197Ab1HPSEH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2011 14:04:07 -0400
In-Reply-To: <1313512142-3355-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

replace it by ndo_set_rx_mode

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 arch/ia64/hp/sim/simeth.c                          |    2 +-
 arch/um/drivers/net_kern.c                         |    2 +-
 arch/xtensa/platforms/iss/network.c                |    2 +-
 drivers/infiniband/hw/nes/nes_nic.c                |    2 +-
 drivers/infiniband/ulp/ipoib/ipoib_main.c          |    2 +-
 drivers/media/dvb/dvb-core/dvb_net.c               |    2 +-
 drivers/net/appletalk/cops.c                       |    2 +-
 drivers/net/appletalk/ltpc.c                       |    2 +-
 drivers/net/arcnet/com20020.c                      |    2 +-
 drivers/net/bonding/bond_main.c                    |    2 +-
 drivers/net/cris/eth_v10.c                         |    2 +-
 drivers/net/defxx.c                                |    2 +-
 drivers/net/dummy.c                                |    2 +-
 drivers/net/ethernet/3com/3c501.c                  |    2 +-
 drivers/net/ethernet/3com/3c509.c                  |    2 +-
 drivers/net/ethernet/3com/3c515.c                  |    2 +-
 drivers/net/ethernet/3com/3c574_cs.c               |    2 +-
 drivers/net/ethernet/3com/3c589_cs.c               |    2 +-
 drivers/net/ethernet/3com/3c59x.c                  |    4 ++--
 drivers/net/ethernet/3com/typhoon.c                |    2 +-
 drivers/net/ethernet/8390/3c503.c                  |    2 +-
 drivers/net/ethernet/8390/8390.c                   |    2 +-
 drivers/net/ethernet/8390/8390p.c                  |    2 +-
 drivers/net/ethernet/8390/ac3200.c                 |    2 +-
 drivers/net/ethernet/8390/ax88796.c                |    2 +-
 drivers/net/ethernet/8390/axnet_cs.c               |    2 +-
 drivers/net/ethernet/8390/e2100.c                  |    2 +-
 drivers/net/ethernet/8390/etherh.c                 |    2 +-
 drivers/net/ethernet/8390/hp-plus.c                |    2 +-
 drivers/net/ethernet/8390/hydra.c                  |    2 +-
 drivers/net/ethernet/8390/mac8390.c                |    2 +-
 drivers/net/ethernet/8390/ne-h8300.c               |    2 +-
 drivers/net/ethernet/8390/ne2k-pci.c               |    2 +-
 drivers/net/ethernet/8390/pcnet_cs.c               |    2 +-
 drivers/net/ethernet/8390/smc-mca.c                |    2 +-
 drivers/net/ethernet/8390/smc-ultra.c              |    2 +-
 drivers/net/ethernet/8390/smc-ultra32.c            |    2 +-
 drivers/net/ethernet/8390/wd.c                     |    2 +-
 drivers/net/ethernet/8390/zorro8390.c              |    2 +-
 drivers/net/ethernet/adaptec/starfire.c            |    2 +-
 drivers/net/ethernet/adi/bfin_mac.c                |    2 +-
 drivers/net/ethernet/aeroflex/greth.c              |    2 +-
 drivers/net/ethernet/alteon/acenic.c               |    2 +-
 drivers/net/ethernet/amd/a2065.c                   |    2 +-
 drivers/net/ethernet/amd/am79c961a.c               |    2 +-
 drivers/net/ethernet/amd/amd8111e.c                |    2 +-
 drivers/net/ethernet/amd/ariadne.c                 |    2 +-
 drivers/net/ethernet/amd/atarilance.c              |    2 +-
 drivers/net/ethernet/amd/au1000_eth.c              |    2 +-
 drivers/net/ethernet/amd/declance.c                |    2 +-
 drivers/net/ethernet/amd/depca.c                   |    2 +-
 drivers/net/ethernet/amd/hplance.c                 |    2 +-
 drivers/net/ethernet/amd/lance.c                   |    2 +-
 drivers/net/ethernet/amd/mvme147.c                 |    2 +-
 drivers/net/ethernet/amd/ni65.c                    |    2 +-
 drivers/net/ethernet/amd/nmclan_cs.c               |    2 +-
 drivers/net/ethernet/amd/pcnet32.c                 |    2 +-
 drivers/net/ethernet/amd/sun3lance.c               |    2 +-
 drivers/net/ethernet/amd/sunlance.c                |    2 +-
 drivers/net/ethernet/apple/bmac.c                  |    2 +-
 drivers/net/ethernet/apple/cs89x0.c                |    2 +-
 drivers/net/ethernet/apple/mac89x0.c               |    2 +-
 drivers/net/ethernet/apple/mace.c                  |    2 +-
 drivers/net/ethernet/apple/macmace.c               |    2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c    |    2 +-
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c    |    2 +-
 drivers/net/ethernet/atheros/atlx/atl1.c           |    2 +-
 drivers/net/ethernet/atheros/atlx/atl2.c           |    2 +-
 drivers/net/ethernet/broadcom/b44.c                |    2 +-
 drivers/net/ethernet/broadcom/bcm63xx_enet.c       |    2 +-
 drivers/net/ethernet/broadcom/sb1250-mac.c         |    2 +-
 drivers/net/ethernet/broadcom/tg3.c                |    2 +-
 drivers/net/ethernet/brocade/bna/bnad.c            |    1 -
 drivers/net/ethernet/cadence/at91_ether.c          |    2 +-
 drivers/net/ethernet/cadence/macb.c                |    2 +-
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c          |    2 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c    |    2 +-
 drivers/net/ethernet/cisco/enic/enic_main.c        |    2 --
 drivers/net/ethernet/davicom/dm9000.c              |    2 +-
 drivers/net/ethernet/dec/ewrk3.c                   |    2 +-
 drivers/net/ethernet/dec/tulip/de2104x.c           |    2 +-
 drivers/net/ethernet/dec/tulip/de4x5.c             |    2 +-
 drivers/net/ethernet/dec/tulip/dmfe.c              |    2 +-
 drivers/net/ethernet/dec/tulip/tulip_core.c        |    2 +-
 drivers/net/ethernet/dec/tulip/uli526x.c           |    2 +-
 drivers/net/ethernet/dec/tulip/winbond-840.c       |    2 +-
 drivers/net/ethernet/dlink/de620.c                 |    2 +-
 drivers/net/ethernet/dlink/dl2k.c                  |    2 +-
 drivers/net/ethernet/dlink/sundance.c              |    2 +-
 drivers/net/ethernet/ethoc.c                       |    2 +-
 drivers/net/ethernet/fealnx.c                      |    2 +-
 drivers/net/ethernet/freescale/fec.c               |    2 +-
 drivers/net/ethernet/freescale/fec_mpc52xx.c       |    2 +-
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  |    2 +-
 drivers/net/ethernet/freescale/gianfar.c           |    2 +-
 drivers/net/ethernet/freescale/ucc_geth.c          |    2 +-
 drivers/net/ethernet/fujitsu/at1700.c              |    2 +-
 drivers/net/ethernet/fujitsu/eth16i.c              |    2 +-
 drivers/net/ethernet/fujitsu/fmvj18x_cs.c          |    2 +-
 drivers/net/ethernet/hp/hp100.c                    |    4 ++--
 drivers/net/ethernet/i825xx/3c505.c                |    2 +-
 drivers/net/ethernet/i825xx/3c523.c                |    2 +-
 drivers/net/ethernet/i825xx/3c527.c                |    2 +-
 drivers/net/ethernet/i825xx/82596.c                |    2 +-
 drivers/net/ethernet/i825xx/eepro.c                |    2 +-
 drivers/net/ethernet/i825xx/eexpress.c             |    2 +-
 drivers/net/ethernet/i825xx/ether1.c               |    2 +-
 drivers/net/ethernet/i825xx/lib82596.c             |    2 +-
 drivers/net/ethernet/i825xx/lp486e.c               |    2 +-
 drivers/net/ethernet/i825xx/ni52.c                 |    2 +-
 drivers/net/ethernet/i825xx/sun3_82586.c           |    2 +-
 drivers/net/ethernet/i825xx/znet.c                 |    2 +-
 drivers/net/ethernet/ibm/ehea/ehea_main.c          |    2 +-
 drivers/net/ethernet/ibm/emac/core.c               |    4 ++--
 drivers/net/ethernet/ibm/ibmveth.c                 |    2 +-
 drivers/net/ethernet/ibm/iseries_veth.c            |    2 +-
 drivers/net/ethernet/icplus/ipg.c                  |    2 +-
 drivers/net/ethernet/intel/e100.c                  |    2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c         |    2 +-
 drivers/net/ethernet/intel/igb/igb_main.c          |    1 -
 drivers/net/ethernet/intel/igbvf/netdev.c          |    2 +-
 drivers/net/ethernet/intel/ixgb/ixgb_main.c        |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |    1 -
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |    1 -
 drivers/net/ethernet/jme.c                         |    2 +-
 drivers/net/ethernet/korina.c                      |    2 +-
 drivers/net/ethernet/lantiq_etop.c                 |    2 +-
 drivers/net/ethernet/marvell/skge.c                |    2 +-
 drivers/net/ethernet/marvell/sky2.c                |    4 ++--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |    2 +-
 drivers/net/ethernet/micrel/ks8695net.c            |    2 +-
 drivers/net/ethernet/microchip/enc28j60.c          |    2 +-
 drivers/net/ethernet/mipsnet.c                     |    2 +-
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c   |    2 +-
 drivers/net/ethernet/natsemi/ibmlana.c             |    2 +-
 drivers/net/ethernet/natsemi/jazzsonic.c           |    2 +-
 drivers/net/ethernet/natsemi/macsonic.c            |    2 +-
 drivers/net/ethernet/natsemi/natsemi.c             |    2 +-
 drivers/net/ethernet/natsemi/ns83820.c             |    2 +-
 drivers/net/ethernet/natsemi/xtsonic.c             |    2 +-
 drivers/net/ethernet/neterion/s2io.c               |    2 +-
 drivers/net/ethernet/neterion/vxge/vxge-main.c     |    2 +-
 drivers/net/ethernet/netx-eth.c                    |    2 +-
 drivers/net/ethernet/nuvoton/w90p910_ether.c       |    2 +-
 drivers/net/ethernet/nvidia/forcedeth.c            |    4 ++--
 drivers/net/ethernet/octeon/octeon_mgmt.c          |    1 -
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    2 +-
 drivers/net/ethernet/packetengines/hamachi.c       |    2 +-
 drivers/net/ethernet/packetengines/yellowfin.c     |    2 +-
 drivers/net/ethernet/pasemi/pasemi_mac.c           |    2 +-
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |    2 +-
 drivers/net/ethernet/qlogic/qla3xxx.c              |    1 -
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    2 +-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c       |    2 +-
 drivers/net/ethernet/racal/ni5010.c                |    2 +-
 drivers/net/ethernet/rdc/r6040.c                   |    2 +-
 drivers/net/ethernet/realtek/8139cp.c              |    2 +-
 drivers/net/ethernet/realtek/8139too.c             |    2 +-
 drivers/net/ethernet/realtek/atp.c                 |    2 +-
 drivers/net/ethernet/realtek/r8169.c               |    2 +-
 drivers/net/ethernet/realtek/sc92031.c             |    2 +-
 drivers/net/ethernet/renesas/sh_eth.c              |    2 +-
 drivers/net/ethernet/seeq/ether3.c                 |    2 +-
 drivers/net/ethernet/seeq/seeq8005.c               |    2 +-
 drivers/net/ethernet/seeq/sgiseeq.c                |    2 +-
 drivers/net/ethernet/sfc/efx.c                     |    2 +-
 drivers/net/ethernet/sgi/ioc3-eth.c                |    2 +-
 drivers/net/ethernet/sis/sis190.c                  |    2 +-
 drivers/net/ethernet/sis/sis900.c                  |    2 +-
 drivers/net/ethernet/smsc/epic100.c                |    2 +-
 drivers/net/ethernet/smsc/smc911x.c                |    2 +-
 drivers/net/ethernet/smsc/smc9194.c                |    2 +-
 drivers/net/ethernet/smsc/smc91c92_cs.c            |    2 +-
 drivers/net/ethernet/smsc/smc91x.c                 |    2 +-
 drivers/net/ethernet/smsc/smsc911x.c               |    2 +-
 drivers/net/ethernet/smsc/smsc9420.c               |    2 +-
 drivers/net/ethernet/sun/cassini.c                 |    2 +-
 drivers/net/ethernet/sun/sunbmac.c                 |    2 +-
 drivers/net/ethernet/sun/sungem.c                  |    2 +-
 drivers/net/ethernet/sun/sunhme.c                  |    2 +-
 drivers/net/ethernet/sun/sunqe.c                   |    2 +-
 drivers/net/ethernet/sun/sunvnet.c                 |    2 +-
 drivers/net/ethernet/tehuti/tehuti.c               |    2 +-
 drivers/net/ethernet/ti/cpmac.c                    |    2 +-
 drivers/net/ethernet/ti/davinci_emac.c             |    2 +-
 drivers/net/ethernet/ti/tlan.c                     |    2 +-
 drivers/net/ethernet/toshiba/ps3_gelic_net.c       |    2 +-
 drivers/net/ethernet/toshiba/ps3_gelic_wireless.c  |    2 +-
 drivers/net/ethernet/toshiba/spider_net.c          |    2 +-
 drivers/net/ethernet/toshiba/tc35815.c             |    2 +-
 drivers/net/ethernet/tundra/tsi108_eth.c           |    2 +-
 drivers/net/ethernet/via/via-rhine.c               |    2 +-
 drivers/net/ethernet/via/via-velocity.c            |    2 +-
 drivers/net/ethernet/xilinx/ll_temac_main.c        |    1 -
 drivers/net/ethernet/xircom/xirc2ps_cs.c           |    2 +-
 drivers/net/ethernet/xscale/ixp4xx_eth.c           |    2 +-
 drivers/net/macvlan.c                              |    2 +-
 drivers/net/skfp/skfddi.c                          |    2 +-
 drivers/net/tokenring/3c359.c                      |    2 +-
 drivers/net/tokenring/ibmtr.c                      |    2 +-
 drivers/net/tokenring/lanstreamer.c                |    2 +-
 drivers/net/tokenring/olympic.c                    |    2 +-
 drivers/net/tokenring/smctr.c                      |    2 +-
 drivers/net/tokenring/tms380tr.c                   |    2 +-
 drivers/net/tun.c                                  |    2 +-
 drivers/net/usb/asix.c                             |    6 +++---
 drivers/net/usb/catc.c                             |    2 +-
 drivers/net/usb/dm9601.c                           |    2 +-
 drivers/net/usb/int51x1.c                          |    2 +-
 drivers/net/usb/kaweth.c                           |    2 +-
 drivers/net/usb/mcs7830.c                          |    2 +-
 drivers/net/usb/pegasus.c                          |    2 +-
 drivers/net/usb/rtl8150.c                          |    2 +-
 drivers/net/usb/smsc75xx.c                         |    2 +-
 drivers/net/usb/smsc95xx.c                         |    2 +-
 drivers/net/vmxnet3/vmxnet3_drv.c                  |    2 +-
 drivers/net/wan/sbni.c                             |    2 +-
 drivers/net/wireless/airo.c                        |    4 ++--
 drivers/net/wireless/hostap/hostap_main.c          |    6 +++---
 drivers/net/wireless/ipw2x00/ipw2200.c             |    2 +-
 drivers/net/wireless/libertas/main.c               |    2 +-
 drivers/net/wireless/libertas/mesh.c               |    2 +-
 drivers/net/wireless/mwifiex/main.c                |    2 +-
 drivers/net/wireless/orinoco/main.c                |    2 +-
 drivers/net/wireless/orinoco/orinoco_usb.c         |    2 +-
 drivers/net/wireless/ray_cs.c                      |    2 +-
 drivers/net/wireless/rndis_wlan.c                  |    2 +-
 drivers/net/wireless/zd1201.c                      |    2 +-
 drivers/s390/net/lcs.c                             |    2 +-
 drivers/s390/net/qeth_l2_main.c                    |    2 +-
 drivers/s390/net/qeth_l3_main.c                    |    4 ++--
 drivers/staging/ath6kl/os/linux/ar6000_drv.c       |    2 +-
 drivers/staging/brcm80211/brcmfmac/dhd_linux.c     |    2 +-
 drivers/staging/et131x/et131x_netdev.c             |    2 +-
 drivers/staging/hv/netvsc_drv.c                    |    2 +-
 drivers/staging/octeon/ethernet.c                  |   12 ++++++------
 drivers/staging/rtl8187se/r8180_core.c             |    2 +-
 drivers/staging/rtl8192e/r8192E_core.c             |    2 +-
 drivers/staging/rtl8192u/r8192U_core.c             |    2 +-
 drivers/staging/slicoss/slicoss.c                  |    2 +-
 drivers/staging/vt6655/device_main.c               |    2 +-
 drivers/staging/vt6656/main_usb.c                  |    2 +-
 drivers/staging/wlags49_h2/wl_netdev.c             |    2 +-
 drivers/staging/wlan-ng/p80211netdev.c             |    2 +-
 net/8021q/vlan_dev.c                               |    1 -
 net/atm/lec.c                                      |    2 +-
 net/bluetooth/bnep/netdev.c                        |    2 +-
 net/bridge/br_device.c                             |    2 +-
 net/dsa/slave.c                                    |    3 ---
 net/irda/irlan/irlan_eth.c                         |    2 +-
 net/mac80211/iface.c                               |    4 ++--
 251 files changed, 258 insertions(+), 271 deletions(-)

diff --git a/arch/ia64/hp/sim/simeth.c b/arch/ia64/hp/sim/simeth.c
index 7e81966..47afcc6 100644
--- a/arch/ia64/hp/sim/simeth.c
+++ b/arch/ia64/hp/sim/simeth.c
@@ -172,7 +172,7 @@ static const struct net_device_ops simeth_netdev_ops = {
 	.ndo_stop		= simeth_close,
 	.ndo_start_xmit		= simeth_tx,
 	.ndo_get_stats		= simeth_get_stats,
-	.ndo_set_multicast_list	= set_multicast_list, /* not yet used */
+	.ndo_set_rx_mode	= set_multicast_list, /* not yet used */
 
 };
 
diff --git a/arch/um/drivers/net_kern.c b/arch/um/drivers/net_kern.c
index 22745b4..a492e59 100644
--- a/arch/um/drivers/net_kern.c
+++ b/arch/um/drivers/net_kern.c
@@ -368,7 +368,7 @@ static const struct net_device_ops uml_netdev_ops = {
 	.ndo_open 		= uml_net_open,
 	.ndo_stop 		= uml_net_close,
 	.ndo_start_xmit 	= uml_net_start_xmit,
-	.ndo_set_multicast_list = uml_net_set_multicast_list,
+	.ndo_set_rx_mode	= uml_net_set_multicast_list,
 	.ndo_tx_timeout 	= uml_net_tx_timeout,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_change_mtu 	= uml_net_change_mtu,
diff --git a/arch/xtensa/platforms/iss/network.c b/arch/xtensa/platforms/iss/network.c
index f717e20..7dde244 100644
--- a/arch/xtensa/platforms/iss/network.c
+++ b/arch/xtensa/platforms/iss/network.c
@@ -633,7 +633,7 @@ static const struct net_device_ops iss_netdev_ops = {
 	.ndo_set_mac_address	= iss_net_set_mac,
 	//.ndo_do_ioctl		= iss_net_ioctl,
 	.ndo_tx_timeout		= iss_net_tx_timeout,
-	.ndo_set_multicast_list = iss_net_set_multicast_list,
+	.ndo_set_rx_mode	= iss_net_set_multicast_list,
 };
 
 static int iss_net_configure(int index, char *init)
diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index 9d7ffeb..66e1229 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -1638,7 +1638,7 @@ static const struct net_device_ops nes_netdev_ops = {
 	.ndo_get_stats		= nes_netdev_get_stats,
 	.ndo_tx_timeout		= nes_netdev_tx_timeout,
 	.ndo_set_mac_address	= nes_netdev_set_mac_address,
-	.ndo_set_multicast_list = nes_netdev_set_multicast_list,
+	.ndo_set_rx_mode	= nes_netdev_set_multicast_list,
 	.ndo_change_mtu		= nes_netdev_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_fix_features	= nes_fix_features,
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 43f89ba..aa30915 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -996,7 +996,7 @@ static const struct net_device_ops ipoib_netdev_ops = {
 	.ndo_fix_features	 = ipoib_fix_features,
 	.ndo_start_xmit	 	 = ipoib_start_xmit,
 	.ndo_tx_timeout		 = ipoib_timeout,
-	.ndo_set_multicast_list	 = ipoib_set_mcast_list,
+	.ndo_set_rx_mode	 = ipoib_set_mcast_list,
 	.ndo_neigh_setup	 = ipoib_neigh_setup_dev,
 };
 
diff --git a/drivers/media/dvb/dvb-core/dvb_net.c b/drivers/media/dvb/dvb-core/dvb_net.c
index 51752a9..93d9869 100644
--- a/drivers/media/dvb/dvb-core/dvb_net.c
+++ b/drivers/media/dvb/dvb-core/dvb_net.c
@@ -1230,7 +1230,7 @@ static const struct net_device_ops dvb_netdev_ops = {
 	.ndo_open		= dvb_net_open,
 	.ndo_stop		= dvb_net_stop,
 	.ndo_start_xmit		= dvb_net_tx,
-	.ndo_set_multicast_list = dvb_net_set_multicast_list,
+	.ndo_set_rx_mode	= dvb_net_set_multicast_list,
 	.ndo_set_mac_address    = dvb_net_set_mac,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/appletalk/cops.c b/drivers/net/appletalk/cops.c
index 748c9f5..9abd4eb 100644
--- a/drivers/net/appletalk/cops.c
+++ b/drivers/net/appletalk/cops.c
@@ -264,7 +264,7 @@ static const struct net_device_ops cops_netdev_ops = {
 	.ndo_start_xmit   	= cops_send_packet,
 	.ndo_tx_timeout		= cops_timeout,
         .ndo_do_ioctl           = cops_ioctl,
-	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 };
 
 /*
diff --git a/drivers/net/appletalk/ltpc.c b/drivers/net/appletalk/ltpc.c
index 34ffb54..6057b30 100644
--- a/drivers/net/appletalk/ltpc.c
+++ b/drivers/net/appletalk/ltpc.c
@@ -1014,7 +1014,7 @@ static int __init ltpc_probe_dma(int base, int dma)
 static const struct net_device_ops ltpc_netdev = {
 	.ndo_start_xmit		= ltpc_xmit,
 	.ndo_do_ioctl		= ltpc_ioctl,
-	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 };
 
 struct net_device * __init ltpc_probe(void)
diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index 7bfb91f..7b96c5f 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -154,7 +154,7 @@ const struct net_device_ops com20020_netdev_ops = {
 	.ndo_stop	= arcnet_close,
 	.ndo_start_xmit = arcnet_send_packet,
 	.ndo_tx_timeout = arcnet_timeout,
-	.ndo_set_multicast_list = com20020_set_mc_list,
+	.ndo_set_rx_mode = com20020_set_mc_list,
 };
 
 /* Set up the struct net_device associated with this card.  Called after
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c3e4683..e61a4e5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4266,7 +4266,7 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_get_stats64	= bond_get_stats,
 	.ndo_do_ioctl		= bond_do_ioctl,
 	.ndo_change_rx_flags	= bond_change_rx_flags,
-	.ndo_set_multicast_list	= bond_set_multicast_list,
+	.ndo_set_rx_mode	= bond_set_multicast_list,
 	.ndo_change_mtu		= bond_change_mtu,
 	.ndo_set_mac_address	= bond_set_mac_address,
 	.ndo_neigh_setup	= bond_neigh_setup,
diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
index e66aceb..7cb2785 100644
--- a/drivers/net/cris/eth_v10.c
+++ b/drivers/net/cris/eth_v10.c
@@ -261,7 +261,7 @@ static const struct net_device_ops e100_netdev_ops = {
 	.ndo_start_xmit		= e100_send_packet,
 	.ndo_tx_timeout		= e100_tx_timeout,
 	.ndo_get_stats		= e100_get_stats,
-	.ndo_set_multicast_list	= set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_do_ioctl		= e100_ioctl,
 	.ndo_set_mac_address	= e100_set_mac_address,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/defxx.c b/drivers/net/defxx.c
index 417e143..4ad80f7 100644
--- a/drivers/net/defxx.c
+++ b/drivers/net/defxx.c
@@ -483,7 +483,7 @@ static const struct net_device_ops dfx_netdev_ops = {
 	.ndo_stop		= dfx_close,
 	.ndo_start_xmit		= dfx_xmt_queue_pkt,
 	.ndo_get_stats		= dfx_ctl_get_stats,
-	.ndo_set_multicast_list	= dfx_ctl_set_multicast_list,
+	.ndo_set_rx_mode	= dfx_ctl_set_multicast_list,
 	.ndo_set_mac_address	= dfx_ctl_set_mac_address,
 };
 
diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 39cf9b9..a7c5e88 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -116,7 +116,7 @@ static const struct net_device_ops dummy_netdev_ops = {
 	.ndo_init		= dummy_dev_init,
 	.ndo_start_xmit		= dummy_xmit,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_set_mac_address	= dummy_set_address,
 	.ndo_get_stats64	= dummy_get_stats64,
 };
diff --git a/drivers/net/ethernet/3com/3c501.c b/drivers/net/ethernet/3com/3c501.c
index 5420f6d..68da81d 100644
--- a/drivers/net/ethernet/3com/3c501.c
+++ b/drivers/net/ethernet/3com/3c501.c
@@ -201,7 +201,7 @@ static const struct net_device_ops el_netdev_ops = {
 	.ndo_stop		= el1_close,
 	.ndo_start_xmit 	= el_start_xmit,
 	.ndo_tx_timeout		= el_timeout,
-	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet/3com/3c509.c
index 44b28b2..92053e6 100644
--- a/drivers/net/ethernet/3com/3c509.c
+++ b/drivers/net/ethernet/3com/3c509.c
@@ -545,7 +545,7 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_stop	 	= el3_close,
 	.ndo_start_xmit 	= el3_start_xmit,
 	.ndo_get_stats 		= el3_get_stats,
-	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_tx_timeout 	= el3_tx_timeout,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
diff --git a/drivers/net/ethernet/3com/3c515.c b/drivers/net/ethernet/3com/3c515.c
index d2bb4b2..f67a5d3 100644
--- a/drivers/net/ethernet/3com/3c515.c
+++ b/drivers/net/ethernet/3com/3c515.c
@@ -569,7 +569,7 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_start_xmit		= corkscrew_start_xmit,
 	.ndo_tx_timeout		= corkscrew_timeout,
 	.ndo_get_stats		= corkscrew_get_stats,
-	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_set_rx_mode	= set_rx_mode,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/3com/3c574_cs.c b/drivers/net/ethernet/3com/3c574_cs.c
index 34c5e1c..9c01bc9 100644
--- a/drivers/net/ethernet/3com/3c574_cs.c
+++ b/drivers/net/ethernet/3com/3c574_cs.c
@@ -255,7 +255,7 @@ static const struct net_device_ops el3_netdev_ops = {
 	.ndo_tx_timeout 	= el3_tx_timeout,
 	.ndo_get_stats		= el3_get_stats,
 	.ndo_do_ioctl		= el3_ioctl,
-	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/3com/3c589_cs.c b/drivers/net/ethernet/3com/3c589_cs.c
index 4a1a358..972f80e 100644
--- a/drivers/net/ethernet/3com/3c589_cs.c
+++ b/drivers/net/ethernet/3com/3c589_cs.c
@@ -184,7 +184,7 @@ static const struct net_device_ops el3_netdev_ops = {
 	.ndo_tx_timeout		= el3_tx_timeout,
 	.ndo_set_config		= el3_config,
 	.ndo_get_stats		= el3_get_stats,
-	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 8cc2256..6e1f595 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -1055,7 +1055,7 @@ static const struct net_device_ops boomrang_netdev_ops = {
 #ifdef CONFIG_PCI
 	.ndo_do_ioctl 		= vortex_ioctl,
 #endif
-	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_set_rx_mode	= set_rx_mode,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -1073,7 +1073,7 @@ static const struct net_device_ops vortex_netdev_ops = {
 #ifdef CONFIG_PCI
 	.ndo_do_ioctl 		= vortex_ioctl,
 #endif
-	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_set_rx_mode	= set_rx_mode,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index 1d5091a..f1dc9acf 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -2266,7 +2266,7 @@ static const struct net_device_ops typhoon_netdev_ops = {
 	.ndo_open		= typhoon_open,
 	.ndo_stop		= typhoon_close,
 	.ndo_start_xmit		= typhoon_start_tx,
-	.ndo_set_multicast_list	= typhoon_set_rx_mode,
+	.ndo_set_rx_mode	= typhoon_set_rx_mode,
 	.ndo_tx_timeout		= typhoon_tx_timeout,
 	.ndo_get_stats		= typhoon_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/8390/3c503.c b/drivers/net/ethernet/8390/3c503.c
index 84e68f1..fbab136 100644
--- a/drivers/net/ethernet/8390/3c503.c
+++ b/drivers/net/ethernet/8390/3c503.c
@@ -176,7 +176,7 @@ static const struct net_device_ops el2_netdev_ops = {
 	.ndo_start_xmit		= eip_start_xmit,
 	.ndo_tx_timeout		= eip_tx_timeout,
 	.ndo_get_stats		= eip_get_stats,
-	.ndo_set_multicast_list = eip_set_multicast_list,
+	.ndo_set_rx_mode	= eip_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/8390/8390.c b/drivers/net/ethernet/8390/8390.c
index 7c7518b..5db1f55 100644
--- a/drivers/net/ethernet/8390/8390.c
+++ b/drivers/net/ethernet/8390/8390.c
@@ -61,7 +61,7 @@ const struct net_device_ops ei_netdev_ops = {
 	.ndo_start_xmit		= ei_start_xmit,
 	.ndo_tx_timeout		= ei_tx_timeout,
 	.ndo_get_stats		= ei_get_stats,
-	.ndo_set_multicast_list = ei_set_multicast_list,
+	.ndo_set_rx_mode	= ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/8390/8390p.c b/drivers/net/ethernet/8390/8390p.c
index a2a64ea..e8fc2e8 100644
--- a/drivers/net/ethernet/8390/8390p.c
+++ b/drivers/net/ethernet/8390/8390p.c
@@ -66,7 +66,7 @@ const struct net_device_ops eip_netdev_ops = {
 	.ndo_start_xmit		= eip_start_xmit,
 	.ndo_tx_timeout		= eip_tx_timeout,
 	.ndo_get_stats		= eip_get_stats,
-	.ndo_set_multicast_list = eip_set_multicast_list,
+	.ndo_set_rx_mode	= eip_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/8390/ac3200.c b/drivers/net/ethernet/8390/ac3200.c
index f07b2e9..5337dd0 100644
--- a/drivers/net/ethernet/8390/ac3200.c
+++ b/drivers/net/ethernet/8390/ac3200.c
@@ -151,7 +151,7 @@ static const struct net_device_ops ac_netdev_ops = {
 	.ndo_start_xmit		= ei_start_xmit,
 	.ndo_tx_timeout		= ei_tx_timeout,
 	.ndo_get_stats		= ei_get_stats,
-	.ndo_set_multicast_list = ei_set_multicast_list,
+	.ndo_set_rx_mode	= ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/8390/ax88796.c b/drivers/net/ethernet/8390/ax88796.c
index e7cb8c8..e9f8432 100644
--- a/drivers/net/ethernet/8390/ax88796.c
+++ b/drivers/net/ethernet/8390/ax88796.c
@@ -543,7 +543,7 @@ static const struct net_device_ops ax_netdev_ops = {
 	.ndo_start_xmit		= ax_ei_start_xmit,
 	.ndo_tx_timeout		= ax_ei_tx_timeout,
 	.ndo_get_stats		= ax_ei_get_stats,
-	.ndo_set_multicast_list = ax_ei_set_multicast_list,
+	.ndo_set_rx_mode	= ax_ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/8390/axnet_cs.c b/drivers/net/ethernet/8390/axnet_cs.c
index 3e4b926..bba51cd 100644
--- a/drivers/net/ethernet/8390/axnet_cs.c
+++ b/drivers/net/ethernet/8390/axnet_cs.c
@@ -134,7 +134,7 @@ static const struct net_device_ops axnet_netdev_ops = {
 	.ndo_start_xmit		= axnet_start_xmit,
 	.ndo_tx_timeout		= axnet_tx_timeout,
 	.ndo_get_stats		= get_stats,
-	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/8390/e2100.c b/drivers/net/ethernet/8390/e2100.c
index d50a999..d16dc53 100644
--- a/drivers/net/ethernet/8390/e2100.c
+++ b/drivers/net/ethernet/8390/e2100.c
@@ -168,7 +168,7 @@ static const struct net_device_ops e21_netdev_ops = {
 	.ndo_start_xmit		= ei_start_xmit,
 	.ndo_tx_timeout		= ei_tx_timeout,
 	.ndo_get_stats		= ei_get_stats,
-	.ndo_set_multicast_list = ei_set_multicast_list,
+	.ndo_set_rx_mode	= ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/8390/etherh.c b/drivers/net/ethernet/8390/etherh.c
index cf851fa..48c4948 100644
--- a/drivers/net/ethernet/8390/etherh.c
+++ b/drivers/net/ethernet/8390/etherh.c
@@ -644,7 +644,7 @@ static const struct net_device_ops etherh_netdev_ops = {
 	.ndo_start_xmit		= __ei_start_xmit,
 	.ndo_tx_timeout		= __ei_tx_timeout,
 	.ndo_get_stats		= __ei_get_stats,
-	.ndo_set_multicast_list = __ei_set_multicast_list,
+	.ndo_set_rx_mode	= __ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/8390/hp-plus.c b/drivers/net/ethernet/8390/hp-plus.c
index 2991736..eeac843 100644
--- a/drivers/net/ethernet/8390/hp-plus.c
+++ b/drivers/net/ethernet/8390/hp-plus.c
@@ -165,7 +165,7 @@ static const struct net_device_ops hpp_netdev_ops = {
 	.ndo_start_xmit		= eip_start_xmit,
 	.ndo_tx_timeout		= eip_tx_timeout,
 	.ndo_get_stats		= eip_get_stats,
-	.ndo_set_multicast_list = eip_set_multicast_list,
+	.ndo_set_rx_mode	= eip_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/8390/hydra.c b/drivers/net/ethernet/8390/hydra.c
index 1cd481c..3dac937 100644
--- a/drivers/net/ethernet/8390/hydra.c
+++ b/drivers/net/ethernet/8390/hydra.c
@@ -101,7 +101,7 @@ static const struct net_device_ops hydra_netdev_ops = {
 	.ndo_start_xmit		= __ei_start_xmit,
 	.ndo_tx_timeout		= __ei_tx_timeout,
 	.ndo_get_stats		= __ei_get_stats,
-	.ndo_set_multicast_list = __ei_set_multicast_list,
+	.ndo_set_rx_mode	= __ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/8390/mac8390.c b/drivers/net/ethernet/8390/mac8390.c
index f84f5e6..af5d982 100644
--- a/drivers/net/ethernet/8390/mac8390.c
+++ b/drivers/net/ethernet/8390/mac8390.c
@@ -494,7 +494,7 @@ static const struct net_device_ops mac8390_netdev_ops = {
 	.ndo_start_xmit		= __ei_start_xmit,
 	.ndo_tx_timeout		= __ei_tx_timeout,
 	.ndo_get_stats		= __ei_get_stats,
-	.ndo_set_multicast_list = __ei_set_multicast_list,
+	.ndo_set_rx_mode	= __ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/8390/ne-h8300.c b/drivers/net/ethernet/8390/ne-h8300.c
index 7298a34..cd36a6a 100644
--- a/drivers/net/ethernet/8390/ne-h8300.c
+++ b/drivers/net/ethernet/8390/ne-h8300.c
@@ -200,7 +200,7 @@ static const struct net_device_ops ne_netdev_ops = {
 	.ndo_start_xmit		= __ei_start_xmit,
 	.ndo_tx_timeout		= __ei_tx_timeout,
 	.ndo_get_stats		= __ei_get_stats,
-	.ndo_set_multicast_list = __ei_set_multicast_list,
+	.ndo_set_rx_mode	= __ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/8390/ne2k-pci.c b/drivers/net/ethernet/8390/ne2k-pci.c
index 3c333cb..3992342 100644
--- a/drivers/net/ethernet/8390/ne2k-pci.c
+++ b/drivers/net/ethernet/8390/ne2k-pci.c
@@ -207,7 +207,7 @@ static const struct net_device_ops ne2k_netdev_ops = {
 	.ndo_start_xmit		= ei_start_xmit,
 	.ndo_tx_timeout		= ei_tx_timeout,
 	.ndo_get_stats		= ei_get_stats,
-	.ndo_set_multicast_list = ei_set_multicast_list,
+	.ndo_set_rx_mode	= ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/8390/pcnet_cs.c b/drivers/net/ethernet/8390/pcnet_cs.c
index 4010761..053b255 100644
--- a/drivers/net/ethernet/8390/pcnet_cs.c
+++ b/drivers/net/ethernet/8390/pcnet_cs.c
@@ -227,7 +227,7 @@ static const struct net_device_ops pcnet_netdev_ops = {
 	.ndo_start_xmit 	= ei_start_xmit,
 	.ndo_get_stats		= ei_get_stats,
 	.ndo_do_ioctl 		= ei_ioctl,
-	.ndo_set_multicast_list = ei_set_multicast_list,
+	.ndo_set_rx_mode	= ei_set_multicast_list,
 	.ndo_tx_timeout 	= ei_tx_timeout,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
diff --git a/drivers/net/ethernet/8390/smc-mca.c b/drivers/net/ethernet/8390/smc-mca.c
index 34934fb..77efec4 100644
--- a/drivers/net/ethernet/8390/smc-mca.c
+++ b/drivers/net/ethernet/8390/smc-mca.c
@@ -191,7 +191,7 @@ static const struct net_device_ops ultramca_netdev_ops = {
 	.ndo_start_xmit		= ei_start_xmit,
 	.ndo_tx_timeout		= ei_tx_timeout,
 	.ndo_get_stats		= ei_get_stats,
-	.ndo_set_multicast_list = ei_set_multicast_list,
+	.ndo_set_rx_mode	= ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/8390/smc-ultra.c b/drivers/net/ethernet/8390/smc-ultra.c
index ba44ede..1cc306a 100644
--- a/drivers/net/ethernet/8390/smc-ultra.c
+++ b/drivers/net/ethernet/8390/smc-ultra.c
@@ -192,7 +192,7 @@ static const struct net_device_ops ultra_netdev_ops = {
 	.ndo_start_xmit		= ei_start_xmit,
 	.ndo_tx_timeout		= ei_tx_timeout,
 	.ndo_get_stats		= ei_get_stats,
-	.ndo_set_multicast_list = ei_set_multicast_list,
+	.ndo_set_rx_mode	= ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/8390/smc-ultra32.c b/drivers/net/ethernet/8390/smc-ultra32.c
index e459c3b..bb87053 100644
--- a/drivers/net/ethernet/8390/smc-ultra32.c
+++ b/drivers/net/ethernet/8390/smc-ultra32.c
@@ -160,7 +160,7 @@ static const struct net_device_ops ultra32_netdev_ops = {
 	.ndo_start_xmit		= ei_start_xmit,
 	.ndo_tx_timeout		= ei_tx_timeout,
 	.ndo_get_stats		= ei_get_stats,
-	.ndo_set_multicast_list = ei_set_multicast_list,
+	.ndo_set_rx_mode	= ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/8390/wd.c b/drivers/net/ethernet/8390/wd.c
index 8831a33..c175fad 100644
--- a/drivers/net/ethernet/8390/wd.c
+++ b/drivers/net/ethernet/8390/wd.c
@@ -153,7 +153,7 @@ static const struct net_device_ops wd_netdev_ops = {
 	.ndo_start_xmit		= ei_start_xmit,
 	.ndo_tx_timeout		= ei_tx_timeout,
 	.ndo_get_stats		= ei_get_stats,
-	.ndo_set_multicast_list = ei_set_multicast_list,
+	.ndo_set_rx_mode	= ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/8390/zorro8390.c b/drivers/net/ethernet/8390/zorro8390.c
index 15e7751a..3aa9fe9 100644
--- a/drivers/net/ethernet/8390/zorro8390.c
+++ b/drivers/net/ethernet/8390/zorro8390.c
@@ -278,7 +278,7 @@ static const struct net_device_ops zorro8390_netdev_ops = {
 	.ndo_start_xmit		= __ei_start_xmit,
 	.ndo_tx_timeout		= __ei_tx_timeout,
 	.ndo_get_stats		= __ei_get_stats,
-	.ndo_set_multicast_list = __ei_set_multicast_list,
+	.ndo_set_rx_mode	= __ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/adaptec/starfire.c b/drivers/net/ethernet/adaptec/starfire.c
index 7ae1f99..df51fdd 100644
--- a/drivers/net/ethernet/adaptec/starfire.c
+++ b/drivers/net/ethernet/adaptec/starfire.c
@@ -639,7 +639,7 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_start_xmit		= start_tx,
 	.ndo_tx_timeout		= tx_timeout,
 	.ndo_get_stats		= get_stats,
-	.ndo_set_multicast_list = &set_rx_mode,
+	.ndo_set_rx_mode	= set_rx_mode,
 	.ndo_do_ioctl		= netdev_ioctl,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index 6c019e1..b6d69c9 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -1449,7 +1449,7 @@ static const struct net_device_ops bfin_mac_netdev_ops = {
 	.ndo_start_xmit		= bfin_mac_hard_start_xmit,
 	.ndo_set_mac_address	= bfin_mac_set_mac_address,
 	.ndo_tx_timeout		= bfin_mac_timeout,
-	.ndo_set_multicast_list	= bfin_mac_set_multicast_list,
+	.ndo_set_rx_mode	= bfin_mac_set_multicast_list,
 	.ndo_do_ioctl           = bfin_mac_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index 16ce45c..a5f6b07 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -1539,7 +1539,7 @@ static int __devinit greth_of_probe(struct platform_device *ofdev)
 	}
 
 	if (greth->multicast) {
-		greth_netdev_ops.ndo_set_multicast_list = greth_set_multicast_list;
+		greth_netdev_ops.ndo_set_rx_mode = greth_set_multicast_list;
 		dev->flags |= IFF_MULTICAST;
 	} else {
 		dev->flags &= ~IFF_MULTICAST;
diff --git a/drivers/net/ethernet/alteon/acenic.c b/drivers/net/ethernet/alteon/acenic.c
index 31798f5..1d6f2db 100644
--- a/drivers/net/ethernet/alteon/acenic.c
+++ b/drivers/net/ethernet/alteon/acenic.c
@@ -449,7 +449,7 @@ static const struct net_device_ops ace_netdev_ops = {
 	.ndo_tx_timeout		= ace_watchdog,
 	.ndo_get_stats		= ace_get_stats,
 	.ndo_start_xmit		= ace_start_xmit,
-	.ndo_set_multicast_list	= ace_set_multicast_list,
+	.ndo_set_rx_mode	= ace_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= ace_set_mac_addr,
 	.ndo_change_mtu		= ace_change_mtu,
diff --git a/drivers/net/ethernet/amd/a2065.c b/drivers/net/ethernet/amd/a2065.c
index e1e1b07..825e5d4 100644
--- a/drivers/net/ethernet/amd/a2065.c
+++ b/drivers/net/ethernet/amd/a2065.c
@@ -664,7 +664,7 @@ static const struct net_device_ops lance_netdev_ops = {
 	.ndo_stop		= lance_close,
 	.ndo_start_xmit		= lance_start_xmit,
 	.ndo_tx_timeout		= lance_tx_timeout,
-	.ndo_set_multicast_list	= lance_set_multicast,
+	.ndo_set_rx_mode	= lance_set_multicast,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
diff --git a/drivers/net/ethernet/amd/am79c961a.c b/drivers/net/ethernet/amd/am79c961a.c
index 52fe21e..c2b630c 100644
--- a/drivers/net/ethernet/amd/am79c961a.c
+++ b/drivers/net/ethernet/amd/am79c961a.c
@@ -659,7 +659,7 @@ static const struct net_device_ops am79c961_netdev_ops = {
 	.ndo_open		= am79c961_open,
 	.ndo_stop		= am79c961_close,
 	.ndo_start_xmit		= am79c961_sendpacket,
-	.ndo_set_multicast_list	= am79c961_setmulticastlist,
+	.ndo_set_rx_mode	= am79c961_setmulticastlist,
 	.ndo_tx_timeout		= am79c961_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index 78002ef..a9745f4 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -1798,7 +1798,7 @@ static const struct net_device_ops amd8111e_netdev_ops = {
 	.ndo_start_xmit		= amd8111e_start_xmit,
 	.ndo_tx_timeout		= amd8111e_tx_timeout,
 	.ndo_get_stats		= amd8111e_get_stats,
-	.ndo_set_multicast_list = amd8111e_set_multicast_list,
+	.ndo_set_rx_mode	= amd8111e_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= amd8111e_set_mac_address,
 	.ndo_do_ioctl		= amd8111e_ioctl,
diff --git a/drivers/net/ethernet/amd/ariadne.c b/drivers/net/ethernet/amd/ariadne.c
index 7ed78f4..eb18e1f 100644
--- a/drivers/net/ethernet/amd/ariadne.c
+++ b/drivers/net/ethernet/amd/ariadne.c
@@ -704,7 +704,7 @@ static const struct net_device_ops ariadne_netdev_ops = {
 	.ndo_start_xmit		= ariadne_start_xmit,
 	.ndo_tx_timeout		= ariadne_tx_timeout,
 	.ndo_get_stats		= ariadne_get_stats,
-	.ndo_set_multicast_list	= set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
diff --git a/drivers/net/ethernet/amd/atarilance.c b/drivers/net/ethernet/amd/atarilance.c
index 1264d78..15bfa28 100644
--- a/drivers/net/ethernet/amd/atarilance.c
+++ b/drivers/net/ethernet/amd/atarilance.c
@@ -456,7 +456,7 @@ static const struct net_device_ops lance_netdev_ops = {
 	.ndo_open		= lance_open,
 	.ndo_stop		= lance_close,
 	.ndo_start_xmit		= lance_start_xmit,
-	.ndo_set_multicast_list	= set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_set_mac_address	= lance_set_mac_address,
 	.ndo_tx_timeout		= lance_tx_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index b9debcf..8238667 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -1010,7 +1010,7 @@ static const struct net_device_ops au1000_netdev_ops = {
 	.ndo_open		= au1000_open,
 	.ndo_stop		= au1000_close,
 	.ndo_start_xmit		= au1000_tx,
-	.ndo_set_multicast_list	= au1000_multicast_list,
+	.ndo_set_rx_mode	= au1000_multicast_list,
 	.ndo_do_ioctl		= au1000_ioctl,
 	.ndo_tx_timeout		= au1000_tx_timeout,
 	.ndo_set_mac_address	= eth_mac_addr,
diff --git a/drivers/net/ethernet/amd/declance.c b/drivers/net/ethernet/amd/declance.c
index d5598f6..73f8d4f 100644
--- a/drivers/net/ethernet/amd/declance.c
+++ b/drivers/net/ethernet/amd/declance.c
@@ -1015,7 +1015,7 @@ static const struct net_device_ops lance_netdev_ops = {
 	.ndo_stop		= lance_close,
 	.ndo_start_xmit		= lance_start_xmit,
 	.ndo_tx_timeout		= lance_tx_timeout,
-	.ndo_set_multicast_list	= lance_set_multicast,
+	.ndo_set_rx_mode	= lance_set_multicast,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
diff --git a/drivers/net/ethernet/amd/depca.c b/drivers/net/ethernet/amd/depca.c
index f2015a8..681970c 100644
--- a/drivers/net/ethernet/amd/depca.c
+++ b/drivers/net/ethernet/amd/depca.c
@@ -572,7 +572,7 @@ static const struct net_device_ops depca_netdev_ops = {
 	.ndo_open 		= depca_open,
 	.ndo_start_xmit 	= depca_start_xmit,
 	.ndo_stop 		= depca_close,
-	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_do_ioctl 		= depca_ioctl,
 	.ndo_tx_timeout 	= depca_tx_timeout,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/amd/hplance.c b/drivers/net/ethernet/amd/hplance.c
index a900d5b..86aa0d5 100644
--- a/drivers/net/ethernet/amd/hplance.c
+++ b/drivers/net/ethernet/amd/hplance.c
@@ -74,7 +74,7 @@ static const struct net_device_ops hplance_netdev_ops = {
 	.ndo_open		= hplance_open,
 	.ndo_stop		= hplance_close,
 	.ndo_start_xmit		= lance_start_xmit,
-	.ndo_set_multicast_list	= lance_set_multicast,
+	.ndo_set_rx_mode	= lance_set_multicast,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
diff --git a/drivers/net/ethernet/amd/lance.c b/drivers/net/ethernet/amd/lance.c
index 02336ed..a6e2e84 100644
--- a/drivers/net/ethernet/amd/lance.c
+++ b/drivers/net/ethernet/amd/lance.c
@@ -459,7 +459,7 @@ static const struct net_device_ops lance_netdev_ops = {
 	.ndo_start_xmit		= lance_start_xmit,
 	.ndo_stop		= lance_close,
 	.ndo_get_stats		= lance_get_stats,
-	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_tx_timeout		= lance_tx_timeout,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
diff --git a/drivers/net/ethernet/amd/mvme147.c b/drivers/net/ethernet/amd/mvme147.c
index 3a7ad84..56bc47a 100644
--- a/drivers/net/ethernet/amd/mvme147.c
+++ b/drivers/net/ethernet/amd/mvme147.c
@@ -61,7 +61,7 @@ static const struct net_device_ops lance_netdev_ops = {
 	.ndo_open		= m147lance_open,
 	.ndo_stop		= m147lance_close,
 	.ndo_start_xmit		= lance_start_xmit,
-	.ndo_set_multicast_list	= lance_set_multicast,
+	.ndo_set_rx_mode	= lance_set_multicast,
 	.ndo_tx_timeout		= lance_tx_timeout,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/amd/ni65.c b/drivers/net/ethernet/amd/ni65.c
index c75ae85..6e6aa72 100644
--- a/drivers/net/ethernet/amd/ni65.c
+++ b/drivers/net/ethernet/amd/ni65.c
@@ -406,7 +406,7 @@ static const struct net_device_ops ni65_netdev_ops = {
 	.ndo_stop		= ni65_close,
 	.ndo_start_xmit		= ni65_send_packet,
 	.ndo_tx_timeout		= ni65_timeout,
-	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/amd/nmclan_cs.c b/drivers/net/ethernet/amd/nmclan_cs.c
index 9d70b65..3accd5d 100644
--- a/drivers/net/ethernet/amd/nmclan_cs.c
+++ b/drivers/net/ethernet/amd/nmclan_cs.c
@@ -430,7 +430,7 @@ static const struct net_device_ops mace_netdev_ops = {
 	.ndo_tx_timeout		= mace_tx_timeout,
 	.ndo_set_config		= mace_config,
 	.ndo_get_stats		= mace_get_stats,
-	.ndo_set_multicast_list	= set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index 8b3090d..e19c1a7 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -1505,7 +1505,7 @@ static const struct net_device_ops pcnet32_netdev_ops = {
 	.ndo_start_xmit		= pcnet32_start_xmit,
 	.ndo_tx_timeout		= pcnet32_tx_timeout,
 	.ndo_get_stats		= pcnet32_get_stats,
-	.ndo_set_multicast_list = pcnet32_set_multicast_list,
+	.ndo_set_rx_mode	= pcnet32_set_multicast_list,
 	.ndo_do_ioctl		= pcnet32_ioctl,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
diff --git a/drivers/net/ethernet/amd/sun3lance.c b/drivers/net/ethernet/amd/sun3lance.c
index 7d9ec23..080b71f 100644
--- a/drivers/net/ethernet/amd/sun3lance.c
+++ b/drivers/net/ethernet/amd/sun3lance.c
@@ -297,7 +297,7 @@ static const struct net_device_ops lance_netdev_ops = {
 	.ndo_open		= lance_open,
 	.ndo_stop		= lance_close,
 	.ndo_start_xmit		= lance_start_xmit,
-	.ndo_set_multicast_list	= set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_set_mac_address	= NULL,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/amd/sunlance.c b/drivers/net/ethernet/amd/sunlance.c
index 06f2d43..8fda457 100644
--- a/drivers/net/ethernet/amd/sunlance.c
+++ b/drivers/net/ethernet/amd/sunlance.c
@@ -1298,7 +1298,7 @@ static const struct net_device_ops sparc_lance_ops = {
 	.ndo_open		= lance_open,
 	.ndo_stop		= lance_close,
 	.ndo_start_xmit		= lance_start_xmit,
-	.ndo_set_multicast_list	= lance_set_multicast,
+	.ndo_set_rx_mode	= lance_set_multicast,
 	.ndo_tx_timeout		= lance_tx_timeout,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
diff --git a/drivers/net/ethernet/apple/bmac.c b/drivers/net/ethernet/apple/bmac.c
index 45e45e8..d070b22 100644
--- a/drivers/net/ethernet/apple/bmac.c
+++ b/drivers/net/ethernet/apple/bmac.c
@@ -1237,7 +1237,7 @@ static const struct net_device_ops bmac_netdev_ops = {
 	.ndo_open		= bmac_open,
 	.ndo_stop		= bmac_close,
 	.ndo_start_xmit		= bmac_output,
-	.ndo_set_multicast_list	= bmac_set_multicast,
+	.ndo_set_rx_mode	= bmac_set_multicast,
 	.ndo_set_mac_address	= bmac_set_address,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/apple/cs89x0.c b/drivers/net/ethernet/apple/cs89x0.c
index 537a4b2..f328da2 100644
--- a/drivers/net/ethernet/apple/cs89x0.c
+++ b/drivers/net/ethernet/apple/cs89x0.c
@@ -488,7 +488,7 @@ static const struct net_device_ops net_ops = {
 	.ndo_tx_timeout		= net_timeout,
 	.ndo_start_xmit 	= net_send_packet,
 	.ndo_get_stats		= net_get_stats,
-	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_set_mac_address 	= set_mac_address,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= net_poll_controller,
diff --git a/drivers/net/ethernet/apple/mac89x0.c b/drivers/net/ethernet/apple/mac89x0.c
index 669b317..83781f3 100644
--- a/drivers/net/ethernet/apple/mac89x0.c
+++ b/drivers/net/ethernet/apple/mac89x0.c
@@ -170,7 +170,7 @@ static const struct net_device_ops mac89x0_netdev_ops = {
 	.ndo_stop		= net_close,
 	.ndo_start_xmit		= net_send_packet,
 	.ndo_get_stats		= net_get_stats,
-	.ndo_set_multicast_list	= set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_set_mac_address	= set_mac_address,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/apple/mace.c b/drivers/net/ethernet/apple/mace.c
index 2074e97..bec87bd 100644
--- a/drivers/net/ethernet/apple/mace.c
+++ b/drivers/net/ethernet/apple/mace.c
@@ -100,7 +100,7 @@ static const struct net_device_ops mace_netdev_ops = {
 	.ndo_open		= mace_open,
 	.ndo_stop		= mace_close,
 	.ndo_start_xmit		= mace_xmit_start,
-	.ndo_set_multicast_list	= mace_set_multicast,
+	.ndo_set_rx_mode	= mace_set_multicast,
 	.ndo_set_mac_address	= mace_set_address,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/apple/macmace.c b/drivers/net/ethernet/apple/macmace.c
index 4286e67..6cd3f86 100644
--- a/drivers/net/ethernet/apple/macmace.c
+++ b/drivers/net/ethernet/apple/macmace.c
@@ -185,7 +185,7 @@ static const struct net_device_ops mace_netdev_ops = {
 	.ndo_stop		= mace_close,
 	.ndo_start_xmit		= mace_xmit_start,
 	.ndo_tx_timeout		= mace_tx_timeout,
-	.ndo_set_multicast_list	= mace_set_multicast,
+	.ndo_set_rx_mode	= mace_set_multicast,
 	.ndo_set_mac_address	= mace_set_address,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 9722442..acb4c10 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -2600,7 +2600,7 @@ static const struct net_device_ops atl1c_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_start_xmit		= atl1c_xmit_frame,
 	.ndo_set_mac_address	= atl1c_set_mac_addr,
-	.ndo_set_multicast_list = atl1c_set_multi,
+	.ndo_set_rx_mode	= atl1c_set_multi,
 	.ndo_change_mtu		= atl1c_change_mtu,
 	.ndo_fix_features	= atl1c_fix_features,
 	.ndo_set_features	= atl1c_set_features,
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index d8d4119..1b5dc79 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -2212,7 +2212,7 @@ static const struct net_device_ops atl1e_netdev_ops = {
 	.ndo_stop		= atl1e_close,
 	.ndo_start_xmit		= atl1e_xmit_frame,
 	.ndo_get_stats		= atl1e_get_stats,
-	.ndo_set_multicast_list	= atl1e_set_multi,
+	.ndo_set_rx_mode	= atl1e_set_multi,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= atl1e_set_mac_addr,
 	.ndo_fix_features	= atl1e_fix_features,
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 97e6954..c34e8239 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -2869,7 +2869,7 @@ static const struct net_device_ops atl1_netdev_ops = {
 	.ndo_open		= atl1_open,
 	.ndo_stop		= atl1_close,
 	.ndo_start_xmit		= atl1_xmit_frame,
-	.ndo_set_multicast_list	= atlx_set_multi,
+	.ndo_set_rx_mode	= atlx_set_multi,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= atl1_set_mac,
 	.ndo_change_mtu		= atl1_change_mtu,
diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
index d4f7dda..1feae59 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -1325,7 +1325,7 @@ static const struct net_device_ops atl2_netdev_ops = {
 	.ndo_open		= atl2_open,
 	.ndo_stop		= atl2_close,
 	.ndo_start_xmit		= atl2_xmit_frame,
-	.ndo_set_multicast_list	= atl2_set_multi,
+	.ndo_set_rx_mode	= atl2_set_multi,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= atl2_set_mac,
 	.ndo_change_mtu		= atl2_change_mtu,
diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 41ea84e..4cf835d 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -2114,7 +2114,7 @@ static const struct net_device_ops b44_netdev_ops = {
 	.ndo_stop		= b44_close,
 	.ndo_start_xmit		= b44_start_xmit,
 	.ndo_get_stats		= b44_get_stats,
-	.ndo_set_multicast_list = b44_set_rx_mode,
+	.ndo_set_rx_mode	= b44_set_rx_mode,
 	.ndo_set_mac_address	= b44_set_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl		= b44_ioctl,
diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 1d9b985..05b0228 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1603,7 +1603,7 @@ static const struct net_device_ops bcm_enet_ops = {
 	.ndo_stop		= bcm_enet_stop,
 	.ndo_start_xmit		= bcm_enet_start_xmit,
 	.ndo_set_mac_address	= bcm_enet_set_mac_address,
-	.ndo_set_multicast_list = bcm_enet_set_multicast_list,
+	.ndo_set_rx_mode	= bcm_enet_set_multicast_list,
 	.ndo_do_ioctl		= bcm_enet_ioctl,
 	.ndo_change_mtu		= bcm_enet_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/broadcom/sb1250-mac.c b/drivers/net/ethernet/broadcom/sb1250-mac.c
index ea65f7e..0a1d7f2 100644
--- a/drivers/net/ethernet/broadcom/sb1250-mac.c
+++ b/drivers/net/ethernet/broadcom/sb1250-mac.c
@@ -2176,7 +2176,7 @@ static const struct net_device_ops sbmac_netdev_ops = {
 	.ndo_open		= sbmac_open,
 	.ndo_stop		= sbmac_close,
 	.ndo_start_xmit		= sbmac_start_tx,
-	.ndo_set_multicast_list	= sbmac_set_rx_mode,
+	.ndo_set_rx_mode	= sbmac_set_rx_mode,
 	.ndo_tx_timeout		= sbmac_tx_timeout,
 	.ndo_do_ioctl		= sbmac_mii_ioctl,
 	.ndo_change_mtu		= sb1250_change_mtu,
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index dc3fbf6..6da9c57 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -15177,7 +15177,7 @@ static const struct net_device_ops tg3_netdev_ops = {
 	.ndo_start_xmit		= tg3_start_xmit,
 	.ndo_get_stats64	= tg3_get_stats64,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_multicast_list	= tg3_set_rx_mode,
+	.ndo_set_rx_mode	= tg3_set_rx_mode,
 	.ndo_set_mac_address	= tg3_set_mac_addr,
 	.ndo_do_ioctl		= tg3_ioctl,
 	.ndo_tx_timeout		= tg3_tx_timeout,
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 5ad07ea..bdfda07 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -2957,7 +2957,6 @@ static const struct net_device_ops bnad_netdev_ops = {
 	.ndo_start_xmit		= bnad_start_xmit,
 	.ndo_get_stats64		= bnad_get_stats64,
 	.ndo_set_rx_mode	= bnad_set_rx_mode,
-	.ndo_set_multicast_list = bnad_set_rx_mode,
 	.ndo_validate_addr      = eth_validate_addr,
 	.ndo_set_mac_address    = bnad_set_mac_address,
 	.ndo_change_mtu		= bnad_change_mtu,
diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index 29dc435..1b0ba8c 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -968,7 +968,7 @@ static const struct net_device_ops at91ether_netdev_ops = {
 	.ndo_stop		= at91ether_close,
 	.ndo_start_xmit		= at91ether_start_xmit,
 	.ndo_get_stats		= at91ether_stats,
-	.ndo_set_multicast_list	= at91ether_set_multicast_list,
+	.ndo_set_rx_mode	= at91ether_set_multicast_list,
 	.ndo_set_mac_address	= set_mac_address,
 	.ndo_do_ioctl		= at91ether_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index dc4e305..a437b46 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1106,7 +1106,7 @@ static const struct net_device_ops macb_netdev_ops = {
 	.ndo_open		= macb_open,
 	.ndo_stop		= macb_close,
 	.ndo_start_xmit		= macb_start_xmit,
-	.ndo_set_multicast_list	= macb_set_rx_mode,
+	.ndo_set_rx_mode	= macb_set_rx_mode,
 	.ndo_get_stats		= macb_get_stats,
 	.ndo_do_ioctl		= macb_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
index 3edbbc4..9993f4f 100644
--- a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
+++ b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
@@ -964,7 +964,7 @@ static const struct net_device_ops cxgb_netdev_ops = {
 	.ndo_start_xmit		= t1_start_xmit,
 	.ndo_get_stats		= t1_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_multicast_list	= t1_set_rxmode,
+	.ndo_set_rx_mode	= t1_set_rxmode,
 	.ndo_do_ioctl		= t1_ioctl,
 	.ndo_change_mtu		= t1_change_mtu,
 	.ndo_set_mac_address	= t1_set_mac_addr,
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index 93b41a7..29e0e42 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -3153,7 +3153,7 @@ static const struct net_device_ops cxgb_netdev_ops = {
 	.ndo_start_xmit		= t3_eth_xmit,
 	.ndo_get_stats		= cxgb_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_multicast_list	= cxgb_set_rxmode,
+	.ndo_set_rx_mode	= cxgb_set_rxmode,
 	.ndo_do_ioctl		= cxgb_ioctl,
 	.ndo_change_mtu		= cxgb_change_mtu,
 	.ndo_set_mac_address	= cxgb_set_mac_addr,
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index f342be0..c751c25 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -2104,7 +2104,6 @@ static const struct net_device_ops enic_netdev_dynamic_ops = {
 	.ndo_get_stats64	= enic_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_rx_mode	= enic_set_rx_mode,
-	.ndo_set_multicast_list	= enic_set_rx_mode,
 	.ndo_set_mac_address	= enic_set_mac_address_dynamic,
 	.ndo_change_mtu		= enic_change_mtu,
 	.ndo_vlan_rx_add_vid	= enic_vlan_rx_add_vid,
@@ -2126,7 +2125,6 @@ static const struct net_device_ops enic_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= enic_set_mac_address,
 	.ndo_set_rx_mode	= enic_set_rx_mode,
-	.ndo_set_multicast_list	= enic_set_rx_mode,
 	.ndo_change_mtu		= enic_change_mtu,
 	.ndo_vlan_rx_add_vid	= enic_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= enic_vlan_rx_kill_vid,
diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 8ef31dc..24d61e1 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1339,7 +1339,7 @@ static const struct net_device_ops dm9000_netdev_ops = {
 	.ndo_stop		= dm9000_stop,
 	.ndo_start_xmit		= dm9000_start_xmit,
 	.ndo_tx_timeout		= dm9000_timeout,
-	.ndo_set_multicast_list	= dm9000_hash_table,
+	.ndo_set_rx_mode	= dm9000_hash_table,
 	.ndo_do_ioctl		= dm9000_ioctl,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_features	= dm9000_set_features,
diff --git a/drivers/net/ethernet/dec/ewrk3.c b/drivers/net/ethernet/dec/ewrk3.c
index 05a5f71..f9df5e4 100644
--- a/drivers/net/ethernet/dec/ewrk3.c
+++ b/drivers/net/ethernet/dec/ewrk3.c
@@ -393,7 +393,7 @@ static const struct net_device_ops ewrk3_netdev_ops = {
 	.ndo_open		= ewrk3_open,
 	.ndo_start_xmit		= ewrk3_queue_pkt,
 	.ndo_stop		= ewrk3_close,
-	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_do_ioctl		= ewrk3_ioctl,
 	.ndo_tx_timeout		= ewrk3_timeout,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/dec/tulip/de2104x.c b/drivers/net/ethernet/dec/tulip/de2104x.c
index ce90efc..1427739 100644
--- a/drivers/net/ethernet/dec/tulip/de2104x.c
+++ b/drivers/net/ethernet/dec/tulip/de2104x.c
@@ -1956,7 +1956,7 @@ bad_srom:
 static const struct net_device_ops de_netdev_ops = {
 	.ndo_open		= de_open,
 	.ndo_stop		= de_close,
-	.ndo_set_multicast_list = de_set_rx_mode,
+	.ndo_set_rx_mode	= de_set_rx_mode,
 	.ndo_start_xmit		= de_start_xmit,
 	.ndo_get_stats		= de_get_stats,
 	.ndo_tx_timeout 	= de_tx_timeout,
diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index 959b410..871bcaa 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -1084,7 +1084,7 @@ static const struct net_device_ops de4x5_netdev_ops = {
     .ndo_stop		= de4x5_close,
     .ndo_start_xmit	= de4x5_queue_pkt,
     .ndo_get_stats	= de4x5_get_stats,
-    .ndo_set_multicast_list = set_multicast_list,
+    .ndo_set_rx_mode	= set_multicast_list,
     .ndo_do_ioctl	= de4x5_ioctl,
     .ndo_change_mtu	= eth_change_mtu,
     .ndo_set_mac_address= eth_mac_addr,
diff --git a/drivers/net/ethernet/dec/tulip/dmfe.c b/drivers/net/ethernet/dec/tulip/dmfe.c
index 9a21ca3..17b11ee 100644
--- a/drivers/net/ethernet/dec/tulip/dmfe.c
+++ b/drivers/net/ethernet/dec/tulip/dmfe.c
@@ -356,7 +356,7 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_open 		= dmfe_open,
 	.ndo_stop		= dmfe_stop,
 	.ndo_start_xmit		= dmfe_start_xmit,
-	.ndo_set_multicast_list = dmfe_set_filter_mode,
+	.ndo_set_rx_mode	= dmfe_set_filter_mode,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index 1246998..011f67c 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -1291,7 +1291,7 @@ static const struct net_device_ops tulip_netdev_ops = {
 	.ndo_stop		= tulip_close,
 	.ndo_get_stats		= tulip_get_stats,
 	.ndo_do_ioctl 		= private_ioctl,
-	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_set_rx_mode	= set_rx_mode,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
index 9e63f40..7a44a7a 100644
--- a/drivers/net/ethernet/dec/tulip/uli526x.c
+++ b/drivers/net/ethernet/dec/tulip/uli526x.c
@@ -259,7 +259,7 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_open		= uli526x_open,
 	.ndo_stop		= uli526x_stop,
 	.ndo_start_xmit		= uli526x_start_xmit,
-	.ndo_set_multicast_list = uli526x_set_filter_mode,
+	.ndo_set_rx_mode	= uli526x_set_filter_mode,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/dec/tulip/winbond-840.c b/drivers/net/ethernet/dec/tulip/winbond-840.c
index 862eadf..4d01219 100644
--- a/drivers/net/ethernet/dec/tulip/winbond-840.c
+++ b/drivers/net/ethernet/dec/tulip/winbond-840.c
@@ -350,7 +350,7 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_stop		= netdev_close,
 	.ndo_start_xmit		= start_tx,
 	.ndo_get_stats		= get_stats,
-	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_set_rx_mode	= set_rx_mode,
 	.ndo_do_ioctl		= netdev_ioctl,
 	.ndo_tx_timeout		= tx_timeout,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/dlink/de620.c b/drivers/net/ethernet/dlink/de620.c
index 1c51a75..3b934ab 100644
--- a/drivers/net/ethernet/dlink/de620.c
+++ b/drivers/net/ethernet/dlink/de620.c
@@ -767,7 +767,7 @@ static const struct net_device_ops de620_netdev_ops = {
 	.ndo_stop 		= de620_close,
 	.ndo_start_xmit 	= de620_start_xmit,
 	.ndo_tx_timeout 	= de620_timeout,
-	.ndo_set_multicast_list = de620_set_multicast_list,
+	.ndo_set_rx_mode	= de620_set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
index ed73e4a..3fa9140 100644
--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -92,7 +92,7 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_get_stats		= get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
-	.ndo_set_multicast_list = set_multicast,
+	.ndo_set_rx_mode	= set_multicast,
 	.ndo_do_ioctl		= rio_ioctl,
 	.ndo_tx_timeout		= rio_tx_timeout,
 	.ndo_change_mtu		= change_mtu,
diff --git a/drivers/net/ethernet/dlink/sundance.c b/drivers/net/ethernet/dlink/sundance.c
index 4793df8..dcd7f7a 100644
--- a/drivers/net/ethernet/dlink/sundance.c
+++ b/drivers/net/ethernet/dlink/sundance.c
@@ -464,7 +464,7 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_stop		= netdev_close,
 	.ndo_start_xmit		= start_tx,
 	.ndo_get_stats 		= get_stats,
-	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_set_rx_mode	= set_rx_mode,
 	.ndo_do_ioctl 		= netdev_ioctl,
 	.ndo_tx_timeout		= tx_timeout,
 	.ndo_change_mtu		= change_mtu,
diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 8abbe1d..bdb348a 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -888,7 +888,7 @@ static const struct net_device_ops ethoc_netdev_ops = {
 	.ndo_do_ioctl = ethoc_ioctl,
 	.ndo_set_config = ethoc_config,
 	.ndo_set_mac_address = ethoc_set_mac_address,
-	.ndo_set_multicast_list = ethoc_set_multicast_list,
+	.ndo_set_rx_mode = ethoc_set_multicast_list,
 	.ndo_change_mtu = ethoc_change_mtu,
 	.ndo_tx_timeout = ethoc_tx_timeout,
 	.ndo_start_xmit = ethoc_start_xmit,
diff --git a/drivers/net/ethernet/fealnx.c b/drivers/net/ethernet/fealnx.c
index fa8677c..61d2bdd 100644
--- a/drivers/net/ethernet/fealnx.c
+++ b/drivers/net/ethernet/fealnx.c
@@ -469,7 +469,7 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_stop		= netdev_close,
 	.ndo_start_xmit		= start_tx,
 	.ndo_get_stats 		= get_stats,
-	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_set_rx_mode	= set_rx_mode,
 	.ndo_do_ioctl		= mii_ioctl,
 	.ndo_tx_timeout		= fealnx_tx_timeout,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index e8266cc..158b82e 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1325,7 +1325,7 @@ static const struct net_device_ops fec_netdev_ops = {
 	.ndo_open		= fec_enet_open,
 	.ndo_stop		= fec_enet_close,
 	.ndo_start_xmit		= fec_enet_start_xmit,
-	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_tx_timeout		= fec_timeout,
diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.c b/drivers/net/ethernet/freescale/fec_mpc52xx.c
index cb4416e..30745b5 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx.c
@@ -828,7 +828,7 @@ static const struct net_device_ops mpc52xx_fec_netdev_ops = {
 	.ndo_open = mpc52xx_fec_open,
 	.ndo_stop = mpc52xx_fec_close,
 	.ndo_start_xmit = mpc52xx_fec_start_xmit,
-	.ndo_set_multicast_list = mpc52xx_fec_set_multicast_list,
+	.ndo_set_rx_mode = mpc52xx_fec_set_multicast_list,
 	.ndo_set_mac_address = mpc52xx_fec_set_mac_address,
 	.ndo_validate_addr = eth_validate_addr,
 	.ndo_do_ioctl = mpc52xx_fec_ioctl,
diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index 329ef23..5bf5471 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -988,7 +988,7 @@ static const struct net_device_ops fs_enet_netdev_ops = {
 	.ndo_get_stats		= fs_enet_get_stats,
 	.ndo_start_xmit		= fs_enet_start_xmit,
 	.ndo_tx_timeout		= fs_timeout,
-	.ndo_set_multicast_list	= fs_set_multicast_list,
+	.ndo_set_rx_mode	= fs_set_multicast_list,
 	.ndo_do_ioctl		= fs_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 2659daa..29dff1e 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -458,7 +458,7 @@ static const struct net_device_ops gfar_netdev_ops = {
 	.ndo_stop = gfar_close,
 	.ndo_change_mtu = gfar_change_mtu,
 	.ndo_set_features = gfar_set_features,
-	.ndo_set_multicast_list = gfar_set_multi,
+	.ndo_set_rx_mode = gfar_set_multi,
 	.ndo_tx_timeout = gfar_timeout,
 	.ndo_do_ioctl = gfar_ioctl,
 	.ndo_get_stats = gfar_get_stats,
diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 42f8e31..46d690a 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -3731,7 +3731,7 @@ static const struct net_device_ops ucc_geth_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= ucc_geth_set_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
-	.ndo_set_multicast_list	= ucc_geth_set_multi,
+	.ndo_set_rx_mode	= ucc_geth_set_multi,
 	.ndo_tx_timeout		= ucc_geth_timeout,
 	.ndo_do_ioctl		= ucc_geth_ioctl,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/fujitsu/at1700.c b/drivers/net/ethernet/fujitsu/at1700.c
index 65a78f9..7c6c908 100644
--- a/drivers/net/ethernet/fujitsu/at1700.c
+++ b/drivers/net/ethernet/fujitsu/at1700.c
@@ -253,7 +253,7 @@ static const struct net_device_ops at1700_netdev_ops = {
 	.ndo_open		= net_open,
 	.ndo_stop		= net_close,
 	.ndo_start_xmit 	= net_send_packet,
-	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_set_rx_mode	= set_rx_mode,
 	.ndo_tx_timeout 	= net_tx_timeout,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
diff --git a/drivers/net/ethernet/fujitsu/eth16i.c b/drivers/net/ethernet/fujitsu/eth16i.c
index 12d28e9..b0e2313 100644
--- a/drivers/net/ethernet/fujitsu/eth16i.c
+++ b/drivers/net/ethernet/fujitsu/eth16i.c
@@ -478,7 +478,7 @@ static const struct net_device_ops eth16i_netdev_ops = {
 	.ndo_open               = eth16i_open,
 	.ndo_stop               = eth16i_close,
 	.ndo_start_xmit    	= eth16i_tx,
-	.ndo_set_multicast_list = eth16i_multicast,
+	.ndo_set_rx_mode	= eth16i_multicast,
 	.ndo_tx_timeout 	= eth16i_timeout,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
diff --git a/drivers/net/ethernet/fujitsu/fmvj18x_cs.c b/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
index 723815e..1541675 100644
--- a/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
+++ b/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
@@ -226,7 +226,7 @@ static const struct net_device_ops fjn_netdev_ops = {
 	.ndo_start_xmit 	= fjn_start_xmit,
 	.ndo_tx_timeout 	= fjn_tx_timeout,
 	.ndo_set_config 	= fjn_config,
-	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_set_rx_mode	= set_rx_mode,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
index b6519c1..6a5ee07 100644
--- a/drivers/net/ethernet/hp/hp100.c
+++ b/drivers/net/ethernet/hp/hp100.c
@@ -430,7 +430,7 @@ static const struct net_device_ops hp100_bm_netdev_ops = {
 	.ndo_stop		= hp100_close,
 	.ndo_start_xmit		= hp100_start_xmit_bm,
 	.ndo_get_stats 		= hp100_get_stats,
-	.ndo_set_multicast_list = hp100_set_multicast_list,
+	.ndo_set_rx_mode	= hp100_set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -441,7 +441,7 @@ static const struct net_device_ops hp100_netdev_ops = {
 	.ndo_stop		= hp100_close,
 	.ndo_start_xmit		= hp100_start_xmit,
 	.ndo_get_stats 		= hp100_get_stats,
-	.ndo_set_multicast_list = hp100_set_multicast_list,
+	.ndo_set_rx_mode	= hp100_set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/i825xx/3c505.c b/drivers/net/ethernet/i825xx/3c505.c
index 88d766e..40e1a17 100644
--- a/drivers/net/ethernet/i825xx/3c505.c
+++ b/drivers/net/ethernet/i825xx/3c505.c
@@ -1363,7 +1363,7 @@ static const struct net_device_ops elp_netdev_ops = {
 	.ndo_get_stats 		= elp_get_stats,
 	.ndo_start_xmit		= elp_start_xmit,
 	.ndo_tx_timeout 	= elp_timeout,
-	.ndo_set_multicast_list = elp_set_mc_list,
+	.ndo_set_rx_mode	= elp_set_mc_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/i825xx/3c523.c b/drivers/net/ethernet/i825xx/3c523.c
index bc0d1a1..d70d3df 100644
--- a/drivers/net/ethernet/i825xx/3c523.c
+++ b/drivers/net/ethernet/i825xx/3c523.c
@@ -409,7 +409,7 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_start_xmit		= elmc_send_packet,
 	.ndo_tx_timeout		= elmc_timeout,
 #ifdef ELMC_MULTICAST
-	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 #endif
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
diff --git a/drivers/net/ethernet/i825xx/3c527.c b/drivers/net/ethernet/i825xx/3c527.c
index d9d056d..474b5e7 100644
--- a/drivers/net/ethernet/i825xx/3c527.c
+++ b/drivers/net/ethernet/i825xx/3c527.c
@@ -292,7 +292,7 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_stop		= mc32_close,
 	.ndo_start_xmit		= mc32_send_packet,
 	.ndo_get_stats		= mc32_get_stats,
-	.ndo_set_multicast_list = mc32_set_multicast_list,
+	.ndo_set_rx_mode	= mc32_set_multicast_list,
 	.ndo_tx_timeout		= mc32_timeout,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
diff --git a/drivers/net/ethernet/i825xx/82596.c b/drivers/net/ethernet/i825xx/82596.c
index be1f197..f2408a4 100644
--- a/drivers/net/ethernet/i825xx/82596.c
+++ b/drivers/net/ethernet/i825xx/82596.c
@@ -1145,7 +1145,7 @@ static const struct net_device_ops i596_netdev_ops = {
 	.ndo_open 		= i596_open,
 	.ndo_stop		= i596_close,
 	.ndo_start_xmit		= i596_start_xmit,
-	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_tx_timeout		= i596_tx_timeout,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
diff --git a/drivers/net/ethernet/i825xx/eepro.c b/drivers/net/ethernet/i825xx/eepro.c
index dfeb006..cd1a0df 100644
--- a/drivers/net/ethernet/i825xx/eepro.c
+++ b/drivers/net/ethernet/i825xx/eepro.c
@@ -743,7 +743,7 @@ static const struct net_device_ops eepro_netdev_ops = {
  	.ndo_open               = eepro_open,
  	.ndo_stop               = eepro_close,
  	.ndo_start_xmit    	= eepro_send_packet,
- 	.ndo_set_multicast_list = set_multicast_list,
+ 	.ndo_set_rx_mode	= set_multicast_list,
  	.ndo_tx_timeout		= eepro_tx_timeout,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
diff --git a/drivers/net/ethernet/i825xx/eexpress.c b/drivers/net/ethernet/i825xx/eexpress.c
index a192285..3a9580f 100644
--- a/drivers/net/ethernet/i825xx/eexpress.c
+++ b/drivers/net/ethernet/i825xx/eexpress.c
@@ -1047,7 +1047,7 @@ static const struct net_device_ops eexp_netdev_ops = {
 	.ndo_open 		= eexp_open,
 	.ndo_stop 		= eexp_close,
 	.ndo_start_xmit		= eexp_xmit,
-	.ndo_set_multicast_list = eexp_set_multicast,
+	.ndo_set_rx_mode	= eexp_set_multicast,
 	.ndo_tx_timeout		= eexp_timeout,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
diff --git a/drivers/net/ethernet/i825xx/ether1.c b/drivers/net/ethernet/i825xx/ether1.c
index b00781c..42e90a9 100644
--- a/drivers/net/ethernet/i825xx/ether1.c
+++ b/drivers/net/ethernet/i825xx/ether1.c
@@ -985,7 +985,7 @@ static const struct net_device_ops ether1_netdev_ops = {
 	.ndo_open		= ether1_open,
 	.ndo_stop		= ether1_close,
 	.ndo_start_xmit		= ether1_sendpacket,
-	.ndo_set_multicast_list	= ether1_setmulticastlist,
+	.ndo_set_rx_mode	= ether1_setmulticastlist,
 	.ndo_tx_timeout		= ether1_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/i825xx/lib82596.c b/drivers/net/ethernet/i825xx/lib82596.c
index 9e04289..3efbd8d 100644
--- a/drivers/net/ethernet/i825xx/lib82596.c
+++ b/drivers/net/ethernet/i825xx/lib82596.c
@@ -1038,7 +1038,7 @@ static const struct net_device_ops i596_netdev_ops = {
 	.ndo_open		= i596_open,
 	.ndo_stop		= i596_close,
 	.ndo_start_xmit		= i596_start_xmit,
-	.ndo_set_multicast_list	= set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_tx_timeout		= i596_tx_timeout,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/i825xx/lp486e.c b/drivers/net/ethernet/i825xx/lp486e.c
index 385a953..414044b 100644
--- a/drivers/net/ethernet/i825xx/lp486e.c
+++ b/drivers/net/ethernet/i825xx/lp486e.c
@@ -954,7 +954,7 @@ static const struct net_device_ops i596_netdev_ops = {
 	.ndo_open		= i596_open,
 	.ndo_stop		= i596_close,
 	.ndo_start_xmit		= i596_start_xmit,
-	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_tx_timeout		= i596_tx_timeout,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
diff --git a/drivers/net/ethernet/i825xx/ni52.c b/drivers/net/ethernet/i825xx/ni52.c
index d973fc6..c089371 100644
--- a/drivers/net/ethernet/i825xx/ni52.c
+++ b/drivers/net/ethernet/i825xx/ni52.c
@@ -445,7 +445,7 @@ static const struct net_device_ops ni52_netdev_ops = {
 	.ndo_get_stats		= ni52_get_stats,
 	.ndo_tx_timeout 	= ni52_timeout,
 	.ndo_start_xmit 	= ni52_send_packet,
-	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/i825xx/sun3_82586.c b/drivers/net/ethernet/i825xx/sun3_82586.c
index b6ae53b..6ef5e11 100644
--- a/drivers/net/ethernet/i825xx/sun3_82586.c
+++ b/drivers/net/ethernet/i825xx/sun3_82586.c
@@ -333,7 +333,7 @@ static const struct net_device_ops sun3_82586_netdev_ops = {
 	.ndo_open		= sun3_82586_open,
 	.ndo_stop		= sun3_82586_close,
 	.ndo_start_xmit		= sun3_82586_send_packet,
-	.ndo_set_multicast_list	= set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_tx_timeout		= sun3_82586_timeout,
 	.ndo_get_stats		= sun3_82586_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/i825xx/znet.c b/drivers/net/ethernet/i825xx/znet.c
index 8b88817..962b4c4 100644
--- a/drivers/net/ethernet/i825xx/znet.c
+++ b/drivers/net/ethernet/i825xx/znet.c
@@ -356,7 +356,7 @@ static const struct net_device_ops znet_netdev_ops = {
 	.ndo_open		= znet_open,
 	.ndo_stop		= znet_close,
 	.ndo_start_xmit		= znet_send_packet,
-	.ndo_set_multicast_list = znet_set_multicast_list,
+	.ndo_set_rx_mode	= znet_set_multicast_list,
 	.ndo_tx_timeout		= znet_tx_timeout,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index be2cb4a..583bcd3 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -3161,7 +3161,7 @@ static const struct net_device_ops ehea_netdev_ops = {
 	.ndo_get_stats		= ehea_get_stats,
 	.ndo_set_mac_address	= ehea_set_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_multicast_list	= ehea_set_multicast_list,
+	.ndo_set_rx_mode	= ehea_set_multicast_list,
 	.ndo_change_mtu		= ehea_change_mtu,
 	.ndo_vlan_rx_add_vid	= ehea_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= ehea_vlan_rx_kill_vid,
diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 70cb7d8..209f568 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -2661,7 +2661,7 @@ static const struct net_device_ops emac_netdev_ops = {
 	.ndo_open		= emac_open,
 	.ndo_stop		= emac_close,
 	.ndo_get_stats		= emac_stats,
-	.ndo_set_multicast_list	= emac_set_multicast_list,
+	.ndo_set_rx_mode	= emac_set_multicast_list,
 	.ndo_do_ioctl		= emac_ioctl,
 	.ndo_tx_timeout		= emac_tx_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -2674,7 +2674,7 @@ static const struct net_device_ops emac_gige_netdev_ops = {
 	.ndo_open		= emac_open,
 	.ndo_stop		= emac_close,
 	.ndo_get_stats		= emac_stats,
-	.ndo_set_multicast_list	= emac_set_multicast_list,
+	.ndo_set_rx_mode	= emac_set_multicast_list,
 	.ndo_do_ioctl		= emac_ioctl,
 	.ndo_tx_timeout		= emac_tx_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index ba99af0..bba1ffc 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -1299,7 +1299,7 @@ static const struct net_device_ops ibmveth_netdev_ops = {
 	.ndo_open		= ibmveth_open,
 	.ndo_stop		= ibmveth_close,
 	.ndo_start_xmit		= ibmveth_start_xmit,
-	.ndo_set_multicast_list	= ibmveth_set_multicast_list,
+	.ndo_set_rx_mode	= ibmveth_set_multicast_list,
 	.ndo_do_ioctl		= ibmveth_ioctl,
 	.ndo_change_mtu		= ibmveth_change_mtu,
 	.ndo_fix_features	= ibmveth_fix_features,
diff --git a/drivers/net/ethernet/ibm/iseries_veth.c b/drivers/net/ethernet/ibm/iseries_veth.c
index 53dd39e..4326681 100644
--- a/drivers/net/ethernet/ibm/iseries_veth.c
+++ b/drivers/net/ethernet/ibm/iseries_veth.c
@@ -1009,7 +1009,7 @@ static const struct net_device_ops veth_netdev_ops = {
 	.ndo_stop		= veth_close,
 	.ndo_start_xmit		= veth_start_xmit,
 	.ndo_change_mtu		= veth_change_mtu,
-	.ndo_set_multicast_list	= veth_set_multicast_list,
+	.ndo_set_rx_mode	= veth_set_multicast_list,
 	.ndo_set_mac_address	= NULL,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/ethernet/icplus/ipg.c b/drivers/net/ethernet/icplus/ipg.c
index b470281..8fd80a0 100644
--- a/drivers/net/ethernet/icplus/ipg.c
+++ b/drivers/net/ethernet/icplus/ipg.c
@@ -2201,7 +2201,7 @@ static const struct net_device_ops ipg_netdev_ops = {
 	.ndo_stop		= ipg_nic_stop,
 	.ndo_start_xmit		= ipg_nic_hard_start_xmit,
 	.ndo_get_stats		= ipg_nic_get_stats,
-	.ndo_set_multicast_list = ipg_nic_set_multicast_list,
+	.ndo_set_rx_mode	= ipg_nic_set_multicast_list,
 	.ndo_do_ioctl		= ipg_ioctl,
 	.ndo_tx_timeout 	= ipg_tx_timeout,
 	.ndo_change_mtu 	= ipg_nic_change_mtu,
diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index c1352c6..fe87d3e 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2738,7 +2738,7 @@ static const struct net_device_ops e100_netdev_ops = {
 	.ndo_stop		= e100_close,
 	.ndo_start_xmit		= e100_xmit_frame,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_multicast_list	= e100_set_multicast_list,
+	.ndo_set_rx_mode	= e100_set_multicast_list,
 	.ndo_set_mac_address	= e100_set_mac_address,
 	.ndo_change_mtu		= e100_change_mtu,
 	.ndo_do_ioctl		= e100_do_ioctl,
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index ab4be80..d0fdb51 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5761,7 +5761,7 @@ static const struct net_device_ops e1000e_netdev_ops = {
 	.ndo_stop		= e1000_close,
 	.ndo_start_xmit		= e1000_xmit_frame,
 	.ndo_get_stats64	= e1000e_get_stats64,
-	.ndo_set_multicast_list	= e1000_set_multi,
+	.ndo_set_rx_mode	= e1000_set_multi,
 	.ndo_set_mac_address	= e1000_set_mac,
 	.ndo_change_mtu		= e1000_change_mtu,
 	.ndo_do_ioctl		= e1000_ioctl,
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 592b5c1..8016084 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1790,7 +1790,6 @@ static const struct net_device_ops igb_netdev_ops = {
 	.ndo_start_xmit		= igb_xmit_frame_adv,
 	.ndo_get_stats64	= igb_get_stats64,
 	.ndo_set_rx_mode	= igb_set_rx_mode,
-	.ndo_set_multicast_list	= igb_set_rx_mode,
 	.ndo_set_mac_address	= igb_set_mac,
 	.ndo_change_mtu		= igb_change_mtu,
 	.ndo_do_ioctl		= igb_ioctl,
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 40ed066..a6bdb3c 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -2538,7 +2538,7 @@ static const struct net_device_ops igbvf_netdev_ops = {
 	.ndo_stop                       = igbvf_close,
 	.ndo_start_xmit                 = igbvf_xmit_frame,
 	.ndo_get_stats                  = igbvf_get_stats,
-	.ndo_set_multicast_list         = igbvf_set_multi,
+	.ndo_set_rx_mode		= igbvf_set_multi,
 	.ndo_set_mac_address            = igbvf_set_mac,
 	.ndo_change_mtu                 = igbvf_change_mtu,
 	.ndo_do_ioctl                   = igbvf_ioctl,
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index 6a130eb..b8ef2c0 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -330,7 +330,7 @@ static const struct net_device_ops ixgb_netdev_ops = {
 	.ndo_stop		= ixgb_close,
 	.ndo_start_xmit		= ixgb_xmit_frame,
 	.ndo_get_stats		= ixgb_get_stats,
-	.ndo_set_multicast_list	= ixgb_set_multi,
+	.ndo_set_rx_mode	= ixgb_set_multi,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= ixgb_set_mac,
 	.ndo_change_mtu		= ixgb_change_mtu,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 8c70273..faa83ce 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7205,7 +7205,6 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_start_xmit		= ixgbe_xmit_frame,
 	.ndo_select_queue	= ixgbe_select_queue,
 	.ndo_set_rx_mode        = ixgbe_set_rx_mode,
-	.ndo_set_multicast_list	= ixgbe_set_rx_mode,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= ixgbe_set_mac,
 	.ndo_change_mtu		= ixgbe_change_mtu,
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 45b0078..b1e1c2d 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3221,7 +3221,6 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_stop		= ixgbevf_close,
 	.ndo_start_xmit		= ixgbevf_xmit_frame,
 	.ndo_set_rx_mode	= ixgbevf_set_rx_mode,
-	.ndo_set_multicast_list	= ixgbevf_set_rx_mode,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= ixgbevf_set_mac,
 	.ndo_change_mtu		= ixgbevf_change_mtu,
diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 3ac262f..a869ee4 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -2839,7 +2839,7 @@ static const struct net_device_ops jme_netdev_ops = {
 	.ndo_do_ioctl		= jme_ioctl,
 	.ndo_start_xmit		= jme_start_xmit,
 	.ndo_set_mac_address	= jme_set_macaddr,
-	.ndo_set_multicast_list	= jme_set_multi,
+	.ndo_set_rx_mode	= jme_set_multi,
 	.ndo_change_mtu		= jme_change_mtu,
 	.ndo_tx_timeout		= jme_tx_timeout,
 	.ndo_fix_features       = jme_fix_features,
diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 763844c..6767756 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -1089,7 +1089,7 @@ static const struct net_device_ops korina_netdev_ops = {
 	.ndo_open		= korina_open,
 	.ndo_stop		= korina_close,
 	.ndo_start_xmit		= korina_send_packet,
-	.ndo_set_multicast_list	= korina_multicast_list,
+	.ndo_set_rx_mode	= korina_multicast_list,
 	.ndo_tx_timeout		= korina_tx_timeout,
 	.ndo_do_ioctl		= korina_ioctl,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 45f252b..6bb2b95 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -687,7 +687,7 @@ static const struct net_device_ops ltq_eth_netdev_ops = {
 	.ndo_do_ioctl = ltq_etop_ioctl,
 	.ndo_set_mac_address = ltq_etop_set_mac_address,
 	.ndo_validate_addr = eth_validate_addr,
-	.ndo_set_multicast_list = ltq_etop_set_multicast_list,
+	.ndo_set_rx_mode = ltq_etop_set_multicast_list,
 	.ndo_select_queue = ltq_etop_select_queue,
 	.ndo_init = ltq_etop_init,
 	.ndo_tx_timeout = ltq_etop_tx_timeout,
diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 98ec614..34622b0 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -3762,7 +3762,7 @@ static const struct net_device_ops skge_netdev_ops = {
 	.ndo_tx_timeout		= skge_tx_timeout,
 	.ndo_change_mtu		= skge_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_multicast_list	= skge_set_multicast,
+	.ndo_set_rx_mode	= skge_set_multicast,
 	.ndo_set_mac_address	= skge_set_mac_address,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= skge_netpoll,
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 57339da..3ff0a12 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -4612,7 +4612,7 @@ static const struct net_device_ops sky2_netdev_ops[2] = {
 	.ndo_do_ioctl		= sky2_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= sky2_set_mac_address,
-	.ndo_set_multicast_list	= sky2_set_multicast,
+	.ndo_set_rx_mode	= sky2_set_multicast,
 	.ndo_change_mtu		= sky2_change_mtu,
 	.ndo_fix_features	= sky2_fix_features,
 	.ndo_set_features	= sky2_set_features,
@@ -4629,7 +4629,7 @@ static const struct net_device_ops sky2_netdev_ops[2] = {
 	.ndo_do_ioctl		= sky2_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= sky2_set_mac_address,
-	.ndo_set_multicast_list	= sky2_set_multicast,
+	.ndo_set_rx_mode	= sky2_set_multicast,
 	.ndo_change_mtu		= sky2_change_mtu,
 	.ndo_fix_features	= sky2_fix_features,
 	.ndo_set_features	= sky2_set_features,
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 4b0f32e..27789be 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1016,7 +1016,7 @@ static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_start_xmit		= mlx4_en_xmit,
 	.ndo_select_queue	= mlx4_en_select_queue,
 	.ndo_get_stats		= mlx4_en_get_stats,
-	.ndo_set_multicast_list	= mlx4_en_set_multicast,
+	.ndo_set_rx_mode	= mlx4_en_set_multicast,
 	.ndo_set_mac_address	= mlx4_en_set_mac,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= mlx4_en_change_mtu,
diff --git a/drivers/net/ethernet/micrel/ks8695net.c b/drivers/net/ethernet/micrel/ks8695net.c
index c827a60..7078840 100644
--- a/drivers/net/ethernet/micrel/ks8695net.c
+++ b/drivers/net/ethernet/micrel/ks8695net.c
@@ -1333,7 +1333,7 @@ static const struct net_device_ops ks8695_netdev_ops = {
 	.ndo_tx_timeout		= ks8695_timeout,
 	.ndo_set_mac_address	= ks8695_set_mac,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_multicast_list	= ks8695_set_multicast,
+	.ndo_set_rx_mode	= ks8695_set_multicast,
 };
 
 /**
diff --git a/drivers/net/ethernet/microchip/enc28j60.c b/drivers/net/ethernet/microchip/enc28j60.c
index 2837ce2..50055e0 100644
--- a/drivers/net/ethernet/microchip/enc28j60.c
+++ b/drivers/net/ethernet/microchip/enc28j60.c
@@ -1534,7 +1534,7 @@ static const struct net_device_ops enc28j60_netdev_ops = {
 	.ndo_open		= enc28j60_net_open,
 	.ndo_stop		= enc28j60_net_close,
 	.ndo_start_xmit		= enc28j60_send_packet,
-	.ndo_set_multicast_list = enc28j60_set_multicast_list,
+	.ndo_set_rx_mode	= enc28j60_set_multicast_list,
 	.ndo_set_mac_address	= enc28j60_set_mac_address,
 	.ndo_tx_timeout		= enc28j60_tx_timeout,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/mipsnet.c b/drivers/net/ethernet/mipsnet.c
index 004e64a..d05b0c9 100644
--- a/drivers/net/ethernet/mipsnet.c
+++ b/drivers/net/ethernet/mipsnet.c
@@ -242,7 +242,7 @@ static const struct net_device_ops mipsnet_netdev_ops = {
 	.ndo_open		= mipsnet_open,
 	.ndo_stop		= mipsnet_close,
 	.ndo_start_xmit		= mipsnet_xmit,
-	.ndo_set_multicast_list	= mipsnet_set_mclist,
+	.ndo_set_rx_mode	= mipsnet_set_mclist,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 1d22475..81c1700 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -3892,7 +3892,7 @@ static const struct net_device_ops myri10ge_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= myri10ge_change_mtu,
 	.ndo_fix_features	= myri10ge_fix_features,
-	.ndo_set_multicast_list = myri10ge_set_multicast_list,
+	.ndo_set_rx_mode	= myri10ge_set_multicast_list,
 	.ndo_set_mac_address	= myri10ge_set_mac_address,
 };
 
diff --git a/drivers/net/ethernet/natsemi/ibmlana.c b/drivers/net/ethernet/natsemi/ibmlana.c
index a7d6cad..999407f 100644
--- a/drivers/net/ethernet/natsemi/ibmlana.c
+++ b/drivers/net/ethernet/natsemi/ibmlana.c
@@ -910,7 +910,7 @@ static const struct net_device_ops ibmlana_netdev_ops = {
 	.ndo_open 		= ibmlana_open,
 	.ndo_stop 		= ibmlana_close,
 	.ndo_start_xmit		= ibmlana_tx,
-	.ndo_set_multicast_list = ibmlana_set_multicast_list,
+	.ndo_set_rx_mode	= ibmlana_set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/natsemi/jazzsonic.c b/drivers/net/ethernet/natsemi/jazzsonic.c
index 949c1f9..fc7c6a9 100644
--- a/drivers/net/ethernet/natsemi/jazzsonic.c
+++ b/drivers/net/ethernet/natsemi/jazzsonic.c
@@ -111,7 +111,7 @@ static const struct net_device_ops sonic_netdev_ops = {
 	.ndo_stop		= jazzsonic_close,
 	.ndo_start_xmit		= sonic_send_packet,
 	.ndo_get_stats		= sonic_get_stats,
-	.ndo_set_multicast_list	= sonic_multicast_list,
+	.ndo_set_rx_mode	= sonic_multicast_list,
 	.ndo_tx_timeout		= sonic_tx_timeout,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/natsemi/macsonic.c b/drivers/net/ethernet/natsemi/macsonic.c
index c93679e..5c36948 100644
--- a/drivers/net/ethernet/natsemi/macsonic.c
+++ b/drivers/net/ethernet/natsemi/macsonic.c
@@ -190,7 +190,7 @@ static const struct net_device_ops macsonic_netdev_ops = {
 	.ndo_open		= macsonic_open,
 	.ndo_stop		= macsonic_close,
 	.ndo_start_xmit		= sonic_send_packet,
-	.ndo_set_multicast_list	= sonic_multicast_list,
+	.ndo_set_rx_mode	= sonic_multicast_list,
 	.ndo_tx_timeout		= sonic_tx_timeout,
 	.ndo_get_stats		= sonic_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
index 2962cc6..6ca047a 100644
--- a/drivers/net/ethernet/natsemi/natsemi.c
+++ b/drivers/net/ethernet/natsemi/natsemi.c
@@ -783,7 +783,7 @@ static const struct net_device_ops natsemi_netdev_ops = {
 	.ndo_stop		= netdev_close,
 	.ndo_start_xmit		= start_tx,
 	.ndo_get_stats		= get_stats,
-	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_set_rx_mode	= set_rx_mode,
 	.ndo_change_mtu		= natsemi_change_mtu,
 	.ndo_do_ioctl		= netdev_ioctl,
 	.ndo_tx_timeout 	= ns_tx_timeout,
diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
index e736aec..1a1e20e 100644
--- a/drivers/net/ethernet/natsemi/ns83820.c
+++ b/drivers/net/ethernet/natsemi/ns83820.c
@@ -1937,7 +1937,7 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_start_xmit		= ns83820_hard_start_xmit,
 	.ndo_get_stats		= ns83820_get_stats,
 	.ndo_change_mtu		= ns83820_change_mtu,
-	.ndo_set_multicast_list = ns83820_set_multicast,
+	.ndo_set_rx_mode	= ns83820_set_multicast,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_tx_timeout		= ns83820_tx_timeout,
diff --git a/drivers/net/ethernet/natsemi/xtsonic.c b/drivers/net/ethernet/natsemi/xtsonic.c
index 9f12026..ccf61b9 100644
--- a/drivers/net/ethernet/natsemi/xtsonic.c
+++ b/drivers/net/ethernet/natsemi/xtsonic.c
@@ -122,7 +122,7 @@ static const struct net_device_ops xtsonic_netdev_ops = {
 	.ndo_stop		= xtsonic_close,
 	.ndo_start_xmit		= sonic_send_packet,
 	.ndo_get_stats		= sonic_get_stats,
-	.ndo_set_multicast_list	= sonic_multicast_list,
+	.ndo_set_rx_mode	= sonic_multicast_list,
 	.ndo_tx_timeout		= sonic_tx_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 277d48b..840cbb2 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -7682,7 +7682,7 @@ static const struct net_device_ops s2io_netdev_ops = {
 	.ndo_get_stats	        = s2io_get_stats,
 	.ndo_start_xmit    	= s2io_xmit,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_multicast_list = s2io_set_multicast,
+	.ndo_set_rx_mode	= s2io_set_multicast,
 	.ndo_do_ioctl	   	= s2io_ioctl,
 	.ndo_set_mac_address    = s2io_set_mac_addr,
 	.ndo_change_mtu	   	= s2io_change_mtu,
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index 178348a2..1a53a24 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -3354,7 +3354,7 @@ static const struct net_device_ops vxge_netdev_ops = {
 	.ndo_get_stats64        = vxge_get_stats64,
 	.ndo_start_xmit         = vxge_xmit,
 	.ndo_validate_addr      = eth_validate_addr,
-	.ndo_set_multicast_list = vxge_set_multicast,
+	.ndo_set_rx_mode	= vxge_set_multicast,
 	.ndo_do_ioctl           = vxge_ioctl,
 	.ndo_set_mac_address    = vxge_set_mac_addr,
 	.ndo_change_mtu         = vxge_change_mtu,
diff --git a/drivers/net/ethernet/netx-eth.c b/drivers/net/ethernet/netx-eth.c
index 2dfee89..8d288af 100644
--- a/drivers/net/ethernet/netx-eth.c
+++ b/drivers/net/ethernet/netx-eth.c
@@ -306,7 +306,7 @@ static const struct net_device_ops netx_eth_netdev_ops = {
 	.ndo_stop		= netx_eth_close,
 	.ndo_start_xmit		= netx_eth_hard_start_xmit,
 	.ndo_tx_timeout		= netx_eth_timeout,
-	.ndo_set_multicast_list	= netx_eth_set_multicast_list,
+	.ndo_set_rx_mode	= netx_eth_set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
diff --git a/drivers/net/ethernet/nuvoton/w90p910_ether.c b/drivers/net/ethernet/nuvoton/w90p910_ether.c
index bfea499..f1bfb8f 100644
--- a/drivers/net/ethernet/nuvoton/w90p910_ether.c
+++ b/drivers/net/ethernet/nuvoton/w90p910_ether.c
@@ -919,7 +919,7 @@ static const struct net_device_ops w90p910_ether_netdev_ops = {
 	.ndo_stop		= w90p910_ether_close,
 	.ndo_start_xmit		= w90p910_ether_start_xmit,
 	.ndo_get_stats		= w90p910_ether_stats,
-	.ndo_set_multicast_list	= w90p910_ether_set_multicast_list,
+	.ndo_set_rx_mode	= w90p910_ether_set_multicast_list,
 	.ndo_set_mac_address	= w90p910_set_mac_address,
 	.ndo_do_ioctl		= w90p910_ether_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index e55df30..3784a72 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -5208,7 +5208,7 @@ static const struct net_device_ops nv_netdev_ops = {
 	.ndo_set_features	= nv_set_features,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= nv_set_mac_address,
-	.ndo_set_multicast_list	= nv_set_multicast,
+	.ndo_set_rx_mode	= nv_set_multicast,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= nv_poll_controller,
 #endif
@@ -5225,7 +5225,7 @@ static const struct net_device_ops nv_netdev_ops_optimized = {
 	.ndo_set_features	= nv_set_features,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= nv_set_mac_address,
-	.ndo_set_multicast_list	= nv_set_multicast,
+	.ndo_set_rx_mode	= nv_set_multicast,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= nv_poll_controller,
 #endif
diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
index d6f96e5..bc1d946 100644
--- a/drivers/net/ethernet/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/octeon/octeon_mgmt.c
@@ -1060,7 +1060,6 @@ static const struct net_device_ops octeon_mgmt_ops = {
 	.ndo_stop =			octeon_mgmt_stop,
 	.ndo_start_xmit =		octeon_mgmt_xmit,
 	.ndo_set_rx_mode = 		octeon_mgmt_set_rx_filtering,
-	.ndo_set_multicast_list =	octeon_mgmt_set_rx_filtering,
 	.ndo_set_mac_address =		octeon_mgmt_set_mac_address,
 	.ndo_do_ioctl = 		octeon_mgmt_ioctl,
 	.ndo_change_mtu =		octeon_mgmt_change_mtu,
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index eac3c5c..72276fe 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -2158,7 +2158,7 @@ static const struct net_device_ops pch_gbe_netdev_ops = {
 	.ndo_change_mtu = pch_gbe_change_mtu,
 	.ndo_set_features = pch_gbe_set_features,
 	.ndo_do_ioctl = pch_gbe_ioctl,
-	.ndo_set_multicast_list = &pch_gbe_set_multi,
+	.ndo_set_rx_mode = pch_gbe_set_multi,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = pch_gbe_netpoll,
 #endif
diff --git a/drivers/net/ethernet/packetengines/hamachi.c b/drivers/net/ethernet/packetengines/hamachi.c
index c274b3d..3458df3 100644
--- a/drivers/net/ethernet/packetengines/hamachi.c
+++ b/drivers/net/ethernet/packetengines/hamachi.c
@@ -567,7 +567,7 @@ static const struct net_device_ops hamachi_netdev_ops = {
 	.ndo_stop		= hamachi_close,
 	.ndo_start_xmit		= hamachi_start_xmit,
 	.ndo_get_stats		= hamachi_get_stats,
-	.ndo_set_multicast_list	= set_rx_mode,
+	.ndo_set_rx_mode	= set_rx_mode,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
diff --git a/drivers/net/ethernet/packetengines/yellowfin.c b/drivers/net/ethernet/packetengines/yellowfin.c
index 3e5ac60..db44e9a 100644
--- a/drivers/net/ethernet/packetengines/yellowfin.c
+++ b/drivers/net/ethernet/packetengines/yellowfin.c
@@ -359,7 +359,7 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_open 		= yellowfin_open,
 	.ndo_stop 		= yellowfin_close,
 	.ndo_start_xmit 	= yellowfin_start_xmit,
-	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_set_rx_mode	= set_rx_mode,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index 9ec112c..fad620d 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -1719,7 +1719,7 @@ static const struct net_device_ops pasemi_netdev_ops = {
 	.ndo_open		= pasemi_mac_open,
 	.ndo_stop		= pasemi_mac_close,
 	.ndo_start_xmit		= pasemi_mac_start_tx,
-	.ndo_set_multicast_list	= pasemi_mac_set_rx_mode,
+	.ndo_set_rx_mode	= pasemi_mac_set_rx_mode,
 	.ndo_set_mac_address	= pasemi_mac_set_mac_addr,
 	.ndo_change_mtu		= pasemi_mac_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 8c7fc32..de18e47 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -524,7 +524,7 @@ static const struct net_device_ops netxen_netdev_ops = {
 	.ndo_start_xmit    = netxen_nic_xmit_frame,
 	.ndo_get_stats64   = netxen_nic_get_stats,
 	.ndo_validate_addr = eth_validate_addr,
-	.ndo_set_multicast_list = netxen_set_multicast_list,
+	.ndo_set_rx_mode   = netxen_set_multicast_list,
 	.ndo_set_mac_address    = netxen_nic_set_mac,
 	.ndo_change_mtu	   = netxen_nic_change_mtu,
 	.ndo_tx_timeout	   = netxen_tx_timeout,
diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
index ccde806..8cab61c 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -3762,7 +3762,6 @@ static const struct net_device_ops ql3xxx_netdev_ops = {
 	.ndo_open		= ql3xxx_open,
 	.ndo_start_xmit		= ql3xxx_send,
 	.ndo_stop		= ql3xxx_close,
-	.ndo_set_multicast_list = NULL, /* not allowed on NIC side */
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= ql3xxx_set_mac_address,
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index ec8ef72..b447cc5 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -325,7 +325,7 @@ static const struct net_device_ops qlcnic_netdev_ops = {
 	.ndo_start_xmit    = qlcnic_xmit_frame,
 	.ndo_get_stats	   = qlcnic_get_stats,
 	.ndo_validate_addr = eth_validate_addr,
-	.ndo_set_multicast_list = qlcnic_set_multi,
+	.ndo_set_rx_mode   = qlcnic_set_multi,
 	.ndo_set_mac_address    = qlcnic_set_mac,
 	.ndo_change_mtu	   = qlcnic_change_mtu,
 	.ndo_fix_features  = qlcnic_fix_features,
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index f07e96e..39360c4 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -4676,7 +4676,7 @@ static const struct net_device_ops qlge_netdev_ops = {
 	.ndo_start_xmit		= qlge_send,
 	.ndo_change_mtu		= qlge_change_mtu,
 	.ndo_get_stats		= qlge_get_stats,
-	.ndo_set_multicast_list = qlge_set_multicast_list,
+	.ndo_set_rx_mode	= qlge_set_multicast_list,
 	.ndo_set_mac_address	= qlge_set_mac_address,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_tx_timeout		= qlge_tx_timeout,
diff --git a/drivers/net/ethernet/racal/ni5010.c b/drivers/net/ethernet/racal/ni5010.c
index 4d3f2e2..072810d 100644
--- a/drivers/net/ethernet/racal/ni5010.c
+++ b/drivers/net/ethernet/racal/ni5010.c
@@ -192,7 +192,7 @@ static const struct net_device_ops ni5010_netdev_ops = {
 	.ndo_open		= ni5010_open,
 	.ndo_stop		= ni5010_close,
 	.ndo_start_xmit		= ni5010_send_packet,
-	.ndo_set_multicast_list	= ni5010_set_multicast_list,
+	.ndo_set_rx_mode	= ni5010_set_multicast_list,
 	.ndo_tx_timeout		= ni5010_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index b64fcee..2bbadc0 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -982,7 +982,7 @@ static const struct net_device_ops r6040_netdev_ops = {
 	.ndo_stop		= r6040_close,
 	.ndo_start_xmit		= r6040_start_xmit,
 	.ndo_get_stats		= r6040_get_stats,
-	.ndo_set_multicast_list = r6040_multicast_list,
+	.ndo_set_rx_mode	= r6040_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index cc4c210..5d2d1b8 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -1785,7 +1785,7 @@ static const struct net_device_ops cp_netdev_ops = {
 	.ndo_stop		= cp_close,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= cp_set_mac_address,
-	.ndo_set_multicast_list	= cp_set_rx_mode,
+	.ndo_set_rx_mode	= cp_set_rx_mode,
 	.ndo_get_stats		= cp_get_stats,
 	.ndo_do_ioctl		= cp_ioctl,
 	.ndo_start_xmit		= cp_start_xmit,
diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index c2672c6..4d6b254 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -916,7 +916,7 @@ static const struct net_device_ops rtl8139_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= rtl8139_set_mac_address,
 	.ndo_start_xmit		= rtl8139_start_xmit,
-	.ndo_set_multicast_list	= rtl8139_set_rx_mode,
+	.ndo_set_rx_mode	= rtl8139_set_rx_mode,
 	.ndo_do_ioctl		= netdev_ioctl,
 	.ndo_tx_timeout		= rtl8139_tx_timeout,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/realtek/atp.c b/drivers/net/ethernet/realtek/atp.c
index f345979..e3f57fd 100644
--- a/drivers/net/ethernet/realtek/atp.c
+++ b/drivers/net/ethernet/realtek/atp.c
@@ -245,7 +245,7 @@ static const struct net_device_ops atp_netdev_ops = {
 	.ndo_open		= net_open,
 	.ndo_stop		= net_close,
 	.ndo_start_xmit		= atp_send_packet,
-	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_set_rx_mode	= set_rx_mode,
 	.ndo_tx_timeout		= tx_timeout,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 02339b3..1cf8c3c 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3277,7 +3277,7 @@ static const struct net_device_ops rtl8169_netdev_ops = {
 	.ndo_set_features	= rtl8169_set_features,
 	.ndo_set_mac_address	= rtl_set_mac_address,
 	.ndo_do_ioctl		= rtl8169_ioctl,
-	.ndo_set_multicast_list	= rtl_set_rx_mode,
+	.ndo_set_rx_mode	= rtl_set_rx_mode,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= rtl8169_netpoll,
 #endif
diff --git a/drivers/net/ethernet/realtek/sc92031.c b/drivers/net/ethernet/realtek/sc92031.c
index 9da4733..128f8eb 100644
--- a/drivers/net/ethernet/realtek/sc92031.c
+++ b/drivers/net/ethernet/realtek/sc92031.c
@@ -1390,7 +1390,7 @@ static const struct net_device_ops sc92031_netdev_ops = {
 	.ndo_start_xmit		= sc92031_start_xmit,
 	.ndo_open		= sc92031_open,
 	.ndo_stop		= sc92031_stop,
-	.ndo_set_multicast_list	= sc92031_set_multicast_list,
+	.ndo_set_rx_mode	= sc92031_set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index ad35c21..ef3a352 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1758,7 +1758,7 @@ static const struct net_device_ops sh_eth_netdev_ops = {
 	.ndo_start_xmit		= sh_eth_start_xmit,
 	.ndo_get_stats		= sh_eth_get_stats,
 #if defined(SH_ETH_HAS_TSU)
-	.ndo_set_multicast_list	= sh_eth_set_multicast_list,
+	.ndo_set_rx_mode	= sh_eth_set_multicast_list,
 #endif
 	.ndo_tx_timeout		= sh_eth_tx_timeout,
 	.ndo_do_ioctl		= sh_eth_do_ioctl,
diff --git a/drivers/net/ethernet/seeq/ether3.c b/drivers/net/ethernet/seeq/ether3.c
index 44a8746..893c880 100644
--- a/drivers/net/ethernet/seeq/ether3.c
+++ b/drivers/net/ethernet/seeq/ether3.c
@@ -761,7 +761,7 @@ static const struct net_device_ops ether3_netdev_ops = {
 	.ndo_open		= ether3_open,
 	.ndo_stop		= ether3_close,
 	.ndo_start_xmit		= ether3_sendpacket,
-	.ndo_set_multicast_list	= ether3_setmulticastlist,
+	.ndo_set_rx_mode	= ether3_setmulticastlist,
 	.ndo_tx_timeout		= ether3_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/seeq/seeq8005.c b/drivers/net/ethernet/seeq/seeq8005.c
index d2fce98..6056145 100644
--- a/drivers/net/ethernet/seeq/seeq8005.c
+++ b/drivers/net/ethernet/seeq/seeq8005.c
@@ -148,7 +148,7 @@ static const struct net_device_ops seeq8005_netdev_ops = {
 	.ndo_stop		= seeq8005_close,
 	.ndo_start_xmit 	= seeq8005_send_packet,
 	.ndo_tx_timeout		= seeq8005_timeout,
-	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/seeq/sgiseeq.c b/drivers/net/ethernet/seeq/sgiseeq.c
index 52fb7ed..c3673f1 100644
--- a/drivers/net/ethernet/seeq/sgiseeq.c
+++ b/drivers/net/ethernet/seeq/sgiseeq.c
@@ -715,7 +715,7 @@ static const struct net_device_ops sgiseeq_netdev_ops = {
 	.ndo_stop		= sgiseeq_close,
 	.ndo_start_xmit		= sgiseeq_start_xmit,
 	.ndo_tx_timeout		= timeout,
-	.ndo_set_multicast_list	= sgiseeq_set_multicast,
+	.ndo_set_rx_mode	= sgiseeq_set_multicast,
 	.ndo_set_mac_address	= sgiseeq_set_mac_address,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index faca764..b6b0e71 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1903,7 +1903,7 @@ static const struct net_device_ops efx_netdev_ops = {
 	.ndo_do_ioctl		= efx_ioctl,
 	.ndo_change_mtu		= efx_change_mtu,
 	.ndo_set_mac_address	= efx_set_mac_address,
-	.ndo_set_multicast_list = efx_set_multicast_list,
+	.ndo_set_rx_mode	= efx_set_multicast_list,
 	.ndo_set_features	= efx_set_features,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = efx_netpoll,
diff --git a/drivers/net/ethernet/sgi/ioc3-eth.c b/drivers/net/ethernet/sgi/ioc3-eth.c
index a234e45..ac149d9 100644
--- a/drivers/net/ethernet/sgi/ioc3-eth.c
+++ b/drivers/net/ethernet/sgi/ioc3-eth.c
@@ -1220,7 +1220,7 @@ static const struct net_device_ops ioc3_netdev_ops = {
 	.ndo_start_xmit		= ioc3_start_xmit,
 	.ndo_tx_timeout		= ioc3_timeout,
 	.ndo_get_stats		= ioc3_get_stats,
-	.ndo_set_multicast_list	= ioc3_set_multicast_list,
+	.ndo_set_rx_mode	= ioc3_set_multicast_list,
 	.ndo_do_ioctl		= ioc3_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= ioc3_set_mac_address,
diff --git a/drivers/net/ethernet/sis/sis190.c b/drivers/net/ethernet/sis/sis190.c
index 3c0f131..1b4658c 100644
--- a/drivers/net/ethernet/sis/sis190.c
+++ b/drivers/net/ethernet/sis/sis190.c
@@ -1841,7 +1841,7 @@ static const struct net_device_ops sis190_netdev_ops = {
 	.ndo_do_ioctl		= sis190_ioctl,
 	.ndo_start_xmit		= sis190_start_xmit,
 	.ndo_tx_timeout		= sis190_tx_timeout,
-	.ndo_set_multicast_list = sis190_set_rx_mode,
+	.ndo_set_rx_mode	= sis190_set_rx_mode,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= sis190_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index 658a192..a184abc 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -403,7 +403,7 @@ static const struct net_device_ops sis900_netdev_ops = {
 	.ndo_stop		= sis900_close,
 	.ndo_start_xmit		= sis900_start_xmit,
 	.ndo_set_config		= sis900_set_config,
-	.ndo_set_multicast_list	= set_rx_mode,
+	.ndo_set_rx_mode	= set_rx_mode,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
diff --git a/drivers/net/ethernet/smsc/epic100.c b/drivers/net/ethernet/smsc/epic100.c
index 814c187..0a5dfb8 100644
--- a/drivers/net/ethernet/smsc/epic100.c
+++ b/drivers/net/ethernet/smsc/epic100.c
@@ -314,7 +314,7 @@ static const struct net_device_ops epic_netdev_ops = {
 	.ndo_start_xmit		= epic_start_xmit,
 	.ndo_tx_timeout 	= epic_tx_timeout,
 	.ndo_get_stats		= epic_get_stats,
-	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_set_rx_mode	= set_rx_mode,
 	.ndo_do_ioctl 		= netdev_ioctl,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
index a91fe17..8f61fe9 100644
--- a/drivers/net/ethernet/smsc/smc911x.c
+++ b/drivers/net/ethernet/smsc/smc911x.c
@@ -1768,7 +1768,7 @@ static const struct net_device_ops smc911x_netdev_ops = {
 	.ndo_stop		= smc911x_close,
 	.ndo_start_xmit		= smc911x_hard_start_xmit,
 	.ndo_tx_timeout		= smc911x_timeout,
-	.ndo_set_multicast_list	= smc911x_set_multicast_list,
+	.ndo_set_rx_mode	= smc911x_set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
diff --git a/drivers/net/ethernet/smsc/smc9194.c b/drivers/net/ethernet/smsc/smc9194.c
index 5b65ac4..4e45094 100644
--- a/drivers/net/ethernet/smsc/smc9194.c
+++ b/drivers/net/ethernet/smsc/smc9194.c
@@ -827,7 +827,7 @@ static const struct net_device_ops smc_netdev_ops = {
 	.ndo_stop		= smc_close,
 	.ndo_start_xmit    	= smc_wait_to_send_packet,
 	.ndo_tx_timeout	    	= smc_timeout,
-	.ndo_set_multicast_list	= smc_set_multicast_list,
+	.ndo_set_rx_mode	= smc_set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/smsc/smc91c92_cs.c b/drivers/net/ethernet/smsc/smc91c92_cs.c
index cffbc03..cbfa981 100644
--- a/drivers/net/ethernet/smsc/smc91c92_cs.c
+++ b/drivers/net/ethernet/smsc/smc91c92_cs.c
@@ -294,7 +294,7 @@ static const struct net_device_ops smc_netdev_ops = {
 	.ndo_start_xmit		= smc_start_xmit,
 	.ndo_tx_timeout 	= smc_tx_timeout,
 	.ndo_set_config 	= s9k_config,
-	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_set_rx_mode	= set_rx_mode,
 	.ndo_do_ioctl		= smc_ioctl,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 2b1d254..f47f81e 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -1768,7 +1768,7 @@ static const struct net_device_ops smc_netdev_ops = {
 	.ndo_stop		= smc_close,
 	.ndo_start_xmit		= smc_hard_start_xmit,
 	.ndo_tx_timeout		= smc_timeout,
-	.ndo_set_multicast_list	= smc_set_multicast_list,
+	.ndo_set_rx_mode	= smc_set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 75c08a5..788c4fd 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -1906,7 +1906,7 @@ static const struct net_device_ops smsc911x_netdev_ops = {
 	.ndo_stop		= smsc911x_stop,
 	.ndo_start_xmit		= smsc911x_hard_start_xmit,
 	.ndo_get_stats		= smsc911x_get_stats,
-	.ndo_set_multicast_list	= smsc911x_set_multicast_list,
+	.ndo_set_rx_mode	= smsc911x_set_multicast_list,
 	.ndo_do_ioctl		= smsc911x_do_ioctl,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index 459726f..4f15680 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -1566,7 +1566,7 @@ static const struct net_device_ops smsc9420_netdev_ops = {
 	.ndo_stop		= smsc9420_stop,
 	.ndo_start_xmit		= smsc9420_hard_start_xmit,
 	.ndo_get_stats		= smsc9420_get_stats,
-	.ndo_set_multicast_list	= smsc9420_set_multicast_list,
+	.ndo_set_rx_mode	= smsc9420_set_multicast_list,
 	.ndo_do_ioctl		= smsc9420_do_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index 646c86b..1776a37 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -4910,7 +4910,7 @@ static const struct net_device_ops cas_netdev_ops = {
 	.ndo_stop		= cas_close,
 	.ndo_start_xmit		= cas_start_xmit,
 	.ndo_get_stats 		= cas_get_stats,
-	.ndo_set_multicast_list = cas_set_multicast,
+	.ndo_set_rx_mode	= cas_set_multicast,
 	.ndo_do_ioctl		= cas_ioctl,
 	.ndo_tx_timeout		= cas_tx_timeout,
 	.ndo_change_mtu		= cas_change_mtu,
diff --git a/drivers/net/ethernet/sun/sunbmac.c b/drivers/net/ethernet/sun/sunbmac.c
index 297a424..c94f5ef 100644
--- a/drivers/net/ethernet/sun/sunbmac.c
+++ b/drivers/net/ethernet/sun/sunbmac.c
@@ -1070,7 +1070,7 @@ static const struct net_device_ops bigmac_ops = {
 	.ndo_stop		= bigmac_close,
 	.ndo_start_xmit		= bigmac_start_xmit,
 	.ndo_get_stats		= bigmac_get_stats,
-	.ndo_set_multicast_list	= bigmac_set_multicast,
+	.ndo_set_rx_mode	= bigmac_set_multicast,
 	.ndo_tx_timeout		= bigmac_tx_timeout,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index 0f13c5d..51c0afc 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -2820,7 +2820,7 @@ static const struct net_device_ops gem_netdev_ops = {
 	.ndo_stop		= gem_close,
 	.ndo_start_xmit		= gem_start_xmit,
 	.ndo_get_stats		= gem_get_stats,
-	.ndo_set_multicast_list = gem_set_multicast,
+	.ndo_set_rx_mode	= gem_set_multicast,
 	.ndo_do_ioctl		= gem_ioctl,
 	.ndo_tx_timeout		= gem_tx_timeout,
 	.ndo_change_mtu		= gem_change_mtu,
diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index 856e05b..42f866e 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -2619,7 +2619,7 @@ static const struct net_device_ops hme_netdev_ops = {
 	.ndo_start_xmit		= happy_meal_start_xmit,
 	.ndo_tx_timeout		= happy_meal_tx_timeout,
 	.ndo_get_stats		= happy_meal_get_stats,
-	.ndo_set_multicast_list = happy_meal_set_multicast,
+	.ndo_set_rx_mode	= happy_meal_set_multicast,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/sun/sunqe.c b/drivers/net/ethernet/sun/sunqe.c
index 209c7f8..b28f743 100644
--- a/drivers/net/ethernet/sun/sunqe.c
+++ b/drivers/net/ethernet/sun/sunqe.c
@@ -824,7 +824,7 @@ static const struct net_device_ops qec_ops = {
 	.ndo_open		= qe_open,
 	.ndo_stop		= qe_close,
 	.ndo_start_xmit		= qe_start_xmit,
-	.ndo_set_multicast_list	= qe_set_multicast,
+	.ndo_set_rx_mode	= qe_set_multicast,
 	.ndo_tx_timeout		= qe_tx_timeout,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index bf3c762..8c6c059 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -1012,7 +1012,7 @@ static DEFINE_MUTEX(vnet_list_mutex);
 static const struct net_device_ops vnet_ops = {
 	.ndo_open		= vnet_open,
 	.ndo_stop		= vnet_close,
-	.ndo_set_multicast_list	= vnet_set_rx_mode,
+	.ndo_set_rx_mode	= vnet_set_rx_mode,
 	.ndo_set_mac_address	= vnet_set_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_tx_timeout		= vnet_tx_timeout,
diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index 749bbf1..bc65aa8 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -1860,7 +1860,7 @@ static const struct net_device_ops bdx_netdev_ops = {
 	.ndo_start_xmit		= bdx_tx_transmit,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl		= bdx_ioctl,
-	.ndo_set_multicast_list = bdx_setmulti,
+	.ndo_set_rx_mode	= bdx_setmulti,
 	.ndo_change_mtu		= bdx_change_mtu,
 	.ndo_set_mac_address	= bdx_set_mac,
 	.ndo_vlan_rx_add_vid	= bdx_vlan_rx_add_vid,
diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index e0638cb..aaac0c7 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -1100,7 +1100,7 @@ static const struct net_device_ops cpmac_netdev_ops = {
 	.ndo_stop		= cpmac_stop,
 	.ndo_start_xmit		= cpmac_start_xmit,
 	.ndo_tx_timeout		= cpmac_tx_timeout,
-	.ndo_set_multicast_list	= cpmac_set_multicast_list,
+	.ndo_set_rx_mode	= cpmac_set_multicast_list,
 	.ndo_do_ioctl		= cpmac_ioctl,
 	.ndo_set_config		= cpmac_config,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 3f451e4..815c797 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1741,7 +1741,7 @@ static const struct net_device_ops emac_netdev_ops = {
 	.ndo_open		= emac_dev_open,
 	.ndo_stop		= emac_dev_stop,
 	.ndo_start_xmit		= emac_dev_xmit,
-	.ndo_set_multicast_list	= emac_dev_mcast_set,
+	.ndo_set_rx_mode	= emac_dev_mcast_set,
 	.ndo_set_mac_address	= emac_dev_setmac_addr,
 	.ndo_do_ioctl		= emac_devioctl,
 	.ndo_tx_timeout		= emac_dev_tx_timeout,
diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index 145871b..9c0dd6b 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -774,7 +774,7 @@ static const struct net_device_ops tlan_netdev_ops = {
 	.ndo_start_xmit		= tlan_start_tx,
 	.ndo_tx_timeout		= tlan_tx_timeout,
 	.ndo_get_stats		= tlan_get_stats,
-	.ndo_set_multicast_list = tlan_set_multicast_list,
+	.ndo_set_rx_mode	= tlan_set_multicast_list,
 	.ndo_do_ioctl		= tlan_ioctl,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_net.c b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
index d82a82d..ddb33cf 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_net.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
@@ -1452,7 +1452,7 @@ static const struct net_device_ops gelic_netdevice_ops = {
 	.ndo_open = gelic_net_open,
 	.ndo_stop = gelic_net_stop,
 	.ndo_start_xmit = gelic_net_xmit,
-	.ndo_set_multicast_list = gelic_net_set_multi,
+	.ndo_set_rx_mode = gelic_net_set_multi,
 	.ndo_change_mtu = gelic_net_change_mtu,
 	.ndo_tx_timeout = gelic_net_tx_timeout,
 	.ndo_set_mac_address = eth_mac_addr,
diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
index 2e62938..fd4ed7f 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
@@ -2568,7 +2568,7 @@ static const struct net_device_ops gelic_wl_netdevice_ops = {
 	.ndo_open = gelic_wl_open,
 	.ndo_stop = gelic_wl_stop,
 	.ndo_start_xmit = gelic_net_xmit,
-	.ndo_set_multicast_list = gelic_net_set_multi,
+	.ndo_set_rx_mode = gelic_net_set_multi,
 	.ndo_change_mtu = gelic_net_change_mtu,
 	.ndo_tx_timeout = gelic_net_tx_timeout,
 	.ndo_set_mac_address = eth_mac_addr,
diff --git a/drivers/net/ethernet/toshiba/spider_net.c b/drivers/net/ethernet/toshiba/spider_net.c
index 1ff3491c..134cae4 100644
--- a/drivers/net/ethernet/toshiba/spider_net.c
+++ b/drivers/net/ethernet/toshiba/spider_net.c
@@ -2259,7 +2259,7 @@ static const struct net_device_ops spider_net_ops = {
 	.ndo_open		= spider_net_open,
 	.ndo_stop		= spider_net_stop,
 	.ndo_start_xmit		= spider_net_xmit,
-	.ndo_set_multicast_list	= spider_net_set_multi,
+	.ndo_set_rx_mode	= spider_net_set_multi,
 	.ndo_set_mac_address	= spider_net_set_mac,
 	.ndo_change_mtu		= spider_net_change_mtu,
 	.ndo_do_ioctl		= spider_net_do_ioctl,
diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index 4a55a16..71b785c 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -774,7 +774,7 @@ static const struct net_device_ops tc35815_netdev_ops = {
 	.ndo_stop		= tc35815_close,
 	.ndo_start_xmit		= tc35815_send_packet,
 	.ndo_get_stats		= tc35815_get_stats,
-	.ndo_set_multicast_list	= tc35815_set_multicast_list,
+	.ndo_set_rx_mode	= tc35815_set_multicast_list,
 	.ndo_tx_timeout		= tc35815_tx_timeout,
 	.ndo_do_ioctl		= tc35815_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/tundra/tsi108_eth.c b/drivers/net/ethernet/tundra/tsi108_eth.c
index 64cb9ac..480a4ba 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.c
+++ b/drivers/net/ethernet/tundra/tsi108_eth.c
@@ -1554,7 +1554,7 @@ static const struct net_device_ops tsi108_netdev_ops = {
 	.ndo_open		= tsi108_open,
 	.ndo_stop		= tsi108_close,
 	.ndo_start_xmit		= tsi108_send_packet,
-	.ndo_set_multicast_list	= tsi108_set_rx_mode,
+	.ndo_set_rx_mode	= tsi108_set_rx_mode,
 	.ndo_get_stats		= tsi108_get_stats,
 	.ndo_do_ioctl		= tsi108_do_ioctl,
 	.ndo_set_mac_address	= tsi108_set_mac,
diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 7f23ab9..f34dd99 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -697,7 +697,7 @@ static const struct net_device_ops rhine_netdev_ops = {
 	.ndo_stop		 = rhine_close,
 	.ndo_start_xmit		 = rhine_start_tx,
 	.ndo_get_stats		 = rhine_get_stats,
-	.ndo_set_multicast_list	 = rhine_set_rx_mode,
+	.ndo_set_rx_mode	 = rhine_set_rx_mode,
 	.ndo_change_mtu		 = eth_change_mtu,
 	.ndo_validate_addr	 = eth_validate_addr,
 	.ndo_set_mac_address 	 = eth_mac_addr,
diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index 490ec5b..095ab56 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -2615,7 +2615,7 @@ static const struct net_device_ops velocity_netdev_ops = {
 	.ndo_get_stats		= velocity_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
-	.ndo_set_multicast_list	= velocity_set_multi,
+	.ndo_set_rx_mode	= velocity_set_multi,
 	.ndo_change_mtu		= velocity_change_mtu,
 	.ndo_do_ioctl		= velocity_ioctl,
 	.ndo_vlan_rx_add_vid	= velocity_vlan_rx_add_vid,
diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 728fe41..570776e 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -922,7 +922,6 @@ static const struct net_device_ops temac_netdev_ops = {
 	.ndo_start_xmit = temac_start_xmit,
 	.ndo_set_mac_address = netdev_set_mac_address,
 	.ndo_validate_addr = eth_validate_addr,
-	//.ndo_set_multicast_list = temac_set_multicast_list,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = temac_poll_controller,
 #endif
diff --git a/drivers/net/ethernet/xircom/xirc2ps_cs.c b/drivers/net/ethernet/xircom/xirc2ps_cs.c
index e33b190..bbe8b7d 100644
--- a/drivers/net/ethernet/xircom/xirc2ps_cs.c
+++ b/drivers/net/ethernet/xircom/xirc2ps_cs.c
@@ -467,7 +467,7 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_tx_timeout 	= xirc_tx_timeout,
 	.ndo_set_config		= do_config,
 	.ndo_do_ioctl		= do_ioctl,
-	.ndo_set_multicast_list	= set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/xscale/ixp4xx_eth.c b/drivers/net/ethernet/xscale/ixp4xx_eth.c
index de51e84..ec96d91 100644
--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -1339,7 +1339,7 @@ static const struct net_device_ops ixp4xx_netdev_ops = {
 	.ndo_open = eth_open,
 	.ndo_stop = eth_close,
 	.ndo_start_xmit = eth_xmit,
-	.ndo_set_multicast_list = eth_set_mcast_list,
+	.ndo_set_rx_mode = eth_set_mcast_list,
 	.ndo_do_ioctl = eth_ioctl,
 	.ndo_change_mtu = eth_change_mtu,
 	.ndo_set_mac_address = eth_mac_addr,
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 05172c3..836e13f 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -561,7 +561,7 @@ static const struct net_device_ops macvlan_netdev_ops = {
 	.ndo_change_mtu		= macvlan_change_mtu,
 	.ndo_change_rx_flags	= macvlan_change_rx_flags,
 	.ndo_set_mac_address	= macvlan_set_mac_address,
-	.ndo_set_multicast_list	= macvlan_set_multicast_list,
+	.ndo_set_rx_mode	= macvlan_set_multicast_list,
 	.ndo_get_stats64	= macvlan_dev_get_stats64,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_vlan_rx_add_vid	= macvlan_vlan_rx_add_vid,
diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
index 16c6265..3d9a459 100644
--- a/drivers/net/skfp/skfddi.c
+++ b/drivers/net/skfp/skfddi.c
@@ -167,7 +167,7 @@ static const struct net_device_ops skfp_netdev_ops = {
 	.ndo_start_xmit		= skfp_send_pkt,
 	.ndo_get_stats		= skfp_ctl_get_stats,
 	.ndo_change_mtu		= fddi_change_mtu,
-	.ndo_set_multicast_list = skfp_ctl_set_multicast_list,
+	.ndo_set_rx_mode	= skfp_ctl_set_multicast_list,
 	.ndo_set_mac_address	= skfp_ctl_set_mac_address,
 	.ndo_do_ioctl		= skfp_ioctl,
 };
diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index b6162fe..ef9fdf3 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -282,7 +282,7 @@ static const struct net_device_ops xl_netdev_ops = {
 	.ndo_stop		= xl_close,
 	.ndo_start_xmit		= xl_xmit,
 	.ndo_change_mtu		= xl_change_mtu,
-	.ndo_set_multicast_list = xl_set_rx_mode,
+	.ndo_set_rx_mode	= xl_set_rx_mode,
 	.ndo_set_mac_address	= xl_set_mac_address,
 };
  
diff --git a/drivers/net/tokenring/ibmtr.c b/drivers/net/tokenring/ibmtr.c
index e257a00..b5c8c18 100644
--- a/drivers/net/tokenring/ibmtr.c
+++ b/drivers/net/tokenring/ibmtr.c
@@ -823,7 +823,7 @@ static const struct net_device_ops trdev_netdev_ops = {
 	.ndo_open		= tok_open,
 	.ndo_stop		= tok_close,
 	.ndo_start_xmit		= tok_send_packet,
-	.ndo_set_multicast_list = tok_set_multicast_list,
+	.ndo_set_rx_mode	= tok_set_multicast_list,
 	.ndo_change_mtu		= ibmtr_change_mtu,
 };
 
diff --git a/drivers/net/tokenring/lanstreamer.c b/drivers/net/tokenring/lanstreamer.c
index 9354ca9..8d71e0d 100644
--- a/drivers/net/tokenring/lanstreamer.c
+++ b/drivers/net/tokenring/lanstreamer.c
@@ -231,7 +231,7 @@ static const struct net_device_ops streamer_netdev_ops = {
 #if STREAMER_IOCTL
 	.ndo_do_ioctl		= streamer_ioctl,
 #endif
-	.ndo_set_multicast_list = streamer_set_rx_mode,
+	.ndo_set_rx_mode	= streamer_set_rx_mode,
 	.ndo_set_mac_address	= streamer_set_mac_address,
 };
 
diff --git a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olympic.c
index e3855ae..fd8dce9 100644
--- a/drivers/net/tokenring/olympic.c
+++ b/drivers/net/tokenring/olympic.c
@@ -201,7 +201,7 @@ static const struct net_device_ops olympic_netdev_ops = {
 	.ndo_stop		= olympic_close,
 	.ndo_start_xmit		= olympic_xmit,
 	.ndo_change_mtu		= olympic_change_mtu,
-	.ndo_set_multicast_list	= olympic_set_rx_mode,
+	.ndo_set_rx_mode	= olympic_set_rx_mode,
 	.ndo_set_mac_address	= olympic_set_mac_address,
 };
 
diff --git a/drivers/net/tokenring/smctr.c b/drivers/net/tokenring/smctr.c
index d9044ab..029846a 100644
--- a/drivers/net/tokenring/smctr.c
+++ b/drivers/net/tokenring/smctr.c
@@ -3623,7 +3623,7 @@ static const struct net_device_ops smctr_netdev_ops = {
 	.ndo_start_xmit    = smctr_send_packet,
 	.ndo_tx_timeout	   = smctr_timeout,
 	.ndo_get_stats     = smctr_get_stats,
-	.ndo_set_multicast_list = smctr_set_multicast_list,
+	.ndo_set_rx_mode   = smctr_set_multicast_list,
 };
 
 static int __init smctr_probe1(struct net_device *dev, int ioaddr)
diff --git a/drivers/net/tokenring/tms380tr.c b/drivers/net/tokenring/tms380tr.c
index 7930203..65e9cf3 100644
--- a/drivers/net/tokenring/tms380tr.c
+++ b/drivers/net/tokenring/tms380tr.c
@@ -2289,7 +2289,7 @@ const struct net_device_ops tms380tr_netdev_ops = {
 	.ndo_start_xmit		= tms380tr_send_packet,
 	.ndo_tx_timeout		= tms380tr_timeout,
 	.ndo_get_stats		= tms380tr_get_stats,
-	.ndo_set_multicast_list = tms380tr_set_multicast_list,
+	.ndo_set_rx_mode	= tms380tr_set_multicast_list,
 	.ndo_set_mac_address	= tms380tr_set_mac_address,
 };
 EXPORT_SYMBOL(tms380tr_netdev_ops);
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 71f3d1a..7bea9c6 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -496,7 +496,7 @@ static const struct net_device_ops tap_netdev_ops = {
 	.ndo_start_xmit		= tun_net_xmit,
 	.ndo_change_mtu		= tun_net_change_mtu,
 	.ndo_fix_features	= tun_net_fix_features,
-	.ndo_set_multicast_list	= tun_net_mclist,
+	.ndo_set_rx_mode	= tun_net_mclist,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index c5c4b4d..b843eed 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -872,7 +872,7 @@ static const struct net_device_ops ax88172_netdev_ops = {
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl		= asix_ioctl,
-	.ndo_set_multicast_list = ax88172_set_multicast,
+	.ndo_set_rx_mode	= ax88172_set_multicast,
 };
 
 static int ax88172_bind(struct usbnet *dev, struct usb_interface *intf)
@@ -975,7 +975,7 @@ static const struct net_device_ops ax88772_netdev_ops = {
 	.ndo_set_mac_address 	= asix_set_mac_address,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl		= asix_ioctl,
-	.ndo_set_multicast_list = asix_set_multicast,
+	.ndo_set_rx_mode	= asix_set_multicast,
 };
 
 static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
@@ -1270,7 +1270,7 @@ static const struct net_device_ops ax88178_netdev_ops = {
 	.ndo_tx_timeout		= usbnet_tx_timeout,
 	.ndo_set_mac_address 	= asix_set_mac_address,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_multicast_list = asix_set_multicast,
+	.ndo_set_rx_mode	= asix_set_multicast,
 	.ndo_do_ioctl 		= asix_ioctl,
 	.ndo_change_mtu 	= ax88178_change_mtu,
 };
diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index 8056f8a..a68272c 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -749,7 +749,7 @@ static const struct net_device_ops catc_netdev_ops = {
 	.ndo_start_xmit		= catc_start_xmit,
 
 	.ndo_tx_timeout		= catc_tx_timeout,
-	.ndo_set_multicast_list = catc_set_multicast_list,
+	.ndo_set_rx_mode	= catc_set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 1d93133..fbc0e4d 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -428,7 +428,7 @@ static const struct net_device_ops dm9601_netdev_ops = {
 	.ndo_change_mtu		= usbnet_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl 		= dm9601_ioctl,
-	.ndo_set_multicast_list = dm9601_set_multicast,
+	.ndo_set_rx_mode	= dm9601_set_multicast,
 	.ndo_set_mac_address	= dm9601_set_mac_address,
 };
 
diff --git a/drivers/net/usb/int51x1.c b/drivers/net/usb/int51x1.c
index be02a25..131ac6c 100644
--- a/drivers/net/usb/int51x1.c
+++ b/drivers/net/usb/int51x1.c
@@ -193,7 +193,7 @@ static const struct net_device_ops int51x1_netdev_ops = {
 	.ndo_change_mtu		= usbnet_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_multicast_list	= int51x1_set_multicast,
+	.ndo_set_rx_mode	= int51x1_set_multicast,
 };
 
 static int int51x1_bind(struct usbnet *dev, struct usb_interface *intf)
diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index ad0298f..582ca2d 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -985,7 +985,7 @@ static const struct net_device_ops kaweth_netdev_ops = {
 	.ndo_stop =			kaweth_close,
 	.ndo_start_xmit =		kaweth_start_xmit,
 	.ndo_tx_timeout =		kaweth_tx_timeout,
-	.ndo_set_multicast_list =	kaweth_set_rx_mode,
+	.ndo_set_rx_mode =		kaweth_set_rx_mode,
 	.ndo_get_stats =		kaweth_netdev_stats,
 	.ndo_change_mtu =		eth_change_mtu,
 	.ndo_set_mac_address =		eth_mac_addr,
diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index 2b79139..db2cb74 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -553,7 +553,7 @@ static const struct net_device_ops mcs7830_netdev_ops = {
 	.ndo_change_mtu		= usbnet_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl 		= mcs7830_ioctl,
-	.ndo_set_multicast_list = mcs7830_set_multicast,
+	.ndo_set_rx_mode	= mcs7830_set_multicast,
 	.ndo_set_mac_address	= mcs7830_set_mac_address,
 };
 
diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index ef36676..769f509 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -1476,7 +1476,7 @@ static const struct net_device_ops pegasus_netdev_ops = {
 	.ndo_stop =			pegasus_close,
 	.ndo_do_ioctl =			pegasus_ioctl,
 	.ndo_start_xmit =		pegasus_start_xmit,
-	.ndo_set_multicast_list =	pegasus_set_multicast,
+	.ndo_set_rx_mode =		pegasus_set_multicast,
 	.ndo_get_stats =		pegasus_netdev_stats,
 	.ndo_tx_timeout =		pegasus_tx_timeout,
 	.ndo_change_mtu =		eth_change_mtu,
diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index ef3b236..b00d692 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -899,7 +899,7 @@ static const struct net_device_ops rtl8150_netdev_ops = {
 	.ndo_do_ioctl		= rtl8150_ioctl,
 	.ndo_start_xmit		= rtl8150_start_xmit,
 	.ndo_tx_timeout 	= rtl8150_tx_timeout,
-	.ndo_set_multicast_list = rtl8150_set_multicast,
+	.ndo_set_rx_mode	= rtl8150_set_multicast,
 	.ndo_set_mac_address	= rtl8150_set_mac_address,
 
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 15b3d68..22a7cf9 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -1000,7 +1000,7 @@ static const struct net_device_ops smsc75xx_netdev_ops = {
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl 		= smsc75xx_ioctl,
-	.ndo_set_multicast_list = smsc75xx_set_multicast,
+	.ndo_set_rx_mode	= smsc75xx_set_multicast,
 	.ndo_set_features	= smsc75xx_set_features,
 };
 
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index f74f3ce..eff6767 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -972,7 +972,7 @@ static const struct net_device_ops smsc95xx_netdev_ops = {
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl 		= smsc95xx_ioctl,
-	.ndo_set_multicast_list = smsc95xx_set_multicast,
+	.ndo_set_rx_mode	= smsc95xx_set_multicast,
 	.ndo_set_features	= smsc95xx_set_features,
 };
 
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 1cbacb3..f530c57 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2870,7 +2870,7 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 		.ndo_set_features = vmxnet3_set_features,
 		.ndo_get_stats64 = vmxnet3_get_stats64,
 		.ndo_tx_timeout = vmxnet3_tx_timeout,
-		.ndo_set_multicast_list = vmxnet3_set_mc,
+		.ndo_set_rx_mode = vmxnet3_set_mc,
 		.ndo_vlan_rx_add_vid = vmxnet3_vlan_rx_add_vid,
 		.ndo_vlan_rx_kill_vid = vmxnet3_vlan_rx_kill_vid,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index 86127bc..783168c 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -212,7 +212,7 @@ static const struct net_device_ops sbni_netdev_ops = {
 	.ndo_open		= sbni_open,
 	.ndo_stop		= sbni_close,
 	.ndo_start_xmit		= sbni_start_xmit,
-	.ndo_set_multicast_list	= set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_do_ioctl		= sbni_ioctl,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index e1b3e3c..ac1176a 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -2754,7 +2754,7 @@ static const struct net_device_ops airo_netdev_ops = {
 	.ndo_stop		= airo_close,
 	.ndo_start_xmit		= airo_start_xmit,
 	.ndo_get_stats		= airo_get_stats,
-	.ndo_set_multicast_list	= airo_set_multicast_list,
+	.ndo_set_rx_mode	= airo_set_multicast_list,
 	.ndo_set_mac_address	= airo_set_mac_address,
 	.ndo_do_ioctl		= airo_ioctl,
 	.ndo_change_mtu		= airo_change_mtu,
@@ -2766,7 +2766,7 @@ static const struct net_device_ops mpi_netdev_ops = {
 	.ndo_stop		= airo_close,
 	.ndo_start_xmit		= mpi_start_xmit,
 	.ndo_get_stats		= airo_get_stats,
-	.ndo_set_multicast_list	= airo_set_multicast_list,
+	.ndo_set_rx_mode	= airo_set_multicast_list,
 	.ndo_set_mac_address	= airo_set_mac_address,
 	.ndo_do_ioctl		= airo_ioctl,
 	.ndo_change_mtu		= airo_change_mtu,
diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
index 89a116f..bfa0d54 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -816,7 +816,7 @@ static const struct net_device_ops hostap_netdev_ops = {
 	.ndo_stop		= prism2_close,
 	.ndo_do_ioctl		= hostap_ioctl,
 	.ndo_set_mac_address	= prism2_set_mac_address,
-	.ndo_set_multicast_list = hostap_set_multicast_list,
+	.ndo_set_rx_mode	= hostap_set_multicast_list,
 	.ndo_change_mtu 	= prism2_change_mtu,
 	.ndo_tx_timeout 	= prism2_tx_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -829,7 +829,7 @@ static const struct net_device_ops hostap_mgmt_netdev_ops = {
 	.ndo_stop		= prism2_close,
 	.ndo_do_ioctl		= hostap_ioctl,
 	.ndo_set_mac_address	= prism2_set_mac_address,
-	.ndo_set_multicast_list = hostap_set_multicast_list,
+	.ndo_set_rx_mode	= hostap_set_multicast_list,
 	.ndo_change_mtu 	= prism2_change_mtu,
 	.ndo_tx_timeout 	= prism2_tx_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -842,7 +842,7 @@ static const struct net_device_ops hostap_master_ops = {
 	.ndo_stop		= prism2_close,
 	.ndo_do_ioctl		= hostap_ioctl,
 	.ndo_set_mac_address	= prism2_set_mac_address,
-	.ndo_set_multicast_list = hostap_set_multicast_list,
+	.ndo_set_rx_mode	= hostap_set_multicast_list,
 	.ndo_change_mtu 	= prism2_change_mtu,
 	.ndo_tx_timeout 	= prism2_tx_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 87813c3..553f66b 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -11701,7 +11701,7 @@ static const struct net_device_ops ipw_netdev_ops = {
 	.ndo_init		= ipw_net_init,
 	.ndo_open		= ipw_net_open,
 	.ndo_stop		= ipw_net_stop,
-	.ndo_set_multicast_list	= ipw_net_set_multicast_list,
+	.ndo_set_rx_mode	= ipw_net_set_multicast_list,
 	.ndo_set_mac_address	= ipw_net_set_mac_address,
 	.ndo_start_xmit		= libipw_xmit,
 	.ndo_change_mtu		= libipw_change_mtu,
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 94652c5..2fdeb81 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -786,7 +786,7 @@ static const struct net_device_ops lbs_netdev_ops = {
 	.ndo_stop		= lbs_eth_stop,
 	.ndo_start_xmit		= lbs_hard_start_xmit,
 	.ndo_set_mac_address	= lbs_set_mac_address,
-	.ndo_set_multicast_list = lbs_set_multicast_list,
+	.ndo_set_rx_mode	= lbs_set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/drivers/net/wireless/libertas/mesh.c b/drivers/net/wireless/libertas/mesh.c
index be72c08..8e3104d 100644
--- a/drivers/net/wireless/libertas/mesh.c
+++ b/drivers/net/wireless/libertas/mesh.c
@@ -959,7 +959,7 @@ static const struct net_device_ops mesh_netdev_ops = {
 	.ndo_stop 		= lbs_mesh_stop,
 	.ndo_start_xmit		= lbs_hard_start_xmit,
 	.ndo_set_mac_address	= lbs_set_mac_address,
-	.ndo_set_multicast_list = lbs_set_multicast_list,
+	.ndo_set_rx_mode	= lbs_set_multicast_list,
 };
 
 /**
diff --git a/drivers/net/wireless/mwifiex/main.c b/drivers/net/wireless/mwifiex/main.c
index e5fc53d..0415e3d 100644
--- a/drivers/net/wireless/mwifiex/main.c
+++ b/drivers/net/wireless/mwifiex/main.c
@@ -627,7 +627,7 @@ static const struct net_device_ops mwifiex_netdev_ops = {
 	.ndo_set_mac_address = mwifiex_set_mac_address,
 	.ndo_tx_timeout = mwifiex_tx_timeout,
 	.ndo_get_stats = mwifiex_get_stats,
-	.ndo_set_multicast_list = mwifiex_set_multicast_list,
+	.ndo_set_rx_mode = mwifiex_set_multicast_list,
 };
 
 /*
diff --git a/drivers/net/wireless/orinoco/main.c b/drivers/net/wireless/orinoco/main.c
index ef7efe8..b52acc4 100644
--- a/drivers/net/wireless/orinoco/main.c
+++ b/drivers/net/wireless/orinoco/main.c
@@ -2135,7 +2135,7 @@ static const struct net_device_ops orinoco_netdev_ops = {
 	.ndo_open		= orinoco_open,
 	.ndo_stop		= orinoco_stop,
 	.ndo_start_xmit		= orinoco_xmit,
-	.ndo_set_multicast_list	= orinoco_set_multicast_list,
+	.ndo_set_rx_mode	= orinoco_set_multicast_list,
 	.ndo_change_mtu		= orinoco_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/wireless/orinoco/orinoco_usb.c b/drivers/net/wireless/orinoco/orinoco_usb.c
index 811e87f..0793e42 100644
--- a/drivers/net/wireless/orinoco/orinoco_usb.c
+++ b/drivers/net/wireless/orinoco/orinoco_usb.c
@@ -1562,7 +1562,7 @@ static const struct net_device_ops ezusb_netdev_ops = {
 	.ndo_open		= orinoco_open,
 	.ndo_stop		= orinoco_stop,
 	.ndo_start_xmit		= ezusb_xmit,
-	.ndo_set_multicast_list	= orinoco_set_multicast_list,
+	.ndo_set_rx_mode	= orinoco_set_multicast_list,
 	.ndo_change_mtu		= orinoco_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 2a06ebc..0021e49 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -273,7 +273,7 @@ static const struct net_device_ops ray_netdev_ops = {
 	.ndo_start_xmit		= ray_dev_start_xmit,
 	.ndo_set_config		= ray_dev_config,
 	.ndo_get_stats		= ray_get_stats,
-	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index 29f9389..6e0c611 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -3392,7 +3392,7 @@ static const struct net_device_ops rndis_wlan_netdev_ops = {
 	.ndo_tx_timeout		= usbnet_tx_timeout,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_multicast_list	= rndis_wlan_set_multicast_list,
+	.ndo_set_rx_mode	= rndis_wlan_set_multicast_list,
 };
 
 static int rndis_wlan_bind(struct usbnet *usbdev, struct usb_interface *intf)
diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index 415eec4..8efa2f2 100644
--- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -1722,7 +1722,7 @@ static const struct net_device_ops zd1201_netdev_ops = {
 	.ndo_stop		= zd1201_net_stop,
 	.ndo_start_xmit		= zd1201_hard_start_xmit,
 	.ndo_tx_timeout		= zd1201_tx_timeout,
-	.ndo_set_multicast_list = zd1201_set_multicast,
+	.ndo_set_rx_mode	= zd1201_set_multicast,
 	.ndo_set_mac_address	= zd1201_set_mac_address,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/s390/net/lcs.c b/drivers/s390/net/lcs.c
index c3b8064..fb246b9 100644
--- a/drivers/s390/net/lcs.c
+++ b/drivers/s390/net/lcs.c
@@ -2122,7 +2122,7 @@ static const struct net_device_ops lcs_mc_netdev_ops = {
 	.ndo_stop		= lcs_stop_device,
 	.ndo_get_stats		= lcs_getstats,
 	.ndo_start_xmit		= lcs_start_xmit,
-	.ndo_set_multicast_list = lcs_set_multicast_list,
+	.ndo_set_rx_mode	= lcs_set_multicast_list,
 };
 
 static int
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 3e68b66..a21ae3d 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -925,7 +925,7 @@ static const struct net_device_ops qeth_l2_netdev_ops = {
 	.ndo_get_stats		= qeth_get_stats,
 	.ndo_start_xmit		= qeth_l2_hard_start_xmit,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_multicast_list = qeth_l2_set_multicast_list,
+	.ndo_set_rx_mode	= qeth_l2_set_multicast_list,
 	.ndo_do_ioctl	   	= qeth_l2_do_ioctl,
 	.ndo_set_mac_address    = qeth_l2_set_mac_address,
 	.ndo_change_mtu	   	= qeth_change_mtu,
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index e2a927a..ce73520 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3275,7 +3275,7 @@ static const struct net_device_ops qeth_l3_netdev_ops = {
 	.ndo_get_stats		= qeth_get_stats,
 	.ndo_start_xmit		= qeth_l3_hard_start_xmit,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_multicast_list = qeth_l3_set_multicast_list,
+	.ndo_set_rx_mode	= qeth_l3_set_multicast_list,
 	.ndo_do_ioctl		= qeth_l3_do_ioctl,
 	.ndo_change_mtu		= qeth_change_mtu,
 	.ndo_fix_features	= qeth_l3_fix_features,
@@ -3291,7 +3291,7 @@ static const struct net_device_ops qeth_l3_osa_netdev_ops = {
 	.ndo_get_stats		= qeth_get_stats,
 	.ndo_start_xmit		= qeth_l3_hard_start_xmit,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_multicast_list = qeth_l3_set_multicast_list,
+	.ndo_set_rx_mode	= qeth_l3_set_multicast_list,
 	.ndo_do_ioctl		= qeth_l3_do_ioctl,
 	.ndo_change_mtu		= qeth_change_mtu,
 	.ndo_fix_features	= qeth_l3_fix_features,
diff --git a/drivers/staging/ath6kl/os/linux/ar6000_drv.c b/drivers/staging/ath6kl/os/linux/ar6000_drv.c
index 32ee39a..9b02895 100644
--- a/drivers/staging/ath6kl/os/linux/ar6000_drv.c
+++ b/drivers/staging/ath6kl/os/linux/ar6000_drv.c
@@ -368,7 +368,7 @@ static struct net_device_ops ar6000_netdev_ops = {
     .ndo_stop               = ar6000_close,
     .ndo_get_stats          = ar6000_get_stats,
     .ndo_start_xmit         = ar6000_data_tx,
-    .ndo_set_multicast_list = ar6000_set_multicast_list,
+    .ndo_set_rx_mode	    = ar6000_set_multicast_list,
 };
 
 /* Debug log support */
diff --git a/drivers/staging/brcm80211/brcmfmac/dhd_linux.c b/drivers/staging/brcm80211/brcmfmac/dhd_linux.c
index 05dada9..b129401 100644
--- a/drivers/staging/brcm80211/brcmfmac/dhd_linux.c
+++ b/drivers/staging/brcm80211/brcmfmac/dhd_linux.c
@@ -1437,7 +1437,7 @@ static struct net_device_ops brcmf_netdev_ops_pri = {
 	.ndo_do_ioctl = brcmf_netdev_ioctl_entry,
 	.ndo_start_xmit = brcmf_netdev_start_xmit,
 	.ndo_set_mac_address = brcmf_netdev_set_mac_address,
-	.ndo_set_multicast_list = brcmf_netdev_set_multicast_list
+	.ndo_set_rx_mode = brcmf_netdev_set_multicast_list,
 };
 
 int brcmf_net_attach(struct brcmf_pub *drvr, int ifidx)
diff --git a/drivers/staging/et131x/et131x_netdev.c b/drivers/staging/et131x/et131x_netdev.c
index 5f25bba..4406630 100644
--- a/drivers/staging/et131x/et131x_netdev.c
+++ b/drivers/staging/et131x/et131x_netdev.c
@@ -638,7 +638,7 @@ static const struct net_device_ops et131x_netdev_ops = {
 	.ndo_open		= et131x_open,
 	.ndo_stop		= et131x_close,
 	.ndo_start_xmit		= et131x_tx,
-	.ndo_set_multicast_list	= et131x_multicast,
+	.ndo_set_rx_mode	= et131x_multicast,
 	.ndo_tx_timeout		= et131x_tx_timeout,
 	.ndo_change_mtu		= et131x_change_mtu,
 	.ndo_set_mac_address	= et131x_set_mac_addr,
diff --git a/drivers/staging/hv/netvsc_drv.c b/drivers/staging/hv/netvsc_drv.c
index 61989f0..bfd4c81 100644
--- a/drivers/staging/hv/netvsc_drv.c
+++ b/drivers/staging/hv/netvsc_drv.c
@@ -307,7 +307,7 @@ static const struct net_device_ops device_ops = {
 	.ndo_open =			netvsc_open,
 	.ndo_stop =			netvsc_close,
 	.ndo_start_xmit =		netvsc_start_xmit,
-	.ndo_set_multicast_list =	netvsc_set_multicast_list,
+	.ndo_set_rx_mode =		netvsc_set_multicast_list,
 	.ndo_change_mtu =		eth_change_mtu,
 	.ndo_validate_addr =		eth_validate_addr,
 	.ndo_set_mac_address =		eth_mac_addr,
diff --git a/drivers/staging/octeon/ethernet.c b/drivers/staging/octeon/ethernet.c
index a8f780e..076f866 100644
--- a/drivers/staging/octeon/ethernet.c
+++ b/drivers/staging/octeon/ethernet.c
@@ -512,7 +512,7 @@ static const struct net_device_ops cvm_oct_npi_netdev_ops = {
 	.ndo_init		= cvm_oct_common_init,
 	.ndo_uninit		= cvm_oct_common_uninit,
 	.ndo_start_xmit		= cvm_oct_xmit,
-	.ndo_set_multicast_list	= cvm_oct_common_set_multicast_list,
+	.ndo_set_rx_mode	= cvm_oct_common_set_multicast_list,
 	.ndo_set_mac_address	= cvm_oct_common_set_mac_address,
 	.ndo_do_ioctl		= cvm_oct_ioctl,
 	.ndo_change_mtu		= cvm_oct_common_change_mtu,
@@ -527,7 +527,7 @@ static const struct net_device_ops cvm_oct_xaui_netdev_ops = {
 	.ndo_open		= cvm_oct_xaui_open,
 	.ndo_stop		= cvm_oct_xaui_stop,
 	.ndo_start_xmit		= cvm_oct_xmit,
-	.ndo_set_multicast_list	= cvm_oct_common_set_multicast_list,
+	.ndo_set_rx_mode	= cvm_oct_common_set_multicast_list,
 	.ndo_set_mac_address	= cvm_oct_common_set_mac_address,
 	.ndo_do_ioctl		= cvm_oct_ioctl,
 	.ndo_change_mtu		= cvm_oct_common_change_mtu,
@@ -542,7 +542,7 @@ static const struct net_device_ops cvm_oct_sgmii_netdev_ops = {
 	.ndo_open		= cvm_oct_sgmii_open,
 	.ndo_stop		= cvm_oct_sgmii_stop,
 	.ndo_start_xmit		= cvm_oct_xmit,
-	.ndo_set_multicast_list	= cvm_oct_common_set_multicast_list,
+	.ndo_set_rx_mode	= cvm_oct_common_set_multicast_list,
 	.ndo_set_mac_address	= cvm_oct_common_set_mac_address,
 	.ndo_do_ioctl		= cvm_oct_ioctl,
 	.ndo_change_mtu		= cvm_oct_common_change_mtu,
@@ -555,7 +555,7 @@ static const struct net_device_ops cvm_oct_spi_netdev_ops = {
 	.ndo_init		= cvm_oct_spi_init,
 	.ndo_uninit		= cvm_oct_spi_uninit,
 	.ndo_start_xmit		= cvm_oct_xmit,
-	.ndo_set_multicast_list	= cvm_oct_common_set_multicast_list,
+	.ndo_set_rx_mode	= cvm_oct_common_set_multicast_list,
 	.ndo_set_mac_address	= cvm_oct_common_set_mac_address,
 	.ndo_do_ioctl		= cvm_oct_ioctl,
 	.ndo_change_mtu		= cvm_oct_common_change_mtu,
@@ -570,7 +570,7 @@ static const struct net_device_ops cvm_oct_rgmii_netdev_ops = {
 	.ndo_open		= cvm_oct_rgmii_open,
 	.ndo_stop		= cvm_oct_rgmii_stop,
 	.ndo_start_xmit		= cvm_oct_xmit,
-	.ndo_set_multicast_list	= cvm_oct_common_set_multicast_list,
+	.ndo_set_rx_mode	= cvm_oct_common_set_multicast_list,
 	.ndo_set_mac_address	= cvm_oct_common_set_mac_address,
 	.ndo_do_ioctl		= cvm_oct_ioctl,
 	.ndo_change_mtu		= cvm_oct_common_change_mtu,
@@ -582,7 +582,7 @@ static const struct net_device_ops cvm_oct_rgmii_netdev_ops = {
 static const struct net_device_ops cvm_oct_pow_netdev_ops = {
 	.ndo_init		= cvm_oct_common_init,
 	.ndo_start_xmit		= cvm_oct_xmit_pow,
-	.ndo_set_multicast_list	= cvm_oct_common_set_multicast_list,
+	.ndo_set_rx_mode	= cvm_oct_common_set_multicast_list,
 	.ndo_set_mac_address	= cvm_oct_common_set_mac_address,
 	.ndo_do_ioctl		= cvm_oct_ioctl,
 	.ndo_change_mtu		= cvm_oct_common_change_mtu,
diff --git a/drivers/staging/rtl8187se/r8180_core.c b/drivers/staging/rtl8187se/r8180_core.c
index 4c6651a..04c2391 100644
--- a/drivers/staging/rtl8187se/r8180_core.c
+++ b/drivers/staging/rtl8187se/r8180_core.c
@@ -3534,7 +3534,7 @@ static const struct net_device_ops rtl8180_netdev_ops = {
 	.ndo_get_stats		= rtl8180_stats,
 	.ndo_tx_timeout		= rtl8180_restart,
 	.ndo_do_ioctl		= rtl8180_ioctl,
-	.ndo_set_multicast_list	= r8180_set_multicast,
+	.ndo_set_rx_mode	= r8180_set_multicast,
 	.ndo_set_mac_address	= r8180_set_mac_adr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= eth_change_mtu,
diff --git a/drivers/staging/rtl8192e/r8192E_core.c b/drivers/staging/rtl8192e/r8192E_core.c
index 94d9c8d..b418fed 100644
--- a/drivers/staging/rtl8192e/r8192E_core.c
+++ b/drivers/staging/rtl8192e/r8192E_core.c
@@ -4519,7 +4519,7 @@ static const struct net_device_ops rtl8192_netdev_ops = {
 	.ndo_stop =			rtl8192_close,
 	.ndo_tx_timeout =		tx_timeout,
 	.ndo_do_ioctl =			rtl8192_ioctl,
-	.ndo_set_multicast_list =	r8192_set_multicast,
+	.ndo_set_rx_mode =		r8192_set_multicast,
 	.ndo_set_mac_address =		r8192_set_mac_adr,
 	.ndo_start_xmit = 		ieee80211_rtl_xmit,
 };
diff --git a/drivers/staging/rtl8192u/r8192U_core.c b/drivers/staging/rtl8192u/r8192U_core.c
index ee86fe8..c09be0a 100644
--- a/drivers/staging/rtl8192u/r8192U_core.c
+++ b/drivers/staging/rtl8192u/r8192U_core.c
@@ -5739,7 +5739,7 @@ static const struct net_device_ops rtl8192_netdev_ops = {
 	.ndo_get_stats          = rtl8192_stats,
 	.ndo_tx_timeout         = tx_timeout,
 	.ndo_do_ioctl           = rtl8192_ioctl,
-	.ndo_set_multicast_list = r8192_set_multicast,
+	.ndo_set_rx_mode	= r8192_set_multicast,
 	.ndo_set_mac_address    = r8192_set_mac_adr,
 	.ndo_validate_addr      = eth_validate_addr,
 	.ndo_change_mtu         = eth_change_mtu,
diff --git a/drivers/staging/slicoss/slicoss.c b/drivers/staging/slicoss/slicoss.c
index 18f1103..77a0751 100644
--- a/drivers/staging/slicoss/slicoss.c
+++ b/drivers/staging/slicoss/slicoss.c
@@ -3724,7 +3724,7 @@ static const struct net_device_ops slic_netdev_ops = {
 	.ndo_do_ioctl		= slic_ioctl,
 	.ndo_set_mac_address	= slic_mac_set_address,
 	.ndo_get_stats		= slic_get_stats,
-	.ndo_set_multicast_list	= slic_mcast_set_list,
+	.ndo_set_rx_mode	= slic_mcast_set_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 };
diff --git a/drivers/staging/vt6655/device_main.c b/drivers/staging/vt6655/device_main.c
index 3d2a9ba..8cb9116 100644
--- a/drivers/staging/vt6655/device_main.c
+++ b/drivers/staging/vt6655/device_main.c
@@ -911,7 +911,7 @@ static const struct net_device_ops device_netdev_ops = {
     .ndo_do_ioctl           = device_ioctl,
     .ndo_get_stats          = device_get_stats,
     .ndo_start_xmit         = device_xmit,
-    .ndo_set_multicast_list = device_set_multi,
+    .ndo_set_rx_mode	    = device_set_multi,
 };
 
 
diff --git a/drivers/staging/vt6656/main_usb.c b/drivers/staging/vt6656/main_usb.c
index e18efd4..1ff3940 100644
--- a/drivers/staging/vt6656/main_usb.c
+++ b/drivers/staging/vt6656/main_usb.c
@@ -753,7 +753,7 @@ static const struct net_device_ops device_netdev_ops = {
     .ndo_do_ioctl           = device_ioctl,
     .ndo_get_stats          = device_get_stats,
     .ndo_start_xmit         = device_xmit,
-    .ndo_set_multicast_list = device_set_multi,
+    .ndo_set_rx_mode	    = device_set_multi,
 };
 
 static int __devinit
diff --git a/drivers/staging/wlags49_h2/wl_netdev.c b/drivers/staging/wlags49_h2/wl_netdev.c
index cf917e6..b21515f 100644
--- a/drivers/staging/wlags49_h2/wl_netdev.c
+++ b/drivers/staging/wlags49_h2/wl_netdev.c
@@ -1179,7 +1179,7 @@ static const struct net_device_ops wl_netdev_ops =
 
     .ndo_set_config         = &wl_config,
     .ndo_get_stats          = &wl_stats,
-    .ndo_set_multicast_list = &wl_multicast,
+    .ndo_set_rx_mode        = &wl_multicast,
 
     .ndo_init               = &wl_insert,
     .ndo_open               = &wl_adapter_open,
diff --git a/drivers/staging/wlan-ng/p80211netdev.c b/drivers/staging/wlan-ng/p80211netdev.c
index b0af292..14bfeb2 100644
--- a/drivers/staging/wlan-ng/p80211netdev.c
+++ b/drivers/staging/wlan-ng/p80211netdev.c
@@ -715,7 +715,7 @@ static const struct net_device_ops p80211_netdev_ops = {
 	.ndo_stop = p80211knetdev_stop,
 	.ndo_get_stats = p80211knetdev_get_stats,
 	.ndo_start_xmit = p80211knetdev_hard_start_xmit,
-	.ndo_set_multicast_list = p80211knetdev_set_multicast_list,
+	.ndo_set_rx_mode = p80211knetdev_set_multicast_list,
 	.ndo_do_ioctl = p80211knetdev_do_ioctl,
 	.ndo_set_mac_address = p80211knetdev_set_mac_address,
 	.ndo_tx_timeout = p80211knetdev_tx_timeout,
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 9d40a07..eba705b 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -674,7 +674,6 @@ static const struct net_device_ops vlan_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= vlan_dev_set_mac_address,
 	.ndo_set_rx_mode	= vlan_dev_set_rx_mode,
-	.ndo_set_multicast_list	= vlan_dev_set_rx_mode,
 	.ndo_change_rx_flags	= vlan_dev_change_rx_flags,
 	.ndo_do_ioctl		= vlan_dev_ioctl,
 	.ndo_neigh_setup	= vlan_dev_neigh_setup,
diff --git a/net/atm/lec.c b/net/atm/lec.c
index 215c9fa..f1964ca 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -643,7 +643,7 @@ static const struct net_device_ops lec_netdev_ops = {
 	.ndo_start_xmit		= lec_start_xmit,
 	.ndo_change_mtu		= lec_change_mtu,
 	.ndo_tx_timeout		= lec_tx_timeout,
-	.ndo_set_multicast_list	= lec_set_multicast_list,
+	.ndo_set_rx_mode	= lec_set_multicast_list,
 };
 
 static const unsigned char lec_ctrl_magic[] = {
diff --git a/net/bluetooth/bnep/netdev.c b/net/bluetooth/bnep/netdev.c
index d4f5dff..bc40864 100644
--- a/net/bluetooth/bnep/netdev.c
+++ b/net/bluetooth/bnep/netdev.c
@@ -217,7 +217,7 @@ static const struct net_device_ops bnep_netdev_ops = {
 	.ndo_stop            = bnep_net_close,
 	.ndo_start_xmit	     = bnep_net_xmit,
 	.ndo_validate_addr   = eth_validate_addr,
-	.ndo_set_multicast_list = bnep_net_set_mc_list,
+	.ndo_set_rx_mode     = bnep_net_set_mc_list,
 	.ndo_set_mac_address = bnep_net_set_mac_addr,
 	.ndo_tx_timeout      = bnep_net_timeout,
 	.ndo_change_mtu	     = eth_change_mtu,
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 32b8f9f..ee68eee 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -304,7 +304,7 @@ static const struct net_device_ops br_netdev_ops = {
 	.ndo_start_xmit		 = br_dev_xmit,
 	.ndo_get_stats64	 = br_get_stats64,
 	.ndo_set_mac_address	 = br_set_mac_address,
-	.ndo_set_multicast_list	 = br_dev_set_multicast_list,
+	.ndo_set_rx_mode	 = br_dev_set_multicast_list,
 	.ndo_change_mtu		 = br_change_mtu,
 	.ndo_do_ioctl		 = br_dev_ioctl,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 0a47b6c..56cf9b8 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -301,7 +301,6 @@ static const struct net_device_ops dsa_netdev_ops = {
 	.ndo_start_xmit		= dsa_xmit,
 	.ndo_change_rx_flags	= dsa_slave_change_rx_flags,
 	.ndo_set_rx_mode	= dsa_slave_set_rx_mode,
-	.ndo_set_multicast_list = dsa_slave_set_rx_mode,
 	.ndo_set_mac_address	= dsa_slave_set_mac_address,
 	.ndo_do_ioctl		= dsa_slave_ioctl,
 };
@@ -314,7 +313,6 @@ static const struct net_device_ops edsa_netdev_ops = {
 	.ndo_start_xmit		= edsa_xmit,
 	.ndo_change_rx_flags	= dsa_slave_change_rx_flags,
 	.ndo_set_rx_mode	= dsa_slave_set_rx_mode,
-	.ndo_set_multicast_list = dsa_slave_set_rx_mode,
 	.ndo_set_mac_address	= dsa_slave_set_mac_address,
 	.ndo_do_ioctl		= dsa_slave_ioctl,
 };
@@ -327,7 +325,6 @@ static const struct net_device_ops trailer_netdev_ops = {
 	.ndo_start_xmit		= trailer_xmit,
 	.ndo_change_rx_flags	= dsa_slave_change_rx_flags,
 	.ndo_set_rx_mode	= dsa_slave_set_rx_mode,
-	.ndo_set_multicast_list = dsa_slave_set_rx_mode,
 	.ndo_set_mac_address	= dsa_slave_set_mac_address,
 	.ndo_do_ioctl		= dsa_slave_ioctl,
 };
diff --git a/net/irda/irlan/irlan_eth.c b/net/irda/irlan/irlan_eth.c
index e8d5f44..d14152e 100644
--- a/net/irda/irlan/irlan_eth.c
+++ b/net/irda/irlan/irlan_eth.c
@@ -50,7 +50,7 @@ static const struct net_device_ops irlan_eth_netdev_ops = {
 	.ndo_open               = irlan_eth_open,
 	.ndo_stop               = irlan_eth_close,
 	.ndo_start_xmit    	= irlan_eth_xmit,
-	.ndo_set_multicast_list = irlan_eth_set_multicast_list,
+	.ndo_set_rx_mode	= irlan_eth_set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 };
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index c798b43..d10dc4d 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -645,7 +645,7 @@ static const struct net_device_ops ieee80211_dataif_ops = {
 	.ndo_stop		= ieee80211_stop,
 	.ndo_uninit		= ieee80211_teardown_sdata,
 	.ndo_start_xmit		= ieee80211_subif_start_xmit,
-	.ndo_set_multicast_list = ieee80211_set_multicast_list,
+	.ndo_set_rx_mode	= ieee80211_set_multicast_list,
 	.ndo_change_mtu 	= ieee80211_change_mtu,
 	.ndo_set_mac_address 	= ieee80211_change_mac,
 	.ndo_select_queue	= ieee80211_netdev_select_queue,
@@ -689,7 +689,7 @@ static const struct net_device_ops ieee80211_monitorif_ops = {
 	.ndo_stop		= ieee80211_stop,
 	.ndo_uninit		= ieee80211_teardown_sdata,
 	.ndo_start_xmit		= ieee80211_monitor_start_xmit,
-	.ndo_set_multicast_list = ieee80211_set_multicast_list,
+	.ndo_set_rx_mode	= ieee80211_set_multicast_list,
 	.ndo_change_mtu 	= ieee80211_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_select_queue	= ieee80211_monitor_select_queue,
-- 
1.7.6

