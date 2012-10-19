From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 05/21] drivers: net: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
Date: Thu, 18 Oct 2012 21:14:09 -0700
Message-ID: <dac1ec4bd5eb10ad85a0c17afbed4ea39ac79a0f.1350618010.git.joe@perches.com>
References: <cover.1350618006.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1350618006.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert the old ether_addr tests to eth_addr_<foo>.
Adds api consistency.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/bonding/bond_3ad.c                     |    2 +-
 drivers/net/bonding/bond_alb.c                     |    2 +-
 drivers/net/bonding/bond_main.c                    |    6 +++---
 drivers/net/dummy.c                                |    2 +-
 drivers/net/ethernet/3com/3c59x.c                  |    2 +-
 drivers/net/ethernet/3com/typhoon.c                |    2 +-
 drivers/net/ethernet/8390/etherh.c                 |    2 +-
 drivers/net/ethernet/adi/bfin_mac.c                |    6 +++---
 drivers/net/ethernet/aeroflex/greth.c              |    4 ++--
 drivers/net/ethernet/amd/au1000_eth.c              |    2 +-
 drivers/net/ethernet/amd/depca.c                   |    4 ++--
 drivers/net/ethernet/amd/pcnet32.c                 |    8 ++++----
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.c      |    2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c    |    2 +-
 drivers/net/ethernet/atheros/atl1e/atl1e_hw.c      |    4 ++--
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c    |    2 +-
 drivers/net/ethernet/atheros/atlx/atl1.c           |   10 +++++-----
 drivers/net/ethernet/atheros/atlx/atl2.c           |   14 +++++++-------
 drivers/net/ethernet/atheros/atlx/atlx.c           |    2 +-
 drivers/net/ethernet/broadcom/b44.c                |    4 ++--
 drivers/net/ethernet/broadcom/bnx2.c               |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |    6 +++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |    4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |    6 +++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c     |    2 +-
 drivers/net/ethernet/broadcom/cnic.c               |    2 +-
 drivers/net/ethernet/broadcom/tg3.c                |    6 +++---
 drivers/net/ethernet/brocade/bna/bnad.c            |    6 +++---
 drivers/net/ethernet/cadence/at91_ether.c          |    6 +++---
 drivers/net/ethernet/cadence/macb.c                |    4 ++--
 drivers/net/ethernet/calxeda/xgmac.c               |    6 +++---
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c    |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |    2 +-
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    2 +-
 drivers/net/ethernet/cirrus/ep93xx_eth.c           |    2 +-
 drivers/net/ethernet/cirrus/mac89x0.c              |    2 +-
 drivers/net/ethernet/cisco/enic/enic_dev.c         |    4 ++--
 drivers/net/ethernet/cisco/enic/enic_main.c        |   10 +++++-----
 drivers/net/ethernet/cisco/enic/enic_pp.c          |   10 +++++-----
 drivers/net/ethernet/davicom/dm9000.c              |    6 +++---
 drivers/net/ethernet/dec/ewrk3.c                   |    4 ++--
 drivers/net/ethernet/dec/tulip/de4x5.c             |    4 ++--
 drivers/net/ethernet/dlink/sundance.c              |    2 +-
 drivers/net/ethernet/dnet.c                        |    6 +++---
 drivers/net/ethernet/emulex/benet/be_main.c        |    8 ++++----
 drivers/net/ethernet/ethoc.c                       |    6 +++---
 drivers/net/ethernet/faraday/ftgmac100.c           |    2 +-
 drivers/net/ethernet/faraday/ftmac100.c            |    2 +-
 drivers/net/ethernet/freescale/fec.c               |    8 ++++----
 drivers/net/ethernet/freescale/fec_mpc52xx.c       |    2 +-
 drivers/net/ethernet/freescale/gianfar_ethtool.c   |   12 ++++++------
 drivers/net/ethernet/freescale/ucc_geth.c          |    2 +-
 drivers/net/ethernet/i825xx/ether1.c               |    2 +-
 drivers/net/ethernet/ibm/ehea/ehea_main.c          |    4 ++--
 drivers/net/ethernet/intel/e100.c                  |    4 ++--
 drivers/net/ethernet/intel/e1000/e1000_main.c      |    4 ++--
 drivers/net/ethernet/intel/e1000e/mac.c            |    2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c         |    4 ++--
 drivers/net/ethernet/intel/igb/e1000_mac.c         |    2 +-
 drivers/net/ethernet/intel/igb/igb_main.c          |    8 ++++----
 drivers/net/ethernet/intel/igbvf/netdev.c          |    6 +++---
 drivers/net/ethernet/intel/ixgb/ixgb_hw.c          |    6 +++---
 drivers/net/ethernet/intel/ixgb/ixgb_main.c        |    6 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c      |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   14 +++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     |    6 +++---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |    8 ++++----
 drivers/net/ethernet/lantiq_etop.c                 |    2 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c         |    4 ++--
 drivers/net/ethernet/marvell/pxa168_eth.c          |    2 +-
 drivers/net/ethernet/marvell/skge.c                |    6 +++---
 drivers/net/ethernet/marvell/sky2.c                |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |    2 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    4 ++--
 drivers/net/ethernet/micrel/ks8695net.c            |    6 +++---
 drivers/net/ethernet/micrel/ks8842.c               |    4 ++--
 drivers/net/ethernet/micrel/ks8851.c               |    4 ++--
 drivers/net/ethernet/micrel/ks8851_mll.c           |    2 +-
 drivers/net/ethernet/microchip/enc28j60.c          |    4 ++--
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c   |    2 +-
 drivers/net/ethernet/neterion/s2io.c               |    2 +-
 drivers/net/ethernet/neterion/vxge/vxge-config.c   |    2 +-
 drivers/net/ethernet/neterion/vxge/vxge-main.c     |   12 ++++++------
 drivers/net/ethernet/netx-eth.c                    |    2 +-
 drivers/net/ethernet/nuvoton/w90p910_ether.c       |    4 ++--
 drivers/net/ethernet/nvidia/forcedeth.c            |    4 ++--
 drivers/net/ethernet/nxp/lpc_eth.c                 |    8 ++++----
 drivers/net/ethernet/octeon/octeon_mgmt.c          |    2 +-
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    6 +++---
 drivers/net/ethernet/pasemi/pasemi_mac.c           |    4 ++--
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |    4 ++--
 drivers/net/ethernet/qlogic/qla3xxx.c              |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    4 ++--
 drivers/net/ethernet/qlogic/qlge/qlge_main.c       |    6 +++---
 drivers/net/ethernet/realtek/8139cp.c              |    2 +-
 drivers/net/ethernet/realtek/8139too.c             |    2 +-
 drivers/net/ethernet/realtek/r8169.c               |    2 +-
 drivers/net/ethernet/renesas/sh_eth.c              |    4 ++--
 drivers/net/ethernet/seeq/ether3.c                 |    2 +-
 drivers/net/ethernet/sfc/efx.c                     |    2 +-
 drivers/net/ethernet/sfc/ethtool.c                 |    6 +++---
 drivers/net/ethernet/sfc/siena_sriov.c             |    6 +++---
 drivers/net/ethernet/sis/sis900.c                  |    2 +-
 drivers/net/ethernet/smsc/smc911x.c                |    4 ++--
 drivers/net/ethernet/smsc/smc91x.c                 |    4 ++--
 drivers/net/ethernet/smsc/smsc911x.c               |   10 +++++-----
 drivers/net/ethernet/smsc/smsc9420.c               |    6 +++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |    4 ++--
 drivers/net/ethernet/sun/niu.c                     |    8 ++++----
 drivers/net/ethernet/sun/sungem.c                  |    2 +-
 drivers/net/ethernet/ti/cpsw.c                     |    2 +-
 drivers/net/ethernet/ti/davinci_emac.c             |    6 +++---
 drivers/net/ethernet/tile/tilegx.c                 |    4 ++--
 drivers/net/ethernet/tile/tilepro.c                |    4 ++--
 drivers/net/ethernet/toshiba/ps3_gelic_net.c       |    2 +-
 drivers/net/ethernet/toshiba/ps3_gelic_wireless.c  |    2 +-
 drivers/net/ethernet/toshiba/spider_net.c          |    4 ++--
 drivers/net/ethernet/toshiba/tc35815.c             |    4 ++--
 drivers/net/ethernet/tundra/tsi108_eth.c           |    8 ++++----
 drivers/net/ethernet/via/via-rhine.c               |    2 +-
 drivers/net/ethernet/wiznet/w5100.c                |    6 +++---
 drivers/net/ethernet/wiznet/w5300.c                |    6 +++---
 drivers/net/ethernet/xilinx/ll_temac_main.c        |    2 +-
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c  |    2 +-
 drivers/net/hamradio/bpqether.c                    |    2 +-
 drivers/net/ifb.c                                  |    2 +-
 drivers/net/macvlan.c                              |   16 ++++++++--------
 drivers/net/phy/at803x.c                           |    2 +-
 drivers/net/rionet.c                               |    4 ++--
 drivers/net/team/team.c                            |    4 ++--
 drivers/net/tun.c                                  |    4 ++--
 drivers/net/usb/asix_common.c                      |    2 +-
 drivers/net/usb/dm9601.c                           |    4 ++--
 drivers/net/usb/mcs7830.c                          |    2 +-
 drivers/net/usb/smsc75xx.c                         |    2 +-
 drivers/net/usb/smsc95xx.c                         |    2 +-
 drivers/net/veth.c                                 |    2 +-
 drivers/net/vxlan.c                                |    4 ++--
 drivers/net/wimax/i2400m/driver.c                  |    2 +-
 139 files changed, 294 insertions(+), 294 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index a030e63..8031bfe 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -213,7 +213,7 @@ static inline struct aggregator *__get_next_agg(struct aggregator *aggregator)
  */
 static inline int __agg_has_partner(struct aggregator *agg)
 {
-	return !is_zero_ether_addr(agg->partner_system.mac_addr_value);
+	return !eth_addr_zero(agg->partner_system.mac_addr_value);
 }
 
 /**
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index e15cc11..adc7277 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1651,7 +1651,7 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 	int res;
 	int i;
 
-	if (!is_valid_ether_addr(sa->sa_data)) {
+	if (!eth_addr_valid(sa->sa_data)) {
 		return -EADDRNOTAVAIL;
 	}
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b2530b0..e89330e 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1607,7 +1607,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	/* If this is the first slave, then we need to set the master's hardware
 	 * address to be the same as the slave's. */
-	if (is_zero_ether_addr(bond->dev->dev_addr))
+	if (eth_addr_zero(bond->dev->dev_addr))
 		memcpy(bond->dev->dev_addr, slave_dev->dev_addr,
 		       slave_dev->addr_len);
 
@@ -3928,7 +3928,7 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 	if (bond->params.fail_over_mac == BOND_FOM_ACTIVE)
 		return 0;
 
-	if (!is_valid_ether_addr(sa->sa_data))
+	if (!eth_addr_valid(sa->sa_data))
 		return -EADDRNOTAVAIL;
 
 	/* Can't hold bond->lock with bh disabled here since
@@ -4885,7 +4885,7 @@ static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
 			return -EINVAL;
-		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
+		if (!eth_addr_valid(nla_data(tb[IFLA_ADDRESS])))
 			return -EADDRNOTAVAIL;
 	}
 	return 0;
diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index c260af5..9d6134c 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -133,7 +133,7 @@ static int dummy_validate(struct nlattr *tb[], struct nlattr *data[])
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
 			return -EINVAL;
-		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
+		if (!eth_addr_valid(nla_data(tb[IFLA_ADDRESS])))
 			return -EADDRNOTAVAIL;
 	}
 	return 0;
diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index e463d10..884ee83 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -1299,7 +1299,7 @@ static int __devinit vortex_probe1(struct device *gendev,
 		pr_cont(" %pM", dev->dev_addr);
 	/* Unfortunately an all zero eeprom passes the checksum and this
 	   gets found in the wild in failure cases. Crypto is hard 8) */
