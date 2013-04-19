From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 1/6] net: vlan: rename NETIF_F_HW_VLAN_* feature flags to NETIF_F_HW_VLAN_CTAG_*
Date: Fri, 19 Apr 2013 14:04:27 +0200
Message-ID: <1366373072-19621-2-git-send-email-kaber@trash.net>
References: <1366373072-19621-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46095 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968275Ab3DSMEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 08:04:38 -0400
In-Reply-To: <1366373072-19621-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename the hardware VLAN acceleration features to include "CTAG" to indicate
that they only support CTAGs. Follow up patches will introduce 802.1ad
server provider tagging (STAGs) and require the distinction for hardware not
supporting acclerating both.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 drivers/infiniband/hw/nes/nes_nic.c                | 14 ++++++------
 drivers/net/bonding/bond_main.c                    |  6 +++---
 drivers/net/ethernet/3com/typhoon.c                |  4 ++--
 drivers/net/ethernet/adaptec/starfire.c            |  2 +-
 drivers/net/ethernet/alteon/acenic.c               |  2 +-
 drivers/net/ethernet/amd/amd8111e.c                |  4 ++--
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c    | 22 +++++++++----------
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c    | 14 ++++++------
 drivers/net/ethernet/atheros/atlx/atl1.c           |  4 ++--
 drivers/net/ethernet/atheros/atlx/atl2.c           | 16 +++++++-------
 drivers/net/ethernet/atheros/atlx/atlx.c           | 10 ++++-----
 drivers/net/ethernet/broadcom/bnx2.c               | 10 ++++-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |  4 ++--
 drivers/net/ethernet/broadcom/tg3.c                |  2 +-
 drivers/net/ethernet/brocade/bna/bnad.c            |  4 ++--
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c          | 13 +++++------
 drivers/net/ethernet/chelsio/cxgb/sge.c            |  2 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c    | 20 +++++++++--------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 10 ++++-----
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    | 15 +++++++------
 drivers/net/ethernet/cisco/enic/enic_main.c        |  4 ++--
 drivers/net/ethernet/emulex/benet/be_main.c        |  4 ++--
 drivers/net/ethernet/freescale/gianfar.c           | 15 +++++++------
 drivers/net/ethernet/freescale/gianfar_ethtool.c   |  2 +-
 drivers/net/ethernet/ibm/ehea/ehea_main.c          |  8 +++----
 drivers/net/ethernet/intel/e1000/e1000_main.c      | 16 +++++++-------
 drivers/net/ethernet/intel/e1000e/netdev.c         | 10 ++++-----
 drivers/net/ethernet/intel/igb/igb_main.c          | 18 ++++++++--------
 drivers/net/ethernet/intel/igbvf/netdev.c          |  6 +++---
 drivers/net/ethernet/intel/ixgb/ixgb_main.c        | 14 ++++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      | 12 +++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     |  2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |  6 +++---
 drivers/net/ethernet/jme.c                         |  4 ++--
 drivers/net/ethernet/marvell/sky2.c                |  9 ++++----
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  4 ++--
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c   |  7 +++---
 drivers/net/ethernet/natsemi/ns83820.c             |  2 +-
 drivers/net/ethernet/neterion/s2io.c               |  2 +-
 drivers/net/ethernet/neterion/vxge/vxge-main.c     |  4 ++--
 drivers/net/ethernet/nvidia/forcedeth.c            | 20 +++++++++--------
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  4 ++--
 drivers/net/ethernet/qlogic/qlge/qlge_main.c       | 16 +++++++-------
 drivers/net/ethernet/realtek/8139cp.c              |  6 +++---
 drivers/net/ethernet/realtek/r8169.c               | 14 ++++++------
 drivers/net/ethernet/renesas/sh_eth.c              |  2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  2 +-
 drivers/net/ethernet/tehuti/tehuti.c               |  6 +++---
 drivers/net/ethernet/ti/cpsw.c                     |  4 ++--
 drivers/net/ethernet/toshiba/spider_net.c          |  4 ++--
 drivers/net/ethernet/via/via-rhine.c               |  5 +++--
 drivers/net/ethernet/via/via-velocity.c            |  7 +++---
 drivers/net/ethernet/xilinx/ll_temac_main.c        |  6 +++---
 drivers/net/hyperv/netvsc_drv.c                    |  2 +-
 drivers/net/ifb.c                                  |  2 +-
 drivers/net/macvlan.c                              |  2 +-
 drivers/net/team/team.c                            |  6 +++---
 drivers/net/usb/cdc_mbim.c                         |  2 +-
 drivers/net/veth.c                                 |  2 +-
 drivers/net/virtio_net.c                           |  2 +-
 drivers/net/vmxnet3/vmxnet3_drv.c                  | 11 +++++-----
 drivers/net/vmxnet3/vmxnet3_ethtool.c              |  5 +++--
 drivers/s390/net/qeth_l2_main.c                    |  2 +-
 drivers/s390/net/qeth_l3_main.c                    |  6 +++---
 drivers/scsi/fcoe/fcoe.c                           |  2 +-
 include/linux/if_vlan.h                            |  4 ++--
 include/linux/netdev_features.h                    | 12 +++++------
 include/linux/netdevice.h                          |  6 ++++--
 net/8021q/vlan.c                                   |  6 +++---
 net/8021q/vlan_core.c                              |  4 ++--
 net/8021q/vlan_dev.c                               |  2 +-
 net/bridge/br_device.c                             |  4 ++--
 net/bridge/br_vlan.c                               |  6 +++---
 net/core/dev.c                                     |  9 ++++----
 net/core/ethtool.c                                 | 25 +++++++++++-----------
 net/core/netpoll.c                                 |  2 +-
 net/openvswitch/vport-internal_dev.c               |  2 +-
 78 files changed, 285 insertions(+), 266 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index 85cf4d1..49eb511 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -1599,7 +1599,7 @@ static void nes_vlan_mode(struct net_device *netdev, struct nes_device *nesdev,
 
 	/* Enable/Disable VLAN Stripping */
 	u32temp = nes_read_indexed(nesdev, NES_IDX_PCIX_DIAG);
-	if (features & NETIF_F_HW_VLAN_RX)
+	if (features & NETIF_F_HW_VLAN_CTAG_RX)
 		u32temp &= 0xfdffffff;
 	else
 		u32temp	|= 0x02000000;
@@ -1614,10 +1614,10 @@ static netdev_features_t nes_fix_features(struct net_device *netdev, netdev_feat
 	 * Since there is no support for separate rx/tx vlan accel
 	 * enable/disable make sure tx flag is always in same state as rx.
 	 */
-	if (features & NETIF_F_HW_VLAN_RX)
-		features |= NETIF_F_HW_VLAN_TX;
+	if (features & NETIF_F_HW_VLAN_CTAG_RX)
+		features |= NETIF_F_HW_VLAN_CTAG_TX;
 	else
-		features &= ~NETIF_F_HW_VLAN_TX;
+		features &= ~NETIF_F_HW_VLAN_CTAG_TX;
 
 	return features;
 }
@@ -1628,7 +1628,7 @@ static int nes_set_features(struct net_device *netdev, netdev_features_t feature
 	struct nes_device *nesdev = nesvnic->nesdev;
 	u32 changed = netdev->features ^ features;
 
-	if (changed & NETIF_F_HW_VLAN_RX)
+	if (changed & NETIF_F_HW_VLAN_CTAG_RX)
 		nes_vlan_mode(netdev, nesdev, features);
 
 	return 0;
@@ -1706,11 +1706,11 @@ struct net_device *nes_netdev_init(struct nes_device *nesdev,
 	netdev->dev_addr[4] = (u8)(u64temp>>8);
 	netdev->dev_addr[5] = (u8)u64temp;
 
-	netdev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_RXCSUM | NETIF_F_HW_VLAN_RX;
+	netdev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_RXCSUM | NETIF_F_HW_VLAN_CTAG_RX;
 	if ((nesvnic->logical_port < 2) || (nesdev->nesadapter->hw_rev != NE020_REV))
 		netdev->hw_features |= NETIF_F_TSO;
 
-	netdev->features = netdev->hw_features | NETIF_F_HIGHDMA | NETIF_F_HW_VLAN_TX;
+	netdev->features = netdev->hw_features | NETIF_F_HIGHDMA | NETIF_F_HW_VLAN_CTAG_TX;
 	netdev->hw_features |= NETIF_F_LRO;
 
 	nes_debug(NES_DBG_INIT, "nesvnic = %p, reported features = 0x%lX, QPid = %d,"
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2aac890..8d324f8 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4322,9 +4322,9 @@ static void bond_setup(struct net_device *bond_dev)
 	 */
 
 	bond_dev->hw_features = BOND_VLAN_FEATURES |
-				NETIF_F_HW_VLAN_TX |
-				NETIF_F_HW_VLAN_RX |
-				NETIF_F_HW_VLAN_FILTER;
+				NETIF_F_HW_VLAN_CTAG_TX |
+				NETIF_F_HW_VLAN_CTAG_RX |
+				NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	bond_dev->hw_features &= ~(NETIF_F_ALL_CSUM & ~NETIF_F_HW_CSUM);
 	bond_dev->features |= bond_dev->hw_features;
diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index 27aaaf9..839a962 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -2445,9 +2445,9 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 * settings -- so we only allow the user to toggle the TX processing.
 	 */
 	dev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
-		NETIF_F_HW_VLAN_TX;
+		NETIF_F_HW_VLAN_CTAG_TX;
 	dev->features = dev->hw_features |
-		NETIF_F_HW_VLAN_RX | NETIF_F_RXCSUM;
+		NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_RXCSUM;
 
 	if(register_netdev(dev) < 0) {
 		err_msg = "unable to register netdev";
diff --git a/drivers/net/ethernet/adaptec/starfire.c b/drivers/net/ethernet/adaptec/starfire.c
index 549b775..3658651 100644
--- a/drivers/net/ethernet/adaptec/starfire.c
+++ b/drivers/net/ethernet/adaptec/starfire.c
@@ -702,7 +702,7 @@ static int starfire_init_one(struct pci_dev *pdev,
 #endif /* ZEROCOPY */
 
 #ifdef VLAN_SUPPORT
-	dev->features |= NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
+	dev->features |= NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_HW_VLAN_CTAG_FILTER;
 #endif /* VLAN_RX_KILL_VID */
 #ifdef ADDR_64BITS
 	dev->features |= NETIF_F_HIGHDMA;
diff --git a/drivers/net/ethernet/alteon/acenic.c b/drivers/net/ethernet/alteon/acenic.c
index c0bc41a..a7689d9 100644
--- a/drivers/net/ethernet/alteon/acenic.c
+++ b/drivers/net/ethernet/alteon/acenic.c
@@ -472,7 +472,7 @@ static int acenic_probe_one(struct pci_dev *pdev,
 	ap->name = pci_name(pdev);
 
 	dev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
-	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+	dev->features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
 
 	dev->watchdog_timeo = 5*HZ;
 
diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index 42d4e6a..6bad84d 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -1869,7 +1869,7 @@ static int amd8111e_probe_one(struct pci_dev *pdev,
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 #if AMD8111E_VLAN_TAG_USED
-	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX ;
+	dev->features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX ;
 #endif
 
 	lp = netdev_priv(dev);
@@ -1907,7 +1907,7 @@ static int amd8111e_probe_one(struct pci_dev *pdev,
 	netif_napi_add(dev, &lp->napi, amd8111e_rx_poll, 32);
 
 #if AMD8111E_VLAN_TAG_USED
-	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+	dev->features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
 #endif
 	/* Probe the external PHY */
 	amd8111e_probe_ext_phy(dev);
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 1f07fc6..3565255 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -417,7 +417,7 @@ static void atl1c_set_multi(struct net_device *netdev)
 
 static void __atl1c_vlan_mode(netdev_features_t features, u32 *mac_ctrl_data)
 {
-	if (features & NETIF_F_HW_VLAN_RX) {
+	if (features & NETIF_F_HW_VLAN_CTAG_RX) {
 		/* enable VLAN tag insert/strip */
 		*mac_ctrl_data |= MAC_CTRL_RMV_VLAN;
 	} else {
@@ -494,10 +494,10 @@ static netdev_features_t atl1c_fix_features(struct net_device *netdev,
 	 * Since there is no support for separate rx/tx vlan accel
 	 * enable/disable make sure tx flag is always in same state as rx.
 	 */
-	if (features & NETIF_F_HW_VLAN_RX)
-		features |= NETIF_F_HW_VLAN_TX;
+	if (features & NETIF_F_HW_VLAN_CTAG_RX)
+		features |= NETIF_F_HW_VLAN_CTAG_TX;
 	else
-		features &= ~NETIF_F_HW_VLAN_TX;
+		features &= ~NETIF_F_HW_VLAN_CTAG_TX;
 
 	if (netdev->mtu > MAX_TSO_FRAME_SIZE)
 		features &= ~(NETIF_F_TSO | NETIF_F_TSO6);
@@ -510,7 +510,7 @@ static int atl1c_set_features(struct net_device *netdev,
 {
 	netdev_features_t changed = netdev->features ^ features;
 
-	if (changed & NETIF_F_HW_VLAN_RX)
+	if (changed & NETIF_F_HW_VLAN_CTAG_RX)
 		atl1c_vlan_mode(netdev, features);
 
 	return 0;
@@ -2475,13 +2475,13 @@ static int atl1c_init_netdev(struct net_device *netdev, struct pci_dev *pdev)
 	atl1c_set_ethtool_ops(netdev);
 
 	/* TODO: add when ready */
-	netdev->hw_features =	NETIF_F_SG	   |
-				NETIF_F_HW_CSUM	   |
-				NETIF_F_HW_VLAN_RX |
-				NETIF_F_TSO	   |
+	netdev->hw_features =	NETIF_F_SG		|
+				NETIF_F_HW_CSUM		|
+				NETIF_F_HW_VLAN_CTAG_RX	|
+				NETIF_F_TSO		|
 				NETIF_F_TSO6;
-	netdev->features =	netdev->hw_features |
-				NETIF_F_HW_VLAN_TX;
+	netdev->features =	netdev->hw_features	|
+				NETIF_F_HW_VLAN_CTAG_TX;
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index d058d00..598a611 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -315,7 +315,7 @@ static void atl1e_set_multi(struct net_device *netdev)
 
 static void __atl1e_vlan_mode(netdev_features_t features, u32 *mac_ctrl_data)
 {
-	if (features & NETIF_F_HW_VLAN_RX) {
+	if (features & NETIF_F_HW_VLAN_CTAG_RX) {
 		/* enable VLAN tag insert/strip */
 		*mac_ctrl_data |= MAC_CTRL_RMV_VLAN;
 	} else {
@@ -378,10 +378,10 @@ static netdev_features_t atl1e_fix_features(struct net_device *netdev,
 	 * Since there is no support for separate rx/tx vlan accel
 	 * enable/disable make sure tx flag is always in same state as rx.
 	 */
-	if (features & NETIF_F_HW_VLAN_RX)
-		features |= NETIF_F_HW_VLAN_TX;
+	if (features & NETIF_F_HW_VLAN_CTAG_RX)
+		features |= NETIF_F_HW_VLAN_CTAG_TX;
 	else
-		features &= ~NETIF_F_HW_VLAN_TX;
+		features &= ~NETIF_F_HW_VLAN_CTAG_TX;
 
 	return features;
 }
@@ -391,7 +391,7 @@ static int atl1e_set_features(struct net_device *netdev,
 {
 	netdev_features_t changed = netdev->features ^ features;
 
-	if (changed & NETIF_F_HW_VLAN_RX)
+	if (changed & NETIF_F_HW_VLAN_CTAG_RX)
 		atl1e_vlan_mode(netdev, features);
 
 	return 0;
@@ -2198,9 +2198,9 @@ static int atl1e_init_netdev(struct net_device *netdev, struct pci_dev *pdev)
 	atl1e_set_ethtool_ops(netdev);
 
 	netdev->hw_features = NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_TSO |
-			      NETIF_F_HW_VLAN_RX;
+			      NETIF_F_HW_VLAN_CTAG_RX;
 	netdev->features = netdev->hw_features | NETIF_F_LLTX |
-			   NETIF_F_HW_VLAN_TX;
+			   NETIF_F_HW_VLAN_CTAG_TX;
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 8338013..fd7d850 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -3018,10 +3018,10 @@ static int atl1_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netdev->features = NETIF_F_HW_CSUM;
 	netdev->features |= NETIF_F_SG;
-	netdev->features |= (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
+	netdev->features |= (NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX);
 
 	netdev->hw_features = NETIF_F_HW_CSUM | NETIF_F_SG | NETIF_F_TSO |
-			      NETIF_F_HW_VLAN_RX;
+			      NETIF_F_HW_VLAN_CTAG_RX;
 
 	/* is this valid? see atl1_setup_mac_ctrl() */
 	netdev->features |= NETIF_F_RXCSUM;
diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
index a046b6f..6b2c08a 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -363,7 +363,7 @@ static inline void atl2_irq_disable(struct atl2_adapter *adapter)
 
 static void __atl2_vlan_mode(netdev_features_t features, u32 *ctrl)
 {
-	if (features & NETIF_F_HW_VLAN_RX) {
+	if (features & NETIF_F_HW_VLAN_CTAG_RX) {
 		/* enable VLAN tag insert/strip */
 		*ctrl |= MAC_CTRL_RMV_VLAN;
 	} else {
@@ -399,10 +399,10 @@ static netdev_features_t atl2_fix_features(struct net_device *netdev,
 	 * Since there is no support for separate rx/tx vlan accel
 	 * enable/disable make sure tx flag is always in same state as rx.
 	 */
-	if (features & NETIF_F_HW_VLAN_RX)
-		features |= NETIF_F_HW_VLAN_TX;
+	if (features & NETIF_F_HW_VLAN_CTAG_RX)
+		features |= NETIF_F_HW_VLAN_CTAG_TX;
 	else
-		features &= ~NETIF_F_HW_VLAN_TX;
+		features &= ~NETIF_F_HW_VLAN_CTAG_TX;
 
 	return features;
 }
@@ -412,7 +412,7 @@ static int atl2_set_features(struct net_device *netdev,
 {
 	netdev_features_t changed = netdev->features ^ features;
 
-	if (changed & NETIF_F_HW_VLAN_RX)
+	if (changed & NETIF_F_HW_VLAN_CTAG_RX)
 		atl2_vlan_mode(netdev, features);
 
 	return 0;
@@ -887,7 +887,7 @@ static netdev_tx_t atl2_xmit_frame(struct sk_buff *skb,
 			skb->len-copy_len);
 		offset = ((u32)(skb->len-copy_len + 3) & ~3);
 	}
-#ifdef NETIF_F_HW_VLAN_TX
+#ifdef NETIF_F_HW_VLAN_CTAG_TX
 	if (vlan_tx_tag_present(skb)) {
 		u16 vlan_tag = vlan_tx_tag_get(skb);
 		vlan_tag = (vlan_tag << 4) |
@@ -1413,8 +1413,8 @@ static int atl2_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	err = -EIO;
 
-	netdev->hw_features = NETIF_F_SG | NETIF_F_HW_VLAN_RX;
-	netdev->features |= (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
+	netdev->hw_features = NETIF_F_SG | NETIF_F_HW_VLAN_CTAG_RX;
+	netdev->features |= (NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX);
 
 	/* Init PHY as early as possible due to power saving issue  */
 	atl2_phy_init(&adapter->hw);
diff --git a/drivers/net/ethernet/atheros/atlx/atlx.c b/drivers/net/ethernet/atheros/atlx/atlx.c
index f82eb16..46a622c 100644
--- a/drivers/net/ethernet/atheros/atlx/atlx.c
+++ b/drivers/net/ethernet/atheros/atlx/atlx.c
@@ -220,7 +220,7 @@ static void atlx_link_chg_task(struct work_struct *work)
 
 static void __atlx_vlan_mode(netdev_features_t features, u32 *ctrl)
 {
-	if (features & NETIF_F_HW_VLAN_RX) {
+	if (features & NETIF_F_HW_VLAN_CTAG_RX) {
 		/* enable VLAN tag insert/strip */
 		*ctrl |= MAC_CTRL_RMV_VLAN;
 	} else {
@@ -257,10 +257,10 @@ static netdev_features_t atlx_fix_features(struct net_device *netdev,
 	 * Since there is no support for separate rx/tx vlan accel
 	 * enable/disable make sure tx flag is always in same state as rx.
 	 */
-	if (features & NETIF_F_HW_VLAN_RX)
-		features |= NETIF_F_HW_VLAN_TX;
+	if (features & NETIF_F_HW_VLAN_CTAG_RX)
+		features |= NETIF_F_HW_VLAN_CTAG_TX;
 	else
-		features &= ~NETIF_F_HW_VLAN_TX;
+		features &= ~NETIF_F_HW_VLAN_CTAG_TX;
 
 	return features;
 }
@@ -270,7 +270,7 @@ static int atlx_set_features(struct net_device *netdev,
 {
 	netdev_features_t changed = netdev->features ^ features;
 
-	if (changed & NETIF_F_HW_VLAN_RX)
+	if (changed & NETIF_F_HW_VLAN_CTAG_RX)
 		atlx_vlan_mode(netdev, features);
 
 	return 0;
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index f27b549..42a8bc8 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -3553,7 +3553,7 @@ bnx2_set_rx_mode(struct net_device *dev)
 	rx_mode = bp->rx_mode & ~(BNX2_EMAC_RX_MODE_PROMISCUOUS |
 				  BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG);
 	sort_mode = 1 | BNX2_RPM_SORT_USER0_BC_EN;
-	if (!(dev->features & NETIF_F_HW_VLAN_RX) &&
+	if (!(dev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
 	     (bp->flags & BNX2_FLAG_CAN_KEEP_VLAN))
 		rx_mode |= BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG;
 	if (dev->flags & IFF_PROMISC) {
@@ -7695,7 +7695,7 @@ bnx2_fix_features(struct net_device *dev, netdev_features_t features)
 	struct bnx2 *bp = netdev_priv(dev);
 
 	if (!(bp->flags & BNX2_FLAG_CAN_KEEP_VLAN))
-		features |= NETIF_F_HW_VLAN_RX;
+		features |= NETIF_F_HW_VLAN_CTAG_RX;
 
 	return features;
 }
@@ -7706,12 +7706,12 @@ bnx2_set_features(struct net_device *dev, netdev_features_t features)
 	struct bnx2 *bp = netdev_priv(dev);
 
 	/* TSO with VLAN tag won't work with current firmware */
-	if (features & NETIF_F_HW_VLAN_TX)
+	if (features & NETIF_F_HW_VLAN_CTAG_TX)
 		dev->vlan_features |= (dev->hw_features & NETIF_F_ALL_TSO);
 	else
 		dev->vlan_features &= ~NETIF_F_ALL_TSO;
 
-	if ((!!(features & NETIF_F_HW_VLAN_RX) !=
+	if ((!!(features & NETIF_F_HW_VLAN_CTAG_RX) !=
 	    !!(bp->rx_mode & BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG)) &&
 	    netif_running(dev)) {
 		bnx2_netif_stop(bp, false);
@@ -8551,7 +8551,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev->hw_features |= NETIF_F_IPV6_CSUM | NETIF_F_TSO6;
 
 	dev->vlan_features = dev->hw_features;
-	dev->hw_features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+	dev->hw_features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
 	dev->features |= dev->hw_features;
 	dev->priv_flags |= IFF_UNICAST_FLT;
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index fdfe33b..1e60c5d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12027,7 +12027,7 @@ static int bnx2x_init_dev(struct bnx2x *bp, struct pci_dev *pdev,
 	dev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 |
 		NETIF_F_RXCSUM | NETIF_F_LRO | NETIF_F_GRO |
-		NETIF_F_RXHASH | NETIF_F_HW_VLAN_TX;
+		NETIF_F_RXHASH | NETIF_F_HW_VLAN_CTAG_TX;
 	if (!CHIP_IS_E1x(bp)) {
 		dev->hw_features |= NETIF_F_GSO_GRE;
 		dev->hw_enc_features =
@@ -12039,7 +12039,7 @@ static int bnx2x_init_dev(struct bnx2x *bp, struct pci_dev *pdev,
 	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_HIGHDMA;
 
-	dev->features |= dev->hw_features | NETIF_F_HW_VLAN_RX;
+	dev->features |= dev->hw_features | NETIF_F_HW_VLAN_CTAG_RX;
 	if (bp->flags & USING_DAC_FLAG)
 		dev->features |= NETIF_F_HIGHDMA;
 
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 45719dd..0c22c9a 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -17197,7 +17197,7 @@ static int tg3_init_one(struct pci_dev *pdev,
 
 	tg3_init_bufmgr_config(tp);
 
-	features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+	features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
 
 	/* 5700 B0 chips do not support checksumming correctly due
 	 * to hardware bugs.
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index d588f84..1d9d037 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -3170,14 +3170,14 @@ bnad_netdev_init(struct bnad *bnad, bool using_dac)
 
 	netdev->hw_features = NETIF_F_SG | NETIF_F_RXCSUM |
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-		NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_HW_VLAN_TX;
+		NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_HW_VLAN_CTAG_TX;
 
 	netdev->vlan_features = NETIF_F_SG | NETIF_F_HIGHDMA |
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 		NETIF_F_TSO | NETIF_F_TSO6;
 
 	netdev->features |= netdev->hw_features |
-		NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
+		NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	if (using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
diff --git a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
index 20d2085..9624cfe 100644
--- a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
+++ b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
@@ -856,10 +856,10 @@ static netdev_features_t t1_fix_features(struct net_device *dev,
 	 * Since there is no support for separate rx/tx vlan accel
 	 * enable/disable make sure tx flag is always in same state as rx.
 	 */
-	if (features & NETIF_F_HW_VLAN_RX)
-		features |= NETIF_F_HW_VLAN_TX;
+	if (features & NETIF_F_HW_VLAN_CTAG_RX)
+		features |= NETIF_F_HW_VLAN_CTAG_TX;
 	else
-		features &= ~NETIF_F_HW_VLAN_TX;
+		features &= ~NETIF_F_HW_VLAN_CTAG_TX;
 
 	return features;
 }
@@ -869,7 +869,7 @@ static int t1_set_features(struct net_device *dev, netdev_features_t features)
 	netdev_features_t changed = dev->features ^ features;
 	struct adapter *adapter = dev->ml_priv;
 
-	if (changed & NETIF_F_HW_VLAN_RX)
+	if (changed & NETIF_F_HW_VLAN_CTAG_RX)
 		t1_vlan_mode(adapter, features);
 
 	return 0;
@@ -1085,8 +1085,9 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 			netdev->features |= NETIF_F_HIGHDMA;
 		if (vlan_tso_capable(adapter)) {
 			netdev->features |=
-				NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-			netdev->hw_features |= NETIF_F_HW_VLAN_RX;
+				NETIF_F_HW_VLAN_CTAG_TX |
+				NETIF_F_HW_VLAN_CTAG_RX;
+			netdev->hw_features |= NETIF_F_HW_VLAN_CTAG_RX;
 
 			/* T204: disable TSO */
 			if (!(is_T2(adapter)) || bi->port_number != 4) {
diff --git a/drivers/net/ethernet/chelsio/cxgb/sge.c b/drivers/net/ethernet/chelsio/cxgb/sge.c
index 55fe8c9..f85e065 100644
--- a/drivers/net/ethernet/chelsio/cxgb/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb/sge.c
@@ -734,7 +734,7 @@ void t1_vlan_mode(struct adapter *adapter, netdev_features_t features)
 {
 	struct sge *sge = adapter->sge;
 
-	if (features & NETIF_F_HW_VLAN_RX)
+	if (features & NETIF_F_HW_VLAN_CTAG_RX)
 		sge->sge_control |= F_VLAN_XTRACT;
 	else
 		sge->sge_control &= ~F_VLAN_XTRACT;
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index 2b5e621..71497e8 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -1181,14 +1181,15 @@ static void cxgb_vlan_mode(struct net_device *dev, netdev_features_t features)
 
 	if (adapter->params.rev > 0) {
 		t3_set_vlan_accel(adapter, 1 << pi->port_id,
-				  features & NETIF_F_HW_VLAN_RX);
+				  features & NETIF_F_HW_VLAN_CTAG_RX);
 	} else {
 		/* single control for all ports */
-		unsigned int i, have_vlans = features & NETIF_F_HW_VLAN_RX;
+		unsigned int i, have_vlans = features & NETIF_F_HW_VLAN_CTAG_RX;
 
 		for_each_port(adapter, i)
 			have_vlans |=
-				adapter->port[i]->features & NETIF_F_HW_VLAN_RX;
+				adapter->port[i]->features &
+				NETIF_F_HW_VLAN_CTAG_RX;
 
 		t3_set_vlan_accel(adapter, 1, have_vlans);
 	}
@@ -2563,10 +2564,10 @@ static netdev_features_t cxgb_fix_features(struct net_device *dev,
 	 * Since there is no support for separate rx/tx vlan accel
 	 * enable/disable make sure tx flag is always in same state as rx.
 	 */
-	if (features & NETIF_F_HW_VLAN_RX)
-		features |= NETIF_F_HW_VLAN_TX;
+	if (features & NETIF_F_HW_VLAN_CTAG_RX)
+		features |= NETIF_F_HW_VLAN_CTAG_TX;
 	else
-		features &= ~NETIF_F_HW_VLAN_TX;
+		features &= ~NETIF_F_HW_VLAN_CTAG_TX;
 
 	return features;
 }
@@ -2575,7 +2576,7 @@ static int cxgb_set_features(struct net_device *dev, netdev_features_t features)
 {
 	netdev_features_t changed = dev->features ^ features;
 
-	if (changed & NETIF_F_HW_VLAN_RX)
+	if (changed & NETIF_F_HW_VLAN_CTAG_RX)
 		cxgb_vlan_mode(dev, features);
 
 	return 0;
@@ -3288,8 +3289,9 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		netdev->mem_start = mmio_start;
 		netdev->mem_end = mmio_start + mmio_len - 1;
 		netdev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM |
-			NETIF_F_TSO | NETIF_F_RXCSUM | NETIF_F_HW_VLAN_RX;
-		netdev->features |= netdev->hw_features | NETIF_F_HW_VLAN_TX;
+			NETIF_F_TSO | NETIF_F_RXCSUM | NETIF_F_HW_VLAN_CTAG_RX;
+		netdev->features |= netdev->hw_features |
+				    NETIF_F_HW_VLAN_CTAG_TX;
 		netdev->vlan_features |= netdev->features & VLAN_FEAT;
 		if (pci_using_dac)
 			netdev->features |= NETIF_F_HIGHDMA;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index e76cf03..6a6a01a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -559,7 +559,7 @@ static int link_start(struct net_device *dev)
 	 * that step explicitly.
 	 */
 	ret = t4_set_rxmode(pi->adapter, mb, pi->viid, dev->mtu, -1, -1, -1,
-			    !!(dev->features & NETIF_F_HW_VLAN_RX), true);
+			    !!(dev->features & NETIF_F_HW_VLAN_CTAG_RX), true);
 	if (ret == 0) {
 		ret = t4_change_mac(pi->adapter, mb, pi->viid,
 				    pi->xact_addr_filt, dev->dev_addr, true,
@@ -2722,14 +2722,14 @@ static int cxgb_set_features(struct net_device *dev, netdev_features_t features)
 	netdev_features_t changed = dev->features ^ features;
 	int err;
 
-	if (!(changed & NETIF_F_HW_VLAN_RX))
+	if (!(changed & NETIF_F_HW_VLAN_CTAG_RX))
 		return 0;
 
 	err = t4_set_rxmode(pi->adapter, pi->adapter->fn, pi->viid, -1,
 			    -1, -1, -1,
-			    !!(features & NETIF_F_HW_VLAN_RX), true);
+			    !!(features & NETIF_F_HW_VLAN_CTAG_RX), true);
 	if (unlikely(err))
-		dev->features = features ^ NETIF_F_HW_VLAN_RX;
+		dev->features = features ^ NETIF_F_HW_VLAN_CTAG_RX;
 	return err;
 }
 
@@ -5628,7 +5628,7 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		netdev->hw_features = NETIF_F_SG | TSO_FLAGS |
 			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 			NETIF_F_RXCSUM | NETIF_F_RXHASH |
-			NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+			NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
 		if (highdma)
 			netdev->hw_features |= NETIF_F_HIGHDMA;
 		netdev->features |= netdev->hw_features;
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 7fcac20..73aef76 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -1100,10 +1100,10 @@ static netdev_features_t cxgb4vf_fix_features(struct net_device *dev,
 	 * Since there is no support for separate rx/tx vlan accel
 	 * enable/disable make sure tx flag is always in same state as rx.
 	 */
-	if (features & NETIF_F_HW_VLAN_RX)
-		features |= NETIF_F_HW_VLAN_TX;
+	if (features & NETIF_F_HW_VLAN_CTAG_RX)
+		features |= NETIF_F_HW_VLAN_CTAG_TX;
 	else
-		features &= ~NETIF_F_HW_VLAN_TX;
+		features &= ~NETIF_F_HW_VLAN_CTAG_TX;
 
 	return features;
 }
@@ -1114,9 +1114,9 @@ static int cxgb4vf_set_features(struct net_device *dev,
 	struct port_info *pi = netdev_priv(dev);
 	netdev_features_t changed = dev->features ^ features;
 
-	if (changed & NETIF_F_HW_VLAN_RX)
+	if (changed & NETIF_F_HW_VLAN_CTAG_RX)
 		t4vf_set_rxmode(pi->adapter, pi->viid, -1, -1, -1, -1,
-				features & NETIF_F_HW_VLAN_TX, 0);
+				features & NETIF_F_HW_VLAN_CTAG_TX, 0);
 
 	return 0;
 }
@@ -2623,11 +2623,12 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 
 		netdev->hw_features = NETIF_F_SG | TSO_FLAGS |
 			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-			NETIF_F_HW_VLAN_RX | NETIF_F_RXCSUM;
+			NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_RXCSUM;
 		netdev->vlan_features = NETIF_F_SG | TSO_FLAGS |
 			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 			NETIF_F_HIGHDMA;
-		netdev->features = netdev->hw_features | NETIF_F_HW_VLAN_TX;
+		netdev->features = netdev->hw_features |
+				   NETIF_F_HW_VLAN_CTAG_TX;
 		if (pci_using_dac)
 			netdev->features |= NETIF_F_HIGHDMA;
 
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index ec1a233..05c1e59 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -2496,9 +2496,9 @@ static int enic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->watchdog_timeo = 2 * HZ;
 	netdev->ethtool_ops = &enic_ethtool_ops;
 
-	netdev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+	netdev->features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
 	if (ENIC_SETTING(enic, LOOP)) {
-		netdev->features &= ~NETIF_F_HW_VLAN_TX;
+		netdev->features &= ~NETIF_F_HW_VLAN_CTAG_TX;
 		enic->loop_enable = 1;
 		enic->loop_tag = enic->config.loop_tag;
 		dev_info(dev, "loopback tag=0x%04x\n", enic->loop_tag);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 536afa2..bde26d4 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3663,12 +3663,12 @@ static void be_netdev_init(struct net_device *netdev)
 
 	netdev->hw_features |= NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO6 |
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_RXCSUM |
-		NETIF_F_HW_VLAN_TX;
+		NETIF_F_HW_VLAN_CTAG_TX;
 	if (be_multi_rxq(adapter))
 		netdev->hw_features |= NETIF_F_RXHASH;
 
 	netdev->features |= netdev->hw_features |
-		NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
+		NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	netdev->vlan_features |= NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO6 |
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 96fbe35..5155544 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -386,7 +386,7 @@ static void gfar_init_mac(struct net_device *ndev)
 		priv->uses_rxfcb = 1;
 	}
 
-	if (ndev->features & NETIF_F_HW_VLAN_RX) {
+	if (ndev->features & NETIF_F_HW_VLAN_CTAG_RX) {
 		rctrl |= RCTRL_VLEX | RCTRL_PRSDEP_INIT;
 		priv->uses_rxfcb = 1;
 	}
@@ -1050,8 +1050,9 @@ static int gfar_probe(struct platform_device *ofdev)
 	}
 
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_VLAN) {
-		dev->hw_features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-		dev->features |= NETIF_F_HW_VLAN_RX;
+		dev->hw_features |= NETIF_F_HW_VLAN_CTAG_TX |
+				    NETIF_F_HW_VLAN_CTAG_RX;
+		dev->features |= NETIF_F_HW_VLAN_CTAG_RX;
 	}
 
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_EXTENDED_HASH) {
@@ -2348,7 +2349,7 @@ void gfar_vlan_mode(struct net_device *dev, netdev_features_t features)
 	local_irq_save(flags);
 	lock_rx_qs(priv);
 
-	if (features & NETIF_F_HW_VLAN_TX) {
+	if (features & NETIF_F_HW_VLAN_CTAG_TX) {
 		/* Enable VLAN tag insertion */
 		tempval = gfar_read(&regs->tctrl);
 		tempval |= TCTRL_VLINS;
@@ -2360,7 +2361,7 @@ void gfar_vlan_mode(struct net_device *dev, netdev_features_t features)
 		gfar_write(&regs->tctrl, tempval);
 	}
 
-	if (features & NETIF_F_HW_VLAN_RX) {
+	if (features & NETIF_F_HW_VLAN_CTAG_RX) {
 		/* Enable VLAN tag extraction */
 		tempval = gfar_read(&regs->rctrl);
 		tempval |= (RCTRL_VLEX | RCTRL_PRSDEP_INIT);
@@ -2724,11 +2725,11 @@ static void gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 	/* Tell the skb what kind of packet this is */
 	skb->protocol = eth_type_trans(skb, dev);
 
-	/* There's need to check for NETIF_F_HW_VLAN_RX here.
+	/* There's need to check for NETIF_F_HW_VLAN_CTAG_RX here.
 	 * Even if vlan rx accel is disabled, on some chips
 	 * RXFCB_VLN is pseudo randomly set.
 	 */
-	if (dev->features & NETIF_F_HW_VLAN_RX &&
+	if (dev->features & NETIF_F_HW_VLAN_CTAG_RX &&
 	    fcb->flags & RXFCB_VLN)
 		__vlan_hwaccel_put_tag(skb, fcb->vlctl);
 
diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 083603f..21cd881 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -542,7 +542,7 @@ int gfar_set_features(struct net_device *dev, netdev_features_t features)
 	int err = 0, i = 0;
 	netdev_features_t changed = dev->features ^ features;
 
-	if (changed & (NETIF_F_HW_VLAN_TX|NETIF_F_HW_VLAN_RX))
+	if (changed & (NETIF_F_HW_VLAN_CTAG_TX|NETIF_F_HW_VLAN_CTAG_RX))
 		gfar_vlan_mode(dev, features);
 
 	if (!(changed & NETIF_F_RXCSUM))
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 0296334..9c9fa74 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -3021,11 +3021,11 @@ static struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 	ehea_set_ethtool_ops(dev);
 
 	dev->hw_features = NETIF_F_SG | NETIF_F_TSO
-		      | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX;
+		      | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_CTAG_TX;
 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO
-		      | NETIF_F_HIGHDMA | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX
-		      | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER
-		      | NETIF_F_RXCSUM;
+		      | NETIF_F_HIGHDMA | NETIF_F_IP_CSUM |
+		      | NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX |
+		      | NETIF_F_HW_VLAN_CTAG_FILTER | NETIF_F_RXCSUM;
 	dev->vlan_features = NETIF_F_SG | NETIF_F_TSO | NETIF_F_HIGHDMA |
 			NETIF_F_IP_CSUM;
 	dev->watchdog_timeo = EHEA_WATCH_DOG_TIMEOUT;
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index d98e1d09..8d0d0d4 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -809,10 +809,10 @@ static netdev_features_t e1000_fix_features(struct net_device *netdev,
 	/* Since there is no support for separate Rx/Tx vlan accel
 	 * enable/disable make sure Tx flag is always in same state as Rx.
 	 */
-	if (features & NETIF_F_HW_VLAN_RX)
-		features |= NETIF_F_HW_VLAN_TX;
+	if (features & NETIF_F_HW_VLAN_CTAG_RX)
+		features |= NETIF_F_HW_VLAN_CTAG_TX;
 	else
-		features &= ~NETIF_F_HW_VLAN_TX;
+		features &= ~NETIF_F_HW_VLAN_CTAG_TX;
 
 	return features;
 }
@@ -823,7 +823,7 @@ static int e1000_set_features(struct net_device *netdev,
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	netdev_features_t changed = features ^ netdev->features;
 
-	if (changed & NETIF_F_HW_VLAN_RX)
+	if (changed & NETIF_F_HW_VLAN_CTAG_RX)
 		e1000_vlan_mode(netdev, features);
 
 	if (!(changed & (NETIF_F_RXCSUM | NETIF_F_RXALL)))
@@ -1058,9 +1058,9 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (hw->mac_type >= e1000_82543) {
 		netdev->hw_features = NETIF_F_SG |
 				   NETIF_F_HW_CSUM |
-				   NETIF_F_HW_VLAN_RX;
-		netdev->features = NETIF_F_HW_VLAN_TX |
-				   NETIF_F_HW_VLAN_FILTER;
+				   NETIF_F_HW_VLAN_CTAG_RX;
+		netdev->features = NETIF_F_HW_VLAN_CTAG_TX |
+				   NETIF_F_HW_VLAN_CTAG_FILTER;
 	}
 
 	if ((hw->mac_type >= e1000_82544) &&
@@ -4785,7 +4785,7 @@ static void __e1000_vlan_mode(struct e1000_adapter *adapter,
 	u32 ctrl;
 
 	ctrl = er32(CTRL);
-	if (features & NETIF_F_HW_VLAN_RX) {
+	if (features & NETIF_F_HW_VLAN_CTAG_RX) {
 		/* enable VLAN tag insert/strip */
 		ctrl |= E1000_CTRL_VME;
 	} else {
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index b18fad5..a2e7db3 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3373,7 +3373,7 @@ static void e1000e_set_rx_mode(struct net_device *netdev)
 
 	ew32(RCTL, rctl);
 
-	if (netdev->features & NETIF_F_HW_VLAN_RX)
+	if (netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
 		e1000e_vlan_strip_enable(adapter);
 	else
 		e1000e_vlan_strip_disable(adapter);
@@ -6418,7 +6418,7 @@ static int e1000_set_features(struct net_device *netdev,
 	if (changed & (NETIF_F_TSO | NETIF_F_TSO6))
 		adapter->flags |= FLAG_TSO_FORCE;
 
-	if (!(changed & (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX |
+	if (!(changed & (NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_HW_VLAN_CTAG_TX |
 			 NETIF_F_RXCSUM | NETIF_F_RXHASH | NETIF_F_RXFCS |
 			 NETIF_F_RXALL)))
 		return 0;
@@ -6629,8 +6629,8 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* Set initial default active device features */
 	netdev->features = (NETIF_F_SG |
-			    NETIF_F_HW_VLAN_RX |
-			    NETIF_F_HW_VLAN_TX |
+			    NETIF_F_HW_VLAN_CTAG_RX |
+			    NETIF_F_HW_VLAN_CTAG_TX |
 			    NETIF_F_TSO |
 			    NETIF_F_TSO6 |
 			    NETIF_F_RXHASH |
@@ -6644,7 +6644,7 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->hw_features |= NETIF_F_RXALL;
 
 	if (adapter->flags & FLAG_HAS_HW_VLAN_FILTER)
-		netdev->features |= NETIF_F_HW_VLAN_FILTER;
+		netdev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	netdev->vlan_features |= (NETIF_F_SG |
 				  NETIF_F_TSO |
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 8496adf..05980de 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1830,10 +1830,10 @@ static netdev_features_t igb_fix_features(struct net_device *netdev,
 	 * Since there is no support for separate rx/tx vlan accel
 	 * enable/disable make sure tx flag is always in same state as rx.
 	 */
-	if (features & NETIF_F_HW_VLAN_RX)
-		features |= NETIF_F_HW_VLAN_TX;
+	if (features & NETIF_F_HW_VLAN_CTAG_RX)
+		features |= NETIF_F_HW_VLAN_CTAG_TX;
 	else
-		features &= ~NETIF_F_HW_VLAN_TX;
+		features &= ~NETIF_F_HW_VLAN_CTAG_TX;
 
 	return features;
 }
@@ -1844,7 +1844,7 @@ static int igb_set_features(struct net_device *netdev,
 	netdev_features_t changed = netdev->features ^ features;
 	struct igb_adapter *adapter = netdev_priv(netdev);
 
-	if (changed & NETIF_F_HW_VLAN_RX)
+	if (changed & NETIF_F_HW_VLAN_CTAG_RX)
 		igb_vlan_mode(netdev, features);
 
 	if (!(changed & NETIF_F_RXALL))
@@ -2097,15 +2097,15 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			    NETIF_F_TSO6 |
 			    NETIF_F_RXHASH |
 			    NETIF_F_RXCSUM |
-			    NETIF_F_HW_VLAN_RX |
-			    NETIF_F_HW_VLAN_TX;
+			    NETIF_F_HW_VLAN_CTAG_RX |
+			    NETIF_F_HW_VLAN_CTAG_TX;
 
 	/* copy netdev features into list of user selectable features */
 	netdev->hw_features |= netdev->features;
 	netdev->hw_features |= NETIF_F_RXALL;
 
 	/* set this bit last since it cannot be part of hw_features */
-	netdev->features |= NETIF_F_HW_VLAN_FILTER;
+	netdev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	netdev->vlan_features |= NETIF_F_TSO |
 				 NETIF_F_TSO6 |
@@ -6645,7 +6645,7 @@ static void igb_process_skb_fields(struct igb_ring *rx_ring,
 
 	igb_ptp_rx_hwtstamp(rx_ring->q_vector, rx_desc, skb);
 
-	if ((dev->features & NETIF_F_HW_VLAN_RX) &&
+	if ((dev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
 	    igb_test_staterr(rx_desc, E1000_RXD_STAT_VP)) {
 		u16 vid;
 		if (igb_test_staterr(rx_desc, E1000_RXDEXT_STATERR_LB) &&
@@ -6928,7 +6928,7 @@ static void igb_vlan_mode(struct net_device *netdev, netdev_features_t features)
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	u32 ctrl, rctl;
-	bool enable = !!(features & NETIF_F_HW_VLAN_RX);
+	bool enable = !!(features & NETIF_F_HW_VLAN_CTAG_RX);
 
 	if (enable) {
 		/* enable VLAN tag insert/strip */
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index bea46bb..33e7b30 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -2722,9 +2722,9 @@ static int igbvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			   NETIF_F_RXCSUM;
 
 	netdev->features = netdev->hw_features |
-	                   NETIF_F_HW_VLAN_TX |
-	                   NETIF_F_HW_VLAN_RX |
-	                   NETIF_F_HW_VLAN_FILTER;
+	                   NETIF_F_HW_VLAN_CTAG_TX |
+	                   NETIF_F_HW_VLAN_CTAG_RX |
+	                   NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index 5dc119f..e65d9e9 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -332,8 +332,8 @@ ixgb_fix_features(struct net_device *netdev, netdev_features_t features)
 	 * Tx VLAN insertion does not work per HW design when Rx stripping is
 	 * disabled.
 	 */
-	if (!(features & NETIF_F_HW_VLAN_RX))
-		features &= ~NETIF_F_HW_VLAN_TX;
+	if (!(features & NETIF_F_HW_VLAN_CTAG_RX))
+		features &= ~NETIF_F_HW_VLAN_CTAG_TX;
 
 	return features;
 }
@@ -344,7 +344,7 @@ ixgb_set_features(struct net_device *netdev, netdev_features_t features)
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	netdev_features_t changed = features ^ netdev->features;
 
-	if (!(changed & (NETIF_F_RXCSUM|NETIF_F_HW_VLAN_RX)))
+	if (!(changed & (NETIF_F_RXCSUM|NETIF_F_HW_VLAN_CTAG_RX)))
 		return 0;
 
 	adapter->rx_csum = !!(features & NETIF_F_RXCSUM);
@@ -479,10 +479,10 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->hw_features = NETIF_F_SG |
 			   NETIF_F_TSO |
 			   NETIF_F_HW_CSUM |
-			   NETIF_F_HW_VLAN_TX |
-			   NETIF_F_HW_VLAN_RX;
+			   NETIF_F_HW_VLAN_CTAG_TX |
+			   NETIF_F_HW_VLAN_CTAG_RX;
 	netdev->features = netdev->hw_features |
-			   NETIF_F_HW_VLAN_FILTER;
+			   NETIF_F_HW_VLAN_CTAG_FILTER;
 	netdev->hw_features |= NETIF_F_RXCSUM;
 
 	if (pci_using_dac) {
@@ -1140,7 +1140,7 @@ ixgb_set_multi(struct net_device *netdev)
 	}
 
 alloc_failed:
-	if (netdev->features & NETIF_F_HW_VLAN_RX)
+	if (netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
 		ixgb_vlan_strip_enable(adapter);
 	else
 		ixgb_vlan_strip_disable(adapter);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 1339932..6839785 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1442,7 +1442,7 @@ static void ixgbe_process_skb_fields(struct ixgbe_ring *rx_ring,
 
 	ixgbe_ptp_rx_hwtstamp(rx_ring, rx_desc, skb);
 
-	if ((dev->features & NETIF_F_HW_VLAN_RX) &&
+	if ((dev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
 	    ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_VP)) {
 		u16 vid = le16_to_cpu(rx_desc->wb.upper.vlan);
 		__vlan_hwaccel_put_tag(skb, vid);
@@ -3676,7 +3676,7 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 
 	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl);
 
-	if (netdev->features & NETIF_F_HW_VLAN_RX)
+	if (netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
 		ixgbe_vlan_strip_enable(adapter);
 	else
 		ixgbe_vlan_strip_disable(adapter);
@@ -6983,7 +6983,7 @@ static int ixgbe_set_features(struct net_device *netdev,
 		break;
 	}
 
-	if (features & NETIF_F_HW_VLAN_RX)
+	if (features & NETIF_F_HW_VLAN_CTAG_RX)
 		ixgbe_vlan_strip_enable(adapter);
 	else
 		ixgbe_vlan_strip_disable(adapter);
@@ -7385,9 +7385,9 @@ skip_sriov:
 	netdev->features = NETIF_F_SG |
 			   NETIF_F_IP_CSUM |
 			   NETIF_F_IPV6_CSUM |
-			   NETIF_F_HW_VLAN_TX |
-			   NETIF_F_HW_VLAN_RX |
-			   NETIF_F_HW_VLAN_FILTER |
+			   NETIF_F_HW_VLAN_CTAG_TX |
+			   NETIF_F_HW_VLAN_CTAG_RX |
+			   NETIF_F_HW_VLAN_CTAG_FILTER |
 			   NETIF_F_TSO |
 			   NETIF_F_TSO6 |
 			   NETIF_F_RXHASH |
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index b3e6530..2d4bdcc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -35,7 +35,7 @@
 #include <linux/ip.h>
 #include <linux/tcp.h>
 #include <linux/ipv6.h>
-#ifdef NETIF_F_HW_VLAN_TX
+#ifdef NETIF_F_HW_VLAN_CTAG_TX
 #include <linux/if_vlan.h>
 #endif
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index eeae934..8f907b7 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3410,9 +3410,9 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			   NETIF_F_RXCSUM;
 
 	netdev->features = netdev->hw_features |
-			   NETIF_F_HW_VLAN_TX |
-			   NETIF_F_HW_VLAN_RX |
-			   NETIF_F_HW_VLAN_FILTER;
+			   NETIF_F_HW_VLAN_CTAG_TX |
+			   NETIF_F_HW_VLAN_CTAG_RX |
+			   NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_TSO6;
diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 0519afa..d28ce6f 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -3030,8 +3030,8 @@ jme_init_one(struct pci_dev *pdev,
 						NETIF_F_SG |
 						NETIF_F_TSO |
 						NETIF_F_TSO6 |
-						NETIF_F_HW_VLAN_TX |
-						NETIF_F_HW_VLAN_RX;
+						NETIF_F_HW_VLAN_CTAG_TX |
+						NETIF_F_HW_VLAN_CTAG_RX;
 	if (using_dac)
 		netdev->features	|=	NETIF_F_HIGHDMA;
 
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 6a0e671..bf9da1b 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -1421,14 +1421,14 @@ static void sky2_vlan_mode(struct net_device *dev, netdev_features_t features)
 	struct sky2_hw *hw = sky2->hw;
 	u16 port = sky2->port;
 
-	if (features & NETIF_F_HW_VLAN_RX)
+	if (features & NETIF_F_HW_VLAN_CTAG_RX)
 		sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T),
 			     RX_VLAN_STRIP_ON);
 	else
 		sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T),
 			     RX_VLAN_STRIP_OFF);
 
-	if (features & NETIF_F_HW_VLAN_TX) {
+	if (features & NETIF_F_HW_VLAN_CTAG_TX) {
 		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
 			     TX_VLAN_TAG_ON);
 
@@ -4406,7 +4406,7 @@ static int sky2_set_features(struct net_device *dev, netdev_features_t features)
 	if (changed & NETIF_F_RXHASH)
 		rx_set_rss(dev, features);
 
-	if (changed & (NETIF_F_HW_VLAN_TX|NETIF_F_HW_VLAN_RX))
+	if (changed & (NETIF_F_HW_VLAN_CTAG_TX|NETIF_F_HW_VLAN_CTAG_RX))
 		sky2_vlan_mode(dev, features);
 
 	return 0;
@@ -4793,7 +4793,8 @@ static struct net_device *sky2_init_netdev(struct sky2_hw *hw, unsigned port,
 		dev->hw_features |= NETIF_F_RXHASH;
 
 	if (!(hw->flags & SKY2_HW_VLAN_BROKEN)) {
-		dev->hw_features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+		dev->hw_features |= NETIF_F_HW_VLAN_CTAG_TX |
+				    NETIF_F_HW_VLAN_CTAG_RX;
 		dev->vlan_features |= SKY2_VLAN_OFFLOADS;
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index d2a4f91..b2ba39c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2082,8 +2082,8 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 
 	dev->hw_features |= NETIF_F_RXCSUM | NETIF_F_RXHASH;
 	dev->features = dev->hw_features | NETIF_F_HIGHDMA |
-			NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
-			NETIF_F_HW_VLAN_FILTER;
+			NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX |
+			NETIF_F_HW_VLAN_CTAG_FILTER;
 	dev->hw_features |= NETIF_F_LOOPBACK;
 
 	if (mdev->dev->caps.steering_mode ==
diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index d5ffdc8..46262ea 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -1281,7 +1281,8 @@ myri10ge_vlan_rx(struct net_device *dev, void *addr, struct sk_buff *skb)
 	va = addr;
 	va += MXGEFW_PAD;
 	veh = (struct vlan_ethhdr *)va;
-	if ((dev->features & NETIF_F_HW_VLAN_RX) == NETIF_F_HW_VLAN_RX &&
+	if ((dev->features & NETIF_F_HW_VLAN_CTAG_RX) ==
+	    NETIF_F_HW_VLAN_CTAG_RX &&
 	    veh->h_vlan_proto == htons(ETH_P_8021Q)) {
 		/* fixup csum if needed */
 		if (skb->ip_summed == CHECKSUM_COMPLETE) {
@@ -3887,8 +3888,8 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->mtu = myri10ge_initial_mtu;
 	netdev->hw_features = mgp->features | NETIF_F_RXCSUM;
 
-	/* fake NETIF_F_HW_VLAN_RX for good GRO performance */
-	netdev->hw_features |= NETIF_F_HW_VLAN_RX;
+	/* fake NETIF_F_HW_VLAN_CTAG_RX for good GRO performance */
+	netdev->hw_features |= NETIF_F_HW_VLAN_CTAG_RX;
 
 	netdev->features = netdev->hw_features;
 
diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
index 77c070d..60267e9 100644
--- a/drivers/net/ethernet/natsemi/ns83820.c
+++ b/drivers/net/ethernet/natsemi/ns83820.c
@@ -2193,7 +2193,7 @@ static int ns83820_init_one(struct pci_dev *pci_dev,
 
 #ifdef NS83820_VLAN_ACCEL_SUPPORT
 	/* We also support hardware vlan acceleration */
-	ndev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+	ndev->features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
 #endif
 
 	if (using_dac) {
diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 3371ff4..ec82d59 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -7920,7 +7920,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 		NETIF_F_TSO | NETIF_F_TSO6 |
 		NETIF_F_RXCSUM | NETIF_F_LRO;
 	dev->features |= dev->hw_features |
-		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+		NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
 	if (sp->device_type & XFRAME_II_DEVICE) {
 		dev->hw_features |= NETIF_F_UFO;
 		if (ufo)
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index 794444e..e9e58aa 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -3415,12 +3415,12 @@ static int vxge_device_register(struct __vxge_hw_device *hldev,
 	ndev->hw_features = NETIF_F_RXCSUM | NETIF_F_SG |
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 		NETIF_F_TSO | NETIF_F_TSO6 |
-		NETIF_F_HW_VLAN_TX;
+		NETIF_F_HW_VLAN_CTAG_TX;
 	if (vdev->config.rth_steering != NO_STEERING)
 		ndev->hw_features |= NETIF_F_RXHASH;
 
 	ndev->features |= ndev->hw_features |
-		NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
+		NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_HW_VLAN_CTAG_FILTER;
 
 
 	ndev->netdev_ops = &vxge_netdev_ops;
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 5ae1247..6c04946 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -2961,11 +2961,11 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 			vlanflags = le32_to_cpu(np->get_rx.ex->buflow);
 
 			/*
-			 * There's need to check for NETIF_F_HW_VLAN_RX here.
-			 * Even if vlan rx accel is disabled,
+			 * There's need to check for NETIF_F_HW_VLAN_CTAG_RX
+			 * here. Even if vlan rx accel is disabled,
 			 * NV_RX3_VLAN_TAG_PRESENT is pseudo randomly set.
 			 */
-			if (dev->features & NETIF_F_HW_VLAN_RX &&
+			if (dev->features & NETIF_F_HW_VLAN_CTAG_RX &&
 			    vlanflags & NV_RX3_VLAN_TAG_PRESENT) {
 				u16 vid = vlanflags & NV_RX3_VLAN_TAG_MASK;
 
@@ -4816,7 +4816,7 @@ static netdev_features_t nv_fix_features(struct net_device *dev,
 	netdev_features_t features)
 {
 	/* vlan is dependent on rx checksum offload */
-	if (features & (NETIF_F_HW_VLAN_TX|NETIF_F_HW_VLAN_RX))
+	if (features & (NETIF_F_HW_VLAN_CTAG_TX|NETIF_F_HW_VLAN_CTAG_RX))
 		features |= NETIF_F_RXCSUM;
 
 	return features;
@@ -4828,12 +4828,12 @@ static void nv_vlan_mode(struct net_device *dev, netdev_features_t features)
 
 	spin_lock_irq(&np->lock);
 
-	if (features & NETIF_F_HW_VLAN_RX)
+	if (features & NETIF_F_HW_VLAN_CTAG_RX)
 		np->txrxctl_bits |= NVREG_TXRXCTL_VLANSTRIP;
 	else
 		np->txrxctl_bits &= ~NVREG_TXRXCTL_VLANSTRIP;
 
-	if (features & NETIF_F_HW_VLAN_TX)
+	if (features & NETIF_F_HW_VLAN_CTAG_TX)
 		np->txrxctl_bits |= NVREG_TXRXCTL_VLANINS;
 	else
 		np->txrxctl_bits &= ~NVREG_TXRXCTL_VLANINS;
@@ -4870,7 +4870,7 @@ static int nv_set_features(struct net_device *dev, netdev_features_t features)
 		spin_unlock_irq(&np->lock);
 	}
 
-	if (changed & (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX))
+	if (changed & (NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX))
 		nv_vlan_mode(dev, features);
 
 	return 0;
@@ -5705,7 +5705,8 @@ static int nv_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
 	np->vlanctl_bits = 0;
 	if (id->driver_data & DEV_HAS_VLAN) {
 		np->vlanctl_bits = NVREG_VLANCONTROL_ENABLE;
-		dev->hw_features |= NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX;
+		dev->hw_features |= NETIF_F_HW_VLAN_CTAG_RX |
+				    NETIF_F_HW_VLAN_CTAG_TX;
 	}
 
 	dev->features |= dev->hw_features;
@@ -5996,7 +5997,8 @@ static int nv_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
 		 dev->features & NETIF_F_HIGHDMA ? "highdma " : "",
 		 dev->features & (NETIF_F_IP_CSUM | NETIF_F_SG) ?
 			"csum " : "",
-		 dev->features & (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX) ?
+		 dev->features & (NETIF_F_HW_VLAN_CTAG_RX |
+			 	  NETIF_F_HW_VLAN_CTAG_TX) ?
 			"vlan " : "",
 		 dev->features & (NETIF_F_LOOPBACK) ?
 			"loopback " : "",
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 7867aeb..af951f3 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -1345,7 +1345,7 @@ netxen_setup_netdev(struct netxen_adapter *adapter,
 	}
 
 	if (adapter->capabilities & NX_FW_CAPABILITY_FVLANTX)
-		netdev->hw_features |= NETIF_F_HW_VLAN_TX;
+		netdev->hw_features |= NETIF_F_HW_VLAN_CTAG_TX;
 
 	if (adapter->capabilities & NX_FW_CAPABILITY_HW_LRO)
 		netdev->hw_features |= NETIF_F_LRO;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 0d00b2b..845ba1d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1714,7 +1714,7 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter, struct net_device *netdev,
 
 	netdev->features |= (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
 			     NETIF_F_IPV6_CSUM | NETIF_F_GRO |
-			     NETIF_F_HW_VLAN_RX);
+			     NETIF_F_HW_VLAN_CTAG_RX);
 	netdev->vlan_features |= (NETIF_F_SG | NETIF_F_IP_CSUM |
 				  NETIF_F_IPV6_CSUM);
 
@@ -1729,7 +1729,7 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter, struct net_device *netdev,
 	}
 
 	if (qlcnic_vlan_tx_check(adapter))
-		netdev->features |= (NETIF_F_HW_VLAN_TX);
+		netdev->features |= (NETIF_F_HW_VLAN_CTAG_TX);
 
 	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO)
 		netdev->features |= NETIF_F_LRO;
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 1dd778a..8e3f43c 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -409,7 +409,7 @@ static int ql_set_mac_addr_reg(struct ql_adapter *qdev, u8 *addr, u32 type,
 				      (qdev->
 				       func << CAM_OUT_FUNC_SHIFT) |
 					(0 << CAM_OUT_CQ_ID_SHIFT));
-			if (qdev->ndev->features & NETIF_F_HW_VLAN_RX)
+			if (qdev->ndev->features & NETIF_F_HW_VLAN_CTAG_RX)
 				cam_output |= CAM_OUT_RV;
 			/* route to NIC core */
 			ql_write32(qdev, MAC_ADDR_DATA, cam_output);
@@ -2279,7 +2279,7 @@ static void qlge_vlan_mode(struct net_device *ndev, netdev_features_t features)
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
 
-	if (features & NETIF_F_HW_VLAN_RX) {
+	if (features & NETIF_F_HW_VLAN_CTAG_RX) {
 		ql_write32(qdev, NIC_RCV_CFG, NIC_RCV_CFG_VLAN_MASK |
 				 NIC_RCV_CFG_VLAN_MATCH_AND_NON);
 	} else {
@@ -2294,10 +2294,10 @@ static netdev_features_t qlge_fix_features(struct net_device *ndev,
 	 * Since there is no support for separate rx/tx vlan accel
 	 * enable/disable make sure tx flag is always in same state as rx.
 	 */
-	if (features & NETIF_F_HW_VLAN_RX)
-		features |= NETIF_F_HW_VLAN_TX;
+	if (features & NETIF_F_HW_VLAN_CTAG_RX)
+		features |= NETIF_F_HW_VLAN_CTAG_TX;
 	else
-		features &= ~NETIF_F_HW_VLAN_TX;
+		features &= ~NETIF_F_HW_VLAN_CTAG_TX;
 
 	return features;
 }
@@ -2307,7 +2307,7 @@ static int qlge_set_features(struct net_device *ndev,
 {
 	netdev_features_t changed = ndev->features ^ features;
 
-	if (changed & NETIF_F_HW_VLAN_RX)
+	if (changed & NETIF_F_HW_VLAN_CTAG_RX)
 		qlge_vlan_mode(ndev, features);
 
 	return 0;
@@ -4665,9 +4665,9 @@ static int qlge_probe(struct pci_dev *pdev,
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 	ndev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM |
 		NETIF_F_TSO | NETIF_F_TSO_ECN |
-		NETIF_F_HW_VLAN_TX | NETIF_F_RXCSUM;
+		NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_RXCSUM;
 	ndev->features = ndev->hw_features |
-		NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
+		NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_HW_VLAN_CTAG_FILTER;
 	ndev->vlan_features = ndev->hw_features;
 
 	if (test_bit(QL_DMA64, &qdev->flags))
diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index b62a324..6d03b52 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -1438,7 +1438,7 @@ static int cp_set_features(struct net_device *dev, netdev_features_t features)
 	else
 		cp->cpcmd &= ~RxChkSum;
 
-	if (features & NETIF_F_HW_VLAN_RX)
+	if (features & NETIF_F_HW_VLAN_CTAG_RX)
 		cp->cpcmd |= RxVlanOn;
 	else
 		cp->cpcmd &= ~RxVlanOn;
@@ -1955,14 +1955,14 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->ethtool_ops = &cp_ethtool_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
-	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+	dev->features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
 
 	if (pci_using_dac)
 		dev->features |= NETIF_F_HIGHDMA;
 
 	/* disabled by default until verified */
 	dev->hw_features |= NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
-		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+		NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
 	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
 		NETIF_F_HIGHDMA;
 
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 9a1bc1a..86d5d79 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1793,16 +1793,17 @@ static void __rtl8169_set_features(struct net_device *dev,
 	netdev_features_t changed = features ^ dev->features;
 	void __iomem *ioaddr = tp->mmio_addr;
 
-	if (!(changed & (NETIF_F_RXALL | NETIF_F_RXCSUM | NETIF_F_HW_VLAN_RX)))
+	if (!(changed & (NETIF_F_RXALL | NETIF_F_RXCSUM |
+			 NETIF_F_HW_VLAN_CTAG_RX)))
 		return;
 
-	if (changed & (NETIF_F_RXCSUM | NETIF_F_HW_VLAN_RX)) {
+	if (changed & (NETIF_F_RXCSUM | NETIF_F_HW_VLAN_CTAG_RX)) {
 		if (features & NETIF_F_RXCSUM)
 			tp->cp_cmd |= RxChkSum;
 		else
 			tp->cp_cmd &= ~RxChkSum;
 
-		if (dev->features & NETIF_F_HW_VLAN_RX)
+		if (dev->features & NETIF_F_HW_VLAN_CTAG_RX)
 			tp->cp_cmd |= RxVlan;
 		else
 			tp->cp_cmd &= ~RxVlan;
@@ -7036,16 +7037,17 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* don't enable SG, IP_CSUM and TSO by default - it might not work
 	 * properly for all devices */
 	dev->features |= NETIF_F_RXCSUM |
-		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+		NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
 
 	dev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
-		NETIF_F_RXCSUM | NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+		NETIF_F_RXCSUM | NETIF_F_HW_VLAN_CTAG_TX |
+		NETIF_F_HW_VLAN_CTAG_RX;
 	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
 		NETIF_F_HIGHDMA;
 
 	if (tp->mac_version == RTL_GIGA_MAC_VER_05)
 		/* 8110SCd requires hardware Rx VLAN - disallow toggling */
-		dev->hw_features &= ~NETIF_F_HW_VLAN_RX;
+		dev->hw_features &= ~NETIF_F_HW_VLAN_CTAG_RX;
 
 	dev->hw_features |= NETIF_F_RXALL;
 	dev->hw_features |= NETIF_F_RXFCS;
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index a7499cb..3d4a1ed 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2749,7 +2749,7 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 			goto out_release;
 		}
 		mdp->port = devno % 2;
-		ndev->features = NETIF_F_HW_VLAN_FILTER;
+		ndev->features = NETIF_F_HW_VLAN_CTAG_FILTER;
 	}
 
 	/* initialize first or needed device */
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 71b6485..618446a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2679,7 +2679,7 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 	ndev->watchdog_timeo = msecs_to_jiffies(watchdog);
 #ifdef STMMAC_VLAN_TAG_USED
 	/* Both mac100 and gmac support receive VLAN tag detection */
-	ndev->features |= NETIF_F_HW_VLAN_RX;
+	ndev->features |= NETIF_F_HW_VLAN_CTAG_RX;
 #endif
 	priv->msg_enable = netif_msg_init(debug, default_msg_level);
 
diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index e8824ce..5ca4b33 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -2017,12 +2017,12 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		 * so we can have them same for all ports of the board */
 		ndev->if_port = port;
 		ndev->features = NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO
-		    | NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
-		    NETIF_F_HW_VLAN_FILTER | NETIF_F_RXCSUM
+		    | NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX |
+		    NETIF_F_HW_VLAN_CTAG_FILTER | NETIF_F_RXCSUM
 		    /*| NETIF_F_FRAGLIST */
 		    ;
 		ndev->hw_features = NETIF_F_IP_CSUM | NETIF_F_SG |
-			NETIF_F_TSO | NETIF_F_HW_VLAN_TX;
+			NETIF_F_TSO | NETIF_F_HW_VLAN_CTAG_TX;
 
 		if (pci_using_dac)
 			ndev->features |= NETIF_F_HIGHDMA;
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 1d74042..0849929 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1599,7 +1599,7 @@ static int cpsw_probe_dual_emac(struct platform_device *pdev,
 		priv_sl2->num_irqs = priv->num_irqs;
 	}
 
-	ndev->features |= NETIF_F_HW_VLAN_FILTER;
+	ndev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	ndev->netdev_ops = &cpsw_netdev_ops;
 	SET_ETHTOOL_OPS(ndev, &cpsw_ethtool_ops);
@@ -1837,7 +1837,7 @@ static int cpsw_probe(struct platform_device *pdev)
 		k++;
 	}
 
-	ndev->features |= NETIF_F_HW_VLAN_FILTER;
+	ndev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	ndev->netdev_ops = &cpsw_netdev_ops;
 	SET_ETHTOOL_OPS(ndev, &cpsw_ethtool_ops);
diff --git a/drivers/net/ethernet/toshiba/spider_net.c b/drivers/net/ethernet/toshiba/spider_net.c
index fef6b59..c655fe6 100644
--- a/drivers/net/ethernet/toshiba/spider_net.c
+++ b/drivers/net/ethernet/toshiba/spider_net.c
@@ -2329,8 +2329,8 @@ spider_net_setup_netdev(struct spider_net_card *card)
 	if (SPIDER_NET_RX_CSUM_DEFAULT)
 		netdev->features |= NETIF_F_RXCSUM;
 	netdev->features |= NETIF_F_IP_CSUM | NETIF_F_LLTX;
-	/* some time: NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
-	 *		NETIF_F_HW_VLAN_FILTER */
+	/* some time: NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX |
+	 *		NETIF_F_HW_VLAN_CTAG_FILTER */
 
 	netdev->irq = card->pdev->irq;
 	card->num_rx_ints = 0;
diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 185c721..8c0f407 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -1026,8 +1026,9 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev->features |= NETIF_F_SG|NETIF_F_HW_CSUM;
 
 	if (pdev->revision >= VT6105M)
-		dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
-		NETIF_F_HW_VLAN_FILTER;
+		dev->features |= NETIF_F_HW_VLAN_CTAG_TX | 
+				 NETIF_F_HW_VLAN_CTAG_RX |
+				 NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	/* dev->name not defined before register_netdev()! */
 	rc = register_netdev(dev);
diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index 1bc7f9fd..c1c55a7 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -2810,9 +2810,10 @@ static int velocity_found1(struct pci_dev *pdev,
 	dev->ethtool_ops = &velocity_ethtool_ops;
 	netif_napi_add(dev, &vptr->napi, velocity_poll, VELOCITY_NAPI_WEIGHT);
 
-	dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_HW_VLAN_TX;
-	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER |
-		NETIF_F_HW_VLAN_RX | NETIF_F_IP_CSUM;
+	dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_SG |
+			   NETIF_F_HW_VLAN_CTAG_TX;
+	dev->features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_FILTER |
+			 NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_IP_CSUM;
 
 	ret = register_netdev(dev);
 	if (ret < 0)
diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 4a7c60f..57c2e5e 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -1018,9 +1018,9 @@ static int temac_of_probe(struct platform_device *op)
 	ndev->features |= NETIF_F_HW_CSUM; /* Can checksum all the packets. */
 	ndev->features |= NETIF_F_IPV6_CSUM; /* Can checksum IPV6 TCP/UDP */
 	ndev->features |= NETIF_F_HIGHDMA; /* Can DMA to high memory. */
-	ndev->features |= NETIF_F_HW_VLAN_TX; /* Transmit VLAN hw accel */
-	ndev->features |= NETIF_F_HW_VLAN_RX; /* Receive VLAN hw acceleration */
-	ndev->features |= NETIF_F_HW_VLAN_FILTER; /* Receive VLAN filtering */
+	ndev->features |= NETIF_F_HW_VLAN_CTAG_TX; /* Transmit VLAN hw accel */
+	ndev->features |= NETIF_F_HW_VLAN_CTAG_RX; /* Receive VLAN hw acceleration */
+	ndev->features |= NETIF_F_HW_VLAN_CTAG_FILTER; /* Receive VLAN filtering */
 	ndev->features |= NETIF_F_VLAN_CHALLENGED; /* cannot handle VLAN pkts */
 	ndev->features |= NETIF_F_GSO; /* Enable software GSO. */
 	ndev->features |= NETIF_F_MULTI_QUEUE; /* Has multiple TX/RX queues */
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 5f85205..4559bb8 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -431,7 +431,7 @@ static int netvsc_probe(struct hv_device *dev,
 
 	/* TODO: Add GSO and Checksum offload */
 	net->hw_features = NETIF_F_SG;
-	net->features = NETIF_F_SG | NETIF_F_HW_VLAN_TX;
+	net->features = NETIF_F_SG | NETIF_F_HW_VLAN_CTAG_TX;
 
 	SET_ETHTOOL_OPS(net, &ethtool_ops);
 	SET_NETDEV_DEV(net, &dev->device);
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 8216438..724ce7a 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -166,7 +166,7 @@ static const struct net_device_ops ifb_netdev_ops = {
 
 #define IFB_FEATURES (NETIF_F_HW_CSUM | NETIF_F_SG  | NETIF_F_FRAGLIST	| \
 		      NETIF_F_TSO_ECN | NETIF_F_TSO | NETIF_F_TSO6	| \
-		      NETIF_F_HIGHDMA | NETIF_F_HW_VLAN_TX)
+		      NETIF_F_HIGHDMA | NETIF_F_HW_VLAN_CTAG_TX)
 
 static void ifb_setup(struct net_device *dev)
 {
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 70af6dc..fedd34c 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -471,7 +471,7 @@ static struct lock_class_key macvlan_netdev_addr_lock_key;
 	(NETIF_F_SG | NETIF_F_ALL_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST | \
 	 NETIF_F_GSO | NETIF_F_TSO | NETIF_F_UFO | NETIF_F_GSO_ROBUST | \
 	 NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_GRO | NETIF_F_RXCSUM | \
-	 NETIF_F_HW_VLAN_FILTER)
+	 NETIF_F_HW_VLAN_CTAG_FILTER)
 
 #define MACVLAN_STATE_MASK \
 	((1<<__LINK_STATE_NOCARRIER) | (1<<__LINK_STATE_DORMANT))
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 9a31e8e..9290eb23d 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1841,9 +1841,9 @@ static void team_setup(struct net_device *dev)
 	dev->features |= NETIF_F_LLTX;
 	dev->features |= NETIF_F_GRO;
 	dev->hw_features = TEAM_VLAN_FEATURES |
-			   NETIF_F_HW_VLAN_TX |
-			   NETIF_F_HW_VLAN_RX |
-			   NETIF_F_HW_VLAN_FILTER;
+			   NETIF_F_HW_VLAN_CTAG_TX |
+			   NETIF_F_HW_VLAN_CTAG_RX |
+			   NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	dev->hw_features &= ~(NETIF_F_ALL_CSUM & ~NETIF_F_HW_CSUM);
 	dev->features |= dev->hw_features;
diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index 16c8429..b7e9cd7 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -101,7 +101,7 @@ static int cdc_mbim_bind(struct usbnet *dev, struct usb_interface *intf)
 	dev->net->flags |= IFF_NOARP;
 
 	/* no need to put the VLAN tci in the packet headers */
-	dev->net->features |= NETIF_F_HW_VLAN_TX;
+	dev->net->features |= NETIF_F_HW_VLAN_CTAG_TX;
 err:
 	return ret;
 }
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 07a4af0..f116c59 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -255,7 +255,7 @@ static const struct net_device_ops veth_netdev_ops = {
 
 #define VETH_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_ALL_TSO |    \
 		       NETIF_F_HW_CSUM | NETIF_F_RXCSUM | NETIF_F_HIGHDMA | \
-		       NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX)
+		       NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX)
 
 static void veth_setup(struct net_device *dev)
 {
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 8fdfde6..b61d57a 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1376,7 +1376,7 @@ static int virtnet_find_vqs(struct virtnet_info *vi)
 	if (vi->has_cvq) {
 		vi->cvq = vqs[total_vqs - 1];
 		if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VLAN))
-			vi->dev->features |= NETIF_F_HW_VLAN_FILTER;
+			vi->dev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 	}
 
 	for (i = 0; i < vi->max_queue_pairs; i++) {
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index eae7a03..ba9bdad 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2107,7 +2107,7 @@ vmxnet3_setup_driver_shared(struct vmxnet3_adapter *adapter)
 		devRead->misc.uptFeatures |= UPT1_F_LRO;
 		devRead->misc.maxNumRxSG = cpu_to_le16(1 + MAX_SKB_FRAGS);
 	}
-	if (adapter->netdev->features & NETIF_F_HW_VLAN_RX)
+	if (adapter->netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
 		devRead->misc.uptFeatures |= UPT1_F_RXVLAN;
 
 	devRead->misc.mtu = cpu_to_le32(adapter->netdev->mtu);
@@ -2669,14 +2669,15 @@ vmxnet3_declare_features(struct vmxnet3_adapter *adapter, bool dma64)
 	struct net_device *netdev = adapter->netdev;
 
 	netdev->hw_features = NETIF_F_SG | NETIF_F_RXCSUM |
-		NETIF_F_HW_CSUM | NETIF_F_HW_VLAN_TX |
-		NETIF_F_HW_VLAN_RX | NETIF_F_TSO | NETIF_F_TSO6 |
+		NETIF_F_HW_CSUM | NETIF_F_HW_VLAN_CTAG_TX |
+		NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_TSO | NETIF_F_TSO6 |
 		NETIF_F_LRO;
 	if (dma64)
 		netdev->hw_features |= NETIF_F_HIGHDMA;
 	netdev->vlan_features = netdev->hw_features &
-				~(NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
-	netdev->features = netdev->hw_features | NETIF_F_HW_VLAN_FILTER;
+				~(NETIF_F_HW_VLAN_CTAG_TX |
+				  NETIF_F_HW_VLAN_CTAG_RX);
+	netdev->features = netdev->hw_features | NETIF_F_HW_VLAN_CTAG_FILTER;
 }
 
 
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index 63a1243..600ab56 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -263,7 +263,8 @@ int vmxnet3_set_features(struct net_device *netdev, netdev_features_t features)
 	unsigned long flags;
 	netdev_features_t changed = features ^ netdev->features;
 
-	if (changed & (NETIF_F_RXCSUM | NETIF_F_LRO | NETIF_F_HW_VLAN_RX)) {
+	if (changed & (NETIF_F_RXCSUM | NETIF_F_LRO |
+		       NETIF_F_HW_VLAN_CTAG_RX)) {
 		if (features & NETIF_F_RXCSUM)
 			adapter->shared->devRead.misc.uptFeatures |=
 			UPT1_F_RXCSUM;
@@ -279,7 +280,7 @@ int vmxnet3_set_features(struct net_device *netdev, netdev_features_t features)
 			adapter->shared->devRead.misc.uptFeatures &=
 							~UPT1_F_LRO;
 
-		if (features & NETIF_F_HW_VLAN_RX)
+		if (features & NETIF_F_HW_VLAN_CTAG_RX)
 			adapter->shared->devRead.misc.uptFeatures |=
 			UPT1_F_RXVLAN;
 		else
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index d690166..90ddd82 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -959,7 +959,7 @@ static int qeth_l2_setup_netdev(struct qeth_card *card)
 		SET_ETHTOOL_OPS(card->dev, &qeth_l2_ethtool_ops);
 	else
 		SET_ETHTOOL_OPS(card->dev, &qeth_l2_osn_ops);
-	card->dev->features |= NETIF_F_HW_VLAN_FILTER;
+	card->dev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 	card->info.broadcast_capable = 1;
 	qeth_l2_request_initial_mac(card);
 	SET_NETDEV_DEV(card->dev, &card->gdev->dev);
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 8710337..04261bc 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3294,9 +3294,9 @@ static int qeth_l3_setup_netdev(struct qeth_card *card)
 	card->dev->watchdog_timeo = QETH_TX_TIMEOUT;
 	card->dev->mtu = card->info.initial_mtu;
 	SET_ETHTOOL_OPS(card->dev, &qeth_l3_ethtool_ops);
-	card->dev->features |=	NETIF_F_HW_VLAN_TX |
-				NETIF_F_HW_VLAN_RX |
-				NETIF_F_HW_VLAN_FILTER;
+	card->dev->features |=	NETIF_F_HW_VLAN_CTAG_TX |
+				NETIF_F_HW_VLAN_CTAG_RX |
+				NETIF_F_HW_VLAN_CTAG_FILTER;
 	card->dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
 	card->dev->gso_max_size = 15 * PAGE_SIZE;
 
diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index 9bfdc9a..292b24f 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -1655,7 +1655,7 @@ static int fcoe_xmit(struct fc_lport *lport, struct fc_frame *fp)
 	skb->priority = fcoe->priority;
 
 	if (fcoe->netdev->priv_flags & IFF_802_1Q_VLAN &&
-	    fcoe->realdev->features & NETIF_F_HW_VLAN_TX) {
+	    fcoe->realdev->features & NETIF_F_HW_VLAN_CTAG_TX) {
 		skb->vlan_tci = VLAN_TAG_PRESENT |
 				vlan_dev_vlan_id(fcoe->netdev);
 		skb->dev = fcoe->realdev;
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 70962f3..fee2829 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -238,7 +238,7 @@ static inline struct sk_buff *__vlan_hwaccel_put_tag(struct sk_buff *skb,
  */
 static inline struct sk_buff *vlan_put_tag(struct sk_buff *skb, u16 vlan_tci)
 {
-	if (skb->dev->features & NETIF_F_HW_VLAN_TX) {
+	if (skb->dev->features & NETIF_F_HW_VLAN_CTAG_TX) {
 		return __vlan_hwaccel_put_tag(skb, vlan_tci);
 	} else {
 		return __vlan_put_tag(skb, vlan_tci);
@@ -294,7 +294,7 @@ static inline int __vlan_hwaccel_get_tag(const struct sk_buff *skb,
  */
 static inline int vlan_get_tag(const struct sk_buff *skb, u16 *vlan_tci)
 {
-	if (skb->dev->features & NETIF_F_HW_VLAN_TX) {
+	if (skb->dev->features & NETIF_F_HW_VLAN_CTAG_TX) {
 		return __vlan_hwaccel_get_tag(skb, vlan_tci);
 	} else {
 		return __vlan_get_tag(skb, vlan_tci);
diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index d6ee2d0..785913b 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -22,9 +22,9 @@ enum {
 	NETIF_F_IPV6_CSUM_BIT,		/* Can checksum TCP/UDP over IPV6 */
 	NETIF_F_HIGHDMA_BIT,		/* Can DMA to high memory. */
 	NETIF_F_FRAGLIST_BIT,		/* Scatter/gather IO. */
-	NETIF_F_HW_VLAN_TX_BIT,		/* Transmit VLAN hw acceleration */
-	NETIF_F_HW_VLAN_RX_BIT,		/* Receive VLAN hw acceleration */
-	NETIF_F_HW_VLAN_FILTER_BIT,	/* Receive filtering on VLAN */
+	NETIF_F_HW_VLAN_CTAG_TX_BIT,	/* Transmit VLAN CTAG HW acceleration */
+	NETIF_F_HW_VLAN_CTAG_RX_BIT,	/* Receive VLAN CTAG HW acceleration */
+	NETIF_F_HW_VLAN_CTAG_FILTER_BIT,/* Receive filtering on VLAN CTAGs */
 	NETIF_F_VLAN_CHALLENGED_BIT,	/* Device cannot handle VLAN packets */
 	NETIF_F_GSO_BIT,		/* Enable software GSO. */
 	NETIF_F_LLTX_BIT,		/* LockLess TX - deprecated. Please */
@@ -80,9 +80,9 @@ enum {
 #define NETIF_F_GSO_ROBUST	__NETIF_F(GSO_ROBUST)
 #define NETIF_F_HIGHDMA		__NETIF_F(HIGHDMA)
 #define NETIF_F_HW_CSUM		__NETIF_F(HW_CSUM)
-#define NETIF_F_HW_VLAN_FILTER	__NETIF_F(HW_VLAN_FILTER)
-#define NETIF_F_HW_VLAN_RX	__NETIF_F(HW_VLAN_RX)
-#define NETIF_F_HW_VLAN_TX	__NETIF_F(HW_VLAN_TX)
+#define NETIF_F_HW_VLAN_CTAG_FILTER __NETIF_F(HW_VLAN_CTAG_FILTER)
+#define NETIF_F_HW_VLAN_CTAG_RX	__NETIF_F(HW_VLAN_CTAG_RX)
+#define NETIF_F_HW_VLAN_CTAG_TX	__NETIF_F(HW_VLAN_CTAG_TX)
 #define NETIF_F_IP_CSUM		__NETIF_F(IP_CSUM)
 #define NETIF_F_IPV6_CSUM	__NETIF_F(IPV6_CSUM)
 #define NETIF_F_LLTX		__NETIF_F(LLTX)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 623b57b..7eb7e03 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -785,11 +785,13 @@ struct netdev_fcoe_hbainfo {
  *	   neither operation.
  *
  * int (*ndo_vlan_rx_add_vid)(struct net_device *dev, unsigned short vid);
- *	If device support VLAN filtering (dev->features & NETIF_F_HW_VLAN_FILTER)
+ *	If device support VLAN filtering (dev->features &
+		 *			  NETIF_F_HW_VLAN_CTAG_FILTER)
  *	this function is called when a VLAN id is registered.
  *
  * int (*ndo_vlan_rx_kill_vid)(struct net_device *dev, unsigned short vid);
- *	If device support VLAN filtering (dev->features & NETIF_F_HW_VLAN_FILTER)
+ *	If device support VLAN filtering (dev->features &
+		 *			  NETIF_F_HW_VLAN_CTAG_FILTER)
  *	this function is called when a VLAN id is unregistered.
  *
  * void (*ndo_poll_controller)(struct net_device *dev);
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 85addcd..d913fee 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -301,7 +301,7 @@ static void vlan_transfer_features(struct net_device *dev,
 {
 	vlandev->gso_max_size = dev->gso_max_size;
 
-	if (dev->features & NETIF_F_HW_VLAN_TX)
+	if (dev->features & NETIF_F_HW_VLAN_CTAG_TX)
 		vlandev->hard_header_len = dev->hard_header_len;
 	else
 		vlandev->hard_header_len = dev->hard_header_len + VLAN_HLEN;
@@ -347,7 +347,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		__vlan_device_event(dev, event);
 
 	if ((event == NETDEV_UP) &&
-	    (dev->features & NETIF_F_HW_VLAN_FILTER)) {
+	    (dev->features & NETIF_F_HW_VLAN_CTAG_FILTER)) {
 		pr_info("adding VLAN 0 to HW filter on device %s\n",
 			dev->name);
 		vlan_vid_add(dev, 0);
@@ -415,7 +415,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		break;
 
 	case NETDEV_DOWN:
-		if (dev->features & NETIF_F_HW_VLAN_FILTER)
+		if (dev->features & NETIF_F_HW_VLAN_CTAG_FILTER)
 			vlan_vid_del(dev, 0);
 
 		/* Put all VLANs for this dev in the down state too.  */
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index f3b6f51..3df29d3 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -225,7 +225,7 @@ static int __vlan_vid_add(struct vlan_info *vlan_info, unsigned short vid,
 	if (!vid_info)
 		return -ENOMEM;
 
-	if (dev->features & NETIF_F_HW_VLAN_FILTER) {
+	if (dev->features & NETIF_F_HW_VLAN_CTAG_FILTER) {
 		err =  ops->ndo_vlan_rx_add_vid(dev, vid);
 		if (err) {
 			kfree(vid_info);
@@ -282,7 +282,7 @@ static void __vlan_vid_del(struct vlan_info *vlan_info,
 	unsigned short vid = vid_info->vid;
 	int err;
 
-	if (dev->features & NETIF_F_HW_VLAN_FILTER) {
+	if (dev->features & NETIF_F_HW_VLAN_CTAG_FILTER) {
 		err = ops->ndo_vlan_rx_kill_vid(dev, vid);
 		if (err) {
 			pr_warn("failed to kill vid %d for device %s\n",
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 19cf81b..5c4892a 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -583,7 +583,7 @@ static int vlan_dev_init(struct net_device *dev)
 #endif
 
 	dev->needed_headroom = real_dev->needed_headroom;
-	if (real_dev->features & NETIF_F_HW_VLAN_TX) {
+	if (real_dev->features & NETIF_F_HW_VLAN_CTAG_TX) {
 		dev->header_ops      = real_dev->header_ops;
 		dev->hard_header_len = real_dev->hard_header_len;
 	} else {
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 314c73e..9673128 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -348,10 +348,10 @@ void br_dev_setup(struct net_device *dev)
 
 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
 			NETIF_F_GSO_MASK | NETIF_F_HW_CSUM | NETIF_F_LLTX |
-			NETIF_F_NETNS_LOCAL | NETIF_F_HW_VLAN_TX;
+			NETIF_F_NETNS_LOCAL | NETIF_F_HW_VLAN_CTAG_TX;
 	dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
 			   NETIF_F_GSO_MASK | NETIF_F_HW_CSUM |
-			   NETIF_F_HW_VLAN_TX;
+			   NETIF_F_HW_VLAN_CTAG_TX;
 
 	br->dev = dev;
 	spin_lock_init(&br->lock);
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 93dde75..0b3dbbe 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -54,7 +54,7 @@ static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 			dev = br->dev;
 		}
 
-		if (p && (dev->features & NETIF_F_HW_VLAN_FILTER)) {
+		if (p && (dev->features & NETIF_F_HW_VLAN_CTAG_FILTER)) {
 			/* Add VLAN to the device filter if it is supported.
 			 * Stricly speaking, this is not necessary now, since
 			 * devices are made promiscuous by the bridge, but if
@@ -82,7 +82,7 @@ static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 	return 0;
 
 out_filt:
-	if (p && (dev->features & NETIF_F_HW_VLAN_FILTER))
+	if (p && (dev->features & NETIF_F_HW_VLAN_CTAG_FILTER))
 		dev->netdev_ops->ndo_vlan_rx_kill_vid(dev, vid);
 	return err;
 }
@@ -98,7 +98,7 @@ static int __vlan_del(struct net_port_vlans *v, u16 vid)
 	if (v->port_idx && vid) {
 		struct net_device *dev = v->parent.port->dev;
 
-		if (dev->features & NETIF_F_HW_VLAN_FILTER)
+		if (dev->features & NETIF_F_HW_VLAN_CTAG_FILTER)
 			dev->netdev_ops->ndo_vlan_rx_kill_vid(dev, vid);
 	}
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 3655ff9..07a8e9d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2435,13 +2435,13 @@ netdev_features_t netif_skb_features(struct sk_buff *skb)
 		return harmonize_features(skb, protocol, features);
 	}
 
-	features &= (skb->dev->vlan_features | NETIF_F_HW_VLAN_TX);
+	features &= (skb->dev->vlan_features | NETIF_F_HW_VLAN_CTAG_TX);
 
 	if (protocol != htons(ETH_P_8021Q)) {
 		return harmonize_features(skb, protocol, features);
 	} else {
 		features &= NETIF_F_SG | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST |
-				NETIF_F_GEN_CSUM | NETIF_F_HW_VLAN_TX;
+				NETIF_F_GEN_CSUM | NETIF_F_HW_VLAN_CTAG_TX;
 		return harmonize_features(skb, protocol, features);
 	}
 }
@@ -2482,7 +2482,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 		features = netif_skb_features(skb);
 
 		if (vlan_tx_tag_present(skb) &&
-		    !(features & NETIF_F_HW_VLAN_TX)) {
+		    !(features & NETIF_F_HW_VLAN_CTAG_TX)) {
 			skb = __vlan_put_tag(skb, vlan_tx_tag_get(skb));
 			if (unlikely(!skb))
 				goto out;
@@ -5180,7 +5180,8 @@ int register_netdevice(struct net_device *dev)
 		}
 	}
 
-	if (((dev->hw_features | dev->features) & NETIF_F_HW_VLAN_FILTER) &&
+	if (((dev->hw_features | dev->features) &
+	     NETIF_F_HW_VLAN_CTAG_FILTER) &&
 	    (!dev->netdev_ops->ndo_vlan_rx_add_vid ||
 	     !dev->netdev_ops->ndo_vlan_rx_kill_vid)) {
 		netdev_WARN(dev, "Buggy VLAN acceleration in driver!\n");
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index adc1351..b87712c 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -60,10 +60,10 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_IPV6_CSUM_BIT] =        "tx-checksum-ipv6",
 	[NETIF_F_HIGHDMA_BIT] =          "highdma",
 	[NETIF_F_FRAGLIST_BIT] =         "tx-scatter-gather-fraglist",
-	[NETIF_F_HW_VLAN_TX_BIT] =       "tx-vlan-hw-insert",
+	[NETIF_F_HW_VLAN_CTAG_TX_BIT] =  "tx-vlan-ctag-hw-insert",
 
-	[NETIF_F_HW_VLAN_RX_BIT] =       "rx-vlan-hw-parse",
-	[NETIF_F_HW_VLAN_FILTER_BIT] =   "rx-vlan-filter",
+	[NETIF_F_HW_VLAN_CTAG_RX_BIT] =  "rx-vlan-ctag-hw-parse",
+	[NETIF_F_HW_VLAN_CTAG_FILTER_BIT] = "rx-vlan-ctag-filter",
 	[NETIF_F_VLAN_CHALLENGED_BIT] =  "vlan-challenged",
 	[NETIF_F_GSO_BIT] =              "tx-generic-segmentation",
 	[NETIF_F_LLTX_BIT] =             "tx-lockless",
@@ -267,18 +267,19 @@ static int ethtool_set_one_feature(struct net_device *dev,
 
 #define ETH_ALL_FLAGS    (ETH_FLAG_LRO | ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN | \
 			  ETH_FLAG_NTUPLE | ETH_FLAG_RXHASH)
-#define ETH_ALL_FEATURES (NETIF_F_LRO | NETIF_F_HW_VLAN_RX | \
-			  NETIF_F_HW_VLAN_TX | NETIF_F_NTUPLE | NETIF_F_RXHASH)
+#define ETH_ALL_FEATURES (NETIF_F_LRO | NETIF_F_HW_VLAN_CTAG_RX | \
+			  NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_NTUPLE | \
+			  NETIF_F_RXHASH)
 
 static u32 __ethtool_get_flags(struct net_device *dev)
 {
 	u32 flags = 0;
 
-	if (dev->features & NETIF_F_LRO)	flags |= ETH_FLAG_LRO;
-	if (dev->features & NETIF_F_HW_VLAN_RX)	flags |= ETH_FLAG_RXVLAN;
-	if (dev->features & NETIF_F_HW_VLAN_TX)	flags |= ETH_FLAG_TXVLAN;
-	if (dev->features & NETIF_F_NTUPLE)	flags |= ETH_FLAG_NTUPLE;
-	if (dev->features & NETIF_F_RXHASH)	flags |= ETH_FLAG_RXHASH;
+	if (dev->features & NETIF_F_LRO)	     flags |= ETH_FLAG_LRO;
+	if (dev->features & NETIF_F_HW_VLAN_CTAG_RX) flags |= ETH_FLAG_RXVLAN;
+	if (dev->features & NETIF_F_HW_VLAN_CTAG_TX) flags |= ETH_FLAG_TXVLAN;
+	if (dev->features & NETIF_F_NTUPLE)	     flags |= ETH_FLAG_NTUPLE;
+	if (dev->features & NETIF_F_RXHASH)	     flags |= ETH_FLAG_RXHASH;
 
 	return flags;
 }
@@ -291,8 +292,8 @@ static int __ethtool_set_flags(struct net_device *dev, u32 data)
 		return -EINVAL;
 
 	if (data & ETH_FLAG_LRO)	features |= NETIF_F_LRO;
-	if (data & ETH_FLAG_RXVLAN)	features |= NETIF_F_HW_VLAN_RX;
-	if (data & ETH_FLAG_TXVLAN)	features |= NETIF_F_HW_VLAN_TX;
+	if (data & ETH_FLAG_RXVLAN)	features |= NETIF_F_HW_VLAN_CTAG_RX;
+	if (data & ETH_FLAG_TXVLAN)	features |= NETIF_F_HW_VLAN_CTAG_TX;
 	if (data & ETH_FLAG_NTUPLE)	features |= NETIF_F_NTUPLE;
 	if (data & ETH_FLAG_RXHASH)	features |= NETIF_F_RXHASH;
 
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index a3a17ae..8de961e 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -383,7 +383,7 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 			if (__netif_tx_trylock(txq)) {
 				if (!netif_xmit_stopped(txq)) {
 					if (vlan_tx_tag_present(skb) &&
-					    !(netif_skb_features(skb) & NETIF_F_HW_VLAN_TX)) {
+					    !(netif_skb_features(skb) & NETIF_F_HW_VLAN_CTAG_TX)) {
 						skb = __vlan_put_tag(skb, vlan_tx_tag_get(skb));
 						if (unlikely(!skb))
 							break;
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 9604760..73682de 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -137,7 +137,7 @@ static void do_setup(struct net_device *netdev)
 			   NETIF_F_HIGHDMA | NETIF_F_HW_CSUM | NETIF_F_TSO;
 
 	netdev->vlan_features = netdev->features;
-	netdev->features |= NETIF_F_HW_VLAN_TX;
+	netdev->features |= NETIF_F_HW_VLAN_CTAG_TX;
 	netdev->hw_features = netdev->features & ~NETIF_F_LLTX;
 	eth_hw_addr_random(netdev);
 }
-- 
1.8.1.4
