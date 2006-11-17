From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/4] chelsio: whitespace cleanup
Date: Fri, 17 Nov 2006 11:21:22 -0800
Message-ID: <20061117112122.30ca213e@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:39604 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1753017AbWKQUKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 15:10:04 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Whitespace cleanups.  Replace leading spaces with tabs and fix indentation

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/chelsio/cxgb2.c |  202 ++++++++++++++++++++++----------------------
 1 file changed, 101 insertions(+), 101 deletions(-)

--- chelsio-t2.orig/drivers/net/chelsio/cxgb2.c
+++ chelsio-t2/drivers/net/chelsio/cxgb2.c
@@ -120,7 +120,7 @@ static void t1_set_rxmode(struct net_dev
 static void link_report(struct port_info *p)
 {
 	if (!netif_carrier_ok(p->dev))
-        	printk(KERN_INFO "%s: link down\n", p->dev->name);
+		printk(KERN_INFO "%s: link down\n", p->dev->name);
 	else {
 		const char *s = "10Mbps";
 
@@ -130,7 +130,7 @@ static void link_report(struct port_info
 			case SPEED_100:   s = "100Mbps"; break;
 		}
 
-        printk(KERN_INFO "%s: link up, %s, %s-duplex\n",
+	printk(KERN_INFO "%s: link up, %s, %s-duplex\n",
 		       p->dev->name, s,
 		       p->link_config.duplex == DUPLEX_FULL ? "full" : "half");
 	}
@@ -261,7 +261,7 @@ static struct net_device_stats *t1_get_s
 
 	/* Do a full update of the MAC stats */
 	pstats = p->mac->ops->statistics_update(p->mac,
-						      MAC_STATS_UPDATE_FULL);
+						MAC_STATS_UPDATE_FULL);
 
 	ns->tx_packets = pstats->TxUnicastFramesOK +
 		pstats->TxMulticastFramesOK + pstats->TxBroadcastFramesOK;
@@ -315,39 +315,39 @@ static void set_msglevel(struct net_devi
 }
 
 static char stats_strings[][ETH_GSTRING_LEN] = {
-        "TxOctetsOK",
-        "TxOctetsBad",
-        "TxUnicastFramesOK",
-        "TxMulticastFramesOK",
-        "TxBroadcastFramesOK",
-        "TxPauseFrames",
-        "TxFramesWithDeferredXmissions",
-        "TxLateCollisions",
-        "TxTotalCollisions",
-        "TxFramesAbortedDueToXSCollisions",
-        "TxUnderrun",
-        "TxLengthErrors",
-        "TxInternalMACXmitError",
-        "TxFramesWithExcessiveDeferral",
-        "TxFCSErrors",
-
-        "RxOctetsOK",
-        "RxOctetsBad",
-        "RxUnicastFramesOK",
-        "RxMulticastFramesOK",
-        "RxBroadcastFramesOK",
-        "RxPauseFrames",
-        "RxFCSErrors",
-        "RxAlignErrors",
-        "RxSymbolErrors",
-        "RxDataErrors",
-        "RxSequenceErrors",
-        "RxRuntErrors",
-        "RxJabberErrors",
-        "RxInternalMACRcvError",
-        "RxInRangeLengthErrors",
-        "RxOutOfRangeLengthField",
-        "RxFrameTooLongErrors",
+	"TxOctetsOK",
+	"TxOctetsBad",
+	"TxUnicastFramesOK",
+	"TxMulticastFramesOK",
+	"TxBroadcastFramesOK",
+	"TxPauseFrames",
+	"TxFramesWithDeferredXmissions",
+	"TxLateCollisions",
+	"TxTotalCollisions",
+	"TxFramesAbortedDueToXSCollisions",
+	"TxUnderrun",
+	"TxLengthErrors",
+	"TxInternalMACXmitError",
+	"TxFramesWithExcessiveDeferral",
+	"TxFCSErrors",
+
+	"RxOctetsOK",
+	"RxOctetsBad",
+	"RxUnicastFramesOK",
+	"RxMulticastFramesOK",
+	"RxBroadcastFramesOK",
+	"RxPauseFrames",
+	"RxFCSErrors",
+	"RxAlignErrors",
+	"RxSymbolErrors",
+	"RxDataErrors",
+	"RxSequenceErrors",
+	"RxRuntErrors",
+	"RxJabberErrors",
+	"RxInternalMACRcvError",
+	"RxInRangeLengthErrors",
+	"RxOutOfRangeLengthField",
+	"RxFrameTooLongErrors",
 
 	"TSO",
 	"VLANextractions",
@@ -367,7 +367,7 @@ static char stats_strings[][ETH_GSTRING_
 	"tx_reg_pkts",
 	"tx_lso_pkts",
 	"tx_do_cksum",
-	
+
 	"espi_DIP2ParityErr",
 	"espi_DIP4Err",
 	"espi_RxDrops",
@@ -375,7 +375,7 @@ static char stats_strings[][ETH_GSTRING_
 	"espi_RxOvfl",
 	"espi_ParityErr"
 };
- 
+
 #define T2_REGMAP_SIZE (3 * 1024)
 
 static int get_regs_len(struct net_device *dev)
@@ -417,39 +417,39 @@ static void get_stats(struct net_device 
 	ss = t1_sge_get_port_stats(adapter->sge, dev->if_port);
 	t = t1_sge_get_intr_counts(adapter->sge);
 
-        *data++ = s->TxOctetsOK;
-        *data++ = s->TxOctetsBad;
-        *data++ = s->TxUnicastFramesOK;
-        *data++ = s->TxMulticastFramesOK;
-        *data++ = s->TxBroadcastFramesOK;
-        *data++ = s->TxPauseFrames;
-        *data++ = s->TxFramesWithDeferredXmissions;
-        *data++ = s->TxLateCollisions;
-        *data++ = s->TxTotalCollisions;
-        *data++ = s->TxFramesAbortedDueToXSCollisions;
-        *data++ = s->TxUnderrun;
-        *data++ = s->TxLengthErrors;
-        *data++ = s->TxInternalMACXmitError;
-        *data++ = s->TxFramesWithExcessiveDeferral;
-        *data++ = s->TxFCSErrors;
-
-        *data++ = s->RxOctetsOK;
-        *data++ = s->RxOctetsBad;
-        *data++ = s->RxUnicastFramesOK;
-        *data++ = s->RxMulticastFramesOK;
-        *data++ = s->RxBroadcastFramesOK;
-        *data++ = s->RxPauseFrames;
-        *data++ = s->RxFCSErrors;
-        *data++ = s->RxAlignErrors;
-        *data++ = s->RxSymbolErrors;
-        *data++ = s->RxDataErrors;
-        *data++ = s->RxSequenceErrors;
-        *data++ = s->RxRuntErrors;
-        *data++ = s->RxJabberErrors;
-        *data++ = s->RxInternalMACRcvError;
-        *data++ = s->RxInRangeLengthErrors;
-        *data++ = s->RxOutOfRangeLengthField;
-        *data++ = s->RxFrameTooLongErrors;
+	*data++ = s->TxOctetsOK;
+	*data++ = s->TxOctetsBad;
+	*data++ = s->TxUnicastFramesOK;
+	*data++ = s->TxMulticastFramesOK;
+	*data++ = s->TxBroadcastFramesOK;
+	*data++ = s->TxPauseFrames;
+	*data++ = s->TxFramesWithDeferredXmissions;
+	*data++ = s->TxLateCollisions;
+	*data++ = s->TxTotalCollisions;
+	*data++ = s->TxFramesAbortedDueToXSCollisions;
+	*data++ = s->TxUnderrun;
+	*data++ = s->TxLengthErrors;
+	*data++ = s->TxInternalMACXmitError;
+	*data++ = s->TxFramesWithExcessiveDeferral;
+	*data++ = s->TxFCSErrors;
+
+	*data++ = s->RxOctetsOK;
+	*data++ = s->RxOctetsBad;
+	*data++ = s->RxUnicastFramesOK;
+	*data++ = s->RxMulticastFramesOK;
+	*data++ = s->RxBroadcastFramesOK;
+	*data++ = s->RxPauseFrames;
+	*data++ = s->RxFCSErrors;
+	*data++ = s->RxAlignErrors;
+	*data++ = s->RxSymbolErrors;
+	*data++ = s->RxDataErrors;
+	*data++ = s->RxSequenceErrors;
+	*data++ = s->RxRuntErrors;
+	*data++ = s->RxJabberErrors;
+	*data++ = s->RxInternalMACRcvError;
+	*data++ = s->RxInRangeLengthErrors;
+	*data++ = s->RxOutOfRangeLengthField;
+	*data++ = s->RxFrameTooLongErrors;
 
 	*data++ = ss->tso;
 	*data++ = ss->vlan_xtract;
@@ -510,12 +510,12 @@ static int get_settings(struct net_devic
 		cmd->duplex = -1;
 	}
 
-        cmd->port = (cmd->supported & SUPPORTED_TP) ? PORT_TP : PORT_FIBRE;
-        cmd->phy_address = p->phy->addr;
-        cmd->transceiver = XCVR_EXTERNAL;
-        cmd->autoneg = p->link_config.autoneg;
-        cmd->maxtxpkt = 0;
-        cmd->maxrxpkt = 0;
+	cmd->port = (cmd->supported & SUPPORTED_TP) ? PORT_TP : PORT_FIBRE;
+	cmd->phy_address = p->phy->addr;
+	cmd->transceiver = XCVR_EXTERNAL;
+	cmd->autoneg = p->link_config.autoneg;
+	cmd->maxtxpkt = 0;
+	cmd->maxrxpkt = 0;
 	return 0;
 }
 
@@ -686,7 +686,7 @@ static int set_sge_param(struct net_devi
 		return -EINVAL;
 
 	if (adapter->flags & FULL_INIT_DONE)
-        return -EBUSY;
+	return -EBUSY;
 
 	adapter->params.sge.freelQ_size[!jumbo_fl] = e->rx_pending;
 	adapter->params.sge.freelQ_size[jumbo_fl] = e->rx_jumbo_pending;
@@ -793,34 +793,34 @@ static void cxgb_proc_cleanup(struct ada
 
 static int t1_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 {
-        struct adapter *adapter = dev->priv;
-        struct mii_ioctl_data *data = if_mii(req);
+	struct adapter *adapter = dev->priv;
+	struct mii_ioctl_data *data = if_mii(req);
 
 	switch (cmd) {
-        case SIOCGMIIPHY:
-                data->phy_id = adapter->port[dev->if_port].phy->addr;
-                /* FALLTHRU */
-        case SIOCGMIIREG: {
+	case SIOCGMIIPHY:
+		data->phy_id = adapter->port[dev->if_port].phy->addr;
+		/* FALLTHRU */
+	case SIOCGMIIREG: {
 		struct cphy *phy = adapter->port[dev->if_port].phy;
 		u32 val;
 
 		if (!phy->mdio_read)
-            return -EOPNOTSUPP;
+	    return -EOPNOTSUPP;
 		phy->mdio_read(adapter, data->phy_id, 0, data->reg_num & 0x1f,
 			       &val);
-                data->val_out = val;
-                break;
+		data->val_out = val;
+		break;
 	}
-        case SIOCSMIIREG: {
+	case SIOCSMIIREG: {
 		struct cphy *phy = adapter->port[dev->if_port].phy;
 
-                if (!capable(CAP_NET_ADMIN))
-                    return -EPERM;
+		if (!capable(CAP_NET_ADMIN))
+		    return -EPERM;
 		if (!phy->mdio_write)
-            return -EOPNOTSUPP;
+	    return -EOPNOTSUPP;
 		phy->mdio_write(adapter, data->phy_id, 0, data->reg_num & 0x1f,
 			        data->val_in);
-                break;
+		break;
 	}
 
 	default:
@@ -836,9 +836,9 @@ static int t1_change_mtu(struct net_devi
 	struct cmac *mac = adapter->port[dev->if_port].mac;
 
 	if (!mac->ops->set_mtu)
-        return -EOPNOTSUPP;
+	return -EOPNOTSUPP;
 	if (new_mtu < 68)
-        return -EINVAL;
+	return -EINVAL;
 	if ((ret = mac->ops->set_mtu(mac, new_mtu)))
 		return ret;
 	dev->mtu = new_mtu;
@@ -889,7 +889,7 @@ static void t1_netpoll(struct net_device
 	struct adapter *adapter = dev->priv;
 
 	local_irq_save(flags);
-        t1_select_intr_handler(adapter)(adapter->pdev->irq, adapter);
+	t1_select_intr_handler(adapter)(adapter->pdev->irq, adapter);
 	local_irq_restore(flags);
 }
 #endif
@@ -933,7 +933,7 @@ static void ext_intr_task(void *data)
 	adapter->slow_intr_mask |= F_PL_INTR_EXT;
 	writel(F_PL_INTR_EXT, adapter->regs + A_PL_CAUSE);
 	writel(adapter->slow_intr_mask | F_PL_INTR_SGE_DATA,
-                   adapter->regs + A_PL_ENABLE);
+		   adapter->regs + A_PL_ENABLE);
 	spin_unlock_irq(&adapter->async_lock);
 }
 
@@ -949,7 +949,7 @@ void t1_elmer0_ext_intr(struct adapter *
 	 */
 	adapter->slow_intr_mask &= ~F_PL_INTR_EXT;
 	writel(adapter->slow_intr_mask | F_PL_INTR_SGE_DATA,
-                   adapter->regs + A_PL_ENABLE);
+		   adapter->regs + A_PL_ENABLE);
 	schedule_work(&adapter->ext_intr_handler_task);
 }
 
@@ -982,7 +982,7 @@ static int __devinit init_one(struct pci
 
 	err = pci_enable_device(pdev);
 	if (err)
-        return err;
+		return err;
 
 	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
 		CH_ERR("%s: cannot find PCI device memory base address\n",
@@ -1014,7 +1014,7 @@ static int __devinit init_one(struct pci
 
 	pci_set_master(pdev);
 
-    mmio_start = pci_resource_start(pdev, 0);
+	mmio_start = pci_resource_start(pdev, 0);
 	mmio_len = pci_resource_len(pdev, 0);
 	bi = t1_get_board_info(ent->driver_data);
 
@@ -1107,7 +1107,7 @@ static int __devinit init_one(struct pci
 #endif
 		netdev->weight = 64;
 
-        SET_ETHTOOL_OPS(netdev, &t1_ethtool_ops);
+		SET_ETHTOOL_OPS(netdev, &t1_ethtool_ops);
 	}
 
 	if (t1_init_sw_modules(adapter, bi) < 0) {
@@ -1134,7 +1134,7 @@ static int __devinit init_one(struct pci
 			if (!adapter->registered_device_map)
 				adapter->name = adapter->port[i].dev->name;
 
-                __set_bit(i, &adapter->registered_device_map);
+			__set_bit(i, &adapter->registered_device_map);
 		}
 	}
 	if (!adapter->registered_device_map) {