-	if (!is_valid_ether_addr(dev->dev_addr)) {
+	if (!eth_addr_valid(dev->dev_addr)) {
 		retval = -EINVAL;
 		pr_err("*** EEPROM MAC address is invalid.\n");
 		goto free_ring;	/* With every pack */
diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index bb9670f..ffe8a93 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -2398,7 +2398,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	*(__be16 *)&dev->dev_addr[0] = htons(le16_to_cpu(xp_resp[0].parm1));
 	*(__be32 *)&dev->dev_addr[2] = htonl(le32_to_cpu(xp_resp[0].parm2));
 
-	if(!is_valid_ether_addr(dev->dev_addr)) {
+	if(!eth_addr_valid(dev->dev_addr)) {
 		err_msg = "Could not obtain valid ethernet address, aborting";
 		goto error_out_reset;
 	}
diff --git a/drivers/net/ethernet/8390/etherh.c b/drivers/net/ethernet/8390/etherh.c
index 8322c54..9a40499 100644
--- a/drivers/net/ethernet/8390/etherh.c
+++ b/drivers/net/ethernet/8390/etherh.c
@@ -463,7 +463,7 @@ etherh_open(struct net_device *dev)
 {
 	struct ei_device *ei_local = netdev_priv(dev);
 
-	if (!is_valid_ether_addr(dev->dev_addr)) {
+	if (!eth_addr_valid(dev->dev_addr)) {
 		printk(KERN_WARNING "%s: invalid ethernet MAC address\n",
 			dev->name);
 		return -EINVAL;
diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index f816426..f672ed6 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -1412,7 +1412,7 @@ static int bfin_mac_open(struct net_device *dev)
 	 * to bring the device up.  The user must specify an
 	 * address using ifconfig eth0 hw ether xx:xx:xx:xx:xx:xx
 	 */
-	if (!is_valid_ether_addr(dev->dev_addr)) {
+	if (!eth_addr_valid(dev->dev_addr)) {
 		netdev_warn(dev, "no valid ethernet hw addr\n");
 		return -EINVAL;
 	}
@@ -1515,9 +1515,9 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 	 * Grab the MAC from the board somehow
 	 * this is done in the arch/blackfin/mach-bfxxx/boards/eth_mac.c
 	 */
-	if (!is_valid_ether_addr(ndev->dev_addr)) {
+	if (!eth_addr_valid(ndev->dev_addr)) {
 		if (bfin_get_ether_addr(ndev->dev_addr) ||
-		     !is_valid_ether_addr(ndev->dev_addr)) {
+		     !eth_addr_valid(ndev->dev_addr)) {
 			/* Still not valid, get a random one */
 			netdev_warn(ndev, "Setting Ethernet MAC to a random one\n");
 			eth_hw_addr_random(ndev);
diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index 9c77c73..216218b 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -1016,7 +1016,7 @@ static int greth_set_mac_add(struct net_device *dev, void *p)
 	greth = netdev_priv(dev);
 	regs = greth->regs;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
@@ -1520,7 +1520,7 @@ static int __devinit greth_of_probe(struct platform_device *ofdev)
 
 	macaddr[5]++;
 
-	if (!is_valid_ether_addr(&dev->dev_addr[0])) {
+	if (!eth_addr_valid(&dev->dev_addr[0])) {
 		if (netif_msg_probe(greth))
 			dev_err(greth->dev, "no valid ethernet address, aborting.\n");
 		err = -EINVAL;
diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index f195acf..c1b302b 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -1138,7 +1138,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 					" PHY search on MAC0\n");
 		aup->phy1_search_mac0 = 1;
 	} else {
-		if (is_valid_ether_addr(pd->mac)) {
+		if (eth_addr_valid(pd->mac)) {
 			memcpy(dev->dev_addr, pd->mac, 6);
 		} else {
 			/* Set a random MAC since no valid provided by platform_data. */
diff --git a/drivers/net/ethernet/amd/depca.c b/drivers/net/ethernet/amd/depca.c
index c771de7..a953092 100644
--- a/drivers/net/ethernet/amd/depca.c
+++ b/drivers/net/ethernet/amd/depca.c
@@ -1008,8 +1008,8 @@ static int depca_rx(struct net_device *dev)
 							i = DEPCA_PKT_STAT_SZ;
 						}
 					}
-					if (is_multicast_ether_addr(buf)) {
-						if (is_broadcast_ether_addr(buf)) {
+					if (eth_addr_multicast(buf)) {
+						if (eth_addr_broadcast(buf)) {
 							lp->pktStats.broadcast++;
 						} else {
 							lp->pktStats.multicast++;
diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index 86b6d8e..28d19d7 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -1679,8 +1679,8 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 		promaddr[i] = inb(ioaddr + i);
 
 	if (memcmp(promaddr, dev->dev_addr, 6) ||
-	    !is_valid_ether_addr(dev->dev_addr)) {
-		if (is_valid_ether_addr(promaddr)) {
+	    !eth_addr_valid(dev->dev_addr)) {
+		if (eth_addr_valid(promaddr)) {
 			if (pcnet32_debug & NETIF_MSG_PROBE) {
 				pr_cont(" warning: CSR address invalid,\n");
 				pr_info("    using instead PROM address of");
@@ -1691,7 +1691,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
 	/* if the ethernet address is not valid, force to 00:00:00:00:00:00 */
-	if (!is_valid_ether_addr(dev->perm_addr))
+	if (!eth_addr_valid(dev->perm_addr))
 		memset(dev->dev_addr, 0, ETH_ALEN);
 
 	if (pcnet32_debug & NETIF_MSG_PROBE) {
@@ -2014,7 +2014,7 @@ static int pcnet32_open(struct net_device *dev)
 
 	spin_lock_irqsave(&lp->lock, flags);
 	/* Check for a valid station address */
-	if (!is_valid_ether_addr(dev->dev_addr)) {
+	if (!eth_addr_valid(dev->dev_addr)) {
 		rc = -EINVAL;
 		goto err_free_irq;
 	}
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
index 21e261f..eb956f4 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
@@ -73,7 +73,7 @@ static bool atl1c_read_current_addr(struct atl1c_hw *hw, u8 *eth_addr)
 	*(u32 *) &eth_addr[2] = htonl(addr[0]);
 	*(u16 *) &eth_addr[0] = htons((u16)addr[1]);
 
-	return is_valid_ether_addr(eth_addr);
+	return eth_addr_valid(eth_addr);
 }
 
 /*
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index d19f82f..362cf5c 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -464,7 +464,7 @@ static int atl1c_set_mac_addr(struct net_device *netdev, void *p)
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	if (netif_running(netdev))
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_hw.c b/drivers/net/ethernet/atheros/atl1e/atl1e_hw.c
index 923063d..419a789 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_hw.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_hw.c
@@ -72,7 +72,7 @@ static int atl1e_get_permanent_address(struct atl1e_hw *hw)
 	u32 twsi_ctrl_data;
 	u8  eth_addr[ETH_ALEN];
 
-	if (is_valid_ether_addr(hw->perm_mac_addr))
+	if (eth_addr_valid(hw->perm_mac_addr))
 		return 0;
 
 	/* init */
@@ -99,7 +99,7 @@ static int atl1e_get_permanent_address(struct atl1e_hw *hw)
 	*(u32 *) &eth_addr[2] = swab32(addr[0]);
 	*(u16 *) &eth_addr[0] = swab16(*(u16 *)&addr[1]);
 
-	if (is_valid_ether_addr(eth_addr)) {
+	if (eth_addr_valid(eth_addr)) {
 		memcpy(hw->perm_mac_addr, eth_addr, ETH_ALEN);
 		return 0;
 	}
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index e213da2..8e4dcae 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -357,7 +357,7 @@ static int atl1e_set_mac_addr(struct net_device *netdev, void *p)
 	struct atl1e_adapter *adapter = netdev_priv(netdev);
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	if (netif_running(netdev))
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 7bae2ad..408bb32 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -440,7 +440,7 @@ static int atl1_get_permanent_address(struct atl1_hw *hw)
 	u8 eth_addr[ETH_ALEN];
 	bool key_valid;
 
-	if (is_valid_ether_addr(hw->perm_mac_addr))
+	if (eth_addr_valid(hw->perm_mac_addr))
 		return 0;
 
 	/* init */
@@ -472,7 +472,7 @@ static int atl1_get_permanent_address(struct atl1_hw *hw)
 
 		*(u32 *) &eth_addr[2] = swab32(addr[0]);
 		*(u16 *) &eth_addr[0] = swab16(*(u16 *) &addr[1]);
-		if (is_valid_ether_addr(eth_addr)) {
+		if (eth_addr_valid(eth_addr)) {
 			memcpy(hw->perm_mac_addr, eth_addr, ETH_ALEN);
 			return 0;
 		}
@@ -505,7 +505,7 @@ static int atl1_get_permanent_address(struct atl1_hw *hw)
 
 	*(u32 *) &eth_addr[2] = swab32(addr[0]);
 	*(u16 *) &eth_addr[0] = swab16(*(u16 *) &addr[1]);
-	if (is_valid_ether_addr(eth_addr)) {
+	if (eth_addr_valid(eth_addr)) {
 		memcpy(hw->perm_mac_addr, eth_addr, ETH_ALEN);
 		return 0;
 	}
@@ -520,7 +520,7 @@ static int atl1_get_permanent_address(struct atl1_hw *hw)
 	addr[1] = ioread16(hw->hw_addr + (REG_MAC_STA_ADDR + 4));
 	*(u32 *) &eth_addr[2] = swab32(addr[0]);
 	*(u16 *) &eth_addr[0] = swab16(*(u16 *) &addr[1]);
-	if (is_valid_ether_addr(eth_addr)) {
+	if (eth_addr_valid(eth_addr)) {
 		memcpy(hw->perm_mac_addr, eth_addr, ETH_ALEN);
 		return 0;
 	}
@@ -3058,7 +3058,7 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	}
 	memcpy(netdev->dev_addr, adapter->hw.mac_addr, netdev->addr_len);
 
-	if (!is_valid_ether_addr(netdev->dev_addr)) {
+	if (!eth_addr_valid(netdev->dev_addr)) {
 		err = -EIO;
 		goto err_common;
 	}
diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
index 623dd86..4da08e2 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -954,7 +954,7 @@ static int atl2_set_mac(struct net_device *netdev, void *p)
 	struct atl2_adapter *adapter = netdev_priv(netdev);
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	if (netif_running(netdev))
@@ -1438,9 +1438,9 @@ static int __devinit atl2_probe(struct pci_dev *pdev,
 #ifdef ETHTOOL_GPERMADDR
 	memcpy(netdev->perm_addr, adapter->hw.mac_addr, netdev->addr_len);
 
-	if (!is_valid_ether_addr(netdev->perm_addr)) {
+	if (!eth_addr_valid(netdev->perm_addr)) {
 #else
-	if (!is_valid_ether_addr(netdev->dev_addr)) {
+	if (!eth_addr_valid(netdev->dev_addr)) {
 #endif
 		err = -EIO;
 		goto err_eeprom;
@@ -2247,7 +2247,7 @@ static int get_permanent_address(struct atl2_hw *hw)
 	u8  EthAddr[ETH_ALEN];
 	bool KeyValid;
 
-	if (is_valid_ether_addr(hw->perm_mac_addr))
+	if (eth_addr_valid(hw->perm_mac_addr))
 		return 0;
 
 	Addr[0] = 0;
@@ -2284,7 +2284,7 @@ static int get_permanent_address(struct atl2_hw *hw)
 		*(u32 *) &EthAddr[2] = LONGSWAP(Addr[0]);
 		*(u16 *) &EthAddr[0] = SHORTSWAP(*(u16 *) &Addr[1]);
 
-		if (is_valid_ether_addr(EthAddr)) {
+		if (eth_addr_valid(EthAddr)) {
 			memcpy(hw->perm_mac_addr, EthAddr, ETH_ALEN);
 			return 0;
 		}
@@ -2319,7 +2319,7 @@ static int get_permanent_address(struct atl2_hw *hw)
 
 	*(u32 *) &EthAddr[2] = LONGSWAP(Addr[0]);
 	*(u16 *) &EthAddr[0] = SHORTSWAP(*(u16 *)&Addr[1]);
-	if (is_valid_ether_addr(EthAddr)) {
+	if (eth_addr_valid(EthAddr)) {
 		memcpy(hw->perm_mac_addr, EthAddr, ETH_ALEN);
 		return 0;
 	}
@@ -2329,7 +2329,7 @@ static int get_permanent_address(struct atl2_hw *hw)
 	*(u32 *) &EthAddr[2] = LONGSWAP(Addr[0]);
 	*(u16 *) &EthAddr[0] = SHORTSWAP(*(u16 *) &Addr[1]);
 
-	if (is_valid_ether_addr(EthAddr)) {
+	if (eth_addr_valid(EthAddr)) {
 		memcpy(hw->perm_mac_addr, EthAddr, ETH_ALEN);
 		return 0;
 	}
diff --git a/drivers/net/ethernet/atheros/atlx/atlx.c b/drivers/net/ethernet/atheros/atlx/atlx.c
index 77ffbc4..9324632 100644
--- a/drivers/net/ethernet/atheros/atlx/atlx.c
+++ b/drivers/net/ethernet/atheros/atlx/atlx.c
@@ -79,7 +79,7 @@ static int atlx_set_mac(struct net_device *netdev, void *p)
 	if (netif_running(netdev))
 		return -EBUSY;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 9786c0e..fcfabc3 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -1357,7 +1357,7 @@ static int b44_set_mac_addr(struct net_device *dev, void *p)
 	if (netif_running(dev))
 		return -EBUSY;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EINVAL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
@@ -2106,7 +2106,7 @@ static int __devinit b44_get_invariants(struct b44 *bp)
 
 	memcpy(bp->dev->dev_addr, addr, 6);
 
-	if (!is_valid_ether_addr(&bp->dev->dev_addr[0])){
+	if (!eth_addr_valid(&bp->dev->dev_addr[0])){
 		pr_err("Invalid MAC address found in EEPROM\n");
 		return -EINVAL;
 	}
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index d431070..74ea138 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -7854,7 +7854,7 @@ bnx2_change_mac_addr(struct net_device *dev, void *p)
 	struct sockaddr *addr = p;
 	struct bnx2 *bp = netdev_priv(dev);
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 4833b6a..26735f9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2975,8 +2975,8 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	eth = (struct ethhdr *)skb->data;
 
 	/* set flag according to packet type (UNICAST_ADDRESS is default)*/
-	if (unlikely(is_multicast_ether_addr(eth->h_dest))) {
-		if (is_broadcast_ether_addr(eth->h_dest))
+	if (unlikely(eth_addr_multicast(eth->h_dest))) {
+		if (eth_addr_broadcast(eth->h_dest))
 			mac_type = BROADCAST_ADDRESS;
 		else
 			mac_type = MULTICAST_ADDRESS;
@@ -3341,7 +3341,7 @@ int bnx2x_change_mac_addr(struct net_device *dev, void *p)
 
 #ifdef BCM_CNIC
 	if ((IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp)) &&
-	    !is_zero_ether_addr(addr->sa_data)) {
+	    !eth_addr_zero(addr->sa_data)) {
 		BNX2X_ERR("Can't configure non-zero address on iSCSI or FCoE functions in MF-SD mode\n");
 		return -EINVAL;
 	}
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 9c5ea6c..6825a56 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -1340,10 +1340,10 @@ static inline void bnx2x_update_drv_flags(struct bnx2x *bp, u32 flags, u32 set)
 
 static inline bool bnx2x_is_valid_ether_addr(struct bnx2x *bp, u8 *addr)
 {
-	if (is_valid_ether_addr(addr))
+	if (eth_addr_valid(addr))
 		return true;
 #ifdef BCM_CNIC
-	if (is_zero_ether_addr(addr) &&
+	if (eth_addr_zero(addr) &&
 	    (IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp)))
 		return true;
 #endif
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index d5648fc..1a8c401 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -7596,7 +7596,7 @@ int bnx2x_set_eth_mac(struct bnx2x *bp, bool set)
 	unsigned long ramrod_flags = 0;
 
 #ifdef BCM_CNIC
-	if (is_zero_ether_addr(bp->dev->dev_addr) &&
+	if (eth_addr_zero(bp->dev->dev_addr) &&
 	    (IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp))) {
 		DP(NETIF_MSG_IFUP | NETIF_MSG_IFDOWN,
 		   "Ignoring Zero MAC for STORAGE SD mode\n");
@@ -10447,7 +10447,7 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 	/* Disable iSCSI if MAC configuration is
 	 * invalid.
 	 */
-	if (!is_valid_ether_addr(iscsi_mac)) {
+	if (!eth_addr_valid(iscsi_mac)) {
 		bp->flags |= NO_ISCSI_FLAG;
 		memset(iscsi_mac, 0, ETH_ALEN);
 	}
@@ -10455,7 +10455,7 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 	/* Disable FCoE if MAC configuration is
 	 * invalid.
 	 */
-	if (!is_valid_ether_addr(fip_mac)) {
+	if (!eth_addr_valid(fip_mac)) {
 		bp->flags |= NO_FCOE_FLAG;
 		memset(bp->fip_mac, 0, ETH_ALEN);
 	}
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index 614981c..da96556 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -482,7 +482,7 @@ static int bnx2x_check_mac_add(struct bnx2x *bp,
 
 	DP(BNX2X_MSG_SP, "Checking MAC %pM for ADD command\n", data->mac.mac);
 
-	if (!is_valid_ether_addr(data->mac.mac))
+	if (!eth_addr_valid(data->mac.mac))
 		return -EINVAL;
 
 	/* Check if a requested MAC already exists */
diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index cc8434f..2f9e257 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -399,7 +399,7 @@ static int cnic_iscsi_nl_msg_recv(struct cnic_dev *dev, u32 msg_type,
 				memcpy(&csk->src_ip[0], &path_resp->src.v4_addr,
 				       sizeof(struct in_addr));
 
-			if (is_valid_ether_addr(csk->ha)) {
+			if (eth_addr_valid(csk->ha)) {
 				cnic_cm_set_pg(csk);
 			} else if (!test_bit(SK_F_OFFLD_SCHED, &csk->flags) &&
 				!test_bit(SK_F_OFFLD_COMPLETE, &csk->flags)) {
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index a8800ac..13efde2 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -8259,7 +8259,7 @@ static int tg3_set_mac_addr(struct net_device *dev, void *p)
 	struct sockaddr *addr = p;
 	int err = 0, skip_mac_1 = 0;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
@@ -15304,7 +15304,7 @@ static int __devinit tg3_get_device_address(struct tg3 *tp)
 		dev->dev_addr[5] = (lo >>  0) & 0xff;
 
 		/* Some old bootcode may report a 0 MAC address in SRAM */
-		addr_ok = is_valid_ether_addr(&dev->dev_addr[0]);
+		addr_ok = eth_addr_valid(&dev->dev_addr[0]);
 	}
 	if (!addr_ok) {
 		/* Next, try NVRAM. */
@@ -15328,7 +15328,7 @@ static int __devinit tg3_get_device_address(struct tg3 *tp)
 		}
 	}
 
-	if (!is_valid_ether_addr(&dev->dev_addr[0])) {
+	if (!eth_addr_valid(&dev->dev_addr[0])) {
 #ifdef CONFIG_SPARC
 		if (!tg3_get_default_macaddr_sparc(tp))
 			return 0;
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index ce1eac5..1cce0d2 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -632,7 +632,7 @@ bnad_set_netdev_perm_addr(struct bnad *bnad)
 	struct net_device *netdev = bnad->netdev;
 
 	memcpy(netdev->perm_addr, &bnad->perm_addr, netdev->addr_len);
-	if (is_zero_ether_addr(netdev->dev_addr))
+	if (eth_addr_zero(netdev->dev_addr))
 		memcpy(netdev->dev_addr, &bnad->perm_addr, netdev->addr_len);
 }
 
@@ -863,7 +863,7 @@ bnad_cb_tx_resume(struct bnad *bnad, struct bna_tx *tx)
 	 * get a 0 MAC address. We try to get the MAC address
 	 * again here.
 	 */
-	if (is_zero_ether_addr(&bnad->perm_addr.mac[0])) {
+	if (eth_addr_zero(&bnad->perm_addr.mac[0])) {
 		bna_enet_perm_mac_get(&bnad->bna.enet, &bnad->perm_addr);
 		bnad_set_netdev_perm_addr(bnad);
 	}
@@ -2040,7 +2040,7 @@ bnad_mac_addr_set_locked(struct bnad *bnad, u8 *mac_addr)
 {
 	int ret;
 
-	if (!is_valid_ether_addr(mac_addr))
+	if (!eth_addr_valid(mac_addr))
 		return -EADDRNOTAVAIL;
 
 	/* If datapath is down, pretend everything went through */
diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index 4e980a7..6ee06d8 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -464,7 +464,7 @@ static short __init unpack_mac_address(struct net_device *dev, unsigned int hi,
 		addr[5] = (hi & 0xff00) >> 8;
 	}
 
-	if (is_valid_ether_addr(addr)) {
+	if (eth_addr_valid(addr)) {
 		memcpy(dev->dev_addr, &addr, 6);
 		return 1;
 	}
@@ -515,7 +515,7 @@ static int set_mac_address(struct net_device *dev, void* addr)
 {
 	struct sockaddr *address = addr;
 
-	if (!is_valid_ether_addr(address->sa_data))
+	if (!eth_addr_valid(address->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, address->sa_data, dev->addr_len);
@@ -777,7 +777,7 @@ static int at91ether_open(struct net_device *dev)
 	struct at91_private *lp = netdev_priv(dev);
 	unsigned long ctl;
 
-	if (!is_valid_ether_addr(dev->dev_addr))
+	if (!eth_addr_valid(dev->dev_addr))
 		return -EADDRNOTAVAIL;
 
 	clk_enable(lp->ether_clk);		/* Re-enable Peripheral clock */
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 033064b..e0d95c04 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -83,7 +83,7 @@ static void __init macb_get_hwaddr(struct macb *bp)
 	addr[4] = top & 0xff;
 	addr[5] = (top >> 8) & 0xff;
 
-	if (is_valid_ether_addr(addr)) {
+	if (eth_addr_valid(addr)) {
 		memcpy(bp->dev->dev_addr, addr, sizeof(addr));
 	} else {
 		netdev_info(bp->dev, "invalid hw address, using random\n");
@@ -1043,7 +1043,7 @@ static int macb_open(struct net_device *dev)
 	if (!bp->phy_dev)
 		return -EAGAIN;
 
-	if (!is_valid_ether_addr(dev->dev_addr))
+	if (!eth_addr_valid(dev->dev_addr))
 		return -EADDRNOTAVAIL;
 
 	err = macb_alloc_consistent(bp);
diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 16814b3..daff393 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -997,7 +997,7 @@ static int xgmac_open(struct net_device *dev)
 	 * to bring the device up. The user must specify an
 	 * address using the following linux command:
 	 *      ifconfig eth0 hw ether xx:xx:xx:xx:xx:xx  */
-	if (!is_valid_ether_addr(dev->dev_addr)) {
+	if (!eth_addr_valid(dev->dev_addr)) {
 		eth_hw_addr_random(dev);
 		netdev_dbg(priv->dev, "generated random MAC address %pM\n",
 			dev->dev_addr);
@@ -1463,7 +1463,7 @@ static int xgmac_set_mac_address(struct net_device *dev, void *p)
 	void __iomem *ioaddr = priv->base;
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
@@ -1765,7 +1765,7 @@ static int xgmac_probe(struct platform_device *pdev)
 
 	/* Get the MAC address */
 	xgmac_get_mac_addr(priv->base, ndev->dev_addr, 0);
-	if (!is_valid_ether_addr(ndev->dev_addr))
+	if (!eth_addr_valid(ndev->dev_addr))
 		netdev_warn(ndev, "MAC address %pM not valid",
 			 ndev->dev_addr);
 
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index 9c9f326..7e03da5 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -2543,7 +2543,7 @@ static int cxgb_set_mac_addr(struct net_device *dev, void *p)
 	struct adapter *adapter = pi->adapter;
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 604f4f8..4f95029 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3106,7 +3106,7 @@ static int cxgb_set_mac_addr(struct net_device *dev, void *p)
 	struct sockaddr *addr = p;
 	struct port_info *pi = netdev_priv(dev);
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	ret = t4_change_mac(pi->adapter, pi->adapter->fn, pi->viid,
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 9dad561..7e46100 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -1129,7 +1129,7 @@ static int cxgb4vf_set_mac_addr(struct net_device *dev, void *_addr)
 	struct sockaddr *addr = _addr;
 	struct port_info *pi = netdev_priv(dev);
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	ret = t4vf_change_mac(pi->adapter, pi->viid, pi->xact_addr_filt,
diff --git a/drivers/net/ethernet/cirrus/ep93xx_eth.c b/drivers/net/ethernet/cirrus/ep93xx_eth.c
index 78c5521..b4806c4 100644
--- a/drivers/net/ethernet/cirrus/ep93xx_eth.c
+++ b/drivers/net/ethernet/cirrus/ep93xx_eth.c
@@ -858,7 +858,7 @@ static int ep93xx_eth_probe(struct platform_device *pdev)
 	ep->mii.mdio_write = ep93xx_mdio_write;
 	ep->mdc_divisor = 40;	/* Max HCLK 100 MHz, min MDIO clk 2.5 MHz.  */
 
-	if (is_zero_ether_addr(dev->dev_addr))
+	if (eth_addr_zero(dev->dev_addr))
 		eth_hw_addr_random(dev);
 
 	err = register_netdev(dev);
diff --git a/drivers/net/ethernet/cirrus/mac89x0.c b/drivers/net/ethernet/cirrus/mac89x0.c
index e285f38..f5b39af 100644
--- a/drivers/net/ethernet/cirrus/mac89x0.c
+++ b/drivers/net/ethernet/cirrus/mac89x0.c
@@ -593,7 +593,7 @@ static int set_mac_address(struct net_device *dev, void *addr)
 	struct sockaddr *saddr = addr;
 	int i;
 
-	if (!is_valid_ether_addr(saddr->sa_data))
+	if (!eth_addr_valid(saddr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, saddr->sa_data, ETH_ALEN);
diff --git a/drivers/net/ethernet/cisco/enic/enic_dev.c b/drivers/net/ethernet/cisco/enic/enic_dev.c
index bf0fc56..bc15a36 100644
--- a/drivers/net/ethernet/cisco/enic/enic_dev.c
+++ b/drivers/net/ethernet/cisco/enic/enic_dev.c
@@ -51,7 +51,7 @@ int enic_dev_add_station_addr(struct enic *enic)
 {
 	int err;
 
-	if (!is_valid_ether_addr(enic->netdev->dev_addr))
+	if (!eth_addr_valid(enic->netdev->dev_addr))
 		return -EADDRNOTAVAIL;
 
 	spin_lock(&enic->devcmd_lock);
@@ -65,7 +65,7 @@ int enic_dev_del_station_addr(struct enic *enic)
 {
 	int err;
 
-	if (!is_valid_ether_addr(enic->netdev->dev_addr))
+	if (!eth_addr_valid(enic->netdev->dev_addr))
 		return -EADDRNOTAVAIL;
 
 	spin_lock(&enic->devcmd_lock);
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index ad1468b..f70c8ff 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -857,10 +857,10 @@ static int enic_set_mac_addr(struct net_device *netdev, char *addr)
 	struct enic *enic = netdev_priv(netdev);
 
 	if (enic_is_dynamic(enic) || enic_is_sriov_vf(enic)) {
-		if (!is_valid_ether_addr(addr) && !is_zero_ether_addr(addr))
+		if (!eth_addr_valid(addr) && !eth_addr_zero(addr))
 			return -EADDRNOTAVAIL;
 	} else {
-		if (!is_valid_ether_addr(addr))
+		if (!eth_addr_valid(addr))
 			return -EADDRNOTAVAIL;
 	}
 
@@ -1065,7 +1065,7 @@ static int enic_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 	if (err)
 		return err;
 
-	if (is_valid_ether_addr(mac) || is_zero_ether_addr(mac)) {
+	if (eth_addr_valid(mac) || eth_addr_zero(mac)) {
 		if (vf == PORT_SELF_VF) {
 			memcpy(pp->vf_mac, mac, ETH_ALEN);
 			return 0;
@@ -1122,10 +1122,10 @@ static int enic_set_vf_port(struct net_device *netdev, int vf,
 
 	if (vf == PORT_SELF_VF) {
 		/* Special case handling: mac came from IFLA_VF_MAC */
-		if (!is_zero_ether_addr(prev_pp.vf_mac))
+		if (!eth_addr_zero(prev_pp.vf_mac))
 			memcpy(pp->mac_addr, prev_pp.vf_mac, ETH_ALEN);
 
-		if (is_zero_ether_addr(netdev->dev_addr))
+		if (eth_addr_zero(netdev->dev_addr))
 			eth_hw_addr_random(netdev);
 	} else {
 		/* SR-IOV VF: get mac from adapter */
diff --git a/drivers/net/ethernet/cisco/enic/enic_pp.c b/drivers/net/ethernet/cisco/enic/enic_pp.c
index 43464f0..3ad72fe 100644
--- a/drivers/net/ethernet/cisco/enic/enic_pp.c
+++ b/drivers/net/ethernet/cisco/enic/enic_pp.c
@@ -94,7 +94,7 @@ static int enic_set_port_profile(struct enic *enic, int vf)
 		VIC_GENERIC_PROV_TLV_PORT_PROFILE_NAME_STR,
 		strlen(pp->name) + 1, pp->name);
 
-	if (!is_zero_ether_addr(pp->mac_addr)) {
+	if (!eth_addr_zero(pp->mac_addr)) {
 		client_mac = pp->mac_addr;
 	} else if (vf == PORT_SELF_VF) {
 		client_mac = netdev->dev_addr;
@@ -204,10 +204,10 @@ static int enic_pp_disassociate(struct enic *enic, int vf,
 		return err;
 
 	/* Deregister mac addresses */
-	if (!is_zero_ether_addr(pp->mac_addr))
+	if (!eth_addr_zero(pp->mac_addr))
 		ENIC_DEVCMD_PROXY_BY_INDEX(vf, err, enic, vnic_dev_del_addr,
 			pp->mac_addr);
-	else if (vf == PORT_SELF_VF && !is_zero_ether_addr(netdev->dev_addr))
+	else if (vf == PORT_SELF_VF && !eth_addr_zero(netdev->dev_addr))
 		ENIC_DEVCMD_PROXY_BY_INDEX(vf, err, enic, vnic_dev_del_addr,
 			netdev->dev_addr);
 
@@ -291,10 +291,10 @@ static int enic_pp_associate(struct enic *enic, int vf,
 		return err;
 
 	/* Register mac address */
-	if (!is_zero_ether_addr(pp->mac_addr))
+	if (!eth_addr_zero(pp->mac_addr))
 		ENIC_DEVCMD_PROXY_BY_INDEX(vf, err, enic, vnic_dev_add_addr,
 			pp->mac_addr);
-	else if (vf == PORT_SELF_VF && !is_zero_ether_addr(netdev->dev_addr))
+	else if (vf == PORT_SELF_VF && !eth_addr_zero(netdev->dev_addr))
 		ENIC_DEVCMD_PROXY_BY_INDEX(vf, err, enic, vnic_dev_add_addr,
 			netdev->dev_addr);
 
diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 36499d5..663e2b3 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1568,12 +1568,12 @@ dm9000_probe(struct platform_device *pdev)
 	for (i = 0; i < 6; i += 2)
 		dm9000_read_eeprom(db, i / 2, ndev->dev_addr+i);
 
-	if (!is_valid_ether_addr(ndev->dev_addr) && pdata != NULL) {
+	if (!eth_addr_valid(ndev->dev_addr) && pdata != NULL) {
 		mac_src = "platform data";
 		memcpy(ndev->dev_addr, pdata->dev_addr, 6);
 	}
 
-	if (!is_valid_ether_addr(ndev->dev_addr)) {
+	if (!eth_addr_valid(ndev->dev_addr)) {
 		/* try reading from mac */
 		
 		mac_src = "chip";
@@ -1581,7 +1581,7 @@ dm9000_probe(struct platform_device *pdev)
 			ndev->dev_addr[i] = ior(db, i+DM9000_PAR);
 	}
 
-	if (!is_valid_ether_addr(ndev->dev_addr)) {
+	if (!eth_addr_valid(ndev->dev_addr)) {
 		dev_warn(db->dev, "%s: Invalid ethernet MAC address. Please "
 			 "set using ifconfig\n", ndev->name);
 
diff --git a/drivers/net/ethernet/dec/ewrk3.c b/drivers/net/ethernet/dec/ewrk3.c
index 17ae8c6..468fd127 100644
--- a/drivers/net/ethernet/dec/ewrk3.c
+++ b/drivers/net/ethernet/dec/ewrk3.c
@@ -1010,8 +1010,8 @@ static int ewrk3_rx(struct net_device *dev)
 							}
 						}
 						p = skb->data;	/* Look at the dest addr */
-						if (is_multicast_ether_addr(p)) {
-							if (is_broadcast_ether_addr(p)) {
+						if (eth_addr_multicast(p)) {
+							if (eth_addr_broadcast(p)) {
 								lp->pktStats.broadcast++;
 							} else {
 								lp->pktStats.multicast++;
diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index f879e92..aca612d 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -1868,8 +1868,8 @@ de4x5_local_stats(struct net_device *dev, char *buf, int pkt_len)
 	    i = DE4X5_PKT_STAT_SZ;
 	}
     }
-    if (is_multicast_ether_addr(buf)) {
-        if (is_broadcast_ether_addr(buf)) {
+    if (eth_addr_multicast(buf)) {
+        if (eth_addr_broadcast(buf)) {
 	    lp->pktStats.broadcast++;
 	} else {
 	    lp->pktStats.multicast++;
diff --git a/drivers/net/ethernet/dlink/sundance.c b/drivers/net/ethernet/dlink/sundance.c
index 3b83588..7c16cd9 100644
--- a/drivers/net/ethernet/dlink/sundance.c
+++ b/drivers/net/ethernet/dlink/sundance.c
@@ -1598,7 +1598,7 @@ static int sundance_set_mac_addr(struct net_device *dev, void *data)
 {
 	const struct sockaddr *addr = data;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
 	__set_mac_addr(dev);
diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index 290b26f..b314d90 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -96,7 +96,7 @@ static void __devinit dnet_get_hwaddr(struct dnet *bp)
 	tmp = dnet_readw_mac(bp, DNET_INTERNAL_MAC_ADDR_2_REG);
 	*((__be16 *)(addr + 4)) = cpu_to_be16(tmp);
 
-	if (is_valid_ether_addr(addr))
+	if (eth_addr_valid(addr))
 		memcpy(bp->dev->dev_addr, addr, sizeof(addr));
 }
 
@@ -664,7 +664,7 @@ static int dnet_open(struct net_device *dev)
 	if (!bp->phy_dev)
 		return -EAGAIN;
 
-	if (!is_valid_ether_addr(dev->dev_addr))
+	if (!eth_addr_valid(dev->dev_addr))
 		return -EADDRNOTAVAIL;
 
 	napi_enable(&bp->napi);
@@ -894,7 +894,7 @@ static int __devinit dnet_probe(struct platform_device *pdev)
 
 	dnet_get_hwaddr(bp);
 
-	if (!is_valid_ether_addr(dev->dev_addr)) {
+	if (!eth_addr_valid(dev->dev_addr)) {
 		/* choose a random ethernet address */
 		eth_hw_addr_random(dev);
 		__dnet_set_hwaddr(bp);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index d1b6cc5..db8eca7 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -238,7 +238,7 @@ static int be_mac_addr_set(struct net_device *netdev, void *p)
 	u8 current_mac[ETH_ALEN];
 	u32 pmac_id = adapter->pmac_id[0];
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	status = be_cmd_mac_addr_query(adapter, current_mac, false,
@@ -966,7 +966,7 @@ static int be_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 	if (!sriov_enabled(adapter))
 		return -EPERM;
 
-	if (!is_valid_ether_addr(mac) || vf >= adapter->num_vfs)
+	if (!eth_addr_valid(mac) || vf >= adapter->num_vfs)
 		return -EINVAL;
 
 	if (lancer_chip(adapter)) {
@@ -2682,7 +2682,7 @@ static int be_get_mac_addr(struct be_adapter *adapter, u8 *mac, u32 if_handle,
 {
 	int status = 0;
 
-	if (!is_zero_ether_addr(adapter->netdev->perm_addr)) {
+	if (!eth_addr_zero(adapter->netdev->perm_addr)) {
 		memcpy(mac, adapter->netdev->dev_addr, ETH_ALEN);
 		if (!lancer_chip(adapter) && !be_physfn(adapter))
 			*active_mac = true;
@@ -2798,7 +2798,7 @@ static int be_setup(struct be_adapter *adapter)
 			goto err;
 	}
 
-	if (is_zero_ether_addr(adapter->netdev->dev_addr)) {
+	if (eth_addr_zero(adapter->netdev->dev_addr)) {
 		memcpy(adapter->netdev->dev_addr, mac, ETH_ALEN);
 		memcpy(adapter->netdev->perm_addr, mac, ETH_ALEN);
 	}
diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 94b7bfc..d5ebf25 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -776,7 +776,7 @@ static int ethoc_set_mac_address(struct net_device *dev, void *addr)
 	struct ethoc *priv = netdev_priv(dev);
 	u8 *mac = (u8 *)addr;
 
-	if (!is_valid_ether_addr(mac))
+	if (!eth_addr_valid(mac))
 		return -EADDRNOTAVAIL;
 
 	ethoc_write(priv, MAC_ADDR0, (mac[2] << 24) | (mac[3] << 16) |
@@ -1051,12 +1051,12 @@ static int __devinit ethoc_probe(struct platform_device *pdev)
 
 	/* Check that the given MAC address is valid. If it isn't, read the
 	 * current MAC from the controller. */
-	if (!is_valid_ether_addr(netdev->dev_addr))
+	if (!eth_addr_valid(netdev->dev_addr))
 		ethoc_get_mac_address(netdev, netdev->dev_addr);
 
 	/* Check the MAC again for validity, if it still isn't choose and
 	 * program a random one. */
-	if (!is_valid_ether_addr(netdev->dev_addr)) {
+	if (!eth_addr_valid(netdev->dev_addr)) {
 		eth_random_addr(netdev->dev_addr);
 		random_mac = true;
 	}
diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 74d749e..2f04209 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1293,7 +1293,7 @@ static int ftgmac100_probe(struct platform_device *pdev)
 
 	netdev_info(netdev, "irq %d, mapped at %p\n", priv->irq, priv->base);
 
-	if (!is_valid_ether_addr(netdev->dev_addr)) {
+	if (!eth_addr_valid(netdev->dev_addr)) {
 		eth_hw_addr_random(netdev);
 		netdev_info(netdev, "generated random MAC address %pM\n",
 			    netdev->dev_addr);
diff --git a/drivers/net/ethernet/faraday/ftmac100.c b/drivers/net/ethernet/faraday/ftmac100.c
index b901a01..607ec55 100644
--- a/drivers/net/ethernet/faraday/ftmac100.c
+++ b/drivers/net/ethernet/faraday/ftmac100.c
@@ -1135,7 +1135,7 @@ static int ftmac100_probe(struct platform_device *pdev)
 
 	netdev_info(netdev, "irq %d, mapped at %p\n", priv->irq, priv->base);
 
-	if (!is_valid_ether_addr(netdev->dev_addr)) {
+	if (!eth_addr_valid(netdev->dev_addr)) {
 		eth_hw_addr_random(netdev);
 		netdev_info(netdev, "generated random MAC address %pM\n",
 			    netdev->dev_addr);
diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index fffd205..72c8380 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -811,7 +811,7 @@ static void __inline__ fec_get_mac(struct net_device *ndev)
 	/*
 	 * 2) from device tree data
 	 */
-	if (!is_valid_ether_addr(iap)) {
+	if (!eth_addr_valid(iap)) {
 		struct device_node *np = fep->pdev->dev.of_node;
 		if (np) {
 			const char *mac = of_get_mac_address(np);
@@ -824,7 +824,7 @@ static void __inline__ fec_get_mac(struct net_device *ndev)
 	/*
 	 * 3) from flash or fuse (via platform data)
 	 */
-	if (!is_valid_ether_addr(iap)) {
+	if (!eth_addr_valid(iap)) {
 #ifdef CONFIG_M5272
 		if (FEC_FLASHMAC)
 			iap = (unsigned char *)FEC_FLASHMAC;
@@ -837,7 +837,7 @@ static void __inline__ fec_get_mac(struct net_device *ndev)
 	/*
 	 * 4) FEC mac registers set by bootloader
 	 */
-	if (!is_valid_ether_addr(iap)) {
+	if (!eth_addr_valid(iap)) {
 		*((unsigned long *) &tmpaddr[0]) =
 			be32_to_cpu(readl(fep->hwp + FEC_ADDR_LOW));
 		*((unsigned short *) &tmpaddr[4]) =
@@ -1375,7 +1375,7 @@ fec_set_mac_address(struct net_device *ndev, void *p)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.c b/drivers/net/ethernet/freescale/fec_mpc52xx.c
index 2933d08..ca5ce3c 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx.c
@@ -928,7 +928,7 @@ static int __devinit mpc52xx_fec_probe(struct platform_device *op)
 	priv->t_irq = bcom_get_task_irq(priv->tx_dmatsk);
 
 	/* MAC address init */
-	if (!is_zero_ether_addr(mpc52xx_fec_mac_addr))
+	if (!eth_addr_zero(mpc52xx_fec_mac_addr))
 		memcpy(ndev->dev_addr, mpc52xx_fec_mac_addr, 6);
 	else
 		mpc52xx_fec_get_paddr(ndev, ndev->dev_addr);
diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index ab6762c..ab65a61 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -1014,8 +1014,8 @@ static void gfar_set_ether(struct ethhdr *value, struct ethhdr *mask,
 	u32 lower_temp_mask = 0;
 
 	/* Source address */
-	if (!is_broadcast_ether_addr(mask->h_source)) {
-		if (is_zero_ether_addr(mask->h_source)) {
+	if (!eth_addr_broadcast(mask->h_source)) {
+		if (eth_addr_zero(mask->h_source)) {
 			upper_temp_mask = 0xFFFFFFFF;
 			lower_temp_mask = 0xFFFFFFFF;
 		} else {
@@ -1038,13 +1038,13 @@ static void gfar_set_ether(struct ethhdr *value, struct ethhdr *mask,
 				   lower_temp_mask, RQFCR_PID_SAL, tab);
 	}
 	/* Destination address */
-	if (!is_broadcast_ether_addr(mask->h_dest)) {
+	if (!eth_addr_broadcast(mask->h_dest)) {
 		/* Special for destination is limited broadcast */
-		if ((is_broadcast_ether_addr(value->h_dest) &&
-		    is_zero_ether_addr(mask->h_dest))) {
+		if ((eth_addr_broadcast(value->h_dest) &&
+		    eth_addr_zero(mask->h_dest))) {
 			gfar_set_parse_bits(RQFPR_EBC, RQFPR_EBC, tab);
 		} else {
-			if (is_zero_ether_addr(mask->h_dest)) {
+			if (eth_addr_zero(mask->h_dest)) {
 				upper_temp_mask = 0xFFFFFFFF;
 				lower_temp_mask = 0xFFFFFFFF;
 			} else {
diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 0a70bb5..424ab77 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -3448,7 +3448,7 @@ static int ucc_geth_set_mac_addr(struct net_device *dev, void *p)
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
diff --git a/drivers/net/ethernet/i825xx/ether1.c b/drivers/net/ethernet/i825xx/ether1.c
index 067db3f..9e67b31 100644
--- a/drivers/net/ethernet/i825xx/ether1.c
+++ b/drivers/net/ethernet/i825xx/ether1.c
@@ -638,7 +638,7 @@ ether1_txalloc (struct net_device *dev, int size)
 static int
 ether1_open (struct net_device *dev)
 {
-	if (!is_valid_ether_addr(dev->dev_addr)) {
+	if (!eth_addr_valid(dev->dev_addr)) {
 		printk(KERN_WARNING "%s: invalid ethernet MAC address\n",
 			dev->name);
 		return -EINVAL;
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index f4d2da0..09f4c1d 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -1011,7 +1011,7 @@ int ehea_sense_port_attr(struct ehea_port *port)
 	/* MAC address */
 	port->mac_addr = cb0->port_mac_addr << 16;
 
-	if (!is_valid_ether_addr((u8 *)&port->mac_addr)) {
+	if (!eth_addr_valid((u8 *)&port->mac_addr)) {
 		ret = -EADDRNOTAVAIL;
 		goto out_free;
 	}
@@ -1741,7 +1741,7 @@ static int ehea_set_mac_addr(struct net_device *dev, void *sa)
 	int ret;
 	u64 hret;
 
-	if (!is_valid_ether_addr(mac_addr->sa_data)) {
+	if (!eth_addr_valid(mac_addr->sa_data)) {
 		ret = -EADDRNOTAVAIL;
 		goto out;
 	}
diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 29ce9bd..6cc50e0 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2263,7 +2263,7 @@ static int e100_set_mac_address(struct net_device *netdev, void *p)
 	struct nic *nic = netdev_priv(netdev);
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
@@ -2930,7 +2930,7 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 
 	memcpy(netdev->dev_addr, nic->eeprom, ETH_ALEN);
 	memcpy(netdev->perm_addr, nic->eeprom, ETH_ALEN);
-	if (!is_valid_ether_addr(netdev->perm_addr)) {
+	if (!eth_addr_valid(netdev->perm_addr)) {
 		if (!eeprom_bad_csum_allow) {
 			netif_err(nic, probe, nic->netdev, "Invalid MAC address from EEPROM, aborting\n");
 			err = -EAGAIN;
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 222bfaf..ad49b1e 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -1126,7 +1126,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	memcpy(netdev->dev_addr, hw->mac_addr, netdev->addr_len);
 	memcpy(netdev->perm_addr, hw->mac_addr, netdev->addr_len);
 
-	if (!is_valid_ether_addr(netdev->perm_addr))
+	if (!eth_addr_valid(netdev->perm_addr))
 		e_err(probe, "Invalid MAC Address\n");
 
 
@@ -2213,7 +2213,7 @@ static int e1000_set_mac(struct net_device *netdev, void *p)
 	struct e1000_hw *hw = &adapter->hw;
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	/* 82542 2.0 needs to be in reset to write receive address registers */
diff --git a/drivers/net/ethernet/intel/e1000e/mac.c b/drivers/net/ethernet/intel/e1000e/mac.c
index a134399..37d9fd1 100644
--- a/drivers/net/ethernet/intel/e1000e/mac.c
+++ b/drivers/net/ethernet/intel/e1000e/mac.c
@@ -205,7 +205,7 @@ s32 e1000_check_alt_mac_addr_generic(struct e1000_hw *hw)
 	}
 
 	/* if multicast bit is set, the alternate address will not be used */
-	if (is_multicast_ether_addr(alt_mac_addr)) {
+	if (eth_addr_multicast(alt_mac_addr)) {
 		e_dbg("Ignoring Alternate Mac Address with MC bit set\n");
 		return 0;
 	}
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index f444eb0..58be1cb 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4053,7 +4053,7 @@ static int e1000_set_mac(struct net_device *netdev, void *p)
 	struct e1000_hw *hw = &adapter->hw;
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
@@ -6292,7 +6292,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	memcpy(netdev->dev_addr, adapter->hw.mac.addr, netdev->addr_len);
 	memcpy(netdev->perm_addr, adapter->hw.mac.addr, netdev->addr_len);
 
-	if (!is_valid_ether_addr(netdev->perm_addr)) {
+	if (!eth_addr_valid(netdev->perm_addr)) {
 		dev_err(&pdev->dev, "Invalid MAC Address: %pM\n",
 			netdev->perm_addr);
 		err = -EIO;
diff --git a/drivers/net/ethernet/intel/igb/e1000_mac.c b/drivers/net/ethernet/intel/igb/e1000_mac.c
index 819c145..0c58632 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mac.c
+++ b/drivers/net/ethernet/intel/igb/e1000_mac.c
@@ -280,7 +280,7 @@ s32 igb_check_alt_mac_addr(struct e1000_hw *hw)
 	}
 
 	/* if multicast bit is set, the alternate address will not be used */
-	if (is_multicast_ether_addr(alt_mac_addr)) {
+	if (eth_addr_multicast(alt_mac_addr)) {
 		hw_dbg("Ignoring Alternate Mac Address with MC bit set\n");
 		goto out;
 	}
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index e1ceb37..7e34d44 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2042,7 +2042,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	memcpy(netdev->dev_addr, hw->mac.addr, netdev->addr_len);
 	memcpy(netdev->perm_addr, hw->mac.addr, netdev->addr_len);
 
-	if (!is_valid_ether_addr(netdev->perm_addr)) {
+	if (!eth_addr_valid(netdev->perm_addr)) {
 		dev_err(&pdev->dev, "Invalid MAC Address\n");
 		err = -EIO;
 		goto err_eeprom;
@@ -3372,7 +3372,7 @@ static int igb_set_mac(struct net_device *netdev, void *p)
 	struct e1000_hw *hw = &adapter->hw;
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
@@ -5362,7 +5362,7 @@ static int igb_set_vf_mac_addr(struct igb_adapter *adapter, u32 *msg, int vf)
 	unsigned char *addr = (char *)&msg[1];
 	int err = -1;
 
-	if (is_valid_ether_addr(addr))
+	if (eth_addr_valid(addr))
 		err = igb_set_vf_mac(adapter, vf, addr);
 
 	return err;
@@ -6718,7 +6718,7 @@ static int igb_set_vf_mac(struct igb_adapter *adapter,
 static int igb_ndo_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
-	if (!is_valid_ether_addr(mac) || (vf >= adapter->vfs_allocated_count))
+	if (!eth_addr_valid(mac) || (vf >= adapter->vfs_allocated_count))
 		return -EINVAL;
 	adapter->vf_data[vf].flags |= IGB_VF_FLAG_PF_SET_MAC;
 	dev_info(&adapter->pdev->dev, "setting MAC %pM on VF %d\n", mac, vf);
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 0ac11f5..e502b73 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -1432,7 +1432,7 @@ static void igbvf_reset(struct igbvf_adapter *adapter)
 
 	mac->ops.init_hw(hw);
 
-	if (is_valid_ether_addr(adapter->hw.mac.addr)) {
+	if (eth_addr_valid(adapter->hw.mac.addr)) {
 		memcpy(netdev->dev_addr, adapter->hw.mac.addr,
 		       netdev->addr_len);
 		memcpy(netdev->perm_addr, adapter->hw.mac.addr,
@@ -1707,7 +1707,7 @@ static int igbvf_set_mac(struct net_device *netdev, void *p)
 	struct e1000_hw *hw = &adapter->hw;
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(hw->mac.addr, addr->sa_data, netdev->addr_len);
@@ -2732,7 +2732,7 @@ static int __devinit igbvf_probe(struct pci_dev *pdev,
 			netdev->addr_len);
 	}
 
-	if (!is_valid_ether_addr(netdev->dev_addr)) {
+	if (!eth_addr_valid(netdev->dev_addr)) {
 		dev_err(&pdev->dev, "Invalid MAC Address: %pM\n",
 		        netdev->dev_addr);
 		err = -EIO;
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_hw.c b/drivers/net/ethernet/intel/ixgb/ixgb_hw.c
index bf9a220..d51cb6d 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_hw.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_hw.c
@@ -1128,17 +1128,17 @@ mac_addr_valid(u8 *mac_addr)
 	ENTER();
 
 	/* Make sure it is not a multicast address */
-	if (is_multicast_ether_addr(mac_addr)) {
+	if (eth_addr_multicast(mac_addr)) {
 		pr_debug("MAC address is multicast\n");
 		is_valid = false;
 	}
 	/* Not a broadcast address */
-	else if (is_broadcast_ether_addr(mac_addr)) {
+	else if (eth_addr_broadcast(mac_addr)) {
 		pr_debug("MAC address is broadcast\n");
 		is_valid = false;
 	}
 	/* Reject the zero address */
-	else if (is_zero_ether_addr(mac_addr)) {
+	else if (eth_addr_zero(mac_addr)) {
 		pr_debug("MAC address is all zeros\n");
 		is_valid = false;
 	}
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index d99a2d5..d6f2a43 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -502,7 +502,7 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	ixgb_get_ee_mac_addr(&adapter->hw, netdev->dev_addr);
 	memcpy(netdev->perm_addr, netdev->dev_addr, netdev->addr_len);
 
-	if (!is_valid_ether_addr(netdev->perm_addr)) {
+	if (!eth_addr_valid(netdev->perm_addr)) {
 		netif_err(adapter, probe, adapter->netdev, "Invalid MAC Address\n");
 		err = -EIO;
 		goto err_eeprom;
@@ -1080,7 +1080,7 @@ ixgb_set_mac(struct net_device *netdev, void *p)
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
@@ -2342,7 +2342,7 @@ static pci_ers_result_t ixgb_io_slot_reset(struct pci_dev *pdev)
 	ixgb_get_ee_mac_addr(&adapter->hw, netdev->dev_addr);
 	memcpy(netdev->perm_addr, netdev->dev_addr, netdev->addr_len);
 
-	if (!is_valid_ether_addr(netdev->perm_addr)) {
+	if (!eth_addr_valid(netdev->perm_addr)) {
 		netif_err(adapter, probe, adapter->netdev,
 			  "After reset, invalid MAC address\n");
 		return PCI_ERS_RESULT_DISCONNECT;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
index ae73ef1..35d46ae 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
@@ -893,7 +893,7 @@ int ixgbe_fcoe_get_wwn(struct net_device *netdev, u64 *wwn, int type)
 	}
 
 	if ((prefix != 0xffff) &&
-	    is_valid_ether_addr(mac->san_addr)) {
+	    eth_addr_valid(mac->san_addr)) {
 		*wwn = ((u64) prefix << 48) |
 		       ((u64) mac->san_addr[0] << 40) |
 		       ((u64) mac->san_addr[1] << 32) |
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index fa3d552..fb05d31 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6504,7 +6504,7 @@ static int ixgbe_set_mac(struct net_device *netdev, void *p)
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
@@ -6569,7 +6569,7 @@ static int ixgbe_add_sanmac_netdev(struct net_device *dev)
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 	struct ixgbe_hw *hw = &adapter->hw;
 
-	if (is_valid_ether_addr(hw->mac.san_addr)) {
+	if (eth_addr_valid(hw->mac.san_addr)) {
 		rtnl_lock();
 		err = dev_addr_add(dev, hw->mac.san_addr, NETDEV_HW_ADDR_T_SAN);
 		rtnl_unlock();
@@ -6593,7 +6593,7 @@ static int ixgbe_del_sanmac_netdev(struct net_device *dev)
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 	struct ixgbe_mac_info *mac = &adapter->hw.mac;
 
-	if (is_valid_ether_addr(mac->san_addr)) {
+	if (eth_addr_valid(mac->san_addr)) {
 		rtnl_lock();
 		err = dev_addr_del(dev, mac->san_addr, NETDEV_HW_ADDR_T_SAN);
 		rtnl_unlock();
@@ -6916,14 +6916,14 @@ static int ixgbe_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		return -EINVAL;
 	}
 
-	if (is_unicast_ether_addr(addr)) {
+	if (eth_addr_unicast(addr)) {
 		u32 rar_uc_entries = IXGBE_MAX_PF_MACVLANS;
 
 		if (netdev_uc_count(dev) < rar_uc_entries)
 			err = dev_uc_add_excl(dev, addr);
 		else
 			err = -ENOMEM;
-	} else if (is_multicast_ether_addr(addr)) {
+	} else if (eth_addr_multicast(addr)) {
 		err = dev_mc_add_excl(dev, addr);
 	} else {
 		err = -EINVAL;
@@ -6950,9 +6950,9 @@ static int ixgbe_ndo_fdb_del(struct ndmsg *ndm,
 	}
 
 	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
-		if (is_unicast_ether_addr(addr))
+		if (eth_addr_unicast(addr))
 			err = dev_uc_del(dev, addr);
-		else if (is_multicast_ether_addr(addr))
+		else if (eth_addr_multicast(addr))
 			err = dev_mc_del(dev, addr);
 		else
 			err = -EINVAL;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index dce48bf..af64c92 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -585,7 +585,7 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 		ixgbe_vf_reset_msg(adapter, vf);
 		adapter->vfinfo[vf].clear_to_send = true;
 
-		if (is_valid_ether_addr(new_mac) &&
+		if (eth_addr_valid(new_mac) &&
 		    !adapter->vfinfo[vf].pf_set_mac)
 			ixgbe_set_vf_mac(adapter, vf, vf_mac);
 		else
@@ -614,7 +614,7 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 	switch ((msgbuf[0] & 0xFFFF)) {
 	case IXGBE_VF_SET_MAC_ADDR:
 		new_mac = ((u8 *)(&msgbuf[1]));
-		if (is_valid_ether_addr(new_mac) &&
+		if (eth_addr_valid(new_mac) &&
 		    !adapter->vfinfo[vf].pf_set_mac) {
 			ixgbe_set_vf_mac(adapter, vf, new_mac);
 		} else if (memcmp(adapter->vfinfo[vf].vf_mac_addresses,
@@ -756,7 +756,7 @@ void ixgbe_ping_all_vfs(struct ixgbe_adapter *adapter)
 int ixgbe_ndo_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	if (!is_valid_ether_addr(mac) || (vf >= adapter->num_vfs))
+	if (!eth_addr_valid(mac) || (vf >= adapter->num_vfs))
 		return -EINVAL;
 	adapter->vfinfo[vf].pf_set_mac = true;
 	dev_info(&adapter->pdev->dev, "setting MAC %pM on VF %d\n", mac, vf);
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index de1ad50..ff61bcb 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1392,7 +1392,7 @@ static void ixgbevf_up_complete(struct ixgbevf_adapter *adapter)
 	spin_lock(&adapter->mbx_lock);
 
 	if (hw->mac.ops.set_rar) {
-		if (is_valid_ether_addr(hw->mac.addr))
+		if (eth_addr_valid(hw->mac.addr))
 			hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0);
 		else
 			hw->mac.ops.set_rar(hw, 0, hw->mac.perm_addr, 0);
@@ -1620,7 +1620,7 @@ void ixgbevf_reset(struct ixgbevf_adapter *adapter)
 
 	spin_unlock(&adapter->mbx_lock);
 
-	if (is_valid_ether_addr(adapter->hw.mac.addr)) {
+	if (eth_addr_valid(adapter->hw.mac.addr)) {
 		memcpy(netdev->dev_addr, adapter->hw.mac.addr,
 		       netdev->addr_len);
 		memcpy(netdev->perm_addr, adapter->hw.mac.addr,
@@ -2896,7 +2896,7 @@ static int ixgbevf_set_mac(struct net_device *netdev, void *p)
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
@@ -3183,7 +3183,7 @@ static int __devinit ixgbevf_probe(struct pci_dev *pdev,
 	/* The HW MAC address was set and/or determined in sw_init */
 	memcpy(netdev->perm_addr, adapter->hw.mac.addr, netdev->addr_len);
 
-	if (!is_valid_ether_addr(netdev->dev_addr)) {
+	if (!eth_addr_valid(netdev->dev_addr)) {
 		pr_err("invalid MAC address\n");
 		err = -EIO;
 		goto err_sw_init;
diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 003c5bc..6e00638 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -643,7 +643,7 @@ ltq_etop_init(struct net_device *dev)
 	ltq_etop_change_mtu(dev, 1500);
 
 	memcpy(&mac, &priv->pldata->mac, sizeof(struct sockaddr));
-	if (!is_valid_ether_addr(mac.sa_data)) {
+	if (!eth_addr_valid(mac.sa_data)) {
 		pr_warn("etop: invalid MAC, using random\n");
 		eth_random_addr(mac.sa_data);
 		random_mac = true;
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 84c1326..9735faa 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1830,7 +1830,7 @@ static int mv643xx_eth_set_mac_address(struct net_device *dev, void *addr)
 {
 	struct sockaddr *sa = addr;
 
-	if (!is_valid_ether_addr(sa->sa_data))
+	if (!eth_addr_valid(sa->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, sa->sa_data, ETH_ALEN);
@@ -2727,7 +2727,7 @@ static void set_params(struct mv643xx_eth_private *mp,
 {
 	struct net_device *dev = mp->dev;
 
-	if (is_valid_ether_addr(pd->mac_addr))
+	if (eth_addr_valid(pd->mac_addr))
 		memcpy(dev->dev_addr, pd->mac_addr, 6);
 	else
 		uc_addr_get(mp, dev->dev_addr);
diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 5948972..8c46003 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -624,7 +624,7 @@ static int pxa168_eth_set_mac_address(struct net_device *dev, void *addr)
 	struct pxa168_eth_private *pep = netdev_priv(dev);
 	unsigned char oldMac[ETH_ALEN];
 
-	if (!is_valid_ether_addr(sa->sa_data))
+	if (!eth_addr_valid(sa->sa_data))
 		return -EADDRNOTAVAIL;
 	memcpy(oldMac, dev->dev_addr, ETH_ALEN);
 	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 9b9c2ac..c03c2a3 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -2524,7 +2524,7 @@ static int skge_up(struct net_device *dev)
 	size_t rx_size, tx_size;
 	int err;
 
-	if (!is_valid_ether_addr(dev->dev_addr))
+	if (!eth_addr_valid(dev->dev_addr))
 		return -EINVAL;
 
 	netif_info(skge, ifup, skge->netdev, "enabling interface\n");
@@ -3419,7 +3419,7 @@ static int skge_set_mac_address(struct net_device *dev, void *p)
 	const struct sockaddr *addr = p;
 	u16 ctrl;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
@@ -3951,7 +3951,7 @@ static int __devinit skge_probe(struct pci_dev *pdev,
 	}
 
 	/* Some motherboards are broken and has zero in ROM. */
-	if (!is_valid_ether_addr(dev->dev_addr))
+	if (!eth_addr_valid(dev->dev_addr))
 		dev_warn(&pdev->dev, "bad (zero?) ethernet address in rom\n");
 
 	err = register_netdev(dev);
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 78946fe..38a8d27 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -3823,7 +3823,7 @@ static int sky2_set_mac_address(struct net_device *dev, void *p)
 	unsigned port = sky2->port;
 	const struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index edd9cb8..aeb6285 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -432,7 +432,7 @@ static int mlx4_en_set_mac(struct net_device *dev, void *addr)
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct sockaddr *saddr = addr;
 
-	if (!is_valid_ether_addr(saddr->sa_data))
+	if (!eth_addr_valid(saddr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, saddr->sa_data, ETH_ALEN);
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 926c911..4c79433 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -2992,8 +2992,8 @@ static int validate_eth_header_mac(int slave, struct _rule_hw *eth_header,
 	__be64 be_mac;
 
 	/* make sure it isn't multicast or broadcast mac*/
-	if (!is_multicast_ether_addr(eth_header->eth.dst_mac) &&
-	    !is_broadcast_ether_addr(eth_header->eth.dst_mac)) {
+	if (!eth_addr_multicast(eth_header->eth.dst_mac) &&
+	    !eth_addr_broadcast(eth_header->eth.dst_mac)) {
 		list_for_each_entry_safe(res, tmp, rlist, list) {
 			be_mac = cpu_to_be64(res->mac << 16);
 			if (!memcmp(&be_mac, eth_header->eth.dst_mac, ETH_ALEN))
diff --git a/drivers/net/ethernet/micrel/ks8695net.c b/drivers/net/ethernet/micrel/ks8695net.c
index dccae1d..562a49e 100644
--- a/drivers/net/ethernet/micrel/ks8695net.c
+++ b/drivers/net/ethernet/micrel/ks8695net.c
@@ -1065,7 +1065,7 @@ ks8695_set_mac(struct net_device *ndev, void *addr)
 	struct ks8695_priv *ksp = netdev_priv(ndev);
 	struct sockaddr *address = addr;
 
-	if (!is_valid_ether_addr(address->sa_data))
+	if (!eth_addr_valid(address->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(ndev->dev_addr, address->sa_data, ndev->addr_len);
@@ -1249,7 +1249,7 @@ ks8695_open(struct net_device *ndev)
 	struct ks8695_priv *ksp = netdev_priv(ndev);
 	int ret;
 
-	if (!is_valid_ether_addr(ndev->dev_addr))
+	if (!eth_addr_valid(ndev->dev_addr))
 		return -EADDRNOTAVAIL;
 
 	ks8695_reset(ksp);
@@ -1459,7 +1459,7 @@ ks8695_probe(struct platform_device *pdev)
 	ndev->dev_addr[4] = (maclow >> 8) & 0xFF;
 	ndev->dev_addr[5] = maclow & 0xFF;
 
-	if (!is_valid_ether_addr(ndev->dev_addr))
+	if (!eth_addr_valid(ndev->dev_addr))
 		dev_warn(ksp->dev, "%s: Invalid ethernet MAC address. Please "
 			 "set using ifconfig\n", ndev->name);
 
diff --git a/drivers/net/ethernet/micrel/ks8842.c b/drivers/net/ethernet/micrel/ks8842.c
index 24fb049..5e34050 100644
--- a/drivers/net/ethernet/micrel/ks8842.c
+++ b/drivers/net/ethernet/micrel/ks8842.c
@@ -1077,7 +1077,7 @@ static int ks8842_set_mac(struct net_device *netdev, void *p)
 
 	netdev_dbg(netdev, "%s: entry\n", __func__);
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	netdev->addr_assign_type &= ~NET_ADDR_RANDOM;
@@ -1211,7 +1211,7 @@ static int __devinit ks8842_probe(struct platform_device *pdev)
 	if (i == netdev->addr_len) {
 		ks8842_read_mac_addr(adapter, netdev->dev_addr);
 
-		if (!is_valid_ether_addr(netdev->dev_addr))
+		if (!eth_addr_valid(netdev->dev_addr))
 			eth_hw_addr_random(netdev);
 	}
 
diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index 1540ebe..b77fbf5 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -432,7 +432,7 @@ static void ks8851_init_mac(struct ks8851_net *ks)
 	/* first, try reading what we've got already */
 	if (ks->rc_ccr & CCR_EEPROM) {
 		ks8851_read_mac_addr(dev);
-		if (is_valid_ether_addr(dev->dev_addr))
+		if (eth_addr_valid(dev->dev_addr))
 			return;
 
 		netdev_err(ks->netdev, "invalid mac address read %pM\n",
@@ -1049,7 +1049,7 @@ static int ks8851_set_mac_address(struct net_device *dev, void *addr)
 	if (netif_running(dev))
 		return -EBUSY;
 
-	if (!is_valid_ether_addr(sa->sa_data))
+	if (!eth_addr_valid(sa->sa_data))
 		return -EADDRNOTAVAIL;
 
 	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index 38529ed..1d78951 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -1607,7 +1607,7 @@ static int __devinit ks8851_probe(struct platform_device *pdev)
 		goto err_pdata;
 	}
 	memcpy(ks->mac_addr, pdata->mac_addr, 6);
-	if (!is_valid_ether_addr(ks->mac_addr)) {
+	if (!eth_addr_valid(ks->mac_addr)) {
 		/* Use random MAC address if none passed */
 		eth_random_addr(ks->mac_addr);
 		netdev_info(netdev, "Using random mac address\n");
diff --git a/drivers/net/ethernet/microchip/enc28j60.c b/drivers/net/ethernet/microchip/enc28j60.c
index 6118bda..bf59887 100644
--- a/drivers/net/ethernet/microchip/enc28j60.c
+++ b/drivers/net/ethernet/microchip/enc28j60.c
@@ -524,7 +524,7 @@ static int enc28j60_set_mac_address(struct net_device *dev, void *addr)
 
 	if (netif_running(dev))
 		return -EBUSY;
-	if (!is_valid_ether_addr(address->sa_data))
+	if (!eth_addr_valid(address->sa_data))
 		return -EADDRNOTAVAIL;
 
 	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
@@ -1352,7 +1352,7 @@ static int enc28j60_net_open(struct net_device *dev)
 	if (netif_msg_drv(priv))
 		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __func__);
 
-	if (!is_valid_ether_addr(dev->dev_addr)) {
+	if (!eth_addr_valid(dev->dev_addr)) {
 		if (netif_msg_ifup(priv))
 			dev_err(&dev->dev, "invalid MAC address %pM\n",
 				dev->dev_addr);
diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 83516e3..4146b7c 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -3128,7 +3128,7 @@ static int myri10ge_set_mac_address(struct net_device *dev, void *addr)
 	struct myri10ge_priv *mgp = netdev_priv(dev);
 	int status;
 
-	if (!is_valid_ether_addr(sa->sa_data))
+	if (!eth_addr_valid(sa->sa_data))
 		return -EADDRNOTAVAIL;
 
 	status = myri10ge_update_mac_address(mgp, sa->sa_data);
diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index de50547..0bb1431 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -5245,7 +5245,7 @@ static int s2io_set_mac_addr(struct net_device *dev, void *p)
 {
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-config.c b/drivers/net/ethernet/neterion/vxge/vxge-config.c
index c2e420a..bf2cb52 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-config.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-config.c
@@ -982,7 +982,7 @@ __vxge_hw_vpath_addr_get(struct __vxge_hw_virtualpath *vpath,
 		action = VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION_LIST_NEXT_ENTRY;
 		data0 = 0, data1 = 0, steer_ctrl = 0;
 
-	} while (!is_valid_ether_addr(macaddr));
+	} while (!eth_addr_valid(macaddr));
 exit:
 	return status;
 }
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index 3e5b750..6262280 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -683,7 +683,7 @@ static int vxge_mac_list_add(struct vxge_vpath *vpath, struct macInfo *mac)
 	new_mac_entry->state = mac->state;
 	vpath->mac_addr_cnt++;
 
-	if (is_multicast_ether_addr(mac->macaddr))
+	if (eth_addr_multicast(mac->macaddr))
 		vpath->mcast_addr_cnt++;
 
 	return TRUE;
@@ -697,7 +697,7 @@ vxge_add_mac_addr(struct vxgedev *vdev, struct macInfo *mac)
 	struct vxge_vpath *vpath;
 	enum vxge_hw_vpath_mac_addr_add_mode duplicate_mode;
 
-	if (is_multicast_ether_addr(mac->macaddr))
+	if (eth_addr_multicast(mac->macaddr))
 		duplicate_mode = VXGE_HW_VPATH_MAC_ADDR_ADD_DUPLICATE;
 	else
 		duplicate_mode = VXGE_HW_VPATH_MAC_ADDR_REPLACE_DUPLICATE;
@@ -1076,7 +1076,7 @@ static int vxge_mac_list_del(struct vxge_vpath *vpath, struct macInfo *mac)
 			kfree((struct vxge_mac_addrs *)entry);
 			vpath->mac_addr_cnt--;
 
-			if (is_multicast_ether_addr(mac->macaddr))
+			if (eth_addr_multicast(mac->macaddr))
 				vpath->mcast_addr_cnt--;
 			return TRUE;
 		}
@@ -1198,7 +1198,7 @@ static void vxge_set_multicast(struct net_device *dev)
 				mac_address = (u8 *)&mac_entry->macaddr;
 				memcpy(mac_info.macaddr, mac_address, ETH_ALEN);
 
-				if (is_multicast_ether_addr(mac_info.macaddr)) {
+				if (eth_addr_multicast(mac_info.macaddr)) {
 					for (vpath_idx = 0; vpath_idx <
 						vdev->no_of_vpath;
 						vpath_idx++) {
@@ -1240,7 +1240,7 @@ _set_all_mcast:
 				mac_address = (u8 *)&mac_entry->macaddr;
 				memcpy(mac_info.macaddr, mac_address, ETH_ALEN);
 
-				if (is_multicast_ether_addr(mac_info.macaddr))
+				if (eth_addr_multicast(mac_info.macaddr))
 					break;
 			}
 
@@ -1291,7 +1291,7 @@ static int vxge_set_mac_addr(struct net_device *dev, void *p)
 	vdev = netdev_priv(dev);
 	hldev = vdev->devh;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EINVAL;
 
 	memset(&mac_info_new, 0, sizeof(struct macInfo));
diff --git a/drivers/net/ethernet/netx-eth.c b/drivers/net/ethernet/netx-eth.c
index 63e7af4..244a7fe 100644
--- a/drivers/net/ethernet/netx-eth.c
+++ b/drivers/net/ethernet/netx-eth.c
@@ -362,7 +362,7 @@ static int netx_eth_enable(struct net_device *ndev)
 	xc_reset(priv->xc);
 	xc_start(priv->xc);
 
-	if (!is_valid_ether_addr(ndev->dev_addr))
+	if (!eth_addr_valid(ndev->dev_addr))
 		printk("%s: Invalid ethernet MAC address.  Please "
 		       "set using ifconfig\n", ndev->name);
 
diff --git a/drivers/net/ethernet/nuvoton/w90p910_ether.c b/drivers/net/ethernet/nuvoton/w90p910_ether.c
index 6893a65..335e417 100644
--- a/drivers/net/ethernet/nuvoton/w90p910_ether.c
+++ b/drivers/net/ethernet/nuvoton/w90p910_ether.c
@@ -558,7 +558,7 @@ static int w90p910_set_mac_address(struct net_device *dev, void *addr)
 {
 	struct sockaddr *address = addr;
 
-	if (!is_valid_ether_addr(address->sa_data))
+	if (!eth_addr_valid(address->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, address->sa_data, dev->addr_len);
@@ -941,7 +941,7 @@ static void __init get_mac_address(struct net_device *dev)
 	addr[4] = 0x88;
 	addr[5] = 0xa8;
 
-	if (is_valid_ether_addr(addr))
+	if (eth_addr_valid(addr))
 		memcpy(dev->dev_addr, &addr, 0x06);
 	else
 		dev_err(&pdev->dev, "invalid mac address\n");
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 876bece..fb5565c 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -3020,7 +3020,7 @@ static int nv_set_mac_address(struct net_device *dev, void *addr)
 	struct fe_priv *np = netdev_priv(dev);
 	struct sockaddr *macaddr = (struct sockaddr *)addr;
 
-	if (!is_valid_ether_addr(macaddr->sa_data))
+	if (!eth_addr_valid(macaddr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	/* synchronized against open : rtnl_lock() held by caller */
@@ -5733,7 +5733,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	}
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
-	if (!is_valid_ether_addr(dev->perm_addr)) {
+	if (!eth_addr_valid(dev->perm_addr)) {
 		/*
 		 * Bad mac address. At least one bios sets the mac address
 		 * to 01:23:45:67:89:ab
diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index 53743f7..da92b95 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -1137,7 +1137,7 @@ static int lpc_set_mac_address(struct net_device *ndev, void *p)
 	struct netdata_local *pldat = netdev_priv(ndev);
 	unsigned long flags;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 	memcpy(ndev->dev_addr, addr->sa_data, ETH_ALEN);
 
@@ -1219,7 +1219,7 @@ static int lpc_eth_open(struct net_device *ndev)
 	if (netif_msg_ifup(pldat))
 		dev_dbg(&pldat->pdev->dev, "enabling %s\n", ndev->name);
 
-	if (!is_valid_ether_addr(ndev->dev_addr))
+	if (!eth_addr_valid(ndev->dev_addr))
 		return -EADDRNOTAVAIL;
 
 	__lpc_eth_clock_enable(pldat, true);
@@ -1436,13 +1436,13 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
 	__lpc_get_mac(pldat, ndev->dev_addr);
 
 #ifdef CONFIG_OF_NET
-	if (!is_valid_ether_addr(ndev->dev_addr)) {
+	if (!eth_addr_valid(ndev->dev_addr)) {
 		const char *macaddr = of_get_mac_address(pdev->dev.of_node);
 		if (macaddr)
 			memcpy(ndev->dev_addr, macaddr, ETH_ALEN);
 	}
 #endif
-	if (!is_valid_ether_addr(ndev->dev_addr))
+	if (!eth_addr_valid(ndev->dev_addr))
 		eth_hw_addr_random(ndev);
 
 	/* Reset the ethernet controller */
diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
index f97719c..147ace9 100644
--- a/drivers/net/ethernet/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/octeon/octeon_mgmt.c
@@ -1534,7 +1534,7 @@ static int __devinit octeon_mgmt_probe(struct platform_device *pdev)
 
 	mac = of_get_mac_address(pdev->dev.of_node);
 
-	if (mac && is_valid_ether_addr(mac)) {
+	if (mac && eth_addr_valid(mac)) {
 		memcpy(netdev->dev_addr, mac, ETH_ALEN);
 		netdev->addr_assign_type &= ~NET_ADDR_RANDOM;
 	} else {
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index b2a94d0..15aec1b 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -1974,7 +1974,7 @@ int pch_gbe_up(struct pch_gbe_adapter *adapter)
 	int err;
 
 	/* Ensure we have a valid MAC */
-	if (!is_valid_ether_addr(adapter->hw.mac.addr)) {
+	if (!eth_addr_valid(adapter->hw.mac.addr)) {
 		pr_err("Error: Invalid MAC address\n");
 		return -EINVAL;
 	}
@@ -2260,7 +2260,7 @@ static int pch_gbe_set_mac(struct net_device *netdev, void *addr)
 	struct sockaddr *skaddr = addr;
 	int ret_val;
 
-	if (!is_valid_ether_addr(skaddr->sa_data)) {
+	if (!eth_addr_valid(skaddr->sa_data)) {
 		ret_val = -EADDRNOTAVAIL;
 	} else {
 		memcpy(netdev->dev_addr, skaddr->sa_data, netdev->addr_len);
@@ -2707,7 +2707,7 @@ static int pch_gbe_probe(struct pci_dev *pdev,
 	}
 
 	memcpy(netdev->dev_addr, adapter->hw.mac.addr, netdev->addr_len);
-	if (!is_valid_ether_addr(netdev->dev_addr)) {
+	if (!eth_addr_valid(netdev->dev_addr)) {
 		/*
 		 * If the MAC is invalid (or just missing), display a warning
 		 * but do not abort setting up the device. pch_gbe_up will
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index 6fa74d5..06c6a32 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -237,7 +237,7 @@ static int pasemi_mac_set_mac_addr(struct net_device *dev, void *p)
 	struct sockaddr *addr = p;
 	unsigned int adr0, adr1;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
@@ -1782,7 +1782,7 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	/* get mac addr from device tree */
-	if (pasemi_get_mac_addr(mac) || !is_valid_ether_addr(mac->mac_addr)) {
+	if (pasemi_get_mac_addr(mac) || !eth_addr_valid(mac->mac_addr)) {
 		err = -ENODEV;
 		goto out;
 	}
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index df45061..df2a26a 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -506,7 +506,7 @@ netxen_read_mac_addr(struct netxen_adapter *adapter)
 
 	/* set station address */
 
-	if (!is_valid_ether_addr(netdev->perm_addr))
+	if (!eth_addr_valid(netdev->perm_addr))
 		dev_warn(&pdev->dev, "Bad MAC address %pM.\n", netdev->dev_addr);
 
 	return 0;
@@ -517,7 +517,7 @@ static int netxen_nic_set_mac(struct net_device *netdev, void *p)
 	struct netxen_adapter *adapter = netdev_priv(netdev);
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	if (netif_running(netdev)) {
diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
index df09b1c..7ffddf0 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -3581,7 +3581,7 @@ static int ql3xxx_set_mac_address(struct net_device *ndev, void *p)
 	if (netif_running(ndev))
 		return -EBUSY;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 24ad17e..df1d45d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -285,7 +285,7 @@ qlcnic_read_mac_addr(struct qlcnic_adapter *adapter)
 
 	/* set station address */
 
-	if (!is_valid_ether_addr(netdev->perm_addr))
+	if (!eth_addr_valid(netdev->perm_addr))
 		dev_warn(&pdev->dev, "Bad MAC address %pM.\n",
 					netdev->dev_addr);
 
@@ -300,7 +300,7 @@ static int qlcnic_set_mac(struct net_device *netdev, void *p)
 	if ((adapter->flags & QLCNIC_MAC_OVERRIDE_DISABLED))
 		return -EOPNOTSUPP;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	if (test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index b262d61..2c02691 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -791,7 +791,7 @@ static int ql_get_8000_flash_params(struct ql_adapter *qdev)
 			qdev->flash.flash_params_8000.mac_addr,
 			qdev->ndev->addr_len);
 
-	if (!is_valid_ether_addr(mac_addr)) {
+	if (!eth_addr_valid(mac_addr)) {
 		netif_err(qdev, ifup, qdev->ndev, "Invalid MAC address.\n");
 		status = -EINVAL;
 		goto exit;
@@ -842,7 +842,7 @@ static int ql_get_8012_flash_params(struct ql_adapter *qdev)
 		goto exit;
 	}
 
-	if (!is_valid_ether_addr(qdev->flash.flash_params_8012.mac_addr)) {
+	if (!eth_addr_valid(qdev->flash.flash_params_8012.mac_addr)) {
 		status = -EINVAL;
 		goto exit;
 	}
@@ -4341,7 +4341,7 @@ static int qlge_set_mac_address(struct net_device *ndev, void *p)
 	struct sockaddr *addr = p;
 	int status;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 	memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
 	/* Update local copy of current mac address. */
diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 1c81825..a14c82f 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -1564,7 +1564,7 @@ static int cp_set_mac_address(struct net_device *dev, void *p)
 	struct cp_private *cp = netdev_priv(dev);
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 3ed7add..5215d65 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -2228,7 +2228,7 @@ static int rtl8139_set_mac_address(struct net_device *dev, void *p)
 	void __iomem *ioaddr = tp->mmio_addr;
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index e7ff886..cdec3ce 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3746,7 +3746,7 @@ static int rtl_set_mac_address(struct net_device *dev, void *p)
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index c8bfea0..8957df9 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2075,7 +2075,7 @@ static void sh_eth_tsu_purge_mcast(struct net_device *ndev)
 
 	for (i = 0; i < SH_ETH_TSU_CAM_ENTRIES; i++, reg_offset += 8) {
 		sh_eth_tsu_read_entry(reg_offset, addr);
-		if (is_multicast_ether_addr(addr))
+		if (eth_addr_multicast(addr))
 			sh_eth_tsu_del_entry(ndev, addr);
 	}
 }
@@ -2111,7 +2111,7 @@ static void sh_eth_set_multicast_list(struct net_device *ndev)
 	} else if (mdp->cd->tsu) {
 		struct netdev_hw_addr *ha;
 		netdev_for_each_mc_addr(ha, ndev) {
-			if (mcast_all && is_multicast_ether_addr(ha->addr))
+			if (mcast_all && eth_addr_multicast(ha->addr))
 				continue;
 
 			if (sh_eth_tsu_add_entry(ndev, ha->addr) < 0) {
diff --git a/drivers/net/ethernet/seeq/ether3.c b/drivers/net/ethernet/seeq/ether3.c
index 6a40dd0..7da5f85 100644
--- a/drivers/net/ethernet/seeq/ether3.c
+++ b/drivers/net/ethernet/seeq/ether3.c
@@ -399,7 +399,7 @@ ether3_probe_bus_16(struct net_device *dev, int val)
 static int
 ether3_open(struct net_device *dev)
 {
-	if (!is_valid_ether_addr(dev->dev_addr)) {
+	if (!eth_addr_valid(dev->dev_addr)) {
 		printk(KERN_WARNING "%s: invalid ethernet MAC address\n",
 			dev->name);
 		return -EINVAL;
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 4f86d0c..5a753f4 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1982,7 +1982,7 @@ static int efx_set_mac_address(struct net_device *net_dev, void *data)
 	struct sockaddr *addr = data;
 	char *new_addr = addr->sa_data;
 
-	if (!is_valid_ether_addr(new_addr)) {
+	if (!eth_addr_valid(new_addr)) {
 		netif_err(efx, drv, efx->net_dev,
 			  "invalid ethernet MAC address requested: %pM\n",
 			  new_addr);
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 90f078e..4541dce 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -1019,14 +1019,14 @@ static int efx_ethtool_set_class_rule(struct efx_nic *efx,
 				     ntohs(rule->m_ext.vlan_tci) : 0);
 
 		/* Must not match on source address or Ethertype */
-		if (!is_zero_ether_addr(mac_mask->h_source) ||
+		if (!eth_addr_zero(mac_mask->h_source) ||
 		    mac_mask->h_proto)
 			return -EINVAL;
 
 		/* Is it a default UC or MC filter? */
 		if (ether_addr_equal(mac_mask->h_dest, mac_addr_mc_mask) &&
 		    vlan_tag_mask == 0) {
-			if (is_multicast_ether_addr(mac_entry->h_dest))
+			if (eth_addr_multicast(mac_entry->h_dest))
 				rc = efx_filter_set_mc_def(&spec);
 			else
 				rc = efx_filter_set_uc_def(&spec);
@@ -1034,7 +1034,7 @@ static int efx_ethtool_set_class_rule(struct efx_nic *efx,
 		/* Otherwise, it must match all of destination and all
 		 * or none of VID.
 		 */
-		else if (is_broadcast_ether_addr(mac_mask->h_dest) &&
+		else if (eth_addr_broadcast(mac_mask->h_dest) &&
 			 (vlan_tag_mask == 0xfff || vlan_tag_mask == 0)) {
 			rc = efx_filter_set_eth_local(
 				&spec,
diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index d49b53d..4ab5330 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -321,7 +321,7 @@ static void efx_sriov_reset_tx_filter(struct efx_vf *vf)
 		vf->tx_filter_id = -1;
 	}
 
-	if (is_zero_ether_addr(vf->addr.mac_addr))
+	if (eth_addr_zero(vf->addr.mac_addr))
 		return;
 
 	/* Turn on TX filtering automatically if not explicitly
@@ -365,7 +365,7 @@ static void efx_sriov_reset_rx_filter(struct efx_vf *vf)
 		vf->rx_filter_id = -1;
 	}
 
-	if (!vf->rx_filtering || is_zero_ether_addr(vf->addr.mac_addr))
+	if (!vf->rx_filtering || eth_addr_zero(vf->addr.mac_addr))
 		return;
 
 	vlan = ntohs(vf->addr.tci) & VLAN_VID_MASK;
@@ -1092,7 +1092,7 @@ static void efx_sriov_peer_work(struct work_struct *data)
 		vf = efx->vf + pos;
 
 		mutex_lock(&vf->status_lock);
-		if (vf->rx_filtering && !is_zero_ether_addr(vf->addr.mac_addr)) {
+		if (vf->rx_filtering && !eth_addr_zero(vf->addr.mac_addr)) {
 			*peer++ = vf->addr;
 			++peer_count;
 			--peer_space;
diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index fb9f6b3..29d8c70 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -539,7 +539,7 @@ static int __devinit sis900_probe(struct pci_dev *pci_dev,
 	else
 		ret = sis900_get_mac_addr(pci_dev, net_dev);
 
-	if (!ret || !is_valid_ether_addr(net_dev->dev_addr)) {
+	if (!ret || !eth_addr_valid(net_dev->dev_addr)) {
 		eth_hw_addr_random(net_dev);
 		printk(KERN_WARNING "%s: Unreadable or invalid MAC address,"
 				"using random generated one\n", dev_name);
diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
index 8d15f7a..fa49ddc 100644
--- a/drivers/net/ethernet/smsc/smc911x.c
+++ b/drivers/net/ethernet/smsc/smc911x.c
@@ -1405,7 +1405,7 @@ smc911x_open(struct net_device *dev)
 	 * to bring the device up.	 The user must specify an
 	 * address using ifconfig eth0 hw ether xx:xx:xx:xx:xx:xx
 	 */
-	if (!is_valid_ether_addr(dev->dev_addr)) {
+	if (!eth_addr_valid(dev->dev_addr)) {
 		PRINTK("%s: no valid ethernet hw addr\n", __func__);
 		return -EINVAL;
 	}
@@ -2001,7 +2001,7 @@ static int __devinit smc911x_probe(struct net_device *dev)
 			printk("TXDMA %d", lp->txdma);
 #endif
 		printk("\n");
-		if (!is_valid_ether_addr(dev->dev_addr)) {
+		if (!eth_addr_valid(dev->dev_addr)) {
 			printk("%s: Invalid ethernet MAC address. Please "
 					"set using ifconfig\n", dev->name);
 		} else {
diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 318adc9..2a0e709 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -1479,7 +1479,7 @@ smc_open(struct net_device *dev)
 	 * to bring the device up.  The user must specify an
 	 * address using ifconfig eth0 hw ether xx:xx:xx:xx:xx:xx
 	 */
-	if (!is_valid_ether_addr(dev->dev_addr)) {
+	if (!eth_addr_valid(dev->dev_addr)) {
 		PRINTK("%s: no valid ethernet hw addr\n", __func__);
 		return -EINVAL;
 	}
@@ -2052,7 +2052,7 @@ static int __devinit smc_probe(struct net_device *dev, void __iomem *ioaddr,
 			lp->cfg.flags & SMC91X_NOWAIT ? " [nowait]" : "",
 			THROTTLE_TX_PKTS ? " [throttle_tx]" : "");
 
-		if (!is_valid_ether_addr(dev->dev_addr)) {
+		if (!eth_addr_valid(dev->dev_addr)) {
 			printk("%s: Invalid ethernet MAC address.  Please "
 			       "set using ifconfig\n", dev->name);
 		} else {
diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 62d1baf..656abcc 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -1463,7 +1463,7 @@ static int smsc911x_open(struct net_device *dev)
 		return -EAGAIN;
 	}
 
-	if (!is_valid_ether_addr(dev->dev_addr)) {
+	if (!eth_addr_valid(dev->dev_addr)) {
 		SMSC_WARN(pdata, hw, "dev_addr is not a valid MAC address");
 		return -EADDRNOTAVAIL;
 	}
@@ -1833,7 +1833,7 @@ static int smsc911x_set_mac_address(struct net_device *dev, void *p)
 	if (pdata->generation <= 1 && netif_running(dev))
 		return -EBUSY;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
@@ -2466,11 +2466,11 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	spin_lock_irq(&pdata->mac_lock);
 
 	/* Check if mac address has been specified when bringing interface up */
-	if (is_valid_ether_addr(dev->dev_addr)) {
+	if (eth_addr_valid(dev->dev_addr)) {
 		smsc911x_set_hw_mac_address(pdata, dev->dev_addr);
 		SMSC_TRACE(pdata, probe,
 			   "MAC Address is specified by configuration");
-	} else if (is_valid_ether_addr(pdata->config.mac)) {
+	} else if (eth_addr_valid(pdata->config.mac)) {
 		memcpy(dev->dev_addr, pdata->config.mac, 6);
 		SMSC_TRACE(pdata, probe,
 			   "MAC Address specified by platform data");
@@ -2479,7 +2479,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 		 * it will already have been set */
 		smsc_get_mac(dev);
 
-		if (is_valid_ether_addr(dev->dev_addr)) {
+		if (eth_addr_valid(dev->dev_addr)) {
 			/* eeprom values are valid  so use them */
 			SMSC_TRACE(pdata, probe,
 				   "Mac Address is read from LAN911x EEPROM");
diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index 1fcd914e..9832b11 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -490,7 +490,7 @@ static void smsc9420_check_mac_address(struct net_device *dev)
 	struct smsc9420_pdata *pd = netdev_priv(dev);
 
 	/* Check if mac address has been specified when bringing interface up */
-	if (is_valid_ether_addr(dev->dev_addr)) {
+	if (eth_addr_valid(dev->dev_addr)) {
 		smsc9420_set_mac_address(dev);
 		smsc_dbg(PROBE, "MAC Address is specified by configuration");
 	} else {
@@ -505,7 +505,7 @@ static void smsc9420_check_mac_address(struct net_device *dev)
 		dev->dev_addr[4] = (u8)(mac_high16);
 		dev->dev_addr[5] = (u8)(mac_high16 >> 8);
 
-		if (is_valid_ether_addr(dev->dev_addr)) {
+		if (eth_addr_valid(dev->dev_addr)) {
 			/* eeprom values are valid  so use them */
 			smsc_dbg(PROBE, "Mac Address is read from EEPROM");
 		} else {
@@ -1341,7 +1341,7 @@ static int smsc9420_open(struct net_device *dev)
 	unsigned long flags;
 	int result = 0, timeout;
 
-	if (!is_valid_ether_addr(dev->dev_addr)) {
+	if (!eth_addr_valid(dev->dev_addr)) {
 		smsc_warn(IFUP, "dev_addr is not a valid MAC address");
 		result = -EADDRNOTAVAIL;
 		goto out_0;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index c6cdbc4..16df337 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -993,11 +993,11 @@ static void stmmac_check_ether_addr(struct stmmac_priv *priv)
 {
 	/* verify if the MAC address is valid, in case of failures it
 	 * generates a random MAC address */
-	if (!is_valid_ether_addr(priv->dev->dev_addr)) {
+	if (!eth_addr_valid(priv->dev->dev_addr)) {
 		priv->hw->mac->get_umac_addr((void __iomem *)
 					     priv->dev->base_addr,
 					     priv->dev->dev_addr, 0);
-		if  (!is_valid_ether_addr(priv->dev->dev_addr))
+		if  (!eth_addr_valid(priv->dev->dev_addr))
 			eth_hw_addr_random(priv->dev);
 	}
 	pr_warning("%s: device MAC address %pM\n", priv->dev->name,
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 275b430..f17b7f0 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -6407,7 +6407,7 @@ static int niu_set_mac_addr(struct net_device *dev, void *p)
 	struct sockaddr *addr = p;
 	unsigned long flags;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
@@ -8340,7 +8340,7 @@ static void __devinit niu_pci_vpd_validate(struct niu *np)
 	struct niu_vpd *vpd = &np->vpd;
 	u8 val8;
 
-	if (!is_valid_ether_addr(&vpd->local_mac[0])) {
+	if (!eth_addr_valid(&vpd->local_mac[0])) {
 		dev_err(np->device, "VPD MAC invalid, falling back to SPROM\n");
 
 		np->flags &= ~NIU_FLAGS_VPD_VALID;
@@ -8485,7 +8485,7 @@ static int __devinit niu_pci_probe_sprom(struct niu *np)
 	dev->perm_addr[4] = (val >>  0) & 0xff;
 	dev->perm_addr[5] = (val >>  8) & 0xff;
 
-	if (!is_valid_ether_addr(&dev->perm_addr[0])) {
+	if (!eth_addr_valid(&dev->perm_addr[0])) {
 		dev_err(np->device, "SPROM MAC address invalid [ %pM ]\n",
 			dev->perm_addr);
 		return -EINVAL;
@@ -9275,7 +9275,7 @@ static int __devinit niu_get_of_props(struct niu *np)
 			   dp->full_name, prop_len);
 	}
 	memcpy(dev->perm_addr, mac_addr, dev->addr_len);
-	if (!is_valid_ether_addr(&dev->perm_addr[0])) {
+	if (!eth_addr_valid(&dev->perm_addr[0])) {
 		netdev_err(dev, "%s: OF MAC address is invalid\n",
 			   dp->full_name);
 		netdev_err(dev, "%s: [ %pM ]\n", dp->full_name, dev->perm_addr);
diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index 6c8695e..4cdf017 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -2424,7 +2424,7 @@ static int gem_set_mac_address(struct net_device *dev, void *addr)
 	struct gem *gp = netdev_priv(dev);
 	unsigned char *e = &dev->dev_addr[0];
 
-	if (!is_valid_ether_addr(macaddr->sa_data))
+	if (!eth_addr_valid(macaddr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, macaddr->sa_data, dev->addr_len);
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index df55e24..b33bccc 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -902,7 +902,7 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
 	}
 	data = &priv->data;
 
-	if (is_valid_ether_addr(data->slave_data[0].mac_addr)) {
+	if (eth_addr_valid(data->slave_data[0].mac_addr)) {
 		memcpy(priv->mac_addr, data->slave_data[0].mac_addr, ETH_ALEN);
 		pr_info("Detected MACID = %pM", priv->mac_addr);
 	} else {
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index fce89a0..aebe8c3 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1258,7 +1258,7 @@ static int emac_dev_setmac_addr(struct net_device *ndev, void *addr)
 	struct device *emac_dev = &priv->ndev->dev;
 	struct sockaddr *sa = addr;
 
-	if (!is_valid_ether_addr(sa->sa_data))
+	if (!eth_addr_valid(sa->sa_data))
 		return -EADDRNOTAVAIL;
 
 	/* Store mac addr in priv and rx channel and set it in EMAC hw */
@@ -1795,7 +1795,7 @@ static struct emac_platform_data
 	else
 		pdata->version = EMAC_VERSION_2;
 
-	if (!is_valid_ether_addr(pdata->mac_addr)) {
+	if (!eth_addr_valid(pdata->mac_addr)) {
 		mac_addr = of_get_mac_address(np);
 		if (mac_addr)
 			memcpy(pdata->mac_addr, mac_addr, ETH_ALEN);
@@ -1982,7 +1982,7 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 	}
 	ndev->irq = res->start;
 
-	if (!is_valid_ether_addr(priv->mac_addr)) {
+	if (!eth_addr_valid(priv->mac_addr)) {
 		/* Use random MAC if none passed */
 		eth_hw_addr_random(ndev);
 		memcpy(priv->mac_addr, ndev->dev_addr, ndev->addr_len);
diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 4e2a162..e7cd4c5 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -397,7 +397,7 @@ static inline bool filter_packet(struct net_device *dev, void *buf)
 
 	/* Filter out packets that aren't for us. */
 	if (!(dev->flags & IFF_PROMISC) &&
-	    !is_multicast_ether_addr(buf) &&
+	    !eth_addr_multicast(buf) &&
 	    compare_ether_addr(dev->dev_addr, buf) != 0)
 		return true;
 
@@ -1756,7 +1756,7 @@ static int tile_net_set_mac_address(struct net_device *dev, void *p)
 {
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EINVAL;
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 	return 0;
diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index 96070e9..2d768d7 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -840,7 +840,7 @@ static bool tile_net_poll_aux(struct tile_net_cpu *info, int index)
 		filter = 1;
 	} else if (!(dev->flags & IFF_PROMISC)) {
 		/* FIXME: Implement HW multicast filter. */
-		if (!is_multicast_ether_addr(buf)) {
+		if (!eth_addr_multicast(buf)) {
 			/* Filter packets not for our address. */
 			const u8 *mine = dev->dev_addr;
 			filter = !ether_addr_equal(mine, buf);
@@ -2190,7 +2190,7 @@ static int tile_net_set_mac_address(struct net_device *dev, void *p)
 {
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	/* ISSUE: Note that "dev_addr" is now a pointer. */
diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_net.c b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
index 5ee82a7..c2f567c 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_net.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
@@ -1505,7 +1505,7 @@ int __devinit gelic_net_setup_netdev(struct net_device *netdev,
 				 GELIC_LV1_GET_MAC_ADDRESS,
 				 0, 0, 0, &v1, &v2);
 	v1 <<= 16;
-	if (status || !is_valid_ether_addr((u8 *)&v1)) {
+	if (status || !eth_addr_valid((u8 *)&v1)) {
 		dev_info(ctodev(card),
 			 "%s:lv1_net_control GET_MAC_ADDR failed %d\n",
 			 __func__, status);
diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
index 961c832..a6bfc6d 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
@@ -1161,7 +1161,7 @@ static int gelic_wl_set_ap(struct net_device *netdev,
 		return -EINVAL;
 
 	spin_lock_irqsave(&wl->lock, irqflag);
-	if (is_valid_ether_addr(data->ap_addr.sa_data)) {
+	if (eth_addr_valid(data->ap_addr.sa_data)) {
 		memcpy(wl->bssid, data->ap_addr.sa_data,
 		       ETH_ALEN);
 		set_bit(GELIC_WL_STAT_BSSID_SET, &wl->stat);
diff --git a/drivers/net/ethernet/toshiba/spider_net.c b/drivers/net/ethernet/toshiba/spider_net.c
index c1ebfe9..eb56f55 100644
--- a/drivers/net/ethernet/toshiba/spider_net.c
+++ b/drivers/net/ethernet/toshiba/spider_net.c
@@ -288,7 +288,7 @@ spider_net_get_mac_address(struct net_device *netdev)
 	netdev->dev_addr[4] = (macl >> 8) & 0xff;
 	netdev->dev_addr[5] = macl & 0xff;
 
-	if (!is_valid_ether_addr(&netdev->dev_addr[0]))
+	if (!eth_addr_valid(&netdev->dev_addr[0]))
 		return -EINVAL;
 
 	return 0;
@@ -1343,7 +1343,7 @@ spider_net_set_mac(struct net_device *netdev, void *p)
 	u32 macl, macu, regvalue;
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	/* switch off GMACTPE and GMACRPE */
diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index 651a70c..aab2cf4 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -736,7 +736,7 @@ static int __devinit tc35815_read_plat_dev_addr(struct net_device *dev)
 		if (pd->platform_data)
 			memcpy(dev->dev_addr, pd->platform_data, ETH_ALEN);
 		put_device(pd);
-		return is_valid_ether_addr(dev->dev_addr) ? 0 : -ENODEV;
+		return eth_addr_valid(dev->dev_addr) ? 0 : -ENODEV;
 	}
 	return -ENODEV;
 }
@@ -764,7 +764,7 @@ static int __devinit tc35815_init_dev_addr(struct net_device *dev)
 		dev->dev_addr[i] = data & 0xff;
 		dev->dev_addr[i+1] = data >> 8;
 	}
-	if (!is_valid_ether_addr(dev->dev_addr))
+	if (!eth_addr_valid(dev->dev_addr))
 		return tc35815_read_plat_dev_addr(dev);
 	return 0;
 }
diff --git a/drivers/net/ethernet/tundra/tsi108_eth.c b/drivers/net/ethernet/tundra/tsi108_eth.c
index 8fa947a..384b5e7 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.c
+++ b/drivers/net/ethernet/tundra/tsi108_eth.c
@@ -349,7 +349,7 @@ static void tsi108_check_phy(struct net_device *dev)
 			udelay(5);
 
 			spin_lock(&data->txlock);
-			if (is_valid_ether_addr(dev->dev_addr) && data->txfree)
+			if (eth_addr_valid(dev->dev_addr) && data->txfree)
 				netif_wake_queue(dev);
 
 			data->link_up = 1;
@@ -646,7 +646,7 @@ static void tsi108_complete_tx(struct net_device *dev)
 	}
 
 	if (release) {
-		if (is_valid_ether_addr(dev->dev_addr) && data->link_up)
+		if (eth_addr_valid(dev->dev_addr) && data->link_up)
 			netif_wake_queue(dev);
 	}
 }
@@ -1130,7 +1130,7 @@ static int tsi108_get_mac(struct net_device *dev)
 		dev->dev_addr[5] = (word1 >> 24) & 0xff;
 	}
 
-	if (!is_valid_ether_addr(dev->dev_addr)) {
+	if (!eth_addr_valid(dev->dev_addr)) {
 		printk(KERN_ERR
 		       "%s: Invalid MAC address. word1: %08x, word2: %08x\n",
 		       dev->name, word1, word2);
@@ -1146,7 +1146,7 @@ static int tsi108_set_mac(struct net_device *dev, void *addr)
 	u32 word1, word2;
 	int i;
 
-	if (!is_valid_ether_addr(addr))
+	if (!eth_addr_valid(addr))
 		return -EADDRNOTAVAIL;
 
 	for (i = 0; i < 6; i++)
diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 0459c09..8851a95 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -984,7 +984,7 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = ioread8(ioaddr + StationAddr + i);
 
-	if (!is_valid_ether_addr(dev->dev_addr)) {
+	if (!eth_addr_valid(dev->dev_addr)) {
 		/* Report it and use a random ethernet address instead */
 		netdev_err(dev, "Invalid MAC address: %pM\n", dev->dev_addr);
 		eth_hw_addr_random(dev);
diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index 2c08bf6..e7d3f0f 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -567,7 +567,7 @@ static int w5100_set_macaddr(struct net_device *ndev, void *addr)
 	struct w5100_priv *priv = netdev_priv(ndev);
 	struct sockaddr *sock_addr = addr;
 
-	if (!is_valid_ether_addr(sock_addr->sa_data))
+	if (!eth_addr_valid(sock_addr->sa_data))
 		return -EADDRNOTAVAIL;
 	memcpy(ndev->dev_addr, sock_addr->sa_data, ETH_ALEN);
 	ndev->addr_assign_type &= ~NET_ADDR_RANDOM;
@@ -580,7 +580,7 @@ static int w5100_open(struct net_device *ndev)
 	struct w5100_priv *priv = netdev_priv(ndev);
 
 	netif_info(priv, ifup, ndev, "enabling\n");
-	if (!is_valid_ether_addr(ndev->dev_addr))
+	if (!eth_addr_valid(ndev->dev_addr))
 		return -EINVAL;
 	w5100_hw_start(priv);
 	napi_enable(&priv->napi);
@@ -634,7 +634,7 @@ static int __devinit w5100_hw_probe(struct platform_device *pdev)
 	int irq;
 	int ret;
 
-	if (data && is_valid_ether_addr(data->mac_addr)) {
+	if (data && eth_addr_valid(data->mac_addr)) {
 		memcpy(ndev->dev_addr, data->mac_addr, ETH_ALEN);
 	} else {
 		eth_hw_addr_random(ndev);
diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet/wiznet/w5300.c
index 88943d9..480c22e 100644
--- a/drivers/net/ethernet/wiznet/w5300.c
+++ b/drivers/net/ethernet/wiznet/w5300.c
@@ -487,7 +487,7 @@ static int w5300_set_macaddr(struct net_device *ndev, void *addr)
 	struct w5300_priv *priv = netdev_priv(ndev);
 	struct sockaddr *sock_addr = addr;
 
-	if (!is_valid_ether_addr(sock_addr->sa_data))
+	if (!eth_addr_valid(sock_addr->sa_data))
 		return -EADDRNOTAVAIL;
 	memcpy(ndev->dev_addr, sock_addr->sa_data, ETH_ALEN);
 	ndev->addr_assign_type &= ~NET_ADDR_RANDOM;
@@ -500,7 +500,7 @@ static int w5300_open(struct net_device *ndev)
 	struct w5300_priv *priv = netdev_priv(ndev);
 
 	netif_info(priv, ifup, ndev, "enabling\n");
-	if (!is_valid_ether_addr(ndev->dev_addr))
+	if (!eth_addr_valid(ndev->dev_addr))
 		return -EINVAL;
 	w5300_hw_start(priv);
 	napi_enable(&priv->napi);
@@ -554,7 +554,7 @@ static int __devinit w5300_hw_probe(struct platform_device *pdev)
 	int irq;
 	int ret;
 
-	if (data && is_valid_ether_addr(data->mac_addr)) {
+	if (data && eth_addr_valid(data->mac_addr)) {
 		memcpy(ndev->dev_addr, data->mac_addr, ETH_ALEN);
 	} else {
 		eth_hw_addr_random(ndev);
diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index f8e3518..31db40b 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -326,7 +326,7 @@ static int temac_set_mac_address(struct net_device *ndev, void *address)
 	if (address)
 		memcpy(ndev->dev_addr, address, ETH_ALEN);
 
-	if (!is_valid_ether_addr(ndev->dev_addr))
+	if (!eth_addr_valid(ndev->dev_addr))
 		eth_hw_addr_random(ndev);
 	else
 		ndev->addr_assign_type &= ~NET_ADDR_RANDOM;
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 0793299..64ebc03 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -311,7 +311,7 @@ static void axienet_set_mac_address(struct net_device *ndev, void *address)
 
 	if (address)
 		memcpy(ndev->dev_addr, address, ETH_ALEN);
-	if (!is_valid_ether_addr(ndev->dev_addr))
+	if (!eth_addr_valid(ndev->dev_addr))
 		eth_random_addr(ndev->dev_addr);
 
 	/* Set up unicast MAC address filter set its mac address */
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index c2e5497..8979a6d 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -431,7 +431,7 @@ static int bpq_seq_show(struct seq_file *seq, void *v)
 			bpqdev->axdev->name, bpqdev->ethdev->name,
 			bpqdev->dest_addr);
 
-		if (is_multicast_ether_addr(bpqdev->acpt_addr))
+		if (eth_addr_multicast(bpqdev->acpt_addr))
 			seq_printf(seq, "*\n");
 		else
 			seq_printf(seq, "%pM\n", bpqdev->acpt_addr);
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 344dceb..aa52f82 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -244,7 +244,7 @@ static int ifb_validate(struct nlattr *tb[], struct nlattr *data[])
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
 			return -EINVAL;
-		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
+		if (!eth_addr_valid(nla_data(tb[IFLA_ADDRESS])))
 			return -EADDRNOTAVAIL;
 	}
 	return 0;
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 68a43fe..db091cc33 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -168,7 +168,7 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 	int ret = NET_RX_DROP;
 
 	port = macvlan_port_get_rcu(skb->dev);
-	if (is_multicast_ether_addr(eth->h_dest)) {
+	if (eth_addr_multicast(eth->h_dest)) {
 		skb = ip_check_defrag(skb, IP_DEFRAG_MACVLAN);
 		if (!skb)
 			return RX_HANDLER_CONSUMED;
@@ -242,7 +242,7 @@ static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 		/* send to other bridge ports directly */
-		if (is_multicast_ether_addr(eth->h_dest)) {
+		if (eth_addr_multicast(eth->h_dest)) {
 			macvlan_broadcast(skb, port, dev, MACVLAN_MODE_BRIDGE);
 			goto xmit_world;
 		}
@@ -370,7 +370,7 @@ static int macvlan_set_mac_address(struct net_device *dev, void *p)
 	struct sockaddr *addr = p;
 	int err;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	if (!(dev->flags & IFF_UP)) {
@@ -557,9 +557,9 @@ static int macvlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	if (!vlan->port->passthru)
 		return -EOPNOTSUPP;
 
-	if (is_unicast_ether_addr(addr))
+	if (eth_addr_unicast(addr))
 		err = dev_uc_add_excl(dev, addr);
-	else if (is_multicast_ether_addr(addr))
+	else if (eth_addr_multicast(addr))
 		err = dev_mc_add_excl(dev, addr);
 
 	return err;
@@ -575,9 +575,9 @@ static int macvlan_fdb_del(struct ndmsg *ndm,
 	if (!vlan->port->passthru)
 		return -EOPNOTSUPP;
 
-	if (is_unicast_ether_addr(addr))
+	if (eth_addr_unicast(addr))
 		err = dev_uc_del(dev, addr);
-	else if (is_multicast_ether_addr(addr))
+	else if (eth_addr_multicast(addr))
 		err = dev_mc_del(dev, addr);
 
 	return err;
@@ -682,7 +682,7 @@ static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
 			return -EINVAL;
-		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
+		if (!eth_addr_valid(nla_data(tb[IFLA_ADDRESS])))
 			return -EADDRNOTAVAIL;
 	}
 
diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index 45cbc10..f595507 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -47,7 +47,7 @@ static void at803x_set_wol_mac_addr(struct phy_device *phydev)
 
 	mac = (const u8 *) ndev->dev_addr;
 
-	if (!is_valid_ether_addr(mac))
+	if (!eth_addr_valid(mac))
 		return;
 
 	for (i = 0; i < 3; i++) {
diff --git a/drivers/net/rionet.c b/drivers/net/rionet.c
index d8b9b1e..f94afc6 100644
--- a/drivers/net/rionet.c
+++ b/drivers/net/rionet.c
@@ -180,7 +180,7 @@ static int rionet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 		return NETDEV_TX_LOCKED;
 	}
 
-	if (is_multicast_ether_addr(eth->h_dest))
+	if (eth_addr_multicast(eth->h_dest))
 		add_num = nets[rnet->mport->id].nact;
 
 	if ((rnet->tx_cnt + add_num) > RIONET_TX_RING_SIZE) {
@@ -191,7 +191,7 @@ static int rionet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 		return NETDEV_TX_BUSY;
 	}
 
-	if (is_multicast_ether_addr(eth->h_dest)) {
+	if (eth_addr_multicast(eth->h_dest)) {
 		int count = 0;
 
 		for (i = 0; i < RIO_MAX_ROUTE_ENTRIES(rnet->mport->sys_size);
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index d44cca3..0f092c5 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1498,7 +1498,7 @@ static int team_set_mac_address(struct net_device *dev, void *p)
 	struct team *team = netdev_priv(dev);
 	struct team_port *port;
 
-	if (dev->type == ARPHRD_ETHER && !is_valid_ether_addr(addr->sa_data))
+	if (dev->type == ARPHRD_ETHER && !eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
@@ -1821,7 +1821,7 @@ static int team_validate(struct nlattr *tb[], struct nlattr *data[])
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
 			return -EINVAL;
-		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
+		if (!eth_addr_valid(nla_data(tb[IFLA_ADDRESS])))
 			return -EADDRNOTAVAIL;
 	}
 	return 0;
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 0873cdc..7444e97 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -281,7 +281,7 @@ static int update_filter(struct tap_filter *filter, void __user *arg)
 	 * unicast will leave the filter disabled. */
 	memset(filter->mask, 0, sizeof(filter->mask));
 	for (; n < uf.count; n++) {
-		if (!is_multicast_ether_addr(addr[n].u)) {
+		if (!eth_addr_multicast(addr[n].u)) {
 			err = 0; /* no filter */
 			goto done;
 		}
@@ -319,7 +319,7 @@ static int run_filter(struct tap_filter *filter, const struct sk_buff *skb)
 			return 1;
 
 	/* Inexact match (multicast only) */
-	if (is_multicast_ether_addr(eh->h_dest))
+	if (eth_addr_multicast(eh->h_dest))
 		return addr_hash_test(filter->mask, eh->h_dest);
 
 	return 0;
diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index 774d9ce..095daa7 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -614,7 +614,7 @@ int asix_set_mac_address(struct net_device *net, void *p)
 
 	if (netif_running(net))
 		return -EBUSY;
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(net->dev_addr, addr->sa_data, ETH_ALEN);
diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index e0433ce..1c42305 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -408,7 +408,7 @@ static int dm9601_set_mac_address(struct net_device *net, void *p)
 	struct sockaddr *addr = p;
 	struct usbnet *dev = netdev_priv(net);
 
-	if (!is_valid_ether_addr(addr->sa_data)) {
+	if (!eth_addr_valid(addr->sa_data)) {
 		dev_err(&net->dev, "not setting invalid mac address %pM\n",
 								addr->sa_data);
 		return -EINVAL;
@@ -467,7 +467,7 @@ static int dm9601_bind(struct usbnet *dev, struct usb_interface *intf)
 	/*
 	 * Overwrite the auto-generated address only with good ones.
 	 */
-	if (is_valid_ether_addr(mac))
+	if (eth_addr_valid(mac))
 		memcpy(dev->net->dev_addr, mac, ETH_ALEN);
 	else {
 		printk(KERN_WARNING
diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index cc7e720..ffff9b9 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -239,7 +239,7 @@ static int mcs7830_set_mac_address(struct net_device *netdev, void *p)
 	if (netif_running(netdev))
 		return -EBUSY;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	ret = mcs7830_hif_set_mac_address(dev, addr->sa_data);
diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index b77ae76..dae7812 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -654,7 +654,7 @@ static void smsc75xx_init_mac_address(struct usbnet *dev)
 	/* try reading mac address from EEPROM */
 	if (smsc75xx_read_eeprom(dev, EEPROM_MAC_OFFSET, ETH_ALEN,
 			dev->net->dev_addr) == 0) {
-		if (is_valid_ether_addr(dev->net->dev_addr)) {
+		if (eth_addr_valid(dev->net->dev_addr)) {
 			/* eeprom values are valid so use them */
 			netif_dbg(dev, ifup, dev->net,
 				"MAC address read from EEPROM");
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 7479a57..6ad71fc 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -714,7 +714,7 @@ static void smsc95xx_init_mac_address(struct usbnet *dev)
 	/* try reading mac address from EEPROM */
 	if (smsc95xx_read_eeprom(dev, EEPROM_MAC_OFFSET, ETH_ALEN,
 			dev->net->dev_addr) == 0) {
-		if (is_valid_ether_addr(dev->net->dev_addr)) {
+		if (eth_addr_valid(dev->net->dev_addr)) {
 			/* eeprom values are valid so use them */
 			netif_dbg(dev, ifup, dev->net, "MAC address read from EEPROM\n");
 			return;
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index e522ff7..5c472d1 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -282,7 +282,7 @@ static int veth_validate(struct nlattr *tb[], struct nlattr *data[])
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
 			return -EINVAL;
-		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
+		if (!eth_addr_valid(nla_data(tb[IFLA_ADDRESS])))
 			return -EADDRNOTAVAIL;
 	}
 	if (tb[IFLA_MTU]) {
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 607976c..e15ada0 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -627,7 +627,7 @@ static __be32 vxlan_find_dst(struct vxlan_dev *vxlan, struct sk_buff *skb)
 	const struct ethhdr *eth = (struct ethhdr *) skb->data;
 	const struct vxlan_fdb *f;
 
-	if (is_multicast_ether_addr(eth->h_dest))
+	if (eth_addr_multicast(eth->h_dest))
 		return vxlan->gaddr;
 
 	f = vxlan_find_mac(vxlan, eth->h_dest);
@@ -1030,7 +1030,7 @@ static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
 			return -EINVAL;
 		}
 
-		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS]))) {
+		if (!eth_addr_valid(nla_data(tb[IFLA_ADDRESS]))) {
 			pr_debug("invalid all zero ethernet address\n");
 			return -EADDRNOTAVAIL;
 		}
diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 9c34d2f..0209271 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -243,7 +243,7 @@ int i2400m_check_mac_addr(struct i2400m *i2400m)
 		 "to that of boot mode's\n");
 	dev_warn(dev, "device reports     %pM\n", ddi->mac_address);
 	dev_warn(dev, "boot mode reported %pM\n", net_dev->perm_addr);
-	if (is_zero_ether_addr(ddi->mac_address))
+	if (eth_addr_zero(ddi->mac_address))
 		dev_err(dev, "device reports an invalid MAC address, "
 			"not updating\n");
 	else {
-- 
1.7.8.111.gad25c.dirty
