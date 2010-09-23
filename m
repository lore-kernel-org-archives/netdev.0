From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next2.6] drivers/net: return operator cleanup
Date: Thu, 23 Sep 2010 17:40:09 +0200
Message-ID: <1285256409.2509.79.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44079 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752578Ab0IWPkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 11:40:16 -0400
Received: by fxm3 with SMTP id 3so129795fxm.19
        for <netdev@vger.kernel.org>; Thu, 23 Sep 2010 08:40:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change "return (EXPR);" to "return EXPR;"

return is not a function, parentheses are not required.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/3c523.c                  |    2 
 drivers/net/appletalk/ipddp.c        |   10 
 drivers/net/appletalk/ltpc.c         |    2 
 drivers/net/atarilance.c             |   24 -
 drivers/net/atlx/atl1.c              |    4 
 drivers/net/benet/be_cmds.c          |    4 
 drivers/net/bmac.c                   |    2 
 drivers/net/bna/bna_ctrl.c           |    6 
 drivers/net/bnx2.c                   |   20 -
 drivers/net/bnx2x/bnx2x_cmn.h        |    4 
 drivers/net/bonding/bond_3ad.c       |    2 
 drivers/net/bsd_comp.c               |    2 
 drivers/net/cassini.c                |    4 
 drivers/net/chelsio/sge.c            |    2 
 drivers/net/chelsio/vsc7326.c        |    2 
 drivers/net/cxgb3/cxgb3_offload.c    |    2 
 drivers/net/de620.c                  |    2 
 drivers/net/defxx.c                  |   66 +--
 drivers/net/e100.c                   |    4 
 drivers/net/e1000/e1000_main.c       |    2 
 drivers/net/e1000e/ethtool.c         |    4 
 drivers/net/e1000e/netdev.c          |    2 
 drivers/net/enic/vnic_rq.h           |    2 
 drivers/net/eth16i.c                 |   12 
 drivers/net/forcedeth.c              |    2 
 drivers/net/fsl_pq_mdio.c            |    4 
 drivers/net/gianfar_ethtool.c        |    4 
 drivers/net/hamradio/bpqether.c      |    2 
 drivers/net/hamradio/hdlcdrv.c       |    2 
 drivers/net/hp100.c                  |    6 
 drivers/net/ibm_newemac/core.c       |    6 
 drivers/net/ibm_newemac/core.h       |    6 
 drivers/net/igb/igb_main.c           |    2 
 drivers/net/igbvf/ethtool.c          |    2 
 drivers/net/igbvf/netdev.c           |    2 
 drivers/net/irda/donauboe.c          |    4 
 drivers/net/irda/irda-usb.c          |    2 
 drivers/net/irda/nsc-ircc.c          |    2 
 drivers/net/irda/sir_dev.c           |    2 
 drivers/net/irda/smsc-ircc2.c        |    2 
 drivers/net/irda/stir4200.c          |    2 
 drivers/net/irda/via-ircc.h          |    2 
 drivers/net/irda/vlsi_ir.h           |    2 
 drivers/net/ixgb/ixgb_ee.c           |   32 -
 drivers/net/ixgb/ixgb_ethtool.c      |    2 
 drivers/net/ixgb/ixgb_hw.c           |   14 
 drivers/net/ixgbe/ixgbe_ethtool.c    |    6 
 drivers/net/ixgbe/ixgbe_main.c       |    2 
 drivers/net/ixgbevf/ixgbevf_main.c   |    2 
 drivers/net/ll_temac_main.c          |    2 
 drivers/net/lp486e.c                 |    2 
 drivers/net/meth.c                   |    2 
 drivers/net/mlx4/en_selftest.c       |    2 
 drivers/net/myri10ge/myri10ge.c      |    6 
 drivers/net/myri_sbus.c              |    2 
 drivers/net/netxen/netxen_nic_init.c |    4 
 drivers/net/netxen/netxen_nic_main.c |    2 
 drivers/net/niu.c                    |   13 
 drivers/net/pcmcia/nmclan_cs.c       |    2 
 drivers/net/pcmcia/smc91c92_cs.c     |    2 
 drivers/net/pcnet32.c                |    4 
 drivers/net/ps3_gelic_wireless.c     |    6 
 drivers/net/qlcnic/qlcnic_main.c     |    2 
 drivers/net/sfc/net_driver.h         |    2 
 drivers/net/sfc/nic.c                |   10 
 drivers/net/sis900.c                 |    6 
 drivers/net/skfp/cfm.c               |   10 
 drivers/net/skfp/drvfbi.c            |   16 
 drivers/net/skfp/ess.c               |   46 +-
 drivers/net/skfp/fplustm.c           |   24 -
 drivers/net/skfp/hwmtm.c             |   30 -
 drivers/net/skfp/hwt.c               |    4 
 drivers/net/skfp/pcmplc.c            |   22 -
 drivers/net/skfp/pmf.c               |   62 +--
 drivers/net/skfp/queue.c             |    2 
 drivers/net/skfp/skfddi.c            |   32 -
 drivers/net/skfp/smt.c               |   78 +--
 drivers/net/skfp/smtdef.c            |    4 
 drivers/net/skfp/smtinit.c           |    2 
 drivers/net/skfp/srf.c               |    2 
 drivers/net/slip.c                   |    2 
 drivers/net/sun3lance.c              |    4 
 drivers/net/sungem_phy.c             |    2 
 drivers/net/sunhme.c                 |    2 
 drivers/net/sunqe.c                  |    2 
 drivers/net/tc35815.c                |    2 
 drivers/net/tg3.c                    |    5 
 drivers/net/tlan.c                   |    2 
 drivers/net/tlan.h                   |    8 
 drivers/net/tokenring/proteon.c      |    2 
 drivers/net/tokenring/smctr.c        |  500 ++++++++++++-------------
 drivers/net/tokenring/tms380tr.c     |   58 +-
 drivers/net/tsi108_eth.c             |    2 
 drivers/net/tulip/de4x5.c            |   36 -
 drivers/net/tulip/uli526x.c          |    2 
 drivers/net/typhoon.c                |    2 
 drivers/net/usb/sierra_net.c         |    4 
 drivers/net/veth.c                   |    2 
 drivers/net/wan/dlci.c               |   42 +-
 drivers/net/wan/lmc/lmc_main.c       |    4 
 drivers/net/wan/n2.c                 |    4 
 drivers/net/wan/pc300_drv.c          |   18 
 drivers/net/wan/pc300_tty.c          |    2 
 drivers/net/wan/sdla.c               |  108 ++---
 drivers/net/wan/x25_asy.c            |    2 
 drivers/net/xen-netfront.c           |    6 
 106 files changed, 762 insertions(+), 764 deletions(-)

diff --git a/drivers/net/3c523.c b/drivers/net/3c523.c
index a7b0e5e..ca00f0a 100644
--- a/drivers/net/3c523.c
+++ b/drivers/net/3c523.c
@@ -463,7 +463,7 @@ static int __init do_elmc_probe(struct net_device *dev)
 
 	/* we didn't find any 3c523 in the slots we checked for */
 	if (slot == MCA_NOTFOUND)
-		return ((base_addr || irq) ? -ENXIO : -ENODEV);
+		return (base_addr || irq) ? -ENXIO : -ENODEV;
 
 	mca_set_adapter_name(slot, "3Com 3c523 Etherlink/MC");
 	mca_set_adapter_procfn(slot, (MCA_ProcFn) elmc_getinfo, dev);
diff --git a/drivers/net/appletalk/ipddp.c b/drivers/net/appletalk/ipddp.c
index 0362c8d..10d0dba 100644
--- a/drivers/net/appletalk/ipddp.c
+++ b/drivers/net/appletalk/ipddp.c
@@ -244,7 +244,7 @@ static int ipddp_delete(struct ipddp_route *rt)
         }
 
 	spin_unlock_bh(&ipddp_route_lock);
-        return (-ENOENT);
+        return -ENOENT;
 }
 
 /*
@@ -259,10 +259,10 @@ static struct ipddp_route* __ipddp_find_route(struct ipddp_route *rt)
                 if(f->ip == rt->ip &&
 		   f->at.s_net == rt->at.s_net &&
 		   f->at.s_node == rt->at.s_node)
-                        return (f);
+                        return f;
         }
 
-        return (NULL);
+        return NULL;
 }
 
 static int ipddp_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
@@ -279,7 +279,7 @@ static int ipddp_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
         switch(cmd)
         {
 		case SIOCADDIPDDPRT:
-                        return (ipddp_create(&rcp));
+                        return ipddp_create(&rcp);
 
                 case SIOCFINDIPDDPRT:
 			spin_lock_bh(&ipddp_route_lock);
@@ -297,7 +297,7 @@ static int ipddp_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 				return -ENOENT;
 
                 case SIOCDELIPDDPRT:
-                        return (ipddp_delete(&rcp));
+                        return ipddp_delete(&rcp);
 
                 default:
                         return -EINVAL;
diff --git a/drivers/net/appletalk/ltpc.c b/drivers/net/appletalk/ltpc.c
index adc0755..e69eead 100644
--- a/drivers/net/appletalk/ltpc.c
+++ b/drivers/net/appletalk/ltpc.c
@@ -727,7 +727,7 @@ static int sendup_buffer (struct net_device *dev)
 
 	if (ltc->command != LT_RCVLAP) {
 		printk("unknown command 0x%02x from ltpc card\n",ltc->command);
-		return(-1);
+		return -1;
 	}
 	dnode = ltc->dnode;
 	snode = ltc->snode;
diff --git a/drivers/net/atarilance.c b/drivers/net/atarilance.c
index b57d7de..3134e53 100644
--- a/drivers/net/atarilance.c
+++ b/drivers/net/atarilance.c
@@ -362,7 +362,7 @@ static void *slow_memcpy( void *dst, const void *src, size_t len )
 		*cto++ = *cfrom++;
 		MFPDELAY();
 	}
-	return( dst );
+	return dst;
 }
 

@@ -449,7 +449,7 @@ static noinline int __init addr_accessible(volatile void *regp, int wordflag,
 	vbr[2] = save_berr;
 	local_irq_restore(flags);
 
-	return( ret );
+	return ret;
 }
 
 static const struct net_device_ops lance_netdev_ops = {
@@ -526,7 +526,7 @@ static unsigned long __init lance_probe1( struct net_device *dev,
 	goto probe_ok;
 
   probe_fail:
-	return( 0 );
+	return 0;
 
   probe_ok:
 	lp = netdev_priv(dev);
@@ -556,7 +556,7 @@ static unsigned long __init lance_probe1( struct net_device *dev,
 		if (request_irq(IRQ_AUTO_5, lance_interrupt, IRQ_TYPE_PRIO,
 		            "PAM/Riebl-ST Ethernet", dev)) {
 			printk( "Lance: request for irq %d failed\n", IRQ_AUTO_5 );
-			return( 0 );
+			return 0;
 		}
 		dev->irq = (unsigned short)IRQ_AUTO_5;
 	}
@@ -568,12 +568,12 @@ static unsigned long __init lance_probe1( struct net_device *dev,
 		unsigned long irq = atari_register_vme_int();
 		if (!irq) {
 			printk( "Lance: request for VME interrupt failed\n" );
-			return( 0 );
+			return 0;
 		}
 		if (request_irq(irq, lance_interrupt, IRQ_TYPE_PRIO,
 		            "Riebl-VME Ethernet", dev)) {
 			printk( "Lance: request for irq %ld failed\n", irq );
-			return( 0 );
+			return 0;
 		}
 		dev->irq = irq;
 	}
@@ -637,7 +637,7 @@ static unsigned long __init lance_probe1( struct net_device *dev,
 	/* XXX MSch */
 	dev->watchdog_timeo = TX_TIMEOUT;
 
-	return( 1 );
+	return 1;
 }
 

@@ -666,7 +666,7 @@ static int lance_open( struct net_device *dev )
 		DPRINTK( 2, ( "lance_open(): opening %s failed, i=%d, csr0=%04x\n",
 					  dev->name, i, DREG ));
 		DREG = CSR0_STOP;
-		return( -EIO );
+		return -EIO;
 	}
 	DREG = CSR0_IDON;
 	DREG = CSR0_STRT;
@@ -676,7 +676,7 @@ static int lance_open( struct net_device *dev )
 
 	DPRINTK( 2, ( "%s: LANCE is open, csr0 %04x\n", dev->name, DREG ));
 
-	return( 0 );
+	return 0;
 }
 

@@ -1126,13 +1126,13 @@ static int lance_set_mac_address( struct net_device *dev, void *addr )
 	int i;
 
 	if (lp->cardtype != OLD_RIEBL && lp->cardtype != NEW_RIEBL)
-		return( -EOPNOTSUPP );
+		return -EOPNOTSUPP;
 
 	if (netif_running(dev)) {
 		/* Only possible while card isn't started */
 		DPRINTK( 1, ( "%s: hwaddr can be set only while card isn't open.\n",
 					  dev->name ));
-		return( -EIO );
+		return -EIO;
 	}
 
 	memcpy( dev->dev_addr, saddr->sa_data, dev->addr_len );
@@ -1142,7 +1142,7 @@ static int lance_set_mac_address( struct net_device *dev, void *addr )
 	/* set also the magic for future sessions */
 	*RIEBL_MAGIC_ADDR = RIEBL_MAGIC;
 
-	return( 0 );
+	return 0;
 }
 

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index e1e0171..4ba6431 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2094,9 +2094,9 @@ static u16 atl1_tpd_avail(struct atl1_tpd_ring *tpd_ring)
 {
 	u16 next_to_clean = atomic_read(&tpd_ring->next_to_clean);
 	u16 next_to_use = atomic_read(&tpd_ring->next_to_use);
-	return ((next_to_clean > next_to_use) ?
+	return (next_to_clean > next_to_use) ?
 		next_to_clean - next_to_use - 1 :
-		tpd_ring->count + next_to_clean - next_to_use - 1);
+		tpd_ring->count + next_to_clean - next_to_use - 1;
 }
 
 static int atl1_tso(struct atl1_adapter *adapter, struct sk_buff *skb,
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 34abcc9..0db28b4 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -98,9 +98,9 @@ static void be_async_link_state_process(struct be_adapter *adapter,
 
 static inline bool is_link_state_evt(u32 trailer)
 {
-	return (((trailer >> ASYNC_TRAILER_EVENT_CODE_SHIFT) &
+	return ((trailer >> ASYNC_TRAILER_EVENT_CODE_SHIFT) &
 		ASYNC_TRAILER_EVENT_CODE_MASK) ==
-				ASYNC_EVENT_CODE_LINK_STATE);
+				ASYNC_EVENT_CODE_LINK_STATE;
 }
 
 static struct be_mcc_compl *be_mcc_compl_get(struct be_adapter *adapter)
diff --git a/drivers/net/bmac.c b/drivers/net/bmac.c
index 9322699..a1b8c8b 100644
--- a/drivers/net/bmac.c
+++ b/drivers/net/bmac.c
@@ -1581,7 +1581,7 @@ bmac_proc_info(char *buffer, char **start, off_t offset, int length)
 	int i;
 
 	if (bmac_devs == NULL)
-		return (-ENOSYS);
+		return -ENOSYS;
 
 	len += sprintf(buffer, "BMAC counters & registers\n");
 
diff --git a/drivers/net/bna/bna_ctrl.c b/drivers/net/bna/bna_ctrl.c
index f3034d6..ddd922f 100644
--- a/drivers/net/bna/bna_ctrl.c
+++ b/drivers/net/bna/bna_ctrl.c
@@ -25,8 +25,8 @@
 static int
 bna_is_aen(u8 msg_id)
 {
-	return (msg_id == BFI_LL_I2H_LINK_DOWN_AEN ||
-		msg_id == BFI_LL_I2H_LINK_UP_AEN);
+	return msg_id == BFI_LL_I2H_LINK_DOWN_AEN ||
+	       msg_id == BFI_LL_I2H_LINK_UP_AEN;
 }
 
 static void
@@ -1702,7 +1702,7 @@ bna_device_cb_port_stopped(void *arg, enum bna_cb_status status)
 int
 bna_device_status_get(struct bna_device *device)
 {
-	return (device->fsm == (bfa_fsm_t)bna_device_sm_ready);
+	return device->fsm == (bfa_fsm_t)bna_device_sm_ready;
 }
 
 void
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 4ff76e3..3d1a5da 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -266,7 +266,7 @@ static inline u32 bnx2_tx_avail(struct bnx2 *bp, struct bnx2_tx_ring_info *txr)
 		if (diff == TX_DESC_CNT)
 			diff = MAX_TX_DESC_CNT;
 	}
-	return (bp->tx_ring_size - diff);
+	return bp->tx_ring_size - diff;
 }
 
 static u32
@@ -299,7 +299,7 @@ bnx2_shmem_wr(struct bnx2 *bp, u32 offset, u32 val)
 static u32
 bnx2_shmem_rd(struct bnx2 *bp, u32 offset)
 {
-	return (bnx2_reg_rd_ind(bp, bp->shmem_base + offset));
+	return bnx2_reg_rd_ind(bp, bp->shmem_base + offset);
 }
 
 static void
@@ -977,9 +977,9 @@ bnx2_report_fw_link(struct bnx2 *bp)
 static char *
 bnx2_xceiver_str(struct bnx2 *bp)
 {
-	return ((bp->phy_port == PORT_FIBRE) ? "SerDes" :
+	return (bp->phy_port == PORT_FIBRE) ? "SerDes" :
 		((bp->phy_flags & BNX2_PHY_FLAG_SERDES) ? "Remote Copper" :
-		 "Copper"));
+		 "Copper");
 }
 
 static void
@@ -1758,7 +1758,7 @@ __acquires(&bp->phy_lock)
 	u32 new_adv = 0;
 
 	if (bp->phy_flags & BNX2_PHY_FLAG_REMOTE_PHY_CAP)
-		return (bnx2_setup_remote_phy(bp, port));
+		return bnx2_setup_remote_phy(bp, port);
 
 	if (!(bp->autoneg & AUTONEG_SPEED)) {
 		u32 new_bmcr;
@@ -2171,10 +2171,10 @@ __acquires(&bp->phy_lock)
 		return 0;
 
 	if (bp->phy_flags & BNX2_PHY_FLAG_SERDES) {
-		return (bnx2_setup_serdes_phy(bp, port));
+		return bnx2_setup_serdes_phy(bp, port);
 	}
 	else {
-		return (bnx2_setup_copper_phy(bp));
+		return bnx2_setup_copper_phy(bp);
 	}
 }
 
@@ -7582,9 +7582,9 @@ bnx2_set_tx_csum(struct net_device *dev, u32 data)
 	struct bnx2 *bp = netdev_priv(dev);
 
 	if (CHIP_NUM(bp) == CHIP_NUM_5709)
-		return (ethtool_op_set_tx_ipv6_csum(dev, data));
+		return ethtool_op_set_tx_ipv6_csum(dev, data);
 	else
-		return (ethtool_op_set_tx_csum(dev, data));
+		return ethtool_op_set_tx_csum(dev, data);
 }
 
 static int
@@ -7705,7 +7705,7 @@ bnx2_change_mtu(struct net_device *dev, int new_mtu)
 		return -EINVAL;
 
 	dev->mtu = new_mtu;
-	return (bnx2_change_ring_size(bp, bp->rx_ring_size, bp->tx_ring_size));
+	return bnx2_change_ring_size(bp, bp->rx_ring_size, bp->tx_ring_size);
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index d1e6a8c..1ad08e4 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -399,7 +399,7 @@ static inline int bnx2x_has_tx_work_unload(struct bnx2x_fastpath *fp)
 {
 	/* Tell compiler that consumer and producer can change */
 	barrier();
-	return (fp->tx_pkt_prod != fp->tx_pkt_cons);
+	return fp->tx_pkt_prod != fp->tx_pkt_cons;
 }
 
 static inline u16 bnx2x_tx_avail(struct bnx2x_fastpath *fp)
@@ -632,7 +632,7 @@ static inline int bnx2x_has_rx_work(struct bnx2x_fastpath *fp)
 	rx_cons_sb = le16_to_cpu(*fp->rx_cons_sb);
 	if ((rx_cons_sb & MAX_RCQ_DESC_CNT) == MAX_RCQ_DESC_CNT)
 		rx_cons_sb++;
-	return (fp->rx_comp_cons != rx_cons_sb);
+	return fp->rx_comp_cons != rx_cons_sb;
 }
 
 /* HW Lock for shared dual port PHYs */
diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 822f586..2a47c1d 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -252,7 +252,7 @@ static inline void __enable_port(struct port *port)
  */
 static inline int __port_is_enabled(struct port *port)
 {
-	return(port->slave->state == BOND_STATE_ACTIVE);
+	return port->slave->state == BOND_STATE_ACTIVE;
 }
 
 /**
diff --git a/drivers/net/bsd_comp.c b/drivers/net/bsd_comp.c
index 88edb98..6e99d80 100644
--- a/drivers/net/bsd_comp.c
+++ b/drivers/net/bsd_comp.c
@@ -429,7 +429,7 @@ static void *bsd_alloc (unsigned char *options, int opt_len, int decomp)
 	if (!db->lens)
 	  {
 	    bsd_free (db);
-	    return (NULL);
+	    return NULL;
 	  }
       }
 /*
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 32aaadc..d6b6d6a 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -419,7 +419,7 @@ static u16 cas_phy_read(struct cas *cp, int reg)
 		udelay(10);
 		cmd = readl(cp->regs + REG_MIF_FRAME);
 		if (cmd & MIF_FRAME_TURN_AROUND_LSB)
-			return (cmd & MIF_FRAME_DATA_MASK);
+			return cmd & MIF_FRAME_DATA_MASK;
 	}
 	return 0xFFFF; /* -1 */
 }
@@ -804,7 +804,7 @@ static int cas_reset_mii_phy(struct cas *cp)
 			break;
 		udelay(10);
 	}
-	return (limit <= 0);
+	return limit <= 0;
 }
 
 static int cas_saturn_firmware_init(struct cas *cp)
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index 1950b9a..340b537 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1551,7 +1551,7 @@ static inline int responses_pending(const struct adapter *adapter)
 	const struct respQ *Q = &adapter->sge->respQ;
 	const struct respQ_e *e = &Q->entries[Q->cidx];
 
-	return (e->GenerationBit == Q->genbit);
+	return e->GenerationBit == Q->genbit;
 }
 
 /*
diff --git a/drivers/net/chelsio/vsc7326.c b/drivers/net/chelsio/vsc7326.c
index c844111..106a590 100644
--- a/drivers/net/chelsio/vsc7326.c
+++ b/drivers/net/chelsio/vsc7326.c
@@ -255,7 +255,7 @@ static int bist_rd(adapter_t *adapter, int moduleid, int address)
 	else if ((result & (1 << 8)) != 0x0)
 		pr_err("bist read error: 0x%x\n", result);
 
-	return (result & 0xff);
+	return result & 0xff;
 }
 
 static int bist_wr(adapter_t *adapter, int moduleid, int address, int value)
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index c6485b3..21db749 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -64,7 +64,7 @@ static inline int offload_activated(struct t3cdev *tdev)
 {
 	const struct adapter *adapter = tdev2adap(tdev);
 
-	return (test_bit(OFFLOAD_DEVMAP_BIT, &adapter->open_device_map));
+	return test_bit(OFFLOAD_DEVMAP_BIT, &adapter->open_device_map);
 }
 
 /**
diff --git a/drivers/net/de620.c b/drivers/net/de620.c
index f3650fd..1c51a75 100644
--- a/drivers/net/de620.c
+++ b/drivers/net/de620.c
@@ -676,7 +676,7 @@ static int de620_rx_intr(struct net_device *dev)
 	de620_set_register(dev, W_NPRF, next_rx_page);
 	pr_debug("next_rx_page=%d CPR=%d\n", next_rx_page, curr_page);
 
-	return (next_rx_page != curr_page); /* That was slightly tricky... */
+	return next_rx_page != curr_page; /* That was slightly tricky... */
 }
 
 /*********************************************
diff --git a/drivers/net/defxx.c b/drivers/net/defxx.c
index e5667c5..417e143 100644
--- a/drivers/net/defxx.c
+++ b/drivers/net/defxx.c
@@ -1024,7 +1024,7 @@ static int __devinit dfx_driver_init(struct net_device *dev,
 				 &data) != DFX_K_SUCCESS) {
 		printk("%s: Could not read adapter factory MAC address!\n",
 		       print_name);
-		return(DFX_K_FAILURE);
+		return DFX_K_FAILURE;
 	}
 	le32 = cpu_to_le32(data);
 	memcpy(&bp->factory_mac_addr[0], &le32, sizeof(u32));
@@ -1033,7 +1033,7 @@ static int __devinit dfx_driver_init(struct net_device *dev,
 				 &data) != DFX_K_SUCCESS) {
 		printk("%s: Could not read adapter factory MAC address!\n",
 		       print_name);
-		return(DFX_K_FAILURE);
+		return DFX_K_FAILURE;
 	}
 	le32 = cpu_to_le32(data);
 	memcpy(&bp->factory_mac_addr[4], &le32, sizeof(u16));
@@ -1075,7 +1075,7 @@ static int __devinit dfx_driver_init(struct net_device *dev,
 	if (top_v == NULL) {
 		printk("%s: Could not allocate memory for host buffers "
 		       "and structures!\n", print_name);
-		return(DFX_K_FAILURE);
+		return DFX_K_FAILURE;
 	}
 	memset(top_v, 0, alloc_size);	/* zero out memory before continuing */
 	top_p = bp->kmalloced_dma;	/* get physical address of buffer */
@@ -1145,7 +1145,7 @@ static int __devinit dfx_driver_init(struct net_device *dev,
 	DBG_printk("%s: Consumer block virt = %0lX, phys = %0X\n",
 		   print_name, (long)bp->cons_block_virt, bp->cons_block_phys);
 
-	return(DFX_K_SUCCESS);
+	return DFX_K_SUCCESS;
 }
 

@@ -1195,7 +1195,7 @@ static int dfx_adap_init(DFX_board_t *bp, int get_buffers)
 	if (dfx_hw_dma_uninit(bp, bp->reset_type) != DFX_K_SUCCESS)
 		{
 		printk("%s: Could not uninitialize/reset adapter!\n", bp->dev->name);
-		return(DFX_K_FAILURE);
+		return DFX_K_FAILURE;
 		}
 
 	/*
@@ -1229,7 +1229,7 @@ static int dfx_adap_init(DFX_board_t *bp, int get_buffers)
 							NULL) != DFX_K_SUCCESS)
 		{
 		printk("%s: Could not set adapter burst size!\n", bp->dev->name);
-		return(DFX_K_FAILURE);
+		return DFX_K_FAILURE;
 		}
 
 	/*
@@ -1246,7 +1246,7 @@ static int dfx_adap_init(DFX_board_t *bp, int get_buffers)
 							NULL) != DFX_K_SUCCESS)
 		{
 		printk("%s: Could not set consumer block address!\n", bp->dev->name);
-		return(DFX_K_FAILURE);
+		return DFX_K_FAILURE;
 		}
 
 	/*
@@ -1278,7 +1278,7 @@ static int dfx_adap_init(DFX_board_t *bp, int get_buffers)
 	if (dfx_hw_dma_cmd_req(bp) != DFX_K_SUCCESS)
 		{
 		printk("%s: DMA command request failed!\n", bp->dev->name);
-		return(DFX_K_FAILURE);
+		return DFX_K_FAILURE;
 		}
 
 	/* Set the initial values for eFDXEnable and MACTReq MIB objects */
@@ -1294,7 +1294,7 @@ static int dfx_adap_init(DFX_board_t *bp, int get_buffers)
 	if (dfx_hw_dma_cmd_req(bp) != DFX_K_SUCCESS)
 		{
 		printk("%s: DMA command request failed!\n", bp->dev->name);
-		return(DFX_K_FAILURE);
+		return DFX_K_FAILURE;
 		}
 
 	/* Initialize adapter CAM */
@@ -1302,7 +1302,7 @@ static int dfx_adap_init(DFX_board_t *bp, int get_buffers)
 	if (dfx_ctl_update_cam(bp) != DFX_K_SUCCESS)
 		{
 		printk("%s: Adapter CAM update failed!\n", bp->dev->name);
-		return(DFX_K_FAILURE);
+		return DFX_K_FAILURE;
 		}
 
 	/* Initialize adapter filters */
@@ -1310,7 +1310,7 @@ static int dfx_adap_init(DFX_board_t *bp, int get_buffers)
 	if (dfx_ctl_update_filters(bp) != DFX_K_SUCCESS)
 		{
 		printk("%s: Adapter filters update failed!\n", bp->dev->name);
-		return(DFX_K_FAILURE);
+		return DFX_K_FAILURE;
 		}
 
 	/*
@@ -1328,7 +1328,7 @@ static int dfx_adap_init(DFX_board_t *bp, int get_buffers)
 		printk("%s: Receive buffer allocation failed\n", bp->dev->name);
 		if (get_buffers)
 			dfx_rcv_flush(bp);
-		return(DFX_K_FAILURE);
+		return DFX_K_FAILURE;
 		}
 
 	/* Issue START command and bring adapter to LINK_(UN)AVAILABLE state */
@@ -1339,13 +1339,13 @@ static int dfx_adap_init(DFX_board_t *bp, int get_buffers)
 		printk("%s: Start command failed\n", bp->dev->name);
 		if (get_buffers)
 			dfx_rcv_flush(bp);
-		return(DFX_K_FAILURE);
+		return DFX_K_FAILURE;
 		}
 
 	/* Initialization succeeded, reenable PDQ interrupts */
 
 	dfx_port_write_long(bp, PI_PDQ_K_REG_HOST_INT_ENB, PI_HOST_INT_K_ENABLE_DEF_INTS);
-	return(DFX_K_SUCCESS);
+	return DFX_K_SUCCESS;
 	}
 

@@ -1434,7 +1434,7 @@ static int dfx_open(struct net_device *dev)
 
 	/* Set device structure info */
 	netif_start_queue(dev);
-	return(0);
+	return 0;
 }
 

@@ -1526,7 +1526,7 @@ static int dfx_close(struct net_device *dev)
 
 	free_irq(dev->irq, dev);
 
-	return(0);
+	return 0;
 }
 

@@ -2027,7 +2027,7 @@ static struct net_device_stats *dfx_ctl_get_stats(struct net_device *dev)
 
 	bp->cmd_req_virt->cmd_type = PI_CMD_K_SMT_MIB_GET;
 	if (dfx_hw_dma_cmd_req(bp) != DFX_K_SUCCESS)
-		return((struct net_device_stats *) &bp->stats);
+		return (struct net_device_stats *)&bp->stats;
 
 	/* Fill the bp->stats structure with the SMT MIB object values */
 
@@ -2128,7 +2128,7 @@ static struct net_device_stats *dfx_ctl_get_stats(struct net_device *dev)
 
 	bp->cmd_req_virt->cmd_type = PI_CMD_K_CNTRS_GET;
 	if (dfx_hw_dma_cmd_req(bp) != DFX_K_SUCCESS)
-		return((struct net_device_stats *) &bp->stats);
+		return (struct net_device_stats *)&bp->stats;
 
 	/* Fill the bp->stats structure with the FDDI counter values */
 
@@ -2144,7 +2144,7 @@ static struct net_device_stats *dfx_ctl_get_stats(struct net_device *dev)
 	bp->stats.port_lem_cts[0]			= bp->cmd_rsp_virt->cntrs_get.cntrs.link_errors[0].ls;
 	bp->stats.port_lem_cts[1]			= bp->cmd_rsp_virt->cntrs_get.cntrs.link_errors[1].ls;
 
-	return((struct net_device_stats *) &bp->stats);
+	return (struct net_device_stats *)&bp->stats;
 	}
 

@@ -2354,7 +2354,7 @@ static int dfx_ctl_set_mac_address(struct net_device *dev, void *addr)
 		{
 		DBG_printk("%s: Adapter CAM updated with new MAC address\n", dev->name);
 		}
-	return(0);			/* always return zero */
+	return 0;			/* always return zero */
 	}
 

@@ -2438,8 +2438,8 @@ static int dfx_ctl_update_cam(DFX_board_t *bp)
 	/* Issue command to update adapter CAM, then return */
 
 	if (dfx_hw_dma_cmd_req(bp) != DFX_K_SUCCESS)
-		return(DFX_K_FAILURE);
-	return(DFX_K_SUCCESS);
+		return DFX_K_FAILURE;
+	return DFX_K_SUCCESS;
 	}
 

@@ -2504,8 +2504,8 @@ static int dfx_ctl_update_filters(DFX_board_t *bp)
 	/* Issue command to update adapter filters, then return */
 
 	if (dfx_hw_dma_cmd_req(bp) != DFX_K_SUCCESS)
-		return(DFX_K_FAILURE);
-	return(DFX_K_SUCCESS);
+		return DFX_K_FAILURE;
+	return DFX_K_SUCCESS;
 	}
 

@@ -2561,7 +2561,7 @@ static int dfx_hw_dma_cmd_req(DFX_board_t *bp)
 		(status == PI_STATE_K_HALTED)		||
 		(status == PI_STATE_K_DMA_UNAVAIL)	||
 		(status == PI_STATE_K_UPGRADE))
-		return(DFX_K_OUTSTATE);
+		return DFX_K_OUTSTATE;
 
 	/* Put response buffer on the command response queue */
 
@@ -2599,7 +2599,7 @@ static int dfx_hw_dma_cmd_req(DFX_board_t *bp)
 		udelay(100);			/* wait for 100 microseconds */
 		}
 	if (timeout_cnt == 0)
-		return(DFX_K_HW_TIMEOUT);
+		return DFX_K_HW_TIMEOUT;
 
 	/* Bump (and wrap) the completion index and write out to register */
 
@@ -2619,14 +2619,14 @@ static int dfx_hw_dma_cmd_req(DFX_board_t *bp)
 		udelay(100);			/* wait for 100 microseconds */
 		}
 	if (timeout_cnt == 0)
-		return(DFX_K_HW_TIMEOUT);
+		return DFX_K_HW_TIMEOUT;
 
 	/* Bump (and wrap) the completion index and write out to register */
 
 	bp->cmd_rsp_reg.index.comp += 1;
 	bp->cmd_rsp_reg.index.comp &= PI_CMD_RSP_K_NUM_ENTRIES-1;
 	dfx_port_write_long(bp, PI_PDQ_K_REG_CMD_RSP_PROD, bp->cmd_rsp_reg.lword);
-	return(DFX_K_SUCCESS);
+	return DFX_K_SUCCESS;
 	}
 

@@ -2700,7 +2700,7 @@ static int dfx_hw_port_ctrl_req(
 		udelay(100);			/* wait for 100 microseconds */
 		}
 	if (timeout_cnt == 0)
-		return(DFX_K_HW_TIMEOUT);
+		return DFX_K_HW_TIMEOUT;
 
 	/*
 	 * If the address of host_data is non-zero, assume caller has supplied a
@@ -2710,7 +2710,7 @@ static int dfx_hw_port_ctrl_req(
 
 	if (host_data != NULL)
 		dfx_port_read_long(bp, PI_PDQ_K_REG_HOST_DATA, host_data);
-	return(DFX_K_SUCCESS);
+	return DFX_K_SUCCESS;
 	}
 

@@ -2800,7 +2800,7 @@ static int dfx_hw_adap_state_rd(DFX_board_t *bp)
 	PI_UINT32 port_status;		/* Port Status register value */
 
 	dfx_port_read_long(bp, PI_PDQ_K_REG_PORT_STATUS, &port_status);
-	return((port_status & PI_PSTATUS_M_STATE) >> PI_PSTATUS_V_STATE);
+	return (port_status & PI_PSTATUS_M_STATE) >> PI_PSTATUS_V_STATE;
 	}
 

@@ -2852,8 +2852,8 @@ static int dfx_hw_dma_uninit(DFX_board_t *bp, PI_UINT32 type)
 		udelay(100);					/* wait for 100 microseconds */
 		}
 	if (timeout_cnt == 0)
-		return(DFX_K_HW_TIMEOUT);
-	return(DFX_K_SUCCESS);
+		return DFX_K_HW_TIMEOUT;
+	return DFX_K_SUCCESS;
 	}
 
 /*
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 8e2eab4..b0aa9e6 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2215,10 +2215,10 @@ static int e100_change_mtu(struct net_device *netdev, int new_mtu)
 static int e100_asf(struct nic *nic)
 {
 	/* ASF can be enabled from eeprom */
-	return((nic->pdev->device >= 0x1050) && (nic->pdev->device <= 0x1057) &&
+	return (nic->pdev->device >= 0x1050) && (nic->pdev->device <= 0x1057) &&
 	   (nic->eeprom[eeprom_config_asf] & eeprom_asf) &&
 	   !(nic->eeprom[eeprom_config_asf] & eeprom_gcl) &&
-	   ((nic->eeprom[eeprom_smbus_addr] & 0xFF) != 0xFE));
+	   ((nic->eeprom[eeprom_smbus_addr] & 0xFF) != 0xFE);
 }
 
 static int e100_up(struct nic *nic)
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 8d9269d..fe817e4 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3557,7 +3557,7 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 	adapter->total_tx_packets += total_tx_packets;
 	netdev->stats.tx_bytes += total_tx_bytes;
 	netdev->stats.tx_packets += total_tx_packets;
-	return (count < tx_ring->count);
+	return count < tx_ring->count;
 }
 
 /**
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 6355a1b..b7f15b3 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -368,7 +368,7 @@ out:
 static u32 e1000_get_rx_csum(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	return (adapter->flags & FLAG_RX_CSUM_ENABLED);
+	return adapter->flags & FLAG_RX_CSUM_ENABLED;
 }
 
 static int e1000_set_rx_csum(struct net_device *netdev, u32 data)
@@ -389,7 +389,7 @@ static int e1000_set_rx_csum(struct net_device *netdev, u32 data)
 
 static u32 e1000_get_tx_csum(struct net_device *netdev)
 {
-	return ((netdev->features & NETIF_F_HW_CSUM) != 0);
+	return (netdev->features & NETIF_F_HW_CSUM) != 0;
 }
 
 static int e1000_set_tx_csum(struct net_device *netdev, u32 data)
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index e2c7e0d..ae90005 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1053,7 +1053,7 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 	adapter->total_tx_packets += total_tx_packets;
 	netdev->stats.tx_bytes += total_tx_bytes;
 	netdev->stats.tx_packets += total_tx_packets;
-	return (count < tx_ring->count);
+	return count < tx_ring->count;
 }
 
 /**
diff --git a/drivers/net/enic/vnic_rq.h b/drivers/net/enic/vnic_rq.h
index 2dc48f9..4b6f021 100644
--- a/drivers/net/enic/vnic_rq.h
+++ b/drivers/net/enic/vnic_rq.h
@@ -143,7 +143,7 @@ static inline void vnic_rq_post(struct vnic_rq *rq,
 
 static inline int vnic_rq_posting_soon(struct vnic_rq *rq)
 {
-	return ((rq->to_use->index & VNIC_RQ_RETURN_RATE) == 0);
+	return (rq->to_use->index & VNIC_RQ_RETURN_RATE) == 0;
 }
 
 static inline void vnic_rq_return_descs(struct vnic_rq *rq, unsigned int count)
diff --git a/drivers/net/eth16i.c b/drivers/net/eth16i.c
index ce22e15..fb717be 100644
--- a/drivers/net/eth16i.c
+++ b/drivers/net/eth16i.c
@@ -796,7 +796,7 @@ static int eth16i_receive_probe_packet(int ioaddr)
 
 			if(eth16i_debug > 1)
 				printk(KERN_DEBUG "RECEIVE_PACKET\n");
-			return(0); /* Found receive packet */
+			return 0; /* Found receive packet */
 		}
 	}
 
@@ -805,7 +805,7 @@ static int eth16i_receive_probe_packet(int ioaddr)
 		printk(KERN_DEBUG "RX_STATUS_REG = %x\n", inb(ioaddr + RX_STATUS_REG));
 	}
 
-	return(0); /* Return success */
+	return 0; /* Return success */
 }
 
 #if 0
@@ -841,7 +841,7 @@ static int __init eth16i_get_irq(int ioaddr)
 
 	if( ioaddr < 0x1000) {
 		cbyte = inb(ioaddr + JUMPERLESS_CONFIG);
-		return( eth16i_irqmap[ ((cbyte & 0xC0) >> 6) ] );
+		return eth16i_irqmap[((cbyte & 0xC0) >> 6)];
 	} else {  /* Oh..the card is EISA so method getting IRQ different */
 		unsigned short index = 0;
 		cbyte = inb(ioaddr + EISA_IRQ_REG);
@@ -849,7 +849,7 @@ static int __init eth16i_get_irq(int ioaddr)
 			cbyte = cbyte >> 1;
 			index++;
 		}
-		return( eth32i_irqmap[ index ] );
+		return eth32i_irqmap[index];
 	}
 }
 
@@ -909,7 +909,7 @@ static int eth16i_read_eeprom(int ioaddr, int offset)
 	data = eth16i_read_eeprom_word(ioaddr);
 	outb(CS_0 | SK_0, ioaddr + EEPROM_CTRL_REG);
 
-	return(data);
+	return data;
 }
 
 static int eth16i_read_eeprom_word(int ioaddr)
@@ -928,7 +928,7 @@ static int eth16i_read_eeprom_word(int ioaddr)
 		eeprom_slow_io();
 	}
 
-	return(data);
+	return data;
 }
 
 static void eth16i_eeprom_cmd(int ioaddr, unsigned char command)
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 6a44fe4..ddac63c 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -4620,7 +4620,7 @@ static int nv_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam*
 static u32 nv_get_rx_csum(struct net_device *dev)
 {
 	struct fe_priv *np = netdev_priv(dev);
-	return (np->rx_csum) != 0;
+	return np->rx_csum != 0;
 }
 
 static int nv_set_rx_csum(struct net_device *dev, u32 data)
diff --git a/drivers/net/fsl_pq_mdio.c b/drivers/net/fsl_pq_mdio.c
index d4bf91a..8d3a2cc 100644
--- a/drivers/net/fsl_pq_mdio.c
+++ b/drivers/net/fsl_pq_mdio.c
@@ -125,7 +125,7 @@ int fsl_pq_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value)
 	struct fsl_pq_mdio __iomem *regs = fsl_pq_mdio_get_regs(bus);
 
 	/* Write to the local MII regs */
-	return(fsl_pq_local_mdio_write(regs, mii_id, regnum, value));
+	return fsl_pq_local_mdio_write(regs, mii_id, regnum, value);
 }
 
 /*
@@ -137,7 +137,7 @@ int fsl_pq_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 	struct fsl_pq_mdio __iomem *regs = fsl_pq_mdio_get_regs(bus);
 
 	/* Read the local MII regs */
-	return(fsl_pq_local_mdio_read(regs, mii_id, regnum));
+	return fsl_pq_local_mdio_read(regs, mii_id, regnum);
 }
 
 /* Reset the MIIM registers, and wait for the bus to free */
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
index 9bda023..ae8e5d3 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -254,7 +254,7 @@ static unsigned int gfar_usecs2ticks(struct gfar_private *priv, unsigned int use
 
 	/* Make sure we return a number greater than 0
 	 * if usecs > 0 */
-	return ((usecs * 1000 + count - 1) / count);
+	return (usecs * 1000 + count - 1) / count;
 }
 
 /* Convert ethernet clock ticks to microseconds */
@@ -278,7 +278,7 @@ static unsigned int gfar_ticks2usecs(struct gfar_private *priv, unsigned int tic
 
 	/* Make sure we return a number greater than 0 */
 	/* if ticks is > 0 */
-	return ((ticks * count) / 1000);
+	return (ticks * count) / 1000;
 }
 
 /* Get the coalescing parameters, and put them in the cvals
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index 14f01d1..ac1d323 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -168,7 +168,7 @@ static inline struct net_device *bpq_get_ax25_dev(struct net_device *dev)
 
 static inline int dev_is_ethdev(struct net_device *dev)
 {
-	return (dev->type == ARPHRD_ETHER && strncmp(dev->name, "dummy", 5));
+	return dev->type == ARPHRD_ETHER && strncmp(dev->name, "dummy", 5);
 }
 
 /* ------------------------------------------------------------------------ */
diff --git a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
index b8bdf9d..5b37579 100644
--- a/drivers/net/hamradio/hdlcdrv.c
+++ b/drivers/net/hamradio/hdlcdrv.c
@@ -110,7 +110,7 @@ static int calc_crc_ccitt(const unsigned char *buf, int cnt)
 	for (; cnt > 0; cnt--)
 		crc = (crc >> 8) ^ crc_ccitt_table[(crc ^ *buf++) & 0xff];
 	crc ^= 0xffff;
-	return (crc & 0xffff);
+	return crc & 0xffff;
 }
 #endif
 
diff --git a/drivers/net/hp100.c b/drivers/net/hp100.c
index 095b17e..8e2c460 100644
--- a/drivers/net/hp100.c
+++ b/drivers/net/hp100.c
@@ -1312,7 +1312,7 @@ static int hp100_build_rx_pdl(hp100_ring_t * ringptr,
 		for (p = (ringptr->pdl); p < (ringptr->pdl + 5); p++)
 			printk("hp100: %s: Adr 0x%.8x = 0x%.8x\n", dev->name, (u_int) p, (u_int) * p);
 #endif
-		return (1);
+		return 1;
 	}
 	/* else: */
 	/* alloc_skb failed (no memory) -> still can receive the header
@@ -1325,7 +1325,7 @@ static int hp100_build_rx_pdl(hp100_ring_t * ringptr,
 
 	ringptr->pdl[0] = 0x00010000;	/* PDH: Count=1 Fragment */
 
-	return (0);
+	return 0;
 }
 
 /*
@@ -2752,7 +2752,7 @@ static int hp100_login_to_vg_hub(struct net_device *dev, u_short force_relogin)
 		hp100_outw(HP100_MISC_ERROR, IRQ_STATUS);
 
 		if (val & HP100_LINK_UP_ST)
-			return (0);	/* login was ok */
+			return 0;	/* login was ok */
 		else {
 			printk("hp100: %s: Training failed.\n", dev->name);
 			hp100_down_vg_link(dev);
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 3506fd6..3bdb4fa 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -2095,11 +2095,11 @@ static void *emac_dump_regs(struct emac_instance *dev, void *buf)
 	if (emac_has_feature(dev, EMAC_FTR_EMAC4)) {
 		hdr->version = EMAC4_ETHTOOL_REGS_VER;
 		memcpy_fromio(hdr + 1, dev->emacp, EMAC4_ETHTOOL_REGS_SIZE(dev));
-		return ((void *)(hdr + 1) + EMAC4_ETHTOOL_REGS_SIZE(dev));
+		return (void *)(hdr + 1) + EMAC4_ETHTOOL_REGS_SIZE(dev);
 	} else {
 		hdr->version = EMAC_ETHTOOL_REGS_VER;
 		memcpy_fromio(hdr + 1, dev->emacp, EMAC_ETHTOOL_REGS_SIZE(dev));
-		return ((void *)(hdr + 1) + EMAC_ETHTOOL_REGS_SIZE(dev));
+		return (void *)(hdr + 1) + EMAC_ETHTOOL_REGS_SIZE(dev);
 	}
 }
 
@@ -2293,7 +2293,7 @@ static int __devinit emac_check_deps(struct emac_instance *dev,
 		if (deps[i].drvdata != NULL)
 			there++;
 	}
-	return (there == EMAC_DEP_COUNT);
+	return there == EMAC_DEP_COUNT;
 }
 
 static void emac_put_deps(struct emac_instance *dev)
diff --git a/drivers/net/ibm_newemac/core.h b/drivers/net/ibm_newemac/core.h
index 9e37e3d..4fec084 100644
--- a/drivers/net/ibm_newemac/core.h
+++ b/drivers/net/ibm_newemac/core.h
@@ -410,7 +410,7 @@ static inline u32 *emac_xaht_base(struct emac_instance *dev)
 	else
 		offset = offsetof(struct emac_regs, u0.emac4.iaht1);
 
-	return ((u32 *)((ptrdiff_t)p + offset));
+	return (u32 *)((ptrdiff_t)p + offset);
 }
 
 static inline u32 *emac_gaht_base(struct emac_instance *dev)
@@ -418,7 +418,7 @@ static inline u32 *emac_gaht_base(struct emac_instance *dev)
 	/* GAHT registers always come after an identical number of
 	 * IAHT registers.
 	 */
-	return (emac_xaht_base(dev) + EMAC_XAHT_REGS(dev));
+	return emac_xaht_base(dev) + EMAC_XAHT_REGS(dev);
 }
 
 static inline u32 *emac_iaht_base(struct emac_instance *dev)
@@ -426,7 +426,7 @@ static inline u32 *emac_iaht_base(struct emac_instance *dev)
 	/* IAHT registers always come before an identical number of
 	 * GAHT registers.
 	 */
-	return (emac_xaht_base(dev));
+	return emac_xaht_base(dev);
 }
 
 /* Ethtool get_regs complex data.
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index c4d861b..4aef7e0 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -5430,7 +5430,7 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 	tx_ring->total_packets += total_packets;
 	tx_ring->tx_stats.bytes += total_bytes;
 	tx_ring->tx_stats.packets += total_packets;
-	return (count < tx_ring->count);
+	return count < tx_ring->count;
 }
 
 /**
diff --git a/drivers/net/igbvf/ethtool.c b/drivers/net/igbvf/ethtool.c
index 103b3aa..33add70 100644
--- a/drivers/net/igbvf/ethtool.c
+++ b/drivers/net/igbvf/ethtool.c
@@ -153,7 +153,7 @@ static int igbvf_set_rx_csum(struct net_device *netdev, u32 data)
 
 static u32 igbvf_get_tx_csum(struct net_device *netdev)
 {
-	return ((netdev->features & NETIF_F_IP_CSUM) != 0);
+	return (netdev->features & NETIF_F_IP_CSUM) != 0;
 }
 
 static int igbvf_set_tx_csum(struct net_device *netdev, u32 data)
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index c7fab80..2655013 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -845,7 +845,7 @@ static bool igbvf_clean_tx_irq(struct igbvf_ring *tx_ring)
 	}
 	adapter->net_stats.tx_bytes += total_bytes;
 	adapter->net_stats.tx_packets += total_packets;
-	return (count < tx_ring->count);
+	return count < tx_ring->count;
 }
 
 static irqreturn_t igbvf_msix_other(int irq, void *data)
diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index 48bd5ec..b626ccc 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -217,7 +217,7 @@ toshoboe_checkfcs (unsigned char *buf, int len)
   for (i = 0; i < len; ++i)
     fcs.value = irda_fcs (fcs.value, *(buf++));
 
-  return (fcs.value == GOOD_FCS);
+  return fcs.value == GOOD_FCS;
 }
 
 /***********************************************************************/
@@ -759,7 +759,7 @@ toshoboe_maketestpacket (unsigned char *buf, int badcrc, int fir)
   if (fir)
     {
       memset (buf, 0, TT_LEN);
-      return (TT_LEN);
+      return TT_LEN;
     }
 
   fcs.value = INIT_FCS;
diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index 4441fa3..cce82f1 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -1514,7 +1514,7 @@ static inline int irda_usb_parse_endpoints(struct irda_usb_cb *self, struct usb_
 	IRDA_DEBUG(0, "%s(), And our endpoints are : in=%02X, out=%02X (%d), int=%02X\n",
 		__func__, self->bulk_in_ep, self->bulk_out_ep, self->bulk_out_mtu, self->bulk_int_ep);
 
-	return((self->bulk_in_ep != 0) && (self->bulk_out_ep != 0));
+	return (self->bulk_in_ep != 0) && (self->bulk_out_ep != 0);
 }
 
 #ifdef IU_DUMP_CLASS_DESC
diff --git a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
index e30cdbb..559fe85 100644
--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -1348,7 +1348,7 @@ static __u8 nsc_ircc_change_speed(struct nsc_ircc_cb *self, __u32 speed)
 	outb(bank, iobase+BSR);
 
 	/* Make sure interrupt handlers keep the proper interrupt mask */
-	return(ier);
+	return ier;
 }
 
 /*
diff --git a/drivers/net/irda/sir_dev.c b/drivers/net/irda/sir_dev.c
index 1b051da..39d6e6f 100644
--- a/drivers/net/irda/sir_dev.c
+++ b/drivers/net/irda/sir_dev.c
@@ -336,7 +336,7 @@ static int sirdev_is_receiving(struct sir_dev *dev)
 	if (!atomic_read(&dev->enable_rx))
 		return 0;
 
-	return (dev->rx_buff.state != OUTSIDE_FRAME);
+	return dev->rx_buff.state != OUTSIDE_FRAME;
 }
 
 int sirdev_set_dongle(struct sir_dev *dev, IRDA_DONGLE type)
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index 850ca1c..8c57bfb 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -2051,7 +2051,7 @@ static int smsc_ircc_sir_write(int iobase, int fifo_size, __u8 *buf, int len)
  */
 static int smsc_ircc_is_receiving(struct smsc_ircc_cb *self)
 {
-	return (self->rx_buff.state != OUTSIDE_FRAME);
+	return self->rx_buff.state != OUTSIDE_FRAME;
 }
 

diff --git a/drivers/net/irda/stir4200.c b/drivers/net/irda/stir4200.c
index e5698fa..41c96b3 100644
--- a/drivers/net/irda/stir4200.c
+++ b/drivers/net/irda/stir4200.c
@@ -219,7 +219,7 @@ static inline int read_reg(struct stir_cb *stir, __u16 reg,
 
 static inline int isfir(u32 speed)
 {
-	return (speed == 4000000);
+	return speed == 4000000;
 }
 
 /*
diff --git a/drivers/net/irda/via-ircc.h b/drivers/net/irda/via-ircc.h
index 5a84822..c6f5848 100644
--- a/drivers/net/irda/via-ircc.h
+++ b/drivers/net/irda/via-ircc.h
@@ -238,7 +238,7 @@ static void WriteLPCReg(int iRegNum, unsigned char iVal)
 
 static __u8 ReadReg(unsigned int BaseAddr, int iRegNum)
 {
-	return ((__u8) inb(BaseAddr + iRegNum));
+	return (__u8) inb(BaseAddr + iRegNum);
 }
 
 static void WriteReg(unsigned int BaseAddr, int iRegNum, unsigned char iVal)
diff --git a/drivers/net/irda/vlsi_ir.h b/drivers/net/irda/vlsi_ir.h
index 3f24a1f..d66fab8 100644
--- a/drivers/net/irda/vlsi_ir.h
+++ b/drivers/net/irda/vlsi_ir.h
@@ -595,7 +595,7 @@ struct ring_descr {
 
 static inline int rd_is_active(struct ring_descr *rd)
 {
-	return ((rd->hw->rd_status & RD_ACTIVE) != 0);
+	return (rd->hw->rd_status & RD_ACTIVE) != 0;
 }
 
 static inline void rd_activate(struct ring_descr *rd)
diff --git a/drivers/net/ixgb/ixgb_ee.c b/drivers/net/ixgb/ixgb_ee.c
index 813993f..c982ab9 100644
--- a/drivers/net/ixgb/ixgb_ee.c
+++ b/drivers/net/ixgb/ixgb_ee.c
@@ -296,12 +296,12 @@ ixgb_wait_eeprom_command(struct ixgb_hw *hw)
 		eecd_reg = IXGB_READ_REG(hw, EECD);
 
 		if (eecd_reg & IXGB_EECD_DO)
-			return (true);
+			return true;
 
 		udelay(50);
 	}
 	ASSERT(0);
-	return (false);
+	return false;
 }
 
 /******************************************************************************
@@ -327,9 +327,9 @@ ixgb_validate_eeprom_checksum(struct ixgb_hw *hw)
 		checksum += ixgb_read_eeprom(hw, i);
 
 	if (checksum == (u16) EEPROM_SUM)
-		return (true);
+		return true;
 	else
-		return (false);
+		return false;
 }
 
 /******************************************************************************
@@ -439,7 +439,7 @@ ixgb_read_eeprom(struct ixgb_hw *hw,
 	/*  End this read operation  */
 	ixgb_standby_eeprom(hw);
 
-	return (data);
+	return data;
 }
 
 /******************************************************************************
@@ -476,16 +476,16 @@ ixgb_get_eeprom_data(struct ixgb_hw *hw)
 		/* clear the init_ctrl_reg_1 to signify that the cache is
 		 * invalidated */
 		ee_map->init_ctrl_reg_1 = cpu_to_le16(EEPROM_ICW1_SIGNATURE_CLEAR);
-		return (false);
+		return false;
 	}
 
 	if ((ee_map->init_ctrl_reg_1 & cpu_to_le16(EEPROM_ICW1_SIGNATURE_MASK))
 		 != cpu_to_le16(EEPROM_ICW1_SIGNATURE_VALID)) {
 		pr_debug("Signature invalid\n");
-		return(false);
+		return false;
 	}
 
-	return(true);
+	return true;
 }
 
 /******************************************************************************
@@ -505,7 +505,7 @@ ixgb_check_and_get_eeprom_data (struct ixgb_hw* hw)
 
 	if ((ee_map->init_ctrl_reg_1 & cpu_to_le16(EEPROM_ICW1_SIGNATURE_MASK))
 	    == cpu_to_le16(EEPROM_ICW1_SIGNATURE_VALID)) {
-		return (true);
+		return true;
 	} else {
 		return ixgb_get_eeprom_data(hw);
 	}
@@ -526,10 +526,10 @@ ixgb_get_eeprom_word(struct ixgb_hw *hw, u16 index)
 
 	if ((index < IXGB_EEPROM_SIZE) &&
 		(ixgb_check_and_get_eeprom_data(hw) == true)) {
-	   return(hw->eeprom[index]);
+	   return hw->eeprom[index];
 	}
 
-	return(0);
+	return 0;
 }
 
 /******************************************************************************
@@ -570,10 +570,10 @@ u32
 ixgb_get_ee_pba_number(struct ixgb_hw *hw)
 {
 	if (ixgb_check_and_get_eeprom_data(hw) == true)
-		return (le16_to_cpu(hw->eeprom[EEPROM_PBA_1_2_REG])
-			| (le16_to_cpu(hw->eeprom[EEPROM_PBA_3_4_REG])<<16));
+		return le16_to_cpu(hw->eeprom[EEPROM_PBA_1_2_REG])
+			| (le16_to_cpu(hw->eeprom[EEPROM_PBA_3_4_REG])<<16);
 
-	return(0);
+	return 0;
 }
 

@@ -591,8 +591,8 @@ ixgb_get_ee_device_id(struct ixgb_hw *hw)
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
 	if (ixgb_check_and_get_eeprom_data(hw) == true)
-		return (le16_to_cpu(ee_map->device_id));
+		return le16_to_cpu(ee_map->device_id);
 
-	return (0);
+	return 0;
 }
 
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index a4ed96c..43994c1 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -410,7 +410,7 @@ static int
 ixgb_get_eeprom_len(struct net_device *netdev)
 {
 	/* return size in bytes */
-	return (IXGB_EEPROM_SIZE << 1);
+	return IXGB_EEPROM_SIZE << 1;
 }
 
 static int
diff --git a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
index 397acab..6cb2e42 100644
--- a/drivers/net/ixgb/ixgb_hw.c
+++ b/drivers/net/ixgb/ixgb_hw.c
@@ -167,7 +167,7 @@ ixgb_adapter_stop(struct ixgb_hw *hw)
 	/* Clear any pending interrupt events. */
 	icr_reg = IXGB_READ_REG(hw, ICR);
 
-	return (ctrl_reg & IXGB_CTRL0_RST);
+	return ctrl_reg & IXGB_CTRL0_RST;
 }
 

@@ -209,7 +209,7 @@ ixgb_identify_xpak_vendor(struct ixgb_hw *hw)
 		xpak_vendor = ixgb_xpak_vendor_infineon;
 	}
 
-	return (xpak_vendor);
+	return xpak_vendor;
 }
 
 /******************************************************************************
@@ -273,7 +273,7 @@ ixgb_identify_phy(struct ixgb_hw *hw)
 	if (hw->subsystem_vendor_id == SUN_SUBVENDOR_ID)
 		phy_type = ixgb_phy_type_bcm;
 
-	return (phy_type);
+	return phy_type;
 }
 
 /******************************************************************************
@@ -366,7 +366,7 @@ ixgb_init_hw(struct ixgb_hw *hw)
 	/* 82597EX errata: Call check-for-link in case lane deskew is locked */
 	ixgb_check_for_link(hw);
 
-	return (status);
+	return status;
 }
 
 /******************************************************************************
@@ -531,7 +531,7 @@ ixgb_hash_mc_addr(struct ixgb_hw *hw,
 	}
 
 	hash_value &= 0xFFF;
-	return (hash_value);
+	return hash_value;
 }
 
 /******************************************************************************
@@ -715,7 +715,7 @@ ixgb_setup_fc(struct ixgb_hw *hw)
 		}
 		IXGB_WRITE_REG(hw, FCRTH, hw->fc.high_water);
 	}
-	return (status);
+	return status;
 }
 
 /******************************************************************************
@@ -1140,7 +1140,7 @@ mac_addr_valid(u8 *mac_addr)
 		pr_debug("MAC address is all zeros\n");
 		is_valid = false;
 	}
-	return (is_valid);
+	return is_valid;
 }
 
 /******************************************************************************
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 25ef8b1..d4ac943 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -401,7 +401,7 @@ static int ixgbe_set_pauseparam(struct net_device *netdev,
 static u32 ixgbe_get_rx_csum(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	return (adapter->flags & IXGBE_FLAG_RX_CSUM_ENABLED);
+	return adapter->flags & IXGBE_FLAG_RX_CSUM_ENABLED;
 }
 
 static int ixgbe_set_rx_csum(struct net_device *netdev, u32 data)
@@ -988,8 +988,8 @@ static int ixgbe_get_sset_count(struct net_device *netdev, int sset)
 	case ETH_SS_STATS:
 		return IXGBE_STATS_LEN;
 	case ETH_SS_NTUPLE_FILTERS:
-		return (ETHTOOL_MAX_NTUPLE_LIST_ENTRY *
-		        ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY);
+		return ETHTOOL_MAX_NTUPLE_LIST_ENTRY *
+		       ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY;
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index d03eef9..38df38f 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -826,7 +826,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 	tx_ring->total_packets += total_packets;
 	tx_ring->stats.packets += total_packets;
 	tx_ring->stats.bytes += total_bytes;
-	return (count < tx_ring->work_limit);
+	return count < tx_ring->work_limit;
 }
 
 #ifdef CONFIG_IXGBE_DCA
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 3eda1bd..0866a1c 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -311,7 +311,7 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_adapter *adapter,
 	netdev->stats.tx_bytes += total_bytes;
 	netdev->stats.tx_packets += total_packets;
 
-	return (count < tx_ring->work_limit);
+	return count < tx_ring->work_limit;
 }
 
 /**
diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index 874ee01..8762dcb 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -494,7 +494,7 @@ static u32 temac_setoptions(struct net_device *ndev, u32 options)
 	lp->options |= options;
 	mutex_unlock(&lp->indirect_mutex);
 
-	return (0);
+	return 0;
 }
 
 /* Initialize temac */
diff --git a/drivers/net/lp486e.c b/drivers/net/lp486e.c
index 3df046a..3698824 100644
--- a/drivers/net/lp486e.c
+++ b/drivers/net/lp486e.c
@@ -460,7 +460,7 @@ init_rx_bufs(struct net_device *dev, int num) {
 	}
 	lp->rbd_tail->next = rfd->rbd;
 #endif
-	return (i);
+	return i;
 }
 
 static inline void
diff --git a/drivers/net/meth.c b/drivers/net/meth.c
index 42e3294..60135aa 100644
--- a/drivers/net/meth.c
+++ b/drivers/net/meth.c
@@ -461,7 +461,7 @@ static int meth_tx_full(struct net_device *dev)
 {
 	struct meth_private *priv = netdev_priv(dev);
 
-	return (priv->tx_count >= TX_RING_ENTRIES - 1);
+	return priv->tx_count >= TX_RING_ENTRIES - 1;
 }
 
 static void meth_tx_cleanup(struct net_device* dev, unsigned long int_status)
diff --git a/drivers/net/mlx4/en_selftest.c b/drivers/net/mlx4/en_selftest.c
index 43357d3..9c91a92 100644
--- a/drivers/net/mlx4/en_selftest.c
+++ b/drivers/net/mlx4/en_selftest.c
@@ -107,7 +107,7 @@ static int mlx4_en_test_loopback(struct mlx4_en_priv *priv)
 mlx4_en_test_loopback_exit:
 
 	priv->validate_loopback = 0;
-	return (!loopback_ok);
+	return !loopback_ok;
 }
 

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 24ab8a4..4f3a3c0 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1555,12 +1555,12 @@ static irqreturn_t myri10ge_intr(int irq, void *arg)
 	 * valid  since MSI-X irqs are not shared */
 	if ((mgp->dev->real_num_tx_queues == 1) && (ss != mgp->ss)) {
 		napi_schedule(&ss->napi);
-		return (IRQ_HANDLED);
+		return IRQ_HANDLED;
 	}
 
 	/* make sure it is our IRQ, and that the DMA has finished */
 	if (unlikely(!stats->valid))
-		return (IRQ_NONE);
+		return IRQ_NONE;
 
 	/* low bit indicates receives are present, so schedule
 	 * napi poll handler */
@@ -1599,7 +1599,7 @@ static irqreturn_t myri10ge_intr(int irq, void *arg)
 		myri10ge_check_statblock(mgp);
 
 	put_be32(htonl(3), ss->irq_claim + 1);
-	return (IRQ_HANDLED);
+	return IRQ_HANDLED;
 }
 
 static int
diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index 617f898..4846e13 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -735,7 +735,7 @@ static int myri_header(struct sk_buff *skb, struct net_device *dev,
 		int i;
 		for (i = 0; i < dev->addr_len; i++)
 			eth->h_dest[i] = 0;
-		return(dev->hard_header_len);
+		return dev->hard_header_len;
 	}
 
 	if (daddr) {
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index cabae7b..9b05e7d 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -346,7 +346,7 @@ static u32 netxen_decode_crb_addr(u32 addr)
 	if (pci_base == NETXEN_ADDR_ERROR)
 		return pci_base;
 	else
-		return (pci_base + offset);
+		return pci_base + offset;
 }
 
 #define NETXEN_MAX_ROM_WAIT_USEC	100
@@ -1792,7 +1792,7 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter)
 	done = (sw_consumer == hw_consumer);
 	spin_unlock(&adapter->tx_clean_lock);
 
-	return (done);
+	return done;
 }
 
 void
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 73d3145..2c6ceeb 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -177,7 +177,7 @@ netxen_alloc_sds_rings(struct netxen_recv_context *recv_ctx, int count)
 
 	recv_ctx->sds_rings = kzalloc(size, GFP_KERNEL);
 
-	return (recv_ctx->sds_rings == NULL);
+	return recv_ctx->sds_rings == NULL;
 }
 
 static void
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index e36a838..4cd9242 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -283,7 +283,7 @@ static int niu_enable_interrupts(struct niu *np, int on)
 
 static u32 phy_encode(u32 type, int port)
 {
-	return (type << (port * 2));
+	return type << (port * 2);
 }
 
 static u32 phy_decode(u32 val, int port)
@@ -3043,8 +3043,7 @@ static int tcam_flush_all(struct niu *np)
 
 static u64 hash_addr_regval(unsigned long index, unsigned long num_entries)
 {
-	return ((u64)index | (num_entries == 1 ?
-			      HASH_TBL_ADDR_AUTOINC : 0));
+	return (u64)index | (num_entries == 1 ? HASH_TBL_ADDR_AUTOINC : 0);
 }
 
 #if 0
@@ -3276,7 +3275,7 @@ static u16 tcam_get_index(struct niu *np, u16 idx)
 	/* One entry reserved for IP fragment rule */
 	if (idx >= (np->clas.tcam_sz - 1))
 		idx = 0;
-	return (np->clas.tcam_top + ((idx+1) * np->parent->num_ports));
+	return np->clas.tcam_top + ((idx+1) * np->parent->num_ports);
 }
 
 static u16 tcam_get_size(struct niu *np)
@@ -3313,7 +3312,7 @@ static unsigned int niu_hash_rxaddr(struct rx_ring_info *rp, u64 a)
 	a >>= PAGE_SHIFT;
 	a ^= (a >> ilog2(MAX_RBR_RING_SIZE));
 
-	return (a & (MAX_RBR_RING_SIZE - 1));
+	return a & (MAX_RBR_RING_SIZE - 1);
 }
 
 static struct page *niu_find_rxpage(struct rx_ring_info *rp, u64 addr,
@@ -7796,11 +7795,11 @@ static int niu_get_sset_count(struct net_device *dev, int stringset)
 	if (stringset != ETH_SS_STATS)
 		return -EINVAL;
 
-	return ((np->flags & NIU_FLAGS_XMAC ?
+	return (np->flags & NIU_FLAGS_XMAC ?
 		 NUM_XMAC_STAT_KEYS :
 		 NUM_BMAC_STAT_KEYS) +
 		(np->num_rx_rings * NUM_RXCHAN_STAT_KEYS) +
-		(np->num_tx_rings * NUM_TXCHAN_STAT_KEYS));
+		(np->num_tx_rings * NUM_TXCHAN_STAT_KEYS);
 }
 
 static void niu_get_ethtool_stats(struct net_device *dev,
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index 89cf63b..c1d8ce9 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -521,7 +521,7 @@ static int mace_read(mace_private *lp, unsigned int ioaddr, int reg)
       spin_unlock_irqrestore(&lp->bank_lock, flags);
       break;
   }
-  return (data & 0xFF);
+  return data & 0xFF;
 } /* mace_read */
 
 /* ----------------------------------------------------------------------------
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 3d1c549..7204a4b 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -815,7 +815,7 @@ static int check_sig(struct pcmcia_device *link)
 	((s >> 8) != (s & 0xff))) {
 	SMC_SELECT_BANK(3);
 	s = inw(ioaddr + REVISION);
-	return (s & 0xff);
+	return s & 0xff;
     }
 
     if (width) {
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index c200c28..aee3bb0 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -376,7 +376,7 @@ static void pcnet32_wio_reset(unsigned long addr)
 static int pcnet32_wio_check(unsigned long addr)
 {
 	outw(88, addr + PCNET32_WIO_RAP);
-	return (inw(addr + PCNET32_WIO_RAP) == 88);
+	return inw(addr + PCNET32_WIO_RAP) == 88;
 }
 
 static struct pcnet32_access pcnet32_wio = {
@@ -431,7 +431,7 @@ static void pcnet32_dwio_reset(unsigned long addr)
 static int pcnet32_dwio_check(unsigned long addr)
 {
 	outl(88, addr + PCNET32_DWIO_RAP);
-	return ((inl(addr + PCNET32_DWIO_RAP) & 0xffff) == 88);
+	return (inl(addr + PCNET32_DWIO_RAP) & 0xffff) == 88;
 }
 
 static struct pcnet32_access pcnet32_dwio = {
diff --git a/drivers/net/ps3_gelic_wireless.c b/drivers/net/ps3_gelic_wireless.c
index 43b8d77..4a624a2 100644
--- a/drivers/net/ps3_gelic_wireless.c
+++ b/drivers/net/ps3_gelic_wireless.c
@@ -85,12 +85,12 @@ static const int bitrate_list[] = {
  */
 static inline int wpa2_capable(void)
 {
-	return (0 <= ps3_compare_firmware_version(2, 0, 0));
+	return 0 <= ps3_compare_firmware_version(2, 0, 0);
 }
 
 static inline int precise_ie(void)
 {
-	return (0 <= ps3_compare_firmware_version(2, 2, 0));
+	return 0 <= ps3_compare_firmware_version(2, 2, 0);
 }
 /*
  * post_eurus_cmd helpers
@@ -506,7 +506,7 @@ static size_t gelic_wl_synthesize_ie(u8 *buf,
 	start[1] = (buf - start - 2);
 
 	pr_debug("%s: ->\n", __func__);
-	return (buf - start);
+	return buf - start;
 }
 
 struct ie_item {
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 17124f6..a3d7705 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -172,7 +172,7 @@ qlcnic_alloc_sds_rings(struct qlcnic_recv_context *recv_ctx, int count)
 
 	recv_ctx->sds_rings = kzalloc(size, GFP_KERNEL);
 
-	return (recv_ctx->sds_rings == NULL);
+	return recv_ctx->sds_rings == NULL;
 }
 
 static void
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index b3f2bf4..ed3c7e3 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -987,7 +987,7 @@ static inline int efx_rx_queue_index(struct efx_rx_queue *rx_queue)
 static inline struct efx_rx_buffer *efx_rx_buffer(struct efx_rx_queue *rx_queue,
 						  unsigned int index)
 {
-	return (&rx_queue->buffer[index]);
+	return &rx_queue->buffer[index];
 }
 
 /* Set bit in a little-endian bitfield */
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index c4de001..394dd92 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -104,7 +104,7 @@ static inline void efx_write_buf_tbl(struct efx_nic *efx, efx_qword_t *value,
 static inline efx_qword_t *efx_event(struct efx_channel *channel,
 				     unsigned int index)
 {
-	return (((efx_qword_t *) (channel->eventq.addr)) + index);
+	return ((efx_qword_t *) (channel->eventq.addr)) + index;
 }
 
 /* See if an event is present
@@ -119,8 +119,8 @@ static inline efx_qword_t *efx_event(struct efx_channel *channel,
  */
 static inline int efx_event_present(efx_qword_t *event)
 {
-	return (!(EFX_DWORD_IS_ALL_ONES(event->dword[0]) |
-		  EFX_DWORD_IS_ALL_ONES(event->dword[1])));
+	return !(EFX_DWORD_IS_ALL_ONES(event->dword[0]) |
+		  EFX_DWORD_IS_ALL_ONES(event->dword[1]));
 }
 
 static bool efx_masked_compare_oword(const efx_oword_t *a, const efx_oword_t *b,
@@ -347,7 +347,7 @@ void efx_nic_free_buffer(struct efx_nic *efx, struct efx_buffer *buffer)
 static inline efx_qword_t *
 efx_tx_desc(struct efx_tx_queue *tx_queue, unsigned int index)
 {
-	return (((efx_qword_t *) (tx_queue->txd.addr)) + index);
+	return ((efx_qword_t *) (tx_queue->txd.addr)) + index;
 }
 
 /* This writes to the TX_DESC_WPTR; write pointer for TX descriptor ring */
@@ -502,7 +502,7 @@ void efx_nic_remove_tx(struct efx_tx_queue *tx_queue)
 static inline efx_qword_t *
 efx_rx_desc(struct efx_rx_queue *rx_queue, unsigned int index)
 {
-	return (((efx_qword_t *) (rx_queue->rxd.addr)) + index);
+	return ((efx_qword_t *) (rx_queue->rxd.addr)) + index;
 }
 
 /* This creates an entry in the RX descriptor queue */
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index ffdd859..5818368 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -832,7 +832,7 @@ static u16 __devinit read_eeprom(long ioaddr, int location)
 	outl(0, ee_addr);
 	eeprom_delay();
 
-	return (retval);
+	return retval;
 }
 
 /* Read and write the MII management registers using software-generated
@@ -2247,9 +2247,9 @@ static inline u16 sis900_mcast_bitnr(u8 *addr, u8 revision)
 
 	/* leave 8 or 7 most siginifant bits */
 	if ((revision >= SIS635A_900_REV) || (revision == SIS900B_900_REV))
-		return ((int)(crc >> 24));
+		return (int)(crc >> 24);
 	else
-		return ((int)(crc >> 25));
+		return (int)(crc >> 25);
 }
 
 /**
diff --git a/drivers/net/skfp/cfm.c b/drivers/net/skfp/cfm.c
index 5310d39..e395ace 100644
--- a/drivers/net/skfp/cfm.c
+++ b/drivers/net/skfp/cfm.c
@@ -542,8 +542,8 @@ static void cfm_fsm(struct s_smc *smc, int cmd)
  */
 int cfm_get_mac_input(struct s_smc *smc)
 {
-	return((smc->mib.fddiSMTCF_State == SC10_C_WRAP_B ||
-		smc->mib.fddiSMTCF_State == SC5_THRU_B) ? PB : PA) ;
+	return (smc->mib.fddiSMTCF_State == SC10_C_WRAP_B ||
+		smc->mib.fddiSMTCF_State == SC5_THRU_B) ? PB : PA;
 }
 
 /*
@@ -553,8 +553,8 @@ int cfm_get_mac_input(struct s_smc *smc)
  */
 int cfm_get_mac_output(struct s_smc *smc)
 {
-	return((smc->mib.fddiSMTCF_State == SC10_C_WRAP_B ||
-		smc->mib.fddiSMTCF_State == SC4_THRU_A) ? PB : PA) ;
+	return (smc->mib.fddiSMTCF_State == SC10_C_WRAP_B ||
+		smc->mib.fddiSMTCF_State == SC4_THRU_A) ? PB : PA;
 }
 
 static char path_iso[] = {
@@ -623,5 +623,5 @@ int cem_build_path(struct s_smc *smc, char *to, int path_index)
 
 	LINT_USE(path_index);
 
-	return(len) ;
+	return len;
 }
diff --git a/drivers/net/skfp/drvfbi.c b/drivers/net/skfp/drvfbi.c
index c77cc14..07da97c 100644
--- a/drivers/net/skfp/drvfbi.c
+++ b/drivers/net/skfp/drvfbi.c
@@ -267,7 +267,7 @@ void timer_irq(struct s_smc *smc)
 int pcm_get_s_port(struct s_smc *smc)
 {
 	SK_UNUSED(smc) ;
-	return(PS) ;
+	return PS;
 }
 
 /*
@@ -366,7 +366,7 @@ void sm_pm_bypass_req(struct s_smc *smc, int mode)
  */
 int sm_pm_bypass_present(struct s_smc *smc)
 {
-	return(	(inp(ADDR(B0_DAS)) & DAS_BYP_ST) ? TRUE: FALSE) ;
+	return (inp(ADDR(B0_DAS)) & DAS_BYP_ST) ? TRUE : FALSE;
 }
 
 void plc_clear_irq(struct s_smc *smc, int p)
@@ -483,9 +483,9 @@ static int is_equal_num(char comp1[], char comp2[], int num)
 
 	for (i = 0 ; i < num ; i++) {
 		if (comp1[i] != comp2[i])
-			return (0) ;
+			return 0;
 	}
-		return (1) ;
+		return 1;
 }	/* is_equal_num */
 

@@ -522,18 +522,18 @@ int set_oi_id_def(struct s_smc *smc)
 			i++ ;
 			break ;			/* entry ok */
 		default:
-			return (1) ;		/* invalid oi_status */
+			return 1;		/* invalid oi_status */
 		}
 	}
 
 	if (i == 0)
-		return (2) ;
+		return 2;
 	if (!act_entries)
-		return (3) ;
+		return 3;
 
 	/* ok, we have a valid OEM data base with an active entry */
 	smc->hw.oem_id = (struct s_oem_ids *)  &oem_ids[sel_id] ;
-	return (0) ;
+	return 0;
 }
 #endif	/* MULT_OEM */
 
diff --git a/drivers/net/skfp/ess.c b/drivers/net/skfp/ess.c
index e8387d2..8639a08 100644
--- a/drivers/net/skfp/ess.c
+++ b/drivers/net/skfp/ess.c
@@ -135,7 +135,7 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
 	 */
 	if (!(p = (void *) sm_to_para(smc,sm,SMT_P0015))) {
 		DB_ESS("ESS: RAF frame error, parameter type not found\n",0,0) ;
-		return(fs) ;
+		return fs;
 	}
 	msg_res_type = ((struct smt_p_0015 *)p)->res_type ;
 
@@ -147,7 +147,7 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
 		 * error in frame: para ESS command was not found
 		 */
 		 DB_ESS("ESS: RAF frame error, parameter command not found\n",0,0);
-		 return(fs) ;
+		 return fs;
 	}
 
 	DB_ESSN(2,"fc %x	ft %x\n",sm->smt_class,sm->smt_type) ;
@@ -175,12 +175,12 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
 			 * local and no static allocation is used
 			 */
 			if (!local || smc->mib.fddiESSPayload)
-				return(fs) ;
+				return fs;
 			
 			p = (void *) sm_to_para(smc,sm,SMT_P0019)  ;
 			for (i = 0; i < 5; i++) {
 				if (((struct smt_p_0019 *)p)->alloc_addr.a[i]) {
-					return(fs) ;
+					return fs;
 				}
 			}
 
@@ -199,10 +199,10 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
 			sm->smt_dest = smt_sba_da ;
 
 			if (smc->ess.local_sba_active)
-				return(fs | I_INDICATOR) ;
+				return fs | I_INDICATOR;
 
 			if (!(db = smt_get_mbuf(smc)))
-				return(fs) ;
+				return fs;
 
 			db->sm_len = mb->sm_len ;
 			db->sm_off = mb->sm_off ;
@@ -212,7 +212,7 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
 				(struct smt_header *)(db->sm_data+db->sm_off),
 				"RAF") ;
 			smt_send_frame(smc,db,FC_SMT_INFO,0) ;
-			return(fs) ;
+			return fs;
 		}
 
 		/*
@@ -221,7 +221,7 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
 		 */
 		if (smt_check_para(smc,sm,plist_raf_alc_res)) {
 			DB_ESS("ESS: RAF with para problem, ignoring\n",0,0) ;
-			return(fs) ;
+			return fs;
 		}
 
 		/*
@@ -242,7 +242,7 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
 			(sm->smt_tid != smc->ess.alloc_trans_id)) {
 
 			DB_ESS("ESS: Allocation Responce not accepted\n",0,0) ;
-			return(fs) ;
+			return fs;
 		}
 
 		/*
@@ -268,7 +268,7 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
 		 */
 		(void)process_bw_alloc(smc,(long)payload,(long)overhead) ;
 
-		return(fs) ;
+		return fs;
 		/* end of Process Allocation Request */
 
 	/*
@@ -280,7 +280,7 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
 		 */
 		if (sm->smt_type != SMT_REQUEST) {
 			DB_ESS("ESS: Do not process Change Responses\n",0,0) ;
-			return(fs) ;
+			return fs;
 		}
 
 		/*
@@ -288,7 +288,7 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
 		 */
 		if (smt_check_para(smc,sm,plist_raf_chg_req)) {
 			DB_ESS("ESS: RAF with para problem, ignoring\n",0,0) ;
-			return(fs) ;
+			return fs;
 		}
 
 		/*
@@ -300,7 +300,7 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
 		if ((((struct smt_p_320b *)sm_to_para(smc,sm,SMT_P320B))->path_index
 			!= PRIMARY_RING) || (msg_res_type != SYNC_BW)) {
 			DB_ESS("ESS: RAF frame with para problem, ignoring\n",0,0) ;
-			return(fs) ;
+			return fs;
 		}
 
 		/*
@@ -319,14 +319,14 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
 		 * process the bandwidth allocation
 		 */
 		if(!process_bw_alloc(smc,(long)payload,(long)overhead))
-			return(fs) ;
+			return fs;
 
 		/*
 		 * send an RAF Change Reply
 		 */
 		ess_send_response(smc,sm,CHANGE_ALLOCATION) ;
 
-		return(fs) ;
+		return fs;
 		/* end of Process Change Request */
 
 	/*
@@ -338,7 +338,7 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
 		 */
 		if (sm->smt_type != SMT_REQUEST) {
 			DB_ESS("ESS: Do not process a Report Reply\n",0,0) ;
-			return(fs) ;
+			return fs;
 		}
 
 		DB_ESSN(2,"ESS: Report Request from %s\n",
@@ -349,7 +349,7 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
 		 */
 		if (msg_res_type != SYNC_BW) {
 			DB_ESS("ESS: ignoring RAF with para problem\n",0,0) ;
-			return(fs) ;
+			return fs;
 		}
 
 		/*
@@ -357,7 +357,7 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
 		 */
 		ess_send_response(smc,sm,REPORT_ALLOCATION) ;
 
-		return(fs) ;
+		return fs;
 		/* end of Process Report Request */
 
 	default:
@@ -368,7 +368,7 @@ int ess_raf_received_pack(struct s_smc *smc, SMbuf *mb, struct smt_header *sm,
 		break ;
 	}
 
-	return(fs) ;
+	return fs;
 }
 
 /*
@@ -418,17 +418,17 @@ static int process_bw_alloc(struct s_smc *smc, long int payload, long int overhe
 	 */
 /*	if (smt_set_obj(smc,SMT_P320F,payload,S_SET)) {
 		DB_ESS("ESS: SMT does not accept the payload value\n",0,0) ;
-		return(FALSE) ;
+		return FALSE;
 	}
 	if (smt_set_obj(smc,SMT_P3210,overhead,S_SET)) {
 		DB_ESS("ESS: SMT does not accept the overhead value\n",0,0) ;
-		return(FALSE) ;
+		return FALSE;
 	} */
 
 	/* premliminary */
 	if (payload > MAX_PAYLOAD || overhead > 5000) {
 		DB_ESS("ESS: payload / overhead not accepted\n",0,0) ;
-		return(FALSE) ;
+		return FALSE;
 	}
 
 	/*
@@ -468,7 +468,7 @@ static int process_bw_alloc(struct s_smc *smc, long int payload, long int overhe
 
 	ess_config_fifo(smc) ;
 	set_formac_tsync(smc,smc->ess.sync_bw) ;
-	return(TRUE) ;
+	return TRUE;
 }
 
 static void ess_send_response(struct s_smc *smc, struct smt_header *sm,
diff --git a/drivers/net/skfp/fplustm.c b/drivers/net/skfp/fplustm.c
index 9d8d1ac..ca4e7bb 100644
--- a/drivers/net/skfp/fplustm.c
+++ b/drivers/net/skfp/fplustm.c
@@ -112,8 +112,8 @@ static u_long mac_get_tneg(struct s_smc *smc)
 	u_long	tneg ;
 
 	tneg = (u_long)((long)inpw(FM_A(FM_TNEG))<<5) ;
-	return((u_long)((tneg + ((inpw(FM_A(FM_TMRS))>>10)&0x1f)) |
-		0xffe00000L)) ;
+	return (u_long)((tneg + ((inpw(FM_A(FM_TMRS))>>10)&0x1f)) |
+		0xffe00000L) ;
 }
 
 void mac_update_counter(struct s_smc *smc)
@@ -163,7 +163,7 @@ static u_long read_mdr(struct s_smc *smc, unsigned int addr)
 			/* is used */
 	p = (u_long)inpw(FM_A(FM_MDRU))<<16 ;
 	p += (u_long)inpw(FM_A(FM_MDRL)) ;
-	return(p) ;
+	return p;
 }
 #endif
 
@@ -887,7 +887,7 @@ int init_fplus(struct s_smc *smc)
 	/* make sure all PCI settings are correct */
 	mac_do_pci_fix(smc) ;
 
-	return(init_mac(smc,1)) ;
+	return init_mac(smc, 1);
 	/* enable_formac(smc) ; */
 }
 
@@ -989,7 +989,7 @@ static int init_mac(struct s_smc *smc, int all)
 	}
 	smc->hw.hw_state = STARTED ;
 
-	return(0) ;
+	return 0;
 }
 

@@ -1049,7 +1049,7 @@ void sm_ma_control(struct s_smc *smc, int mode)
 
 int sm_mac_get_tx_state(struct s_smc *smc)
 {
-	return((inpw(FM_A(FM_STMCHN))>>4)&7) ;
+	return (inpw(FM_A(FM_STMCHN))>>4) & 7;
 }
 
 /*
@@ -1084,9 +1084,9 @@ static struct s_fpmc* mac_get_mc_table(struct s_smc *smc,
 		}
 		if (memcmp((char *)&tb->a,(char *)own,6))
 			continue ;
-		return(tb) ;
+		return tb;
 	}
-	return(slot) ;			/* return first free or NULL */
+	return slot;			/* return first free or NULL */
 }
 
 /*
@@ -1152,12 +1152,12 @@ int mac_add_multicast(struct s_smc *smc, struct fddi_addr *addr, int can)
 	 */
 	if (can & 0x80) {
 		if (smc->hw.fp.smt_slots_used >= SMT_MAX_MULTI) {
-			return(1) ;
+			return 1;
 		}
 	}
 	else {
 		if (smc->hw.fp.os_slots_used >= FPMAX_MULTICAST-SMT_MAX_MULTI) {
-			return(1) ;
+			return 1;
 		}
 	}
 
@@ -1165,7 +1165,7 @@ int mac_add_multicast(struct s_smc *smc, struct fddi_addr *addr, int can)
 	 * find empty slot
 	 */
 	if (!(tb = mac_get_mc_table(smc,addr,&own,0,can & ~0x80)))
-		return(1) ;
+		return 1;
 	tb->n++ ;
 	tb->a = own ;
 	tb->perm = (can & 0x80) ? 1 : 0 ;
@@ -1175,7 +1175,7 @@ int mac_add_multicast(struct s_smc *smc, struct fddi_addr *addr, int can)
 	else
 		smc->hw.fp.os_slots_used++ ;
 
-	return(0) ;
+	return 0;
 }
 
 /*
diff --git a/drivers/net/skfp/hwmtm.c b/drivers/net/skfp/hwmtm.c
index d322f1b..af5a755 100644
--- a/drivers/net/skfp/hwmtm.c
+++ b/drivers/net/skfp/hwmtm.c
@@ -232,16 +232,16 @@ u_int mac_drv_check_space(void)
 #ifdef	COMMON_MB_POOL
 	call_count++ ;
 	if (call_count == 1) {
-		return(EXT_VIRT_MEM) ;
+		return EXT_VIRT_MEM;
 	}
 	else {
-		return(EXT_VIRT_MEM_2) ;
+		return EXT_VIRT_MEM_2;
 	}
 #else
-	return (EXT_VIRT_MEM) ;
+	return EXT_VIRT_MEM;
 #endif
 #else
-	return (0) ;
+	return 0;
 #endif
 }
 
@@ -271,7 +271,7 @@ int mac_drv_init(struct s_smc *smc)
 	if (!(smc->os.hwm.descr_p = (union s_fp_descr volatile *)
 		mac_drv_get_desc_mem(smc,(u_int)
 		(RXD_TXD_COUNT+1)*sizeof(struct s_smt_fp_txd)))) {
-		return(1) ;	/* no space the hwm modul can't work */
+		return 1;	/* no space the hwm modul can't work */
 	}
 
 	/*
@@ -283,18 +283,18 @@ int mac_drv_init(struct s_smc *smc)
 #ifndef	COMMON_MB_POOL
 	if (!(smc->os.hwm.mbuf_pool.mb_start = (SMbuf *) mac_drv_get_space(smc,
 		MAX_MBUF*sizeof(SMbuf)))) {
-		return(1) ;	/* no space the hwm modul can't work */
+		return 1;	/* no space the hwm modul can't work */
 	}
 #else
 	if (!mb_start) {
 		if (!(mb_start = (SMbuf *) mac_drv_get_space(smc,
 			MAX_MBUF*sizeof(SMbuf)))) {
-			return(1) ;	/* no space the hwm modul can't work */
+			return 1;	/* no space the hwm modul can't work */
 		}
 	}
 #endif
 #endif
-	return (0) ;
+	return 0;
 }
 
 /*
@@ -349,7 +349,7 @@ static u_long init_descr_ring(struct s_smc *smc,
 		DRV_BUF_FLUSH(&d1->r,DDI_DMA_SYNC_FORDEV) ;
 		d1++;
 	}
-	return(phys) ;
+	return phys;
 }
 
 static void init_txd_ring(struct s_smc *smc)
@@ -502,7 +502,7 @@ SMbuf *smt_get_mbuf(struct s_smc *smc)
 		mb->sm_use_count = 1 ;
 	}
 	DB_GEN("get SMbuf: mb = %x",(void *)mb,0,3) ;
-	return (mb) ;	/* May be NULL */
+	return mb;	/* May be NULL */
 }
 
 void smt_free_mbuf(struct s_smc *smc, SMbuf *mb)
@@ -621,7 +621,7 @@ static u_long repair_txd_ring(struct s_smc *smc, struct s_smt_tx_queue *queue)
 		t = t->txd_next ;
 		tx_used-- ;
 	}
-	return(phys) ;
+	return phys;
 }
 
 /*
@@ -673,7 +673,7 @@ static u_long repair_rxd_ring(struct s_smc *smc, struct s_smt_rx_queue *queue)
 		r = r->rxd_next ;
 		rx_used-- ;
 	}
-	return(phys) ;
+	return phys;
 }
 

@@ -1595,7 +1595,7 @@ int hwm_tx_init(struct s_smc *smc, u_char fc, int frag_count, int frame_len,
 	}
 	DB_TX("frame_status = %x",frame_status,0,3) ;
 	NDD_TRACE("THiE",frame_status,smc->os.hwm.tx_p->tx_free,0) ;
-	return(frame_status) ;
+	return frame_status;
 }
 
 /*
@@ -1764,7 +1764,7 @@ static SMbuf *get_llc_rx(struct s_smc *smc)
 		smc->os.hwm.llc_rx_pipe = mb->sm_next ;
 	}
 	DB_GEN("get_llc_rx: mb = 0x%x",(void *)mb,0,4) ;
-	return(mb) ;
+	return mb;
 }
 
 /*
@@ -1797,7 +1797,7 @@ static SMbuf *get_txd_mb(struct s_smc *smc)
 		smc->os.hwm.txd_tx_pipe = mb->sm_next ;
 	}
 	DB_GEN("get_txd_mb: mb = 0x%x",(void *)mb,0,4) ;
-	return(mb) ;
+	return mb;
 }
 
 /*
diff --git a/drivers/net/skfp/hwt.c b/drivers/net/skfp/hwt.c
index 0531514..e6baa53 100644
--- a/drivers/net/skfp/hwt.c
+++ b/drivers/net/skfp/hwt.c
@@ -179,7 +179,7 @@ u_long hwt_read(struct s_smc *smc)
 		else
 			smc->hw.t_stop = smc->hw.t_start - tr ;
 	}
-	return (smc->hw.t_stop) ;
+	return smc->hw.t_stop;
 }
 
 #ifdef	PCI
@@ -208,7 +208,7 @@ u_long hwt_quick_read(struct s_smc *smc)
 	outpw(ADDR(B2_TI_CRTL), TIM_START) ;
 	outpd(ADDR(B2_TI_INI),interval) ;
 
-	return(time) ;
+	return time;
 }
 
 /************************
diff --git a/drivers/net/skfp/pcmplc.c b/drivers/net/skfp/pcmplc.c
index ba45bc7..112d35b 100644
--- a/drivers/net/skfp/pcmplc.c
+++ b/drivers/net/skfp/pcmplc.c
@@ -504,7 +504,7 @@ int sm_pm_get_ls(struct s_smc *smc, int phy)
 
 #ifdef	CONCENTRATOR
 	if (!plc_is_installed(smc,phy))
-		return(PC_QLS) ;
+		return PC_QLS;
 #endif
 
 	state = inpw(PLC(phy,PL_STATUS_A)) & PL_LINE_ST ;
@@ -528,7 +528,7 @@ int sm_pm_get_ls(struct s_smc *smc, int phy)
 	default :
 		state = PC_LS_NONE ;
 	}
-	return(state) ;
+	return state;
 }
 
 static int plc_send_bits(struct s_smc *smc, struct s_phy *phy, int len)
@@ -547,7 +547,7 @@ static int plc_send_bits(struct s_smc *smc, struct s_phy *phy, int len)
 #if	0
 		printf("PL_PCM_SIGNAL is set\n") ;
 #endif
-		return(1) ;
+		return 1;
 	}
 	/* write bit[n] & length = 1 to regs */
 	outpw(PLC(np,PL_VECTOR_LEN),len-1) ;	/* len=nr-1 */
@@ -562,7 +562,7 @@ static int plc_send_bits(struct s_smc *smc, struct s_phy *phy, int len)
 		printf("SIGNALING bit %d .. %d\n",phy->bitn,phy->bitn+len-1) ;
 #endif
 #endif
-	return(0) ;
+	return 0;
 }
 
 /*
@@ -1590,12 +1590,12 @@ int pcm_status_twisted(struct s_smc *smc)
 {
 	int	twist = 0 ;
 	if (smc->s.sas != SMT_DAS)
-		return(0) ;
+		return 0;
 	if (smc->y[PA].twisted && (smc->y[PA].mib->fddiPORTPCMState == PC8_ACTIVE))
 		twist |= 1 ;
 	if (smc->y[PB].twisted && (smc->y[PB].mib->fddiPORTPCMState == PC8_ACTIVE))
 		twist |= 2 ;
-	return(twist) ;
+	return twist;
 }
 
 /*
@@ -1636,9 +1636,9 @@ int pcm_rooted_station(struct s_smc *smc)
 	for (n = 0 ; n < NUMPHYS ; n++) {
 		if (smc->y[n].mib->fddiPORTPCMState == PC8_ACTIVE &&
 		    smc->y[n].mib->fddiPORTNeighborType == TM)
-			return(0) ;
+			return 0;
 	}
-	return(1) ;
+	return 1;
 }
 
 /*
@@ -1915,7 +1915,7 @@ int get_pcm_state(struct s_smc *smc, int np)
 		case PL_PC9 :	pcs = PC_MAINT ;	break ;
 		default :	pcs = PC_DISABLE ; 	break ;
 	}
-	return(pcs) ;
+	return pcs;
 }
 
 char *get_linestate(struct s_smc *smc, int np)
@@ -1937,7 +1937,7 @@ char *get_linestate(struct s_smc *smc, int np)
 		default:	ls = "unknown" ; break ;
 #endif
 	}
-	return(ls) ;
+	return ls;
 }
 
 char *get_pcmstate(struct s_smc *smc, int np)
@@ -1959,7 +1959,7 @@ char *get_pcmstate(struct s_smc *smc, int np)
 		case PL_PC9 :	pcs = "MAINT" ;		break ;
 		default :	pcs = "UNKNOWN" ; 	break ;
 	}
-	return(pcs) ;
+	return pcs;
 }
 
 void list_phy(struct s_smc *smc)
diff --git a/drivers/net/skfp/pmf.c b/drivers/net/skfp/pmf.c
index a320fdb..9ac4665 100644
--- a/drivers/net/skfp/pmf.c
+++ b/drivers/net/skfp/pmf.c
@@ -328,7 +328,7 @@ static SMbuf *smt_build_pmf_response(struct s_smc *smc, struct smt_header *req,
 	 * build SMT header
 	 */
 	if (!(mb = smt_get_mbuf(smc)))
-		return(mb) ;
+		return mb;
 
 	smt = smtod(mb, struct smt_header *) ;
 	smt->smt_dest = req->smt_source ;	/* DA == source of request */
@@ -493,7 +493,7 @@ static SMbuf *smt_build_pmf_response(struct s_smc *smc, struct smt_header *req,
 		smt_add_para(smc,&set_pcon,(u_short) SMT_P1035,0,0) ;
 		smt_add_para(smc,&set_pcon,(u_short) SMT_P1036,0,0) ;
 	}
-	return(mb) ;
+	return mb;
 }
 
 static int smt_authorize(struct s_smc *smc, struct smt_header *sm)
@@ -511,7 +511,7 @@ static int smt_authorize(struct s_smc *smc, struct smt_header *sm)
 	if (i != 8) {
 		if (memcmp((char *) &sm->smt_sid,
 			(char *) &smc->mib.fddiPRPMFStation,8))
-			return(1) ;
+			return 1;
 	}
 	/*
 	 * check authoriziation parameter if passwd not zero
@@ -522,13 +522,13 @@ static int smt_authorize(struct s_smc *smc, struct smt_header *sm)
 	if (i != 8) {
 		pa = (struct smt_para *) sm_to_para(smc,sm,SMT_P_AUTHOR) ;
 		if (!pa)
-			return(1) ;
+			return 1;
 		if (pa->p_len != 8)
-			return(1) ;
+			return 1;
 		if (memcmp((char *)(pa+1),(char *)smc->mib.fddiPRPMFPasswd,8))
-			return(1) ;
+			return 1;
 	}
-	return(0) ;
+	return 0;
 }
 
 static int smt_check_set_count(struct s_smc *smc, struct smt_header *sm)
@@ -542,9 +542,9 @@ static int smt_check_set_count(struct s_smc *smc, struct smt_header *sm)
 		if ((smc->mib.fddiSMTSetCount.count != sc->count) ||
 			memcmp((char *) smc->mib.fddiSMTSetCount.timestamp,
 			(char *)sc->timestamp,8))
-			return(1) ;
+			return 1;
 	}
-	return(0) ;
+	return 0;
 }
 
 void smt_add_para(struct s_smc *smc, struct s_pcon *pcon, u_short para,
@@ -1109,7 +1109,7 @@ static int smt_set_para(struct s_smc *smc, struct smt_para *pa, int index,
 		break ;
 	case 0x2000 :
 		if (mac < 0 || mac >= NUMMACS) {
-			return(SMT_RDF_NOPARAM) ;
+			return SMT_RDF_NOPARAM;
 		}
 		mib_m = &smc->mib.m[mac] ;
 		mib_addr = (char *) mib_m ;
@@ -1118,7 +1118,7 @@ static int smt_set_para(struct s_smc *smc, struct smt_para *pa, int index,
 		break ;
 	case 0x3000 :
 		if (path < 0 || path >= NUMPATHS) {
-			return(SMT_RDF_NOPARAM) ;
+			return SMT_RDF_NOPARAM;
 		}
 		mib_a = &smc->mib.a[path] ;
 		mib_addr = (char *) mib_a ;
@@ -1127,7 +1127,7 @@ static int smt_set_para(struct s_smc *smc, struct smt_para *pa, int index,
 		break ;
 	case 0x4000 :
 		if (port < 0 || port >= smt_mib_phys(smc)) {
-			return(SMT_RDF_NOPARAM) ;
+			return SMT_RDF_NOPARAM;
 		}
 		mib_p = &smc->mib.p[port_to_mib(smc,port)] ;
 		mib_addr = (char *) mib_p ;
@@ -1151,22 +1151,20 @@ static int smt_set_para(struct s_smc *smc, struct smt_para *pa, int index,
 	case SMT_P10F9 :
 #endif
 	case SMT_P20F1 :
-		if (!local) {
-			return(SMT_RDF_NOPARAM) ;
-		}
+		if (!local)
+			return SMT_RDF_NOPARAM;
 		break ;
 	}
 	pt = smt_get_ptab(pa->p_type) ;
-	if (!pt) {
-		return( (pa->p_type & 0xff00) ? SMT_RDF_NOPARAM :
-						SMT_RDF_ILLEGAL ) ;
-	}
+	if (!pt)
+		return (pa->p_type & 0xff00) ? SMT_RDF_NOPARAM :
+					       SMT_RDF_ILLEGAL;
 	switch (pt->p_access) {
 	case AC_GR :
 	case AC_S :
 		break ;
 	default :
-		return(SMT_RDF_ILLEGAL) ;
+		return SMT_RDF_ILLEGAL;
 	}
 	to = mib_addr + pt->p_offset ;
 	swap = pt->p_swap ;		/* pointer to swap string */
@@ -1292,7 +1290,7 @@ static int smt_set_para(struct s_smc *smc, struct smt_para *pa, int index,
 			break ;
 		default :
 			SMT_PANIC(smc,SMT_E0120, SMT_E0120_MSG) ;
-			return(SMT_RDF_ILLEGAL) ;
+			return SMT_RDF_ILLEGAL;
 		}
 	}
 	/*
@@ -1501,15 +1499,15 @@ change_mac_para:
 	default :
 		break ;
 	}
-	return(0) ;
+	return 0;
 
 val_error:
 	/* parameter value in frame is out of range */
-	return(SMT_RDF_RANGE) ;
+	return SMT_RDF_RANGE;
 
 len_error:
 	/* parameter value in frame is too short */
-	return(SMT_RDF_LENGTH) ;
+	return SMT_RDF_LENGTH;
 
 #if	0
 no_author_error:
@@ -1518,7 +1516,7 @@ no_author_error:
 	 *  because SBA denied is not a valid return code in the
 	 * PMF protocol.
 	 */
-	return(SMT_RDF_AUTHOR) ;
+	return SMT_RDF_AUTHOR;
 #endif
 }
 
@@ -1527,7 +1525,7 @@ static const struct s_p_tab *smt_get_ptab(u_short para)
 	const struct s_p_tab	*pt ;
 	for (pt = p_tab ; pt->p_num && pt->p_num != para ; pt++)
 		;
-	return(pt->p_num ? pt : NULL) ;
+	return pt->p_num ? pt : NULL;
 }
 
 static int smt_mib_phys(struct s_smc *smc)
@@ -1535,11 +1533,11 @@ static int smt_mib_phys(struct s_smc *smc)
 #ifdef	CONCENTRATOR
 	SK_UNUSED(smc) ;
 
-	return(NUMPHYS) ;
+	return NUMPHYS;
 #else
 	if (smc->s.sas == SMT_SAS)
-		return(1) ;
-	return(NUMPHYS) ;
+		return 1;
+	return NUMPHYS;
 #endif
 }
 
@@ -1548,11 +1546,11 @@ static int port_to_mib(struct s_smc *smc, int p)
 #ifdef	CONCENTRATOR
 	SK_UNUSED(smc) ;
 
-	return(p) ;
+	return p;
 #else
 	if (smc->s.sas == SMT_SAS)
-		return(PS) ;
-	return(p) ;
+		return PS;
+	return p;
 #endif
 }
 
diff --git a/drivers/net/skfp/queue.c b/drivers/net/skfp/queue.c
index 09adb3d..c1a0df4 100644
--- a/drivers/net/skfp/queue.c
+++ b/drivers/net/skfp/queue.c
@@ -128,7 +128,7 @@ u_short smt_online(struct s_smc *smc, int on)
 {
 	queue_event(smc,EVENT_ECM,on ? EC_CONNECT : EC_DISCONNECT) ;
 	ev_dispatcher(smc) ;
-	return(smc->mib.fddiSMTCF_State) ;
+	return smc->mib.fddiSMTCF_State;
 }
 
 /*
diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
index 8a12bd9..ba2e833 100644
--- a/drivers/net/skfp/skfddi.c
+++ b/drivers/net/skfp/skfddi.c
@@ -440,7 +440,7 @@ static  int skfp_driver_init(struct net_device *dev)
 
 	smt_reset_defaults(smc, 0);
 
-	return (0);
+	return 0;
 
 fail:
 	if (bp->SharedMemAddr) {
@@ -516,7 +516,7 @@ static int skfp_open(struct net_device *dev)
 	mac_drv_rx_mode(smc, RX_DISABLE_PROMISC);
 
 	netif_start_queue(dev);
-	return (0);
+	return 0;
 }				// skfp_open
 

@@ -565,7 +565,7 @@ static int skfp_close(struct net_device *dev)
 	skb_queue_purge(&bp->SendSkbQueue);
 	bp->QueueSkb = MAX_TX_QUEUE_LEN;
 
-	return (0);
+	return 0;
 }				// skfp_close
 

@@ -794,7 +794,7 @@ static struct net_device_stats *skfp_ctl_get_stats(struct net_device *dev)
 	bp->stats.port_lem_cts[1] = bp->cmd_rsp_virt->cntrs_get.cntrs.link_errors[1].ls;
 
 #endif
-	return ((struct net_device_stats *) &bp->os.MacStat);
+	return (struct net_device_stats *)&bp->os.MacStat;
 }				// ctl_get_stat
 

@@ -932,7 +932,7 @@ static int skfp_ctl_set_mac_address(struct net_device *dev, void *addr)
 	ResetAdapter(smc);
 	spin_unlock_irqrestore(&bp->DriverLock, Flags);
 
-	return (0);		/* always return zero */
+	return 0;		/* always return zero */
 }				// skfp_ctl_set_mac_address
 

@@ -1313,7 +1313,7 @@ void *mac_drv_get_space(struct s_smc *smc, unsigned int size)
 
 	if ((smc->os.SharedMemHeap + size) > smc->os.SharedMemSize) {
 		printk("Unexpected SMT memory size requested: %d\n", size);
-		return (NULL);
+		return NULL;
 	}
 	smc->os.SharedMemHeap += size;	// Move heap pointer.
 
@@ -1322,7 +1322,7 @@ void *mac_drv_get_space(struct s_smc *smc, unsigned int size)
 	pr_debug("bus  addr: %lx\n", (ulong)
 	       (smc->os.SharedMemDMA +
 		((char *) virt - (char *)smc->os.SharedMemAddr)));
-	return (virt);
+	return virt;
 }				// mac_drv_get_space
 

@@ -1363,9 +1363,9 @@ void *mac_drv_get_desc_mem(struct s_smc *smc, unsigned int size)
 
 	if (!mac_drv_get_space(smc, size)) {
 		printk("fddi: Unable to align descriptor memory.\n");
-		return (NULL);
+		return NULL;
 	}
-	return (virt + size);
+	return virt + size;
 }				// mac_drv_get_desc_mem
 

@@ -1384,8 +1384,8 @@ void *mac_drv_get_desc_mem(struct s_smc *smc, unsigned int size)
  ************************/
 unsigned long mac_drv_virt2phys(struct s_smc *smc, void *virt)
 {
-	return (smc->os.SharedMemDMA +
-		((char *) virt - (char *)smc->os.SharedMemAddr));
+	return smc->os.SharedMemDMA +
+		((char *) virt - (char *)smc->os.SharedMemAddr);
 }				// mac_drv_virt2phys
 

@@ -1419,8 +1419,8 @@ unsigned long mac_drv_virt2phys(struct s_smc *smc, void *virt)
  ************************/
 u_long dma_master(struct s_smc * smc, void *virt, int len, int flag)
 {
-	return (smc->os.SharedMemDMA +
-		((char *) virt - (char *)smc->os.SharedMemAddr));
+	return smc->os.SharedMemDMA +
+		((char *) virt - (char *)smc->os.SharedMemAddr);
 }				// dma_master
 

@@ -1904,12 +1904,12 @@ int mac_drv_rx_init(struct s_smc *smc, int len, int fc,
 		pr_debug("fddi: Discard invalid local SMT frame\n");
 		pr_debug("  len=%d, la_len=%d, (ULONG) look_ahead=%08lXh.\n",
 		       len, la_len, (unsigned long) look_ahead);
-		return (0);
+		return 0;
 	}
 	skb = alloc_skb(len + 3, GFP_ATOMIC);
 	if (!skb) {
 		pr_debug("fddi: Local SMT: skb memory exhausted.\n");
-		return (0);
+		return 0;
 	}
 	skb_reserve(skb, 3);
 	skb_put(skb, len);
@@ -1919,7 +1919,7 @@ int mac_drv_rx_init(struct s_smc *smc, int len, int fc,
 	skb->protocol = fddi_type_trans(skb, smc->os.dev);
 	netif_rx(skb);
 
-	return (0);
+	return 0;
 }				// mac_drv_rx_init
 

diff --git a/drivers/net/skfp/smt.c b/drivers/net/skfp/smt.c
index 6f35bb7..2d9941c 100644
--- a/drivers/net/skfp/smt.c
+++ b/drivers/net/skfp/smt.c
@@ -127,22 +127,22 @@ static inline int is_my_addr(const struct s_smc *smc,
 
 static inline int is_broadcast(const struct fddi_addr *addr)
 {
-	return(*(u_short *)(&addr->a[0]) == 0xffff &&
+	return *(u_short *)(&addr->a[0]) == 0xffff &&
 	       *(u_short *)(&addr->a[2]) == 0xffff &&
-	       *(u_short *)(&addr->a[4]) == 0xffff ) ;
+	       *(u_short *)(&addr->a[4]) == 0xffff;
 }
 
 static inline int is_individual(const struct fddi_addr *addr)
 {
-	return(!(addr->a[0] & GROUP_ADDR)) ;
+	return !(addr->a[0] & GROUP_ADDR);
 }
 
 static inline int is_equal(const struct fddi_addr *addr1, 
 			   const struct fddi_addr *addr2)
 {
-	return(*(u_short *)(&addr1->a[0]) == *(u_short *)(&addr2->a[0]) &&
+	return *(u_short *)(&addr1->a[0]) == *(u_short *)(&addr2->a[0]) &&
 	       *(u_short *)(&addr1->a[2]) == *(u_short *)(&addr2->a[2]) &&
-	       *(u_short *)(&addr1->a[4]) == *(u_short *)(&addr2->a[4]) ) ;
+	       *(u_short *)(&addr1->a[4]) == *(u_short *)(&addr2->a[4]);
 }
 
 /*
@@ -457,8 +457,8 @@ static int div_ratio(u_long upper, u_long lower)
 	else
 		upper <<= 16L ;
 	if (!lower)
-		return(0) ;
-	return((int)(upper/lower)) ;
+		return 0;
+	return (int)(upper/lower) ;
 }
 
 #ifndef	SLIM_SMT
@@ -1111,11 +1111,11 @@ SMbuf *smt_build_frame(struct s_smc *smc, int class, int type,
 
 #if	0
 	if (!smc->r.sm_ma_avail) {
-		return(0) ;
+		return 0;
 	}
 #endif
 	if (!(mb = smt_get_mbuf(smc)))
-		return(mb) ;
+		return mb;
 
 	mb->sm_len = length ;
 	smt = smtod(mb, struct smt_header *) ;
@@ -1136,7 +1136,7 @@ SMbuf *smt_build_frame(struct s_smc *smc, int class, int type,
 	smt->smt_tid = smt_get_tid(smc) ;	/* set transaction ID */
 	smt->smt_pad = 0 ;
 	smt->smt_len = length - sizeof(struct smt_header) ;
-	return(mb) ;
+	return mb;
 }
 
 static void smt_add_frame_len(SMbuf *mb, int len)
@@ -1375,7 +1375,7 @@ static int smt_fill_path(struct s_smc *smc, struct smt_p_path *path)
 	pd_mac = (struct smt_mac_rec *) phy ;
 	pd_mac->mac_addr = smc->mib.m[MAC0].fddiMACSMTAddress ;
 	pd_mac->mac_resource_idx = mac_con_resource_index(smc,1) ;
-	return(len) ;
+	return len;
 }
 
 /*
@@ -1563,7 +1563,7 @@ u_long smt_get_tid(struct s_smc *smc)
 	u_long	tid ;
 	while ((tid = ++(smc->sm.smt_tid) ^ SMT_TID_MAGIC) == 0)
 		;
-	return(tid & 0x3fffffffL) ;
+	return tid & 0x3fffffffL;
 }
 

@@ -1654,11 +1654,11 @@ int smt_check_para(struct s_smc *smc, struct smt_header	*sm,
 	while (*p) {
 		if (!sm_to_para(smc,sm,(int) *p)) {
 			DB_SMT("SMT: smt_check_para - missing para %x\n",*p,0);
-			return(-1) ;
+			return -1;
 		}
 		p++ ;
 	}
-	return(0) ;
+	return 0;
 }
 
 void *sm_to_para(struct s_smc *smc, struct smt_header *sm, int para)
@@ -1687,7 +1687,7 @@ void *sm_to_para(struct s_smc *smc, struct smt_header *sm, int para)
 			return NULL;
 		}
 		if (found)
-			return(found) ;
+			return found;
 	}
 	return NULL;
 }
@@ -1732,7 +1732,7 @@ char *addr_to_string(struct fddi_addr *addr)
 		string[i * 3 + 2] = ':';
 	}
 	string[5 * 3 + 2] = 0;
-	return(string);
+	return string;
 }
 #endif
 
@@ -1742,9 +1742,9 @@ int smt_ifconfig(int argc, char *argv[])
 	if (argc >= 2 && !strcmp(argv[0],"opt_bypass") &&
 	    !strcmp(argv[1],"yes")) {
 		smc->mib.fddiSMTBypassPresent = 1 ;
-		return(0) ;
+		return 0;
 	}
-	return(amdfddi_config(0,argc,argv)) ;
+	return amdfddi_config(0, argc, argv);
 }
 #endif
 
@@ -1756,9 +1756,9 @@ static int mac_index(struct s_smc *smc, int mac)
 	SK_UNUSED(mac) ;
 #ifdef	CONCENTRATOR
 	SK_UNUSED(smc) ;
-	return(NUMPHYS+1) ;
+	return NUMPHYS + 1;
 #else
-	return((smc->s.sas == SMT_SAS) ? 2 : 3) ;
+	return (smc->s.sas == SMT_SAS) ? 2 : 3;
 #endif
 }
 
@@ -1768,7 +1768,7 @@ static int mac_index(struct s_smc *smc, int mac)
 static int phy_index(struct s_smc *smc, int phy)
 {
 	SK_UNUSED(smc) ;
-	return(phy+1);
+	return phy + 1;
 }
 
 /*
@@ -1779,19 +1779,19 @@ static int mac_con_resource_index(struct s_smc *smc, int mac)
 #ifdef	CONCENTRATOR
 	SK_UNUSED(smc) ;
 	SK_UNUSED(mac) ;
-	return(entity_to_index(smc,cem_get_downstream(smc,ENTITY_MAC))) ;
+	return entity_to_index(smc, cem_get_downstream(smc, ENTITY_MAC));
 #else
 	SK_UNUSED(mac) ;
 	switch (smc->mib.fddiSMTCF_State) {
 	case SC9_C_WRAP_A :
 	case SC5_THRU_B :
 	case SC11_C_WRAP_S :
-		return(1) ;
+		return 1;
 	case SC10_C_WRAP_B :
 	case SC4_THRU_A :
-		return(2) ;
+		return 2;
 	}
-	return(smc->s.sas == SMT_SAS ? 2 : 3) ;
+	return smc->s.sas == SMT_SAS ? 2 : 3;
 #endif
 }
 
@@ -1801,21 +1801,21 @@ static int mac_con_resource_index(struct s_smc *smc, int mac)
 static int phy_con_resource_index(struct s_smc *smc, int phy)
 {
 #ifdef	CONCENTRATOR
-	return(entity_to_index(smc,cem_get_downstream(smc,ENTITY_PHY(phy)))) ;
+	return entity_to_index(smc, cem_get_downstream(smc, ENTITY_PHY(phy))) ;
 #else
 	switch (smc->mib.fddiSMTCF_State) {
 	case SC9_C_WRAP_A :
-		return(phy == PA ? 3 : 2) ;
+		return phy == PA ? 3 : 2;
 	case SC10_C_WRAP_B :
-		return(phy == PA ? 1 : 3) ;
+		return phy == PA ? 1 : 3;
 	case SC4_THRU_A :
-		return(phy == PA ? 3 : 1) ;
+		return phy == PA ? 3 : 1;
 	case SC5_THRU_B :
-		return(phy == PA ? 2 : 3) ;
+		return phy == PA ? 2 : 3;
 	case SC11_C_WRAP_S :
-		return(2) ;
+		return 2;
 	}
-	return(phy) ;
+	return phy;
 #endif
 }
 
@@ -1823,16 +1823,16 @@ static int phy_con_resource_index(struct s_smc *smc, int phy)
 static int entity_to_index(struct s_smc *smc, int e)
 {
 	if (e == ENTITY_MAC)
-		return(mac_index(smc,1)) ;
+		return mac_index(smc, 1);
 	else
-		return(phy_index(smc,e - ENTITY_PHY(0))) ;
+		return phy_index(smc, e - ENTITY_PHY(0));
 }
 #endif
 
 #ifdef	LITTLE_ENDIAN
 static int smt_swap_short(u_short s)
 {
-	return(((s>>8)&0xff)|((s&0xff)<<8)) ;
+	return ((s>>8)&0xff) | ((s&0xff)<<8);
 }
 
 void smt_swap_para(struct smt_header *sm, int len, int direction)
@@ -1996,7 +1996,7 @@ int smt_action(struct s_smc *smc, int class, int code, int index)
 			}
 			break ;
 		default :
-			return(1) ;
+			return 1;
 		}
 		break ;
 	case SMT_PORT_ACTION :
@@ -2017,14 +2017,14 @@ int smt_action(struct s_smc *smc, int class, int code, int index)
 			event = PC_STOP ;
 			break ;
 		default :
-			return(1) ;
+			return 1;
 		}
 		queue_event(smc,EVENT_PCM+index,event) ;
 		break ;
 	default :
-		return(1) ;
+		return 1;
 	}
-	return(0) ;
+	return 0;
 }
 
 /*
diff --git a/drivers/net/skfp/smtdef.c b/drivers/net/skfp/smtdef.c
index 4e07ff7..1acab0b 100644
--- a/drivers/net/skfp/smtdef.c
+++ b/drivers/net/skfp/smtdef.c
@@ -303,7 +303,7 @@ int smt_set_mac_opvalues(struct s_smc *smc)
 			FDDI_SMT_EVENT, (u_long) FDDI_REMOTE_T_REQ,
 			smt_get_event_word(smc));
 	}
-	return(st) ;
+	return st;
 }
 
 void smt_fixup_mib(struct s_smc *smc)
@@ -350,6 +350,6 @@ static int set_min_max(int maxflag, u_long mib, u_long limit, u_long *oper)
 		*oper = limit ;
 	else
 		*oper = mib ;
-	return(old != *oper) ;
+	return old != *oper;
 }
 
diff --git a/drivers/net/skfp/smtinit.c b/drivers/net/skfp/smtinit.c
index 3c8964c..e3a0c0b 100644
--- a/drivers/net/skfp/smtinit.c
+++ b/drivers/net/skfp/smtinit.c
@@ -120,6 +120,6 @@ int init_smt(struct s_smc *smc, u_char *mac_addr)
 
         PNMI_INIT(smc) ;                /* PNMI initialization */
 
-	return(0) ;
+	return 0;
 }
 
diff --git a/drivers/net/skfp/srf.c b/drivers/net/skfp/srf.c
index 40882b3..f6f7baf 100644
--- a/drivers/net/skfp/srf.c
+++ b/drivers/net/skfp/srf.c
@@ -165,7 +165,7 @@ static struct s_srf_evc *smt_get_evc(struct s_smc *smc, int code, int index)
 
 	for (i = 0, evc = smc->evcs ; (unsigned) i < MAX_EVCS ; i++, evc++) {
 		if (evc->evc_code == code && evc->evc_index == index)
-			return(evc) ;
+			return evc;
 	}
 	return NULL;
 }
diff --git a/drivers/net/slip.c b/drivers/net/slip.c
index 38547a8..86cbb9e 100644
--- a/drivers/net/slip.c
+++ b/drivers/net/slip.c
@@ -944,7 +944,7 @@ static int slip_esc(unsigned char *s, unsigned char *d, int len)
 		}
 	}
 	*ptr++ = END;
-	return (ptr - d);
+	return ptr - d;
 }
 
 static void slip_unesc(struct slip *sl, unsigned char s)
diff --git a/drivers/net/sun3lance.c b/drivers/net/sun3lance.c
index 358c22f..7d9ec23 100644
--- a/drivers/net/sun3lance.c
+++ b/drivers/net/sun3lance.c
@@ -436,7 +436,7 @@ static int lance_open( struct net_device *dev )
 		DPRINTK( 2, ( "lance_open(): opening %s failed, i=%d, csr0=%04x\n",
 					  dev->name, i, DREG ));
 		DREG = CSR0_STOP;
-		return( -EIO );
+		return -EIO;
 	}
 
 	DREG = CSR0_IDON | CSR0_STRT | CSR0_INEA;
@@ -445,7 +445,7 @@ static int lance_open( struct net_device *dev )
 
 	DPRINTK( 2, ( "%s: LANCE is open, csr0 %04x\n", dev->name, DREG ));
 
-	return( 0 );
+	return 0;
 }
 

diff --git a/drivers/net/sungem_phy.c b/drivers/net/sungem_phy.c
index 4a4fac6..d16880d 100644
--- a/drivers/net/sungem_phy.c
+++ b/drivers/net/sungem_phy.c
@@ -88,7 +88,7 @@ static int reset_one_mii_phy(struct mii_phy* phy, int phy_id)
 	if ((val & BMCR_ISOLATE) && limit > 0)
 		__phy_write(phy, phy_id, MII_BMCR, val & ~BMCR_ISOLATE);
 
-	return (limit <= 0);
+	return limit <= 0;
 }
 
 static int bcm5201_init(struct mii_phy* phy)
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index 45f315e..5e28c41 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -2497,7 +2497,7 @@ static u32 hme_get_link(struct net_device *dev)
 	hp->sw_bmcr = happy_meal_tcvr_read(hp, hp->tcvregs, MII_BMCR);
 	spin_unlock_irq(&hp->happy_lock);
 
-	return (hp->sw_bmsr & BMSR_LSTATUS);
+	return hp->sw_bmsr & BMSR_LSTATUS;
 }
 
 static const struct ethtool_ops hme_ethtool_ops = {
diff --git a/drivers/net/sunqe.c b/drivers/net/sunqe.c
index 72e65d4..9536b2f 100644
--- a/drivers/net/sunqe.c
+++ b/drivers/net/sunqe.c
@@ -711,7 +711,7 @@ static u32 qe_get_link(struct net_device *dev)
 	phyconfig = sbus_readb(mregs + MREGS_PHYCONFIG);
 	spin_unlock_irq(&qep->lock);
 
-	return (phyconfig & MREGS_PHYCONFIG_LSTAT);
+	return phyconfig & MREGS_PHYCONFIG_LSTAT;
 }
 
 static const struct ethtool_ops qe_ethtool_ops = {
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 99e423a..b6eec8c 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -1167,7 +1167,7 @@ static void print_eth(const u8 *add)
 static int tc35815_tx_full(struct net_device *dev)
 {
 	struct tc35815_local *lp = netdev_priv(dev);
-	return ((lp->tfd_start + 1) % TX_FD_NUM == lp->tfd_end);
+	return (lp->tfd_start + 1) % TX_FD_NUM == lp->tfd_end;
 }
 
 static void tc35815_restart(struct net_device *dev)
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index e7a2ba8..fdb438d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5389,8 +5389,7 @@ static inline int tg3_4g_overflow_test(dma_addr_t mapping, int len)
 {
 	u32 base = (u32) mapping & 0xffffffff;
 
-	return ((base > 0xffffdcc0) &&
-		(base + len + 8 < base));
+	return (base > 0xffffdcc0) && (base + len + 8 < base);
 }
 
 /* Test for DMA addresses > 40-bit */
@@ -5399,7 +5398,7 @@ static inline int tg3_40bit_overflow_test(struct tg3 *tp, dma_addr_t mapping,
 {
 #if defined(CONFIG_HIGHMEM) && (BITS_PER_LONG == 64)
 	if (tp->tg3_flags & TG3_FLAG_40BIT_DMA_BUG)
-		return (((u64) mapping + len) > DMA_BIT_MASK(40));
+		return ((u64) mapping + len) > DMA_BIT_MASK(40);
 	return 0;
 #else
 	return 0;
diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index 0564ca0..ec8c804 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -3187,7 +3187,7 @@ static int TLan_EeSendByte( u16 io_base, u8 data, int stop )
 		TLan_SetBit( TLAN_NET_SIO_EDATA, sio );
 	}
 
-	return ( err );
+	return err;
 
 } /* TLan_EeSendByte */
 
diff --git a/drivers/net/tlan.h b/drivers/net/tlan.h
index d13ff12..3315ced 100644
--- a/drivers/net/tlan.h
+++ b/drivers/net/tlan.h
@@ -442,7 +442,7 @@ typedef struct tlan_private_tag {
 static inline u8 TLan_DioRead8(u16 base_addr, u16 internal_addr)
 {
 	outw(internal_addr, base_addr + TLAN_DIO_ADR);
-	return (inb((base_addr + TLAN_DIO_DATA) + (internal_addr & 0x3)));
+	return inb((base_addr + TLAN_DIO_DATA) + (internal_addr & 0x3));
 
 } /* TLan_DioRead8 */
 
@@ -452,7 +452,7 @@ static inline u8 TLan_DioRead8(u16 base_addr, u16 internal_addr)
 static inline u16 TLan_DioRead16(u16 base_addr, u16 internal_addr)
 {
 	outw(internal_addr, base_addr + TLAN_DIO_ADR);
-	return (inw((base_addr + TLAN_DIO_DATA) + (internal_addr & 0x2)));
+	return inw((base_addr + TLAN_DIO_DATA) + (internal_addr & 0x2));
 
 } /* TLan_DioRead16 */
 
@@ -462,7 +462,7 @@ static inline u16 TLan_DioRead16(u16 base_addr, u16 internal_addr)
 static inline u32 TLan_DioRead32(u16 base_addr, u16 internal_addr)
 {
 	outw(internal_addr, base_addr + TLAN_DIO_ADR);
-	return (inl(base_addr + TLAN_DIO_DATA));
+	return inl(base_addr + TLAN_DIO_DATA);
 
 } /* TLan_DioRead32 */
 
@@ -537,6 +537,6 @@ static inline u32 TLan_HashFunc( const u8 *a )
         hash ^= ((a[2]^a[5])<<4);       /* & 060 */
         hash ^= ((a[2]^a[5])>>2);       /* & 077 */
 
-        return (hash & 077);
+        return hash & 077;
 }
 #endif
diff --git a/drivers/net/tokenring/proteon.c b/drivers/net/tokenring/proteon.c
index 16e8783..8d362e6 100644
--- a/drivers/net/tokenring/proteon.c
+++ b/drivers/net/tokenring/proteon.c
@@ -110,7 +110,7 @@ static int __init proteon_probe1(struct net_device *dev, int ioaddr)
 	}
 
 	dev->base_addr = ioaddr;
-	return (0);
+	return 0;
 nodev:
 	release_region(ioaddr, PROTEON_IO_EXTENT); 
 	return -ENODEV;
diff --git a/drivers/net/tokenring/smctr.c b/drivers/net/tokenring/smctr.c
index 0929fff..c40f64f 100644
--- a/drivers/net/tokenring/smctr.c
+++ b/drivers/net/tokenring/smctr.c
@@ -435,7 +435,7 @@ static int smctr_alloc_shared_memory(struct net_device *dev)
                 RX_DATA_BUFFER_SIZE * tp->num_rx_bdbs[NON_MAC_QUEUE]);
         tp->rx_buff_end[NON_MAC_QUEUE] = (__u16 *)smctr_malloc(dev, 0);
 
-        return (0);
+        return 0;
 }
 
 /* Enter Bypass state. */
@@ -448,7 +448,7 @@ static int smctr_bypass_state(struct net_device *dev)
 
         err = smctr_setup_single_cmd(dev, ACB_CMD_CHANGE_JOIN_STATE, JS_BYPASS_STATE);
 
-        return (err);
+        return err;
 }
 
 static int smctr_checksum_firmware(struct net_device *dev)
@@ -471,9 +471,9 @@ static int smctr_checksum_firmware(struct net_device *dev)
         smctr_disable_adapter_ctrl_store(dev);
 
         if(checksum)
-                return (checksum);
+                return checksum;
 
-        return (0);
+        return 0;
 }
 
 static int __init smctr_chk_mca(struct net_device *dev)
@@ -485,7 +485,7 @@ static int __init smctr_chk_mca(struct net_device *dev)
 
 	current_slot = mca_find_unused_adapter(smctr_posid, 0);
 	if(current_slot == MCA_NOTFOUND)
-		return (-ENODEV);
+		return -ENODEV;
 
 	mca_set_adapter_name(current_slot, smctr_name);
 	mca_mark_as_used(current_slot);
@@ -622,9 +622,9 @@ static int __init smctr_chk_mca(struct net_device *dev)
                         break;
         }
 
-	return (0);
+	return 0;
 #else
-	return (-1);
+	return -1;
 #endif /* CONFIG_MCA_LEGACY */
 }
 
@@ -677,18 +677,18 @@ static int smctr_chg_rx_mask(struct net_device *dev)
         if((err = smctr_issue_write_word_cmd(dev, RW_CONFIG_REGISTER_0,
                 &tp->config_word0)))
         {
-                return (err);
+                return err;
         }
 
         if((err = smctr_issue_write_word_cmd(dev, RW_CONFIG_REGISTER_1,
                 &tp->config_word1)))
         {
-                return (err);
+                return err;
         }
 
         smctr_disable_16bit(dev);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_clear_int(struct net_device *dev)
@@ -697,7 +697,7 @@ static int smctr_clear_int(struct net_device *dev)
 
         outb((tp->trc_mask | CSR_CLRTINT), dev->base_addr + CSR);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_clear_trc_reset(int ioaddr)
@@ -707,7 +707,7 @@ static int smctr_clear_trc_reset(int ioaddr)
         r = inb(ioaddr + MSR);
         outb(~MSR_RST & r, ioaddr + MSR);
 
-        return (0);
+        return 0;
 }
 
 /*
@@ -725,7 +725,7 @@ static int smctr_close(struct net_device *dev)
 
         /* Check to see if adapter is already in a closed state. */
         if(tp->status != OPEN)
-                return (0);
+                return 0;
 
         smctr_enable_16bit(dev);
         smctr_set_page(dev, (__u8 *)tp->ram_access);
@@ -733,7 +733,7 @@ static int smctr_close(struct net_device *dev)
         if((err = smctr_issue_remove_cmd(dev)))
         {
                 smctr_disable_16bit(dev);
-                return (err);
+                return err;
         }
 
         for(;;)
@@ -746,7 +746,7 @@ static int smctr_close(struct net_device *dev)
         }
 

-        return (0);
+        return 0;
 }
 
 static int smctr_decode_firmware(struct net_device *dev,
@@ -807,12 +807,12 @@ static int smctr_decode_firmware(struct net_device *dev,
         if(buff)
                 *(mem++) = SWAP_BYTES(buff);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_disable_16bit(struct net_device *dev)
 {
-        return (0);
+        return 0;
 }
 
 /*
@@ -832,7 +832,7 @@ static int smctr_disable_adapter_ctrl_store(struct net_device *dev)
         tp->trc_mask |= CSR_WCSS;
         outb(tp->trc_mask, ioaddr + CSR);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_disable_bic_int(struct net_device *dev)
@@ -844,7 +844,7 @@ static int smctr_disable_bic_int(struct net_device *dev)
 	        | CSR_MSKTINT | CSR_WCSS;
         outb(tp->trc_mask, ioaddr + CSR);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_enable_16bit(struct net_device *dev)
@@ -858,7 +858,7 @@ static int smctr_enable_16bit(struct net_device *dev)
                 outb((r | LAAR_MEM16ENB), dev->base_addr + LAAR);
         }
 
-        return (0);
+        return 0;
 }
 
 /*
@@ -881,7 +881,7 @@ static int smctr_enable_adapter_ctrl_store(struct net_device *dev)
         tp->trc_mask &= ~CSR_WCSS;
         outb(tp->trc_mask, ioaddr + CSR);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_enable_adapter_ram(struct net_device *dev)
@@ -895,7 +895,7 @@ static int smctr_enable_adapter_ram(struct net_device *dev)
         r = inb(ioaddr + MSR);
         outb(MSR_MEMB | r, ioaddr + MSR);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_enable_bic_int(struct net_device *dev)
@@ -921,7 +921,7 @@ static int smctr_enable_bic_int(struct net_device *dev)
                         break;
         }
 
-        return (0);
+        return 0;
 }
 
 static int __init smctr_chk_isa(struct net_device *dev)
@@ -1145,7 +1145,7 @@ static int __init smctr_chk_isa(struct net_device *dev)
 		*/
         }
 
-        return (0);
+        return 0;
 
 out2:
 	release_region(ioaddr, SMCTR_IO_EXTENT);
@@ -1199,7 +1199,7 @@ static int __init smctr_get_boardid(struct net_device *dev, int mca)
          *      return;
          */
         if(IdByte & 0xF8)
-                return (-1);
+                return -1;
 
         r1 = inb(ioaddr + BID_REG_1);
         r1 &= BID_ICR_MASK;
@@ -1250,21 +1250,21 @@ static int __init smctr_get_boardid(struct net_device *dev, int mca)
         while(r1 & BID_RECALL_DONE_MASK)
                 r1 = inb(ioaddr + BID_REG_1);
 
-        return (BoardIdMask);
+        return BoardIdMask;
 }
 
 static int smctr_get_group_address(struct net_device *dev)
 {
         smctr_issue_read_word_cmd(dev, RW_INDIVIDUAL_GROUP_ADDR);
 
-        return(smctr_wait_cmd(dev));
+        return smctr_wait_cmd(dev);
 }
 
 static int smctr_get_functional_address(struct net_device *dev)
 {
         smctr_issue_read_word_cmd(dev, RW_FUNCTIONAL_ADDR);
 
-        return(smctr_wait_cmd(dev));
+        return smctr_wait_cmd(dev);
 }
 
 /* Calculate number of Non-MAC receive BDB's and data buffers.
@@ -1346,14 +1346,14 @@ static unsigned int smctr_get_num_rx_bdbs(struct net_device *dev)
          */
         mem_used += 0x100;
 
-        return((0xffff - mem_used) / (RX_DATA_BUFFER_SIZE + sizeof(BDBlock)));
+        return (0xffff - mem_used) / (RX_DATA_BUFFER_SIZE + sizeof(BDBlock));
 }
 
 static int smctr_get_physical_drop_number(struct net_device *dev)
 {
         smctr_issue_read_word_cmd(dev, RW_PHYSICAL_DROP_NUMBER);
 
-        return(smctr_wait_cmd(dev));
+        return smctr_wait_cmd(dev);
 }
 
 static __u8 * smctr_get_rx_pointer(struct net_device *dev, short queue)
@@ -1366,14 +1366,14 @@ static __u8 * smctr_get_rx_pointer(struct net_device *dev, short queue)
 
         tp->rx_fcb_curr[queue]->bdb_ptr = bdb;
 
-        return ((__u8 *)bdb->data_block_ptr);
+        return (__u8 *)bdb->data_block_ptr;
 }
 
 static int smctr_get_station_id(struct net_device *dev)
 {
         smctr_issue_read_word_cmd(dev, RW_INDIVIDUAL_MAC_ADDRESS);
 
-        return(smctr_wait_cmd(dev));
+        return smctr_wait_cmd(dev);
 }
 
 /*
@@ -1384,7 +1384,7 @@ static struct net_device_stats *smctr_get_stats(struct net_device *dev)
 {
         struct net_local *tp = netdev_priv(dev);
 
-        return ((struct net_device_stats *)&tp->MacStat);
+        return (struct net_device_stats *)&tp->MacStat;
 }
 
 static FCBlock *smctr_get_tx_fcb(struct net_device *dev, __u16 queue,
@@ -1401,14 +1401,14 @@ static FCBlock *smctr_get_tx_fcb(struct net_device *dev, __u16 queue,
 
         /* check if there is enough FCB blocks */
         if(tp->num_tx_fcbs_used[queue] >= tp->num_tx_fcbs[queue])
-                return ((FCBlock *)(-1L));
+                return (FCBlock *)(-1L);
 
         /* round off the input pkt size to the nearest even number */
         alloc_size = (bytes_count + 1) & 0xfffe;
 
         /* check if enough mem */
         if((tp->tx_buff_used[queue] + alloc_size) > tp->tx_buff_size[queue])
-                return ((FCBlock *)(-1L));
+                return (FCBlock *)(-1L);
 
         /* check if past the end ;
          * if exactly enough mem to end of ring, alloc from front.
@@ -1425,7 +1425,7 @@ static FCBlock *smctr_get_tx_fcb(struct net_device *dev, __u16 queue,
                 if((tp->tx_buff_used[queue] + alloc_size)
                         > tp->tx_buff_size[queue])
                 {
-                        return ((FCBlock *)(-1L));
+                        return (FCBlock *)(-1L);
                 }
 
                 /* ring wrap */
@@ -1448,14 +1448,14 @@ static FCBlock *smctr_get_tx_fcb(struct net_device *dev, __u16 queue,
         pFCB = tp->tx_fcb_curr[queue];
         tp->tx_fcb_curr[queue] = tp->tx_fcb_curr[queue]->next_ptr;
 
-        return (pFCB);
+        return pFCB;
 }
 
 static int smctr_get_upstream_neighbor_addr(struct net_device *dev)
 {
         smctr_issue_read_word_cmd(dev, RW_UPSTREAM_NEIGHBOR_ADDRESS);
 
-        return(smctr_wait_cmd(dev));
+        return smctr_wait_cmd(dev);
 }
 
 static int smctr_hardware_send_packet(struct net_device *dev,
@@ -1469,21 +1469,22 @@ static int smctr_hardware_send_packet(struct net_device *dev,
                 printk(KERN_DEBUG"%s: smctr_hardware_send_packet\n", dev->name);
 
         if(tp->status != OPEN)
-                return (-1);
+                return -1;
 
         if(tp->monitor_state_ready != 1)
-                return (-1);
+                return -1;
 
         for(;;)
         {
                 /* Send first buffer from queue */
                 skb = skb_dequeue(&tp->SendSkbQueue);
                 if(skb == NULL)
-                        return (-1);
+                        return -1;
 
                 tp->QueueSkb++;
 
-                if(skb->len < SMC_HEADER_SIZE || skb->len > tp->max_packet_size)                        return (-1);
+                if(skb->len < SMC_HEADER_SIZE || skb->len > tp->max_packet_size)
+			return -1;
 
                 smctr_enable_16bit(dev);
                 smctr_set_page(dev, (__u8 *)tp->ram_access);
@@ -1492,7 +1493,7 @@ static int smctr_hardware_send_packet(struct net_device *dev,
                         == (FCBlock *)(-1L))
                 {
                         smctr_disable_16bit(dev);
-                        return (-1);
+                        return -1;
                 }
 
                 smctr_tx_move_frame(dev, skb,
@@ -1508,7 +1509,7 @@ static int smctr_hardware_send_packet(struct net_device *dev,
                 smctr_disable_16bit(dev);
         }
 
-        return (0);
+        return 0;
 }
 
 static int smctr_init_acbs(struct net_device *dev)
@@ -1552,7 +1553,7 @@ static int smctr_init_acbs(struct net_device *dev)
         tp->acb_curr            = tp->acb_head->next_ptr;
         tp->num_acbs_used       = 0;
 
-        return (0);
+        return 0;
 }
 
 static int smctr_init_adapter(struct net_device *dev)
@@ -1590,13 +1591,14 @@ static int smctr_init_adapter(struct net_device *dev)
 
         if(smctr_checksum_firmware(dev))
 	{
-                printk(KERN_ERR "%s: Previously loaded firmware is missing\n",dev->name);                return (-ENOENT);
+                printk(KERN_ERR "%s: Previously loaded firmware is missing\n",dev->name);
+		return -ENOENT;
         }
 
         if((err = smctr_ram_memory_test(dev)))
 	{
                 printk(KERN_ERR "%s: RAM memory test failed.\n", dev->name);
-                return (-EIO);
+                return -EIO;
         }
 
 	smctr_set_rx_look_ahead(dev);
@@ -1608,7 +1610,7 @@ static int smctr_init_adapter(struct net_device *dev)
 	{
                 printk(KERN_ERR "%s: Initialization of card failed (%d)\n",
                         dev->name, err);
-                return (-EINVAL);
+                return -EINVAL;
         }
 
         /* This routine clobbers the TRC's internal registers. */
@@ -1616,7 +1618,7 @@ static int smctr_init_adapter(struct net_device *dev)
 	{
                 printk(KERN_ERR "%s: Card failed internal self test (%d)\n",
                         dev->name, err);
-                return (-EINVAL);
+                return -EINVAL;
         }
 
         /* Re-Initialize adapter's internal registers */
@@ -1625,17 +1627,17 @@ static int smctr_init_adapter(struct net_device *dev)
 	{
                 printk(KERN_ERR "%s: Initialization of card failed (%d)\n",
                         dev->name, err);
-                return (-EINVAL);
+                return -EINVAL;
         }
 
         smctr_enable_bic_int(dev);
 
         if((err = smctr_issue_enable_int_cmd(dev, TRC_INTERRUPT_ENABLE_MASK)))
-                return (err);
+                return err;
 
         smctr_disable_16bit(dev);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_init_card_real(struct net_device *dev)
@@ -1703,15 +1705,15 @@ static int smctr_init_card_real(struct net_device *dev)
         smctr_init_shared_memory(dev);
 
         if((err = smctr_issue_init_timers_cmd(dev)))
-                return (err);
+                return err;
 
         if((err = smctr_issue_init_txrx_cmd(dev)))
 	{
                 printk(KERN_ERR "%s: Hardware failure\n", dev->name);
-                return (err);
+                return err;
         }
 
-        return (0);
+        return 0;
 }
 
 static int smctr_init_rx_bdbs(struct net_device *dev)
@@ -1763,7 +1765,7 @@ static int smctr_init_rx_bdbs(struct net_device *dev)
                 tp->rx_bdb_curr[i]              = tp->rx_bdb_head[i]->next_ptr;
         }
 
-        return (0);
+        return 0;
 }
 
 static int smctr_init_rx_fcbs(struct net_device *dev)
@@ -1813,7 +1815,7 @@ static int smctr_init_rx_fcbs(struct net_device *dev)
                 tp->rx_fcb_curr[i]              = tp->rx_fcb_head[i]->next_ptr;
         }
 
-        return(0);
+        return 0;
 }
 
 static int smctr_init_shared_memory(struct net_device *dev)
@@ -1871,7 +1873,7 @@ static int smctr_init_shared_memory(struct net_device *dev)
         smctr_init_rx_bdbs(dev);
         smctr_init_rx_fcbs(dev);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_init_tx_bdbs(struct net_device *dev)
@@ -1901,7 +1903,7 @@ static int smctr_init_tx_bdbs(struct net_device *dev)
                 tp->tx_bdb_head[i]->back_ptr = bdb;
         }
 
-        return (0);
+        return 0;
 }
 
 static int smctr_init_tx_fcbs(struct net_device *dev)
@@ -1940,7 +1942,7 @@ static int smctr_init_tx_fcbs(struct net_device *dev)
                 tp->num_tx_fcbs_used[i]         = 0;
         }
 
-        return (0);
+        return 0;
 }
 
 static int smctr_internal_self_test(struct net_device *dev)
@@ -1949,33 +1951,33 @@ static int smctr_internal_self_test(struct net_device *dev)
         int err;
 
         if((err = smctr_issue_test_internal_rom_cmd(dev)))
-                return (err);
+                return err;
 
         if((err = smctr_wait_cmd(dev)))
-                return (err);
+                return err;
 
         if(tp->acb_head->cmd_done_status & 0xff)
-                return (-1);
+                return -1;
 
         if((err = smctr_issue_test_hic_cmd(dev)))
-                return (err);
+                return err;
 
         if((err = smctr_wait_cmd(dev)))
-                return (err);
+                return err;
 
         if(tp->acb_head->cmd_done_status & 0xff)
-                return (-1);
+                return -1;
 
         if((err = smctr_issue_test_mac_reg_cmd(dev)))
-                return (err);
+                return err;
 
         if((err = smctr_wait_cmd(dev)))
-                return (err);
+                return err;
 
         if(tp->acb_head->cmd_done_status & 0xff)
-                return (-1);
+                return -1;
 
-        return (0);
+        return 0;
 }
 
 /*
@@ -2468,14 +2470,14 @@ static int smctr_issue_enable_int_cmd(struct net_device *dev,
         int err;
 
         if((err = smctr_wait_while_cbusy(dev)))
-                return (err);
+                return err;
 
         tp->sclb_ptr->int_mask_control  = interrupt_enable_mask;
         tp->sclb_ptr->valid_command     = SCLB_VALID | SCLB_CMD_CLEAR_INTERRUPT_MASK;
 
         smctr_set_ctrl_attention(dev);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_issue_int_ack(struct net_device *dev, __u16 iack_code, __u16 ibits)
@@ -2483,7 +2485,7 @@ static int smctr_issue_int_ack(struct net_device *dev, __u16 iack_code, __u16 ib
         struct net_local *tp = netdev_priv(dev);
 
         if(smctr_wait_while_cbusy(dev))
-                return (-1);
+                return -1;
 
         tp->sclb_ptr->int_mask_control = ibits;
         tp->sclb_ptr->iack_code = iack_code << 1; /* use the offset from base */        tp->sclb_ptr->resume_control = 0;
@@ -2491,7 +2493,7 @@ static int smctr_issue_int_ack(struct net_device *dev, __u16 iack_code, __u16 ib
 
         smctr_set_ctrl_attention(dev);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_issue_init_timers_cmd(struct net_device *dev)
@@ -2502,10 +2504,10 @@ static int smctr_issue_init_timers_cmd(struct net_device *dev)
         __u16 *pTimer_Struc = (__u16 *)tp->misc_command_data;
 
         if((err = smctr_wait_while_cbusy(dev)))
-                return (err);
+                return err;
 
         if((err = smctr_wait_cmd(dev)))
-                return (err);
+                return err;
 
         tp->config_word0 = THDREN | DMA_TRIGGER | USETPT | NO_AUTOREMOVE;
         tp->config_word1 = 0;
@@ -2648,7 +2650,7 @@ static int smctr_issue_init_timers_cmd(struct net_device *dev)
 
         err = smctr_setup_single_cmd_w_data(dev, ACB_CMD_INIT_TRC_TIMERS, 0);
 
-        return (err);
+        return err;
 }
 
 static int smctr_issue_init_txrx_cmd(struct net_device *dev)
@@ -2659,12 +2661,12 @@ static int smctr_issue_init_txrx_cmd(struct net_device *dev)
         void **txrx_ptrs = (void *)tp->misc_command_data;
 
         if((err = smctr_wait_while_cbusy(dev)))
-                return (err);
+                return err;
 
         if((err = smctr_wait_cmd(dev)))
 	{
                 printk(KERN_ERR "%s: Hardware failure\n", dev->name);
-                return (err);
+                return err;
         }
 
         /* Initialize Transmit Queue Pointers that are used, to point to
@@ -2695,7 +2697,7 @@ static int smctr_issue_init_txrx_cmd(struct net_device *dev)
 
         err = smctr_setup_single_cmd_w_data(dev, ACB_CMD_INIT_TX_RX, 0);
 
-        return (err);
+        return err;
 }
 
 static int smctr_issue_insert_cmd(struct net_device *dev)
@@ -2704,7 +2706,7 @@ static int smctr_issue_insert_cmd(struct net_device *dev)
 
         err = smctr_setup_single_cmd(dev, ACB_CMD_INSERT, ACB_SUB_CMD_NOP);
 
-        return (err);
+        return err;
 }
 
 static int smctr_issue_read_ring_status_cmd(struct net_device *dev)
@@ -2712,15 +2714,15 @@ static int smctr_issue_read_ring_status_cmd(struct net_device *dev)
         int err;
 
         if((err = smctr_wait_while_cbusy(dev)))
-                return (err);
+                return err;
 
         if((err = smctr_wait_cmd(dev)))
-                return (err);
+                return err;
 
         err = smctr_setup_single_cmd_w_data(dev, ACB_CMD_READ_TRC_STATUS,
                 RW_TRC_STATUS_BLOCK);
 
-        return (err);
+        return err;
 }
 
 static int smctr_issue_read_word_cmd(struct net_device *dev, __u16 aword_cnt)
@@ -2728,15 +2730,15 @@ static int smctr_issue_read_word_cmd(struct net_device *dev, __u16 aword_cnt)
         int err;
 
         if((err = smctr_wait_while_cbusy(dev)))
-                return (err);
+                return err;
 
         if((err = smctr_wait_cmd(dev)))
-                return (err);
+                return err;
 
         err = smctr_setup_single_cmd_w_data(dev, ACB_CMD_MCT_READ_VALUE,
                 aword_cnt);
 
-        return (err);
+        return err;
 }
 
 static int smctr_issue_remove_cmd(struct net_device *dev)
@@ -2745,14 +2747,14 @@ static int smctr_issue_remove_cmd(struct net_device *dev)
         int err;
 
         if((err = smctr_wait_while_cbusy(dev)))
-                return (err);
+                return err;
 
         tp->sclb_ptr->resume_control    = 0;
         tp->sclb_ptr->valid_command     = SCLB_VALID | SCLB_CMD_REMOVE;
 
         smctr_set_ctrl_attention(dev);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_issue_resume_acb_cmd(struct net_device *dev)
@@ -2761,7 +2763,7 @@ static int smctr_issue_resume_acb_cmd(struct net_device *dev)
         int err;
 
         if((err = smctr_wait_while_cbusy(dev)))
-                return (err);
+                return err;
 
         tp->sclb_ptr->resume_control = SCLB_RC_ACB;
         tp->sclb_ptr->valid_command  = SCLB_VALID | SCLB_RESUME_CONTROL_VALID;
@@ -2770,7 +2772,7 @@ static int smctr_issue_resume_acb_cmd(struct net_device *dev)
 
         smctr_set_ctrl_attention(dev);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_issue_resume_rx_bdb_cmd(struct net_device *dev, __u16 queue)
@@ -2779,7 +2781,7 @@ static int smctr_issue_resume_rx_bdb_cmd(struct net_device *dev, __u16 queue)
         int err;
 
         if((err = smctr_wait_while_cbusy(dev)))
-                return (err);
+                return err;
 
         if(queue == MAC_QUEUE)
                 tp->sclb_ptr->resume_control = SCLB_RC_RX_MAC_BDB;
@@ -2790,7 +2792,7 @@ static int smctr_issue_resume_rx_bdb_cmd(struct net_device *dev, __u16 queue)
 
         smctr_set_ctrl_attention(dev);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_issue_resume_rx_fcb_cmd(struct net_device *dev, __u16 queue)
@@ -2801,7 +2803,7 @@ static int smctr_issue_resume_rx_fcb_cmd(struct net_device *dev, __u16 queue)
                 printk(KERN_DEBUG "%s: smctr_issue_resume_rx_fcb_cmd\n", dev->name);
 
         if(smctr_wait_while_cbusy(dev))
-                return (-1);
+                return -1;
 
         if(queue == MAC_QUEUE)
                 tp->sclb_ptr->resume_control = SCLB_RC_RX_MAC_FCB;
@@ -2812,7 +2814,7 @@ static int smctr_issue_resume_rx_fcb_cmd(struct net_device *dev, __u16 queue)
 
         smctr_set_ctrl_attention(dev);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_issue_resume_tx_fcb_cmd(struct net_device *dev, __u16 queue)
@@ -2823,14 +2825,14 @@ static int smctr_issue_resume_tx_fcb_cmd(struct net_device *dev, __u16 queue)
                 printk(KERN_DEBUG "%s: smctr_issue_resume_tx_fcb_cmd\n", dev->name);
 
         if(smctr_wait_while_cbusy(dev))
-                return (-1);
+                return -1;
 
         tp->sclb_ptr->resume_control = (SCLB_RC_TFCB0 << queue);
         tp->sclb_ptr->valid_command = SCLB_RESUME_CONTROL_VALID | SCLB_VALID;
 
         smctr_set_ctrl_attention(dev);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_issue_test_internal_rom_cmd(struct net_device *dev)
@@ -2840,7 +2842,7 @@ static int smctr_issue_test_internal_rom_cmd(struct net_device *dev)
         err = smctr_setup_single_cmd(dev, ACB_CMD_MCT_TEST,
                 TRC_INTERNAL_ROM_TEST);
 
-        return (err);
+        return err;
 }
 
 static int smctr_issue_test_hic_cmd(struct net_device *dev)
@@ -2850,7 +2852,7 @@ static int smctr_issue_test_hic_cmd(struct net_device *dev)
         err = smctr_setup_single_cmd(dev, ACB_CMD_HIC_TEST,
                 TRC_HOST_INTERFACE_REG_TEST);
 
-        return (err);
+        return err;
 }
 
 static int smctr_issue_test_mac_reg_cmd(struct net_device *dev)
@@ -2860,7 +2862,7 @@ static int smctr_issue_test_mac_reg_cmd(struct net_device *dev)
         err = smctr_setup_single_cmd(dev, ACB_CMD_MCT_TEST,
                 TRC_MAC_REGISTERS_TEST);
 
-        return (err);
+        return err;
 }
 
 static int smctr_issue_trc_loopback_cmd(struct net_device *dev)
@@ -2870,7 +2872,7 @@ static int smctr_issue_trc_loopback_cmd(struct net_device *dev)
         err = smctr_setup_single_cmd(dev, ACB_CMD_MCT_TEST,
                 TRC_INTERNAL_LOOPBACK);
 
-        return (err);
+        return err;
 }
 
 static int smctr_issue_tri_loopback_cmd(struct net_device *dev)
@@ -2880,7 +2882,7 @@ static int smctr_issue_tri_loopback_cmd(struct net_device *dev)
         err = smctr_setup_single_cmd(dev, ACB_CMD_MCT_TEST,
                 TRC_TRI_LOOPBACK);
 
-        return (err);
+        return err;
 }
 
 static int smctr_issue_write_byte_cmd(struct net_device *dev,
@@ -2891,10 +2893,10 @@ static int smctr_issue_write_byte_cmd(struct net_device *dev,
 	int err;
 
         if((err = smctr_wait_while_cbusy(dev)))
-                return (err);
+                return err;
 
         if((err = smctr_wait_cmd(dev)))
-                return (err);
+                return err;
 
         for(iword = 0, ibyte = 0; iword < (unsigned int)(aword_cnt & 0xff);
         	iword++, ibyte += 2)
@@ -2903,8 +2905,8 @@ static int smctr_issue_write_byte_cmd(struct net_device *dev,
 			| (*((__u8 *)byte + ibyte + 1));
         }
 
-        return (smctr_setup_single_cmd_w_data(dev, ACB_CMD_MCT_WRITE_VALUE, 
-		aword_cnt));
+        return smctr_setup_single_cmd_w_data(dev, ACB_CMD_MCT_WRITE_VALUE, 
+		aword_cnt);
 }
 
 static int smctr_issue_write_word_cmd(struct net_device *dev,
@@ -2914,10 +2916,10 @@ static int smctr_issue_write_word_cmd(struct net_device *dev,
         unsigned int i, err;
 
         if((err = smctr_wait_while_cbusy(dev)))
-                return (err);
+                return err;
 
         if((err = smctr_wait_cmd(dev)))
-                return (err);
+                return err;
 
         for(i = 0; i < (unsigned int)(aword_cnt & 0xff); i++)
                 tp->misc_command_data[i] = *((__u16 *)word + i);
@@ -2925,7 +2927,7 @@ static int smctr_issue_write_word_cmd(struct net_device *dev,
         err = smctr_setup_single_cmd_w_data(dev, ACB_CMD_MCT_WRITE_VALUE,
                 aword_cnt);
 
-        return (err);
+        return err;
 }
 
 static int smctr_join_complete_state(struct net_device *dev)
@@ -2935,7 +2937,7 @@ static int smctr_join_complete_state(struct net_device *dev)
         err = smctr_setup_single_cmd(dev, ACB_CMD_CHANGE_JOIN_STATE,
                 JS_JOIN_COMPLETE_STATE);
 
-        return (err);
+        return err;
 }
 
 static int smctr_link_tx_fcbs_to_bdbs(struct net_device *dev)
@@ -2959,7 +2961,7 @@ static int smctr_link_tx_fcbs_to_bdbs(struct net_device *dev)
                 }
         }
 
-        return (0);
+        return 0;
 }
 
 static int smctr_load_firmware(struct net_device *dev)
@@ -2974,7 +2976,7 @@ static int smctr_load_firmware(struct net_device *dev)
 
 	if (request_firmware(&fw, "tr_smctr.bin", &dev->dev)) {
 		printk(KERN_ERR "%s: firmware not found\n", dev->name);
-		return (UCODE_NOT_PRESENT);
+		return UCODE_NOT_PRESENT;
 	}
 
         tp->num_of_tx_buffs     = 4;
@@ -3036,7 +3038,7 @@ static int smctr_load_firmware(struct net_device *dev)
         smctr_disable_16bit(dev);
  out:
 	release_firmware(fw);
-        return (err);
+        return err;
 }
 
 static int smctr_load_node_addr(struct net_device *dev)
@@ -3052,7 +3054,7 @@ static int smctr_load_node_addr(struct net_device *dev)
         }
         dev->addr_len = 6;
 
-        return (0);
+        return 0;
 }
 
 /* Lobe Media Test.
@@ -3146,14 +3148,14 @@ static int smctr_lobe_media_test_cmd(struct net_device *dev)
                 if(smctr_wait_cmd(dev))
                 {
                         printk(KERN_ERR "Lobe Failed test state\n");
-                        return (LOBE_MEDIA_TEST_FAILED);
+                        return LOBE_MEDIA_TEST_FAILED;
                 }
         }
 
         err = smctr_setup_single_cmd(dev, ACB_CMD_MCT_TEST,
                 TRC_LOBE_MEDIA_TEST);
 
-        return (err);
+        return err;
 }
 
 static int smctr_lobe_media_test_state(struct net_device *dev)
@@ -3163,7 +3165,7 @@ static int smctr_lobe_media_test_state(struct net_device *dev)
         err = smctr_setup_single_cmd(dev, ACB_CMD_CHANGE_JOIN_STATE,
                 JS_LOBE_TEST_STATE);
 
-        return (err);
+        return err;
 }
 
 static int smctr_make_8025_hdr(struct net_device *dev,
@@ -3212,7 +3214,7 @@ static int smctr_make_8025_hdr(struct net_device *dev,
                         break;
         }
 
-        return (0);
+        return 0;
 }
 
 static int smctr_make_access_pri(struct net_device *dev, MAC_SUB_VECTOR *tsv)
@@ -3225,7 +3227,7 @@ static int smctr_make_access_pri(struct net_device *dev, MAC_SUB_VECTOR *tsv)
         tsv->svv[0] = MSB(tp->authorized_access_priority);
         tsv->svv[1] = LSB(tp->authorized_access_priority);
 
-	return (0);
+	return 0;
 }
 
 static int smctr_make_addr_mod(struct net_device *dev, MAC_SUB_VECTOR *tsv)
@@ -3236,7 +3238,7 @@ static int smctr_make_addr_mod(struct net_device *dev, MAC_SUB_VECTOR *tsv)
         tsv->svv[0] = 0;
         tsv->svv[1] = 0;
 
-        return (0);
+        return 0;
 }
 
 static int smctr_make_auth_funct_class(struct net_device *dev,
@@ -3250,7 +3252,7 @@ static int smctr_make_auth_funct_class(struct net_device *dev,
         tsv->svv[0] = MSB(tp->authorized_function_classes);
         tsv->svv[1] = LSB(tp->authorized_function_classes);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_make_corr(struct net_device *dev,
@@ -3262,7 +3264,7 @@ static int smctr_make_corr(struct net_device *dev,
         tsv->svv[0] = MSB(correlator);
         tsv->svv[1] = LSB(correlator);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_make_funct_addr(struct net_device *dev, MAC_SUB_VECTOR *tsv)
@@ -3280,7 +3282,7 @@ static int smctr_make_funct_addr(struct net_device *dev, MAC_SUB_VECTOR *tsv)
         tsv->svv[2] = MSB(tp->misc_command_data[1]);
         tsv->svv[3] = LSB(tp->misc_command_data[1]);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_make_group_addr(struct net_device *dev, MAC_SUB_VECTOR *tsv)
@@ -3305,7 +3307,7 @@ static int smctr_make_group_addr(struct net_device *dev, MAC_SUB_VECTOR *tsv)
 	   tsv->svv[2] == 0x00 && tsv->svv[3] == 0x00)
                 tsv->svv[0] = 0x00;
 
-        return (0);
+        return 0;
 }
 
 static int smctr_make_phy_drop_num(struct net_device *dev,
@@ -3324,7 +3326,7 @@ static int smctr_make_phy_drop_num(struct net_device *dev,
         tsv->svv[2] = MSB(tp->misc_command_data[1]);
         tsv->svv[3] = LSB(tp->misc_command_data[1]);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_make_product_id(struct net_device *dev, MAC_SUB_VECTOR *tsv)
@@ -3337,7 +3339,7 @@ static int smctr_make_product_id(struct net_device *dev, MAC_SUB_VECTOR *tsv)
         for(i = 0; i < 18; i++)
                 tsv->svv[i] = 0xF0;
 
-        return (0);
+        return 0;
 }
 
 static int smctr_make_station_id(struct net_device *dev, MAC_SUB_VECTOR *tsv)
@@ -3358,7 +3360,7 @@ static int smctr_make_station_id(struct net_device *dev, MAC_SUB_VECTOR *tsv)
         tsv->svv[4] = MSB(tp->misc_command_data[2]);
         tsv->svv[5] = LSB(tp->misc_command_data[2]);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_make_ring_station_status(struct net_device *dev,
@@ -3374,7 +3376,7 @@ static int smctr_make_ring_station_status(struct net_device *dev,
         tsv->svv[4] = 0;
         tsv->svv[5] = 0;
 
-        return (0);
+        return 0;
 }
 
 static int smctr_make_ring_station_version(struct net_device *dev,
@@ -3400,7 +3402,7 @@ static int smctr_make_ring_station_version(struct net_device *dev,
         else
                 tsv->svv[9] = 0xc4;    /* EBCDIC - D */
 
-        return (0);
+        return 0;
 }
 
 static int smctr_make_tx_status_code(struct net_device *dev,
@@ -3414,7 +3416,7 @@ static int smctr_make_tx_status_code(struct net_device *dev,
         /* Stripped frame status of Transmitted Frame */
         tsv->svv[1] = tx_fstatus & 0xff;
 
-        return (0);
+        return 0;
 }
 
 static int smctr_make_upstream_neighbor_addr(struct net_device *dev,
@@ -3436,7 +3438,7 @@ static int smctr_make_upstream_neighbor_addr(struct net_device *dev,
         tsv->svv[4] = MSB(tp->misc_command_data[2]);
         tsv->svv[5] = LSB(tp->misc_command_data[2]);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_make_wrap_data(struct net_device *dev, MAC_SUB_VECTOR *tsv)
@@ -3444,7 +3446,7 @@ static int smctr_make_wrap_data(struct net_device *dev, MAC_SUB_VECTOR *tsv)
         tsv->svi = WRAP_DATA;
         tsv->svl = S_WRAP_DATA;
 
-        return (0);
+        return 0;
 }
 
 /*
@@ -3464,9 +3466,9 @@ static int smctr_open(struct net_device *dev)
 
         err = smctr_init_adapter(dev);
         if(err < 0)
-                return (err);
+                return err;
 
-        return (err);
+        return err;
 }
 
 /* Interrupt driven open of Token card. */
@@ -3481,9 +3483,9 @@ static int smctr_open_tr(struct net_device *dev)
 
         /* Now we can actually open the adapter. */
         if(tp->status == OPEN)
-                return (0);
+                return 0;
         if(tp->status != INITIALIZED)
-                return (-1);
+                return -1;
 
 	/* FIXME: it would work a lot better if we masked the irq sources
 	   on the card here, then we could skip the locking and poll nicely */
@@ -3560,7 +3562,7 @@ static int smctr_open_tr(struct net_device *dev)
 out:
         spin_unlock_irqrestore(&tp->lock, flags);
 
-        return (err);
+        return err;
 }
 
 /* Check for a network adapter of this type, 
@@ -3675,7 +3677,7 @@ static int __init smctr_probe1(struct net_device *dev, int ioaddr)
 
 	dev->netdev_ops = &smctr_netdev_ops;
         dev->watchdog_timeo	= HZ;
-        return (0);
+        return 0;
 
 out:
 	return err;
@@ -3699,13 +3701,13 @@ static int smctr_process_rx_packet(MAC_HEADER *rmf, __u16 size,
                         case INIT:
                                 if((rcode = smctr_rcv_init(dev, rmf, &correlator)) == HARDWARE_FAILED)
                                 {
-                                        return (rcode);
+                                        return rcode;
                                 }
 
                                 if((err = smctr_send_rsp(dev, rmf, rcode,
                                         correlator)))
                                 {
-                                        return (err);
+                                        return err;
                                 }
                                 break;
 
@@ -3713,13 +3715,13 @@ static int smctr_process_rx_packet(MAC_HEADER *rmf, __u16 size,
                                 if((rcode = smctr_rcv_chg_param(dev, rmf,
                                         &correlator)) ==HARDWARE_FAILED)
                                 {
-                                        return (rcode);
+                                        return rcode;
                                 }
 
                                 if((err = smctr_send_rsp(dev, rmf, rcode,
                                         correlator)))
                                 {
-                                        return (err);
+                                        return err;
                                 }
                                 break;
 
@@ -3728,16 +3730,16 @@ static int smctr_process_rx_packet(MAC_HEADER *rmf, __u16 size,
                                         rmf, &correlator)) != POSITIVE_ACK)
                                 {
                                         if(rcode == HARDWARE_FAILED)
-                                                return (rcode);
+                                                return rcode;
                                         else
-                                                return (smctr_send_rsp(dev, rmf,
-                                                        rcode, correlator));
+                                                return smctr_send_rsp(dev, rmf,
+                                                        rcode, correlator);
                                 }
 
                                 if((err = smctr_send_rpt_addr(dev, rmf,
                                         correlator)))
                                 {
-                                        return (err);
+                                        return err;
                                 }
                                 break;
 
@@ -3746,17 +3748,17 @@ static int smctr_process_rx_packet(MAC_HEADER *rmf, __u16 size,
                                         rmf, &correlator)) != POSITIVE_ACK)
                                 {
                                         if(rcode == HARDWARE_FAILED)
-                                                return (rcode);
+                                                return rcode;
                                         else
-                                                return (smctr_send_rsp(dev, rmf,
+                                                return smctr_send_rsp(dev, rmf,
                                                         rcode,
-                                                        correlator));
+                                                        correlator);
                                 }
 
                                 if((err = smctr_send_rpt_attch(dev, rmf,
                                         correlator)))
                                 {
-                                        return (err);
+                                        return err;
                                 }
                                 break;
 
@@ -3765,17 +3767,17 @@ static int smctr_process_rx_packet(MAC_HEADER *rmf, __u16 size,
                                         rmf, &correlator)) != POSITIVE_ACK)
                                 {
                                         if(rcode == HARDWARE_FAILED)
-                                                return (rcode);
+                                                return rcode;
                                         else
-                                                return (smctr_send_rsp(dev, rmf,
+                                                return smctr_send_rsp(dev, rmf,
                                                         rcode,
-                                                        correlator));
+                                                        correlator);
                                 }
 
                                 if((err = smctr_send_rpt_state(dev, rmf,
                                         correlator)))
                                 {
-                                        return (err);
+                                        return err;
                                 }
                                 break;
 
@@ -3786,17 +3788,17 @@ static int smctr_process_rx_packet(MAC_HEADER *rmf, __u16 size,
                                         != POSITIVE_ACK)
                                 {
                                         if(rcode == HARDWARE_FAILED)
-                                                return (rcode);
+                                                return rcode;
                                         else
-                                                return (smctr_send_rsp(dev, rmf,
+                                                return smctr_send_rsp(dev, rmf,
                                                         rcode,
-                                                        correlator));
+                                                        correlator);
                                 }
 
                                 if((err = smctr_send_tx_forward(dev, rmf,
                                         &tx_fstatus)) == HARDWARE_FAILED)
                                 {
-                                        return (err);
+                                        return err;
                                 }
 
                                 if(err == A_FRAME_WAS_FORWARDED)
@@ -3805,7 +3807,7 @@ static int smctr_process_rx_packet(MAC_HEADER *rmf, __u16 size,
 						rmf, tx_fstatus))
                                                 == HARDWARE_FAILED)
                                         {
-                                                return (err);
+                                                return err;
                                         }
                                 }
                                 break;
@@ -3834,7 +3836,7 @@ static int smctr_process_rx_packet(MAC_HEADER *rmf, __u16 size,
                                         if((err = smctr_send_rsp(dev, rmf,rcode,
                                                 correlator)))
                                         {
-                                                return (err);
+                                                return err;
                                         }
                                 }
 
@@ -3899,7 +3901,7 @@ static int smctr_process_rx_packet(MAC_HEADER *rmf, __u16 size,
                 err = 0;
         }
 
-        return (err);
+        return err;
 }
 
 /* Adapter RAM test. Incremental word ODD boundary data test. */
@@ -3942,7 +3944,7 @@ static int smctr_ram_memory_test(struct net_device *dev)
                                 err_offset      = j;
                                 err_word        = word_read;
                                 err_pattern     = word_pattern;
-                                return (RAM_TEST_FAILED);
+                                return RAM_TEST_FAILED;
                         }
                 }
         }
@@ -3966,14 +3968,14 @@ static int smctr_ram_memory_test(struct net_device *dev)
                                 err_offset      = j;
                                 err_word        = word_read;
                                 err_pattern     = word_pattern;
-                                return (RAM_TEST_FAILED);
+                                return RAM_TEST_FAILED;
                         }
                 }
         }
 
         smctr_set_page(dev, (__u8 *)tp->ram_access);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_rcv_chg_param(struct net_device *dev, MAC_HEADER *rmf,
@@ -3986,7 +3988,7 @@ static int smctr_rcv_chg_param(struct net_device *dev, MAC_HEADER *rmf,
 
         /* This Frame can only come from a CRS */
         if((rmf->dc_sc & SC_MASK) != SC_CRS)
-                return(E_INAPPROPRIATE_SOURCE_CLASS);
+                return E_INAPPROPRIATE_SOURCE_CLASS;
 
         /* Remove MVID Length from total length. */
         vlen = (signed short)rmf->vl - 4;
@@ -4058,7 +4060,7 @@ static int smctr_rcv_chg_param(struct net_device *dev, MAC_HEADER *rmf,
 		}
         }
 
-        return (rcode);
+        return rcode;
 }
 
 static int smctr_rcv_init(struct net_device *dev, MAC_HEADER *rmf,
@@ -4071,7 +4073,7 @@ static int smctr_rcv_init(struct net_device *dev, MAC_HEADER *rmf,
 
         /* This Frame can only come from a RPS */
         if((rmf->dc_sc & SC_MASK) != SC_RPS)
-                return (E_INAPPROPRIATE_SOURCE_CLASS);
+                return E_INAPPROPRIATE_SOURCE_CLASS;
 
         /* Remove MVID Length from total length. */
         vlen = (signed short)rmf->vl - 4;
@@ -4133,7 +4135,7 @@ static int smctr_rcv_init(struct net_device *dev, MAC_HEADER *rmf,
 		}
         }
 
-        return (rcode);
+        return rcode;
 }
 
 static int smctr_rcv_tx_forward(struct net_device *dev, MAC_HEADER *rmf)
@@ -4145,7 +4147,7 @@ static int smctr_rcv_tx_forward(struct net_device *dev, MAC_HEADER *rmf)
 
         /* This Frame can only come from a CRS */
         if((rmf->dc_sc & SC_MASK) != SC_CRS)
-                return (E_INAPPROPRIATE_SOURCE_CLASS);
+                return E_INAPPROPRIATE_SOURCE_CLASS;
 
         /* Remove MVID Length from total length */
         vlen = (signed short)rmf->vl - 4;
@@ -4193,7 +4195,7 @@ static int smctr_rcv_tx_forward(struct net_device *dev, MAC_HEADER *rmf)
 		}
         }
 
-        return (rcode);
+        return rcode;
 }
 
 static int smctr_rcv_rq_addr_state_attch(struct net_device *dev,
@@ -4250,7 +4252,7 @@ static int smctr_rcv_rq_addr_state_attch(struct net_device *dev,
 			}
         }
 
-        return (rcode);
+        return rcode;
 }
 
 static int smctr_rcv_unknown(struct net_device *dev, MAC_HEADER *rmf,
@@ -4284,7 +4286,7 @@ static int smctr_rcv_unknown(struct net_device *dev, MAC_HEADER *rmf,
                 rsv = (MAC_SUB_VECTOR *)((__u32)rsv + rsv->svl);
         }
 
-        return (E_UNRECOGNIZED_VECTOR_ID);
+        return E_UNRECOGNIZED_VECTOR_ID;
 }
 
 /*
@@ -4311,7 +4313,7 @@ static int smctr_reset_adapter(struct net_device *dev)
          */
         outb(tp->trc_mask | CSR_CLRTINT | CSR_CLRCBUSY, ioaddr + CSR);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_restart_tx_chain(struct net_device *dev, short queue)
@@ -4329,7 +4331,7 @@ static int smctr_restart_tx_chain(struct net_device *dev, short queue)
                 err = smctr_issue_resume_tx_fcb_cmd(dev, queue);
         }
 
-        return (err);
+        return err;
 }
 
 static int smctr_ring_status_chg(struct net_device *dev)
@@ -4371,7 +4373,7 @@ static int smctr_ring_status_chg(struct net_device *dev)
         }
 
         if(!(tp->ring_status_flags & RING_STATUS_CHANGED))
-                return (0);
+                return 0;
 
         switch(tp->ring_status)
         {
@@ -4421,7 +4423,7 @@ static int smctr_ring_status_chg(struct net_device *dev)
                         break;
         }
 
-        return (0);
+        return 0;
 }
 
 static int smctr_rx_frame(struct net_device *dev)
@@ -4486,7 +4488,7 @@ static int smctr_rx_frame(struct net_device *dev)
                         break;
         }
 
-        return (err);
+        return err;
 }
 
 static int smctr_send_dat(struct net_device *dev)
@@ -4502,7 +4504,7 @@ static int smctr_send_dat(struct net_device *dev)
         if((fcb = smctr_get_tx_fcb(dev, MAC_QUEUE,
                 sizeof(MAC_HEADER))) == (FCBlock *)(-1L))
         {
-                return (OUT_OF_RESOURCES);
+                return OUT_OF_RESOURCES;
         }
 
         /* Initialize DAT Data Fields. */
@@ -4524,7 +4526,7 @@ static int smctr_send_dat(struct net_device *dev)
 
         /* Start Transmit. */
         if((err = smctr_trc_send_packet(dev, fcb, MAC_QUEUE)))
-                return (err);
+                return err;
 
         /* Wait for Transmit to Complete */
         for(i = 0; i < 10000; i++)
@@ -4538,7 +4540,7 @@ static int smctr_send_dat(struct net_device *dev)
         if(!(fcb->frame_status &  FCB_COMMAND_DONE) ||
 	   fcb->frame_status & (FCB_TX_STATUS_E | FCB_TX_AC_BITS))
         {
-                return (INITIALIZE_FAILED);
+                return INITIALIZE_FAILED;
         }
 
         /* De-allocated Tx FCB and Frame Buffer
@@ -4549,7 +4551,7 @@ static int smctr_send_dat(struct net_device *dev)
         tp->tx_queue_status[MAC_QUEUE] = NOT_TRANSMITING;
         smctr_update_tx_chain(dev, fcb, MAC_QUEUE);
 
-        return (0);
+        return 0;
 }
 
 static void smctr_timeout(struct net_device *dev)
@@ -4610,7 +4612,7 @@ static int smctr_send_lobe_media_test(struct net_device *dev)
         if((fcb = smctr_get_tx_fcb(dev, MAC_QUEUE, sizeof(struct trh_hdr)
                 + S_WRAP_DATA + S_WRAP_DATA)) == (FCBlock *)(-1L))
         {
-                return (OUT_OF_RESOURCES);
+                return OUT_OF_RESOURCES;
         }
 
         /* Initialize DAT Data Fields. */
@@ -4639,7 +4641,7 @@ static int smctr_send_lobe_media_test(struct net_device *dev)
         /* Start Transmit. */
         tmf->vl = SWAP_BYTES(tmf->vl);
         if((err = smctr_trc_send_packet(dev, fcb, MAC_QUEUE)))
-                return (err);
+                return err;
 
         /* Wait for Transmit to Complete. (10 ms). */
         for(i=0; i < 10000; i++)
@@ -4653,7 +4655,7 @@ static int smctr_send_lobe_media_test(struct net_device *dev)
         if(!(fcb->frame_status & FCB_COMMAND_DONE) ||
 	   fcb->frame_status & (FCB_TX_STATUS_E | FCB_TX_AC_BITS))
         {
-                return (LOBE_MEDIA_TEST_FAILED);
+                return LOBE_MEDIA_TEST_FAILED;
         }
 
         /* De-allocated Tx FCB and Frame Buffer
@@ -4664,7 +4666,7 @@ static int smctr_send_lobe_media_test(struct net_device *dev)
         tp->tx_queue_status[MAC_QUEUE] = NOT_TRANSMITING;
         smctr_update_tx_chain(dev, fcb, MAC_QUEUE);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_send_rpt_addr(struct net_device *dev, MAC_HEADER *rmf,
@@ -4679,7 +4681,7 @@ static int smctr_send_rpt_addr(struct net_device *dev, MAC_HEADER *rmf,
 		+ S_ADDRESS_MODIFER + S_GROUP_ADDRESS + S_FUNCTIONAL_ADDRESS))
 		== (FCBlock *)(-1L))
         {
-                return (0);
+                return 0;
         }
 
         tmf 		= (MAC_HEADER *)fcb->bdb_ptr->data_block_ptr;
@@ -4722,7 +4724,7 @@ static int smctr_send_rpt_addr(struct net_device *dev, MAC_HEADER *rmf,
 */
         tmf->vl = SWAP_BYTES(tmf->vl);
 
-        return (smctr_trc_send_packet(dev, fcb, MAC_QUEUE));
+        return smctr_trc_send_packet(dev, fcb, MAC_QUEUE);
 }
 
 static int smctr_send_rpt_attch(struct net_device *dev, MAC_HEADER *rmf,
@@ -4737,7 +4739,7 @@ static int smctr_send_rpt_attch(struct net_device *dev, MAC_HEADER *rmf,
 		+ S_AUTHORIZED_FUNCTION_CLASS + S_AUTHORIZED_ACCESS_PRIORITY))
 		== (FCBlock *)(-1L))
         {
-                return (0);
+                return 0;
         }
 
         tmf 	   = (MAC_HEADER *)fcb->bdb_ptr->data_block_ptr;
@@ -4776,7 +4778,7 @@ static int smctr_send_rpt_attch(struct net_device *dev, MAC_HEADER *rmf,
 */
         tmf->vl = SWAP_BYTES(tmf->vl);
 
-        return (smctr_trc_send_packet(dev, fcb, MAC_QUEUE));
+        return smctr_trc_send_packet(dev, fcb, MAC_QUEUE);
 }
 
 static int smctr_send_rpt_state(struct net_device *dev, MAC_HEADER *rmf,
@@ -4791,7 +4793,7 @@ static int smctr_send_rpt_state(struct net_device *dev, MAC_HEADER *rmf,
 		+ S_RING_STATION_STATUS + S_STATION_IDENTIFER))
 		== (FCBlock *)(-1L))
         {
-                return (0);
+                return 0;
         }
 
         tmf 	   = (MAC_HEADER *)fcb->bdb_ptr->data_block_ptr;
@@ -4826,7 +4828,7 @@ static int smctr_send_rpt_state(struct net_device *dev, MAC_HEADER *rmf,
 */
         tmf->vl = SWAP_BYTES(tmf->vl);
 
-        return (smctr_trc_send_packet(dev, fcb, MAC_QUEUE));
+        return smctr_trc_send_packet(dev, fcb, MAC_QUEUE);
 }
 
 static int smctr_send_rpt_tx_forward(struct net_device *dev,
@@ -4839,7 +4841,7 @@ static int smctr_send_rpt_tx_forward(struct net_device *dev,
         if((fcb = smctr_get_tx_fcb(dev, MAC_QUEUE, sizeof(MAC_HEADER)
 		+ S_TRANSMIT_STATUS_CODE)) == (FCBlock *)(-1L))
         {
-                return (0);
+                return 0;
         }
 
         tmf 	   = (MAC_HEADER *)fcb->bdb_ptr->data_block_ptr;
@@ -4862,7 +4864,7 @@ static int smctr_send_rpt_tx_forward(struct net_device *dev,
 */
         tmf->vl = SWAP_BYTES(tmf->vl);
 
-        return(smctr_trc_send_packet(dev, fcb, MAC_QUEUE));
+        return smctr_trc_send_packet(dev, fcb, MAC_QUEUE);
 }
 
 static int smctr_send_rsp(struct net_device *dev, MAC_HEADER *rmf,
@@ -4875,7 +4877,7 @@ static int smctr_send_rsp(struct net_device *dev, MAC_HEADER *rmf,
         if((fcb = smctr_get_tx_fcb(dev, MAC_QUEUE, sizeof(MAC_HEADER)
 		+ S_CORRELATOR + S_RESPONSE_CODE)) == (FCBlock *)(-1L))
         {
-                return (0);
+                return 0;
         }
 
         tmf 	   = (MAC_HEADER *)fcb->bdb_ptr->data_block_ptr;
@@ -4888,7 +4890,7 @@ static int smctr_send_rsp(struct net_device *dev, MAC_HEADER *rmf,
         tsv = (MAC_SUB_VECTOR *)((__u32)tmf + sizeof(MAC_HEADER));
         smctr_make_corr(dev, tsv, correlator);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_send_rq_init(struct net_device *dev)
@@ -4907,7 +4909,7 @@ static int smctr_send_rq_init(struct net_device *dev)
 			+ S_RING_STATION_VERSION_NUMBER + S_ADDRESS_MODIFER))
 			== (FCBlock *)(-1L)))
                 {
-                        return (0);
+                        return 0;
                 }
 
                 tmf 	   = (MAC_HEADER *)fcb->bdb_ptr->data_block_ptr;
@@ -4943,7 +4945,7 @@ static int smctr_send_rq_init(struct net_device *dev)
                 tmf->vl = SWAP_BYTES(tmf->vl);
 
                 if((err = smctr_trc_send_packet(dev, fcb, MAC_QUEUE)))
-                        return (err);
+                        return err;
 
                 /* Wait for Transmit to Complete */
       		for(i = 0; i < 10000; i++) 
@@ -4957,7 +4959,7 @@ static int smctr_send_rq_init(struct net_device *dev)
                 fstatus = fcb->frame_status;
 
                 if(!(fstatus & FCB_COMMAND_DONE))
-                        return (HARDWARE_FAILED);
+                        return HARDWARE_FAILED;
 
                 if(!(fstatus & FCB_TX_STATUS_E))
                         count++;
@@ -4971,7 +4973,7 @@ static int smctr_send_rq_init(struct net_device *dev)
                 smctr_update_tx_chain(dev, fcb, MAC_QUEUE);
         } while(count < 4 && ((fstatus & FCB_TX_AC_BITS) ^ FCB_TX_AC_BITS));
 
-	return (smctr_join_complete_state(dev));
+	return smctr_join_complete_state(dev);
 }
 
 static int smctr_send_tx_forward(struct net_device *dev, MAC_HEADER *rmf,
@@ -4984,13 +4986,13 @@ static int smctr_send_tx_forward(struct net_device *dev, MAC_HEADER *rmf,
 
         /* Check if this is the END POINT of the Transmit Forward Chain. */
         if(rmf->vl <= 18)
-                return (0);
+                return 0;
 
         /* Allocate Transmit FCB only by requesting 0 bytes
          * of data buffer.
          */
         if((fcb = smctr_get_tx_fcb(dev, MAC_QUEUE, 0)) == (FCBlock *)(-1L))
-                return (0);
+                return 0;
 
         /* Set pointer to Transmit Frame Buffer to the data
          * portion of the received TX Forward frame, making
@@ -5006,7 +5008,7 @@ static int smctr_send_tx_forward(struct net_device *dev, MAC_HEADER *rmf,
         fcb->bdb_ptr->buffer_length      = rmf->vl - 4 - 2;
 
         if((err = smctr_trc_send_packet(dev, fcb, MAC_QUEUE)))
-                return (err);
+                return err;
 
         /* Wait for Transmit to Complete */
    	for(i = 0; i < 10000; i++) 
@@ -5020,7 +5022,7 @@ static int smctr_send_tx_forward(struct net_device *dev, MAC_HEADER *rmf,
         if(!(fcb->frame_status & FCB_COMMAND_DONE))
         {
                 if((err = smctr_issue_resume_tx_fcb_cmd(dev, MAC_QUEUE)))
-                        return (err);
+                        return err;
 
       		for(i = 0; i < 10000; i++) 
 		{
@@ -5030,12 +5032,12 @@ static int smctr_send_tx_forward(struct net_device *dev, MAC_HEADER *rmf,
       		}
 
                 if(!(fcb->frame_status & FCB_COMMAND_DONE))
-                        return (HARDWARE_FAILED);
+                        return HARDWARE_FAILED;
         }
 
         *tx_fstatus = fcb->frame_status;
 
-        return (A_FRAME_WAS_FORWARDED);
+        return A_FRAME_WAS_FORWARDED;
 }
 
 static int smctr_set_auth_access_pri(struct net_device *dev,
@@ -5044,11 +5046,11 @@ static int smctr_set_auth_access_pri(struct net_device *dev,
         struct net_local *tp = netdev_priv(dev);
 
         if(rsv->svl != S_AUTHORIZED_ACCESS_PRIORITY)
-                return (E_SUB_VECTOR_LENGTH_ERROR);
+                return E_SUB_VECTOR_LENGTH_ERROR;
 
         tp->authorized_access_priority = (rsv->svv[0] << 8 | rsv->svv[1]);
 
-        return (POSITIVE_ACK);
+        return POSITIVE_ACK;
 }
 
 static int smctr_set_auth_funct_class(struct net_device *dev,
@@ -5057,22 +5059,22 @@ static int smctr_set_auth_funct_class(struct net_device *dev,
         struct net_local *tp = netdev_priv(dev);
 
         if(rsv->svl != S_AUTHORIZED_FUNCTION_CLASS)
-                return (E_SUB_VECTOR_LENGTH_ERROR);
+                return E_SUB_VECTOR_LENGTH_ERROR;
 
         tp->authorized_function_classes = (rsv->svv[0] << 8 | rsv->svv[1]);
 
-        return (POSITIVE_ACK);
+        return POSITIVE_ACK;
 }
 
 static int smctr_set_corr(struct net_device *dev, MAC_SUB_VECTOR *rsv,
         __u16 *correlator)
 {
         if(rsv->svl != S_CORRELATOR)
-                return (E_SUB_VECTOR_LENGTH_ERROR);
+                return E_SUB_VECTOR_LENGTH_ERROR;
 
         *correlator = (rsv->svv[0] << 8 | rsv->svv[1]);
 
-        return (POSITIVE_ACK);
+        return POSITIVE_ACK;
 }
 
 static int smctr_set_error_timer_value(struct net_device *dev,
@@ -5082,34 +5084,34 @@ static int smctr_set_error_timer_value(struct net_device *dev,
 	int err;
 
         if(rsv->svl != S_ERROR_TIMER_VALUE)
-                return (E_SUB_VECTOR_LENGTH_ERROR);
+                return E_SUB_VECTOR_LENGTH_ERROR;
 
         err_tval = (rsv->svv[0] << 8 | rsv->svv[1])*10;
 
         smctr_issue_write_word_cmd(dev, RW_TER_THRESHOLD, &err_tval);
 
         if((err = smctr_wait_cmd(dev)))
-                return (err);
+                return err;
 
-        return (POSITIVE_ACK);
+        return POSITIVE_ACK;
 }
 
 static int smctr_set_frame_forward(struct net_device *dev,
         MAC_SUB_VECTOR *rsv, __u8 dc_sc)
 {
         if((rsv->svl < 2) || (rsv->svl > S_FRAME_FORWARD))
-                return (E_SUB_VECTOR_LENGTH_ERROR);
+                return E_SUB_VECTOR_LENGTH_ERROR;
 
         if((dc_sc & DC_MASK) != DC_CRS)
         {
                 if(rsv->svl >= 2 && rsv->svl < 20)
-                	return (E_TRANSMIT_FORWARD_INVALID);
+                	return E_TRANSMIT_FORWARD_INVALID;
 
                 if((rsv->svv[0] != 0) || (rsv->svv[1] != 0))
-                        return (E_TRANSMIT_FORWARD_INVALID);
+                        return E_TRANSMIT_FORWARD_INVALID;
         }
 
-        return (POSITIVE_ACK);
+        return POSITIVE_ACK;
 }
 
 static int smctr_set_local_ring_num(struct net_device *dev,
@@ -5118,13 +5120,13 @@ static int smctr_set_local_ring_num(struct net_device *dev,
         struct net_local *tp = netdev_priv(dev);
 
         if(rsv->svl != S_LOCAL_RING_NUMBER)
-                return (E_SUB_VECTOR_LENGTH_ERROR);
+                return E_SUB_VECTOR_LENGTH_ERROR;
 
         if(tp->ptr_local_ring_num)
                 *(__u16 *)(tp->ptr_local_ring_num) 
 			= (rsv->svv[0] << 8 | rsv->svv[1]);
 
-        return (POSITIVE_ACK);
+        return POSITIVE_ACK;
 }
 
 static unsigned short smctr_set_ctrl_attention(struct net_device *dev)
@@ -5140,7 +5142,7 @@ static unsigned short smctr_set_ctrl_attention(struct net_device *dev)
                 outb(tp->trc_mask, ioaddr + CSR);
         }
 
-        return (0);
+        return 0;
 }
 
 static void smctr_set_multicast_list(struct net_device *dev)
@@ -5159,7 +5161,7 @@ static int smctr_set_page(struct net_device *dev, __u8 *buf)
         amask = (__u8)((tptr & PR_PAGE_MASK) >> 8);
         outb(amask, dev->base_addr + PR);
 
-        return (0);
+        return 0;
 }
 
 static int smctr_set_phy_drop(struct net_device *dev, MAC_SUB_VECTOR *rsv)
@@ -5167,13 +5169,13 @@ static int smctr_set_phy_drop(struct net_device *dev, MAC_SUB_VECTOR *rsv)
 	int err;
 
         if(rsv->svl != S_PHYSICAL_DROP)
-                return (E_SUB_VECTOR_LENGTH_ERROR);
+                return E_SUB_VECTOR_LENGTH_ERROR;
 
         smctr_issue_write_byte_cmd(dev, RW_PHYSICAL_DROP_NUMBER, &rsv->svv[0]);
         if((err = smctr_wait_cmd(dev)))
-                return (err);
+                return err;
 
-        return (POSITIVE_ACK);
+        return POSITIVE_ACK;
 }
 
 /* Reset the ring speed to the opposite of what it was. This auto-pilot
@@ -5195,16 +5197,16 @@ static int smctr_set_ring_speed(struct net_device *dev)
         smctr_reset_adapter(dev);
 
         if((err = smctr_init_card_real(dev)))
-                return (err);
+                return err;
 
         smctr_enable_bic_int(dev);
 
         if((err = smctr_issue_enable_int_cmd(dev, TRC_INTERRUPT_ENABLE_MASK)))
-                return (err);
+                return err;
 
         smctr_disable_16bit(dev);
 
-	return (0);
+	return 0;
 }
 
 static int smctr_set_rx_look_ahead(struct net_device *dev)
@@ -5233,7 +5235,7 @@ static int smctr_set_rx_look_ahead(struct net_device *dev)
                 *((__u16 *)(tp->ram_access)) = sword;
         }
 
-        return (0);
+        return 0;
 }
 
 static int smctr_set_trc_reset(int ioaddr)
@@ -5243,7 +5245,7 @@ static int smctr_set_trc_reset(int ioaddr)
         r = inb(ioaddr + MSR);
         outb(MSR_RST | r, ioaddr + MSR);
 
-        return (0);
+        return 0;
 }
 
 /*
@@ -5259,10 +5261,10 @@ static int smctr_setup_single_cmd(struct net_device *dev,
                 printk(KERN_DEBUG "%s: smctr_setup_single_cmd\n", dev->name);
 
         if((err = smctr_wait_while_cbusy(dev)))
-                return (err);
+                return err;
 
         if((err = (unsigned int)smctr_wait_cmd(dev)))
-                return (err);
+                return err;
 
         tp->acb_head->cmd_done_status   = 0;
         tp->acb_head->cmd               = command;
@@ -5270,7 +5272,7 @@ static int smctr_setup_single_cmd(struct net_device *dev,
 
         err = smctr_issue_resume_acb_cmd(dev);
 
-        return (err);
+        return err;
 }
 
 /*
@@ -5287,7 +5289,7 @@ static int smctr_setup_single_cmd_w_data(struct net_device *dev,
         tp->acb_head->data_offset_lo
                 = (__u16)TRC_POINTER(tp->misc_command_data);
 
-        return(smctr_issue_resume_acb_cmd(dev));
+        return smctr_issue_resume_acb_cmd(dev);
 }
 
 static char *smctr_malloc(struct net_device *dev, __u16 size)
@@ -5298,7 +5300,7 @@ static char *smctr_malloc(struct net_device *dev, __u16 size)
         m = (char *)(tp->ram_access + tp->sh_mem_used);
         tp->sh_mem_used += (__u32)size;
 
-        return (m);
+        return m;
 }
 
 static int smctr_status_chg(struct net_device *dev)
@@ -5333,7 +5335,7 @@ static int smctr_status_chg(struct net_device *dev)
                         break;
         }
 
-        return (0);
+        return 0;
 }
 
 static int smctr_trc_send_packet(struct net_device *dev, FCBlock *fcb,
@@ -5355,7 +5357,7 @@ static int smctr_trc_send_packet(struct net_device *dev, FCBlock *fcb,
                 err = smctr_issue_resume_tx_fcb_cmd(dev, queue);
         }
 
-        return (err);
+        return err;
 }
 
 static __u16 smctr_tx_complete(struct net_device *dev, __u16 queue)
@@ -5409,7 +5411,7 @@ static __u16 smctr_tx_complete(struct net_device *dev, __u16 queue)
                         break;
         }
 
-        return (err);
+        return err;
 }
 
 static unsigned short smctr_tx_move_frame(struct net_device *dev,
@@ -5450,7 +5452,7 @@ static unsigned short smctr_tx_move_frame(struct net_device *dev,
                 pbuff += len;
         }
 
-        return (0);
+        return 0;
 }
 
 /* Update the error statistic counters for this adapter. */
@@ -5493,7 +5495,7 @@ static int smctr_update_err_stats(struct net_device *dev)
         if(tstat->token_errors)
                 tstat->token_errors += *(tp->misc_command_data + 5) >> 8;
 
-        return (0);
+        return 0;
 }
 
 static int smctr_update_rx_chain(struct net_device *dev, __u16 queue)
@@ -5530,7 +5532,7 @@ static int smctr_update_rx_chain(struct net_device *dev, __u16 queue)
         tp->rx_bdb_curr[queue]->back_ptr->info = BDB_NOT_CHAIN_END;
         tp->rx_bdb_curr[queue] = bdb;
 
-        return (0);
+        return 0;
 }
 
 static int smctr_update_tx_chain(struct net_device *dev, FCBlock *fcb,
@@ -5542,13 +5544,13 @@ static int smctr_update_tx_chain(struct net_device *dev, FCBlock *fcb,
                 printk(KERN_DEBUG "smctr_update_tx_chain\n");
 
         if(tp->num_tx_fcbs_used[queue] <= 0)
-                return (HARDWARE_FAILED);
+                return HARDWARE_FAILED;
         else
         {
                 if(tp->tx_buff_used[queue] < fcb->memory_alloc)
                 {
                         tp->tx_buff_used[queue] = 0;
-                        return (HARDWARE_FAILED);
+                        return HARDWARE_FAILED;
                 }
 
                 tp->tx_buff_used[queue] -= fcb->memory_alloc;
@@ -5566,7 +5568,7 @@ static int smctr_update_tx_chain(struct net_device *dev, FCBlock *fcb,
                 fcb->frame_status = 0;
                 tp->tx_fcb_end[queue] = fcb->next_ptr;
 		netif_wake_queue(dev);
-                return (0);
+                return 0;
         }
 }
 
@@ -5587,12 +5589,12 @@ static int smctr_wait_cmd(struct net_device *dev)
         }
 
         if(loop_count == 0)
-                return(HARDWARE_FAILED);
+                return HARDWARE_FAILED;
 
         if(tp->acb_head->cmd_done_status & 0xff)
-                return(HARDWARE_FAILED);
+                return HARDWARE_FAILED;
 
-        return (0);
+        return 0;
 }
 
 static int smctr_wait_while_cbusy(struct net_device *dev)
@@ -5624,9 +5626,9 @@ static int smctr_wait_while_cbusy(struct net_device *dev)
         }
 
         if(timeout)
-                return (0);
+                return 0;
         else
-                return (HARDWARE_FAILED);
+                return HARDWARE_FAILED;
 }
 
 #ifdef MODULE
diff --git a/drivers/net/tokenring/tms380tr.c b/drivers/net/tokenring/tms380tr.c
index 08182fd..c83f4f6 100644
--- a/drivers/net/tokenring/tms380tr.c
+++ b/drivers/net/tokenring/tms380tr.c
@@ -224,7 +224,7 @@ static int madgemc_sifprobe(struct net_device *dev)
                 chk2 ^= 0x0FE;
 
                 if(chk1 != chk2)
-                        return (-1);    /* No adapter */
+                        return -1;    /* No adapter */
                 chk1 -= 2;
         } while(chk1 != 0);     /* Repeat 128 times (all byte values) */
 
@@ -232,7 +232,7 @@ static int madgemc_sifprobe(struct net_device *dev)
         /* Restore the SIFADR value */
 	SIFWRITEB(old, SIFADR);
 
-        return (0);
+        return 0;
 }
 #endif
 
@@ -271,7 +271,7 @@ int tms380tr_open(struct net_device *dev)
 	{
 		printk(KERN_INFO "%s: Chipset initialization error\n", 
 			dev->name);
-		return (-1);
+		return -1;
 	}
 
 	tp->timer.expires	= jiffies + 30*HZ;
@@ -298,7 +298,7 @@ int tms380tr_open(struct net_device *dev)
 	if(tp->AdapterVirtOpenFlag == 0)
 	{
 		tms380tr_disable_interrupts(dev);
-		return (-1);
+		return -1;
 	}
 
 	tp->StartTime = jiffies;
@@ -309,7 +309,7 @@ int tms380tr_open(struct net_device *dev)
 	tp->timer.data		= (unsigned long)dev;
 	add_timer(&tp->timer);
 
-	return (0);
+	return 0;
 }
 
 /*
@@ -343,23 +343,23 @@ static int tms380tr_chipset_init(struct net_device *dev)
 		printk(KERN_DEBUG "%s: Resetting adapter...\n", dev->name);
 	err = tms380tr_reset_adapter(dev);
 	if(err < 0)
-		return (-1);
+		return -1;
 
 	if(tms380tr_debug > 3)
 		printk(KERN_DEBUG "%s: Bringup diags...\n", dev->name);
 	err = tms380tr_bringup_diags(dev);
 	if(err < 0)
-		return (-1);
+		return -1;
 
 	if(tms380tr_debug > 3)
 		printk(KERN_DEBUG "%s: Init adapter...\n", dev->name);
 	err = tms380tr_init_adapter(dev);
 	if(err < 0)
-		return (-1);
+		return -1;
 
 	if(tms380tr_debug > 3)
 		printk(KERN_DEBUG "%s: Done!\n", dev->name);
-	return (0);
+	return 0;
 }
 
 /*
@@ -877,7 +877,7 @@ static unsigned char tms380tr_chk_ssb(struct net_local *tp, unsigned short IrqTy
 	   IrqType != STS_IRQ_COMMAND_STATUS &&
 	   IrqType != STS_IRQ_RING_STATUS)
 	{
-		return (1);	/* SSB not involved. */
+		return 1;	/* SSB not involved. */
 	}
 
 	/* Note: All fields of the SSB have been set to all ones (-1) after it
@@ -887,21 +887,21 @@ static unsigned char tms380tr_chk_ssb(struct net_local *tp, unsigned short IrqTy
 	 */
 
 	if(ssb->STS == (unsigned short) -1)
-		return (0);	/* Command field not yet available. */
+		return 0;	/* Command field not yet available. */
 	if(IrqType == STS_IRQ_COMMAND_STATUS)
-		return (1);	/* Status fields not always affected. */
+		return 1;	/* Status fields not always affected. */
 	if(ssb->Parm[0] == (unsigned short) -1)
-		return (0);	/* Status 1 field not yet available. */
+		return 0;	/* Status 1 field not yet available. */
 	if(IrqType == STS_IRQ_RING_STATUS)
-		return (1);	/* Status 2 & 3 fields not affected. */
+		return 1;	/* Status 2 & 3 fields not affected. */
 
 	/* Note: At this point, the interrupt is either TRANSMIT or RECEIVE. */
 	if(ssb->Parm[1] == (unsigned short) -1)
-		return (0);	/* Status 2 field not yet available. */
+		return 0;	/* Status 2 field not yet available. */
 	if(ssb->Parm[2] == (unsigned short) -1)
-		return (0);	/* Status 3 field not yet available. */
+		return 0;	/* Status 3 field not yet available. */
 
-	return (1);	/* All SSB fields have been written by the adapter. */
+	return 1;	/* All SSB fields have been written by the adapter. */
 }
 
 /*
@@ -1143,7 +1143,7 @@ int tms380tr_close(struct net_device *dev)
 #endif
 	tms380tr_cancel_tx_queue(tp);
 
-	return (0);
+	return 0;
 }
 
 /*
@@ -1154,7 +1154,7 @@ static struct net_device_stats *tms380tr_get_stats(struct net_device *dev)
 {
 	struct net_local *tp = netdev_priv(dev);
 
-	return ((struct net_device_stats *)&tp->MacStat);
+	return (struct net_device_stats *)&tp->MacStat;
 }
 
 /*
@@ -1256,7 +1256,7 @@ static int tms380tr_reset_adapter(struct net_device *dev)
 	if (request_firmware(&fw_entry, "tms380tr.bin", tp->pdev) != 0) {
 		printk(KERN_ALERT "%s: firmware %s is missing, cannot start.\n",
 			dev->name, "tms380tr.bin");
-		return (-1);
+		return -1;
 	}
 
 	fw_ptr = (unsigned short *)fw_entry->data;
@@ -1322,13 +1322,13 @@ static int tms380tr_reset_adapter(struct net_device *dev)
 			/* Clear CPHALT and start BUD */
 			SIFWRITEW(c, SIFACL);
 			release_firmware(fw_entry);
-			return (1);
+			return 1;
 		}
 	} while(count == 0);
 
 	release_firmware(fw_entry);
 	printk(KERN_INFO "%s: Adapter Download Failed\n", dev->name);
-	return (-1);
+	return -1;
 }
 
 MODULE_FIRMWARE("tms380tr.bin");
@@ -1363,7 +1363,7 @@ static int tms380tr_bringup_diags(struct net_device *dev)
 				printk(KERN_DEBUG " %04X\n", Status);
 			/* BUD successfully completed */
 			if(Status == STS_INITIALIZE)
-				return (1);
+				return 1;
 		/* Unrecoverable hardware error, BUD not completed? */
 		} while((loop_cnt > 0) && ((Status & (STS_ERROR | STS_TEST))
 			!= (STS_ERROR | STS_TEST)));
@@ -1390,7 +1390,7 @@ static int tms380tr_bringup_diags(struct net_device *dev)
 	else
 		printk(KERN_INFO "%s: Bring Up Diagnostics Error (%04X) occurred\n", dev->name, Status & 0x000f);
 
-	return (-1);
+	return -1;
 }
 
 /*
@@ -1464,7 +1464,7 @@ static int tms380tr_init_adapter(struct net_device *dev)
 				{
 					printk(KERN_INFO "%s: DMA failed\n", dev->name);
 					/* DMA data error: wrong data in SCB */
-					return (-1);
+					return -1;
 				}
 				i++;
 			} while(i < 6);
@@ -1473,11 +1473,11 @@ static int tms380tr_init_adapter(struct net_device *dev)
 			do {	/* Test if contents of SSB is valid */
 				if(SSB_Test[i] != *(sb_ptr + i))
 					/* DMA data error: wrong data in SSB */
-					return (-1);
+					return -1;
 				i++;
 			} while (i < 8);
 
-			return (1);	/* Adapter successfully initialized */
+			return 1;	/* Adapter successfully initialized */
 		}
 		else
 		{
@@ -1488,7 +1488,7 @@ static int tms380tr_init_adapter(struct net_device *dev)
 				Status &= STS_ERROR_MASK;
 				/* ShowInitialisationErrorCode(Status); */
 				printk(KERN_INFO "%s: Status error: %d\n", dev->name, Status);
-				return (-1); /* Unrecoverable error */
+				return -1; /* Unrecoverable error */
 			}
 			else
 			{
@@ -1503,7 +1503,7 @@ static int tms380tr_init_adapter(struct net_device *dev)
 	} while(retry_cnt > 0);
 
 	printk(KERN_INFO "%s: Retry exceeded\n", dev->name);
-	return (-1);
+	return -1;
 }
 
 /*
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index a03730b..5c633a3 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -219,7 +219,7 @@ static int tsi108_read_mii(struct tsi108_prv_data *data, int reg)
 	if (i == 100)
 		return 0xffff;
 	else
-		return (TSI_READ_PHY(TSI108_MAC_MII_DATAIN));
+		return TSI_READ_PHY(TSI108_MAC_MII_DATAIN);
 }
 
 static void tsi108_write_mii(struct tsi108_prv_data *data,
diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index 1d9fef7..251c6ce 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -3119,7 +3119,7 @@ dc2114x_autoconf(struct net_device *dev)
 	  if (lp->media == _100Mb) {
 	      if ((slnk = test_for_100Mb(dev, 6500)) < 0) {
 		  lp->media = SPD_DET;
-		  return  (slnk & ~TIMER_CB);
+		  return slnk & ~TIMER_CB;
 	      }
 	  } else {
 	      if (wait_for_link(dev) < 0) {
@@ -3484,7 +3484,7 @@ is_spd_100(struct net_device *dev)
 	spd = ((~gep_rd(dev)) & GEP_SLNK);
     } else {
 	if ((lp->ibn == 2) || !lp->asBitValid)
-	    return ((lp->chipset == DC21143)?(~inl(DE4X5_SISR)&SISR_LS100):0);
+	    return (lp->chipset == DC21143) ? (~inl(DE4X5_SISR)&SISR_LS100) : 0;
 
 	spd = (lp->asBitValid & (lp->asPolarity ^ (gep_rd(dev) & lp->asBit))) |
 	          (lp->linkOK & ~lp->asBitValid);
@@ -3502,15 +3502,15 @@ is_100_up(struct net_device *dev)
     if (lp->useMII) {
 	/* Double read for sticky bits & temporary drops */
 	mii_rd(MII_SR, lp->phy[lp->active].addr, DE4X5_MII);
-	return (mii_rd(MII_SR, lp->phy[lp->active].addr, DE4X5_MII) & MII_SR_LKS);
+	return mii_rd(MII_SR, lp->phy[lp->active].addr, DE4X5_MII) & MII_SR_LKS;
     } else if (!lp->useSROM) {                       /* de500-xa */
-	return ((~gep_rd(dev)) & GEP_SLNK);
+	return (~gep_rd(dev)) & GEP_SLNK;
     } else {
 	if ((lp->ibn == 2) || !lp->asBitValid)
-	    return ((lp->chipset == DC21143)?(~inl(DE4X5_SISR)&SISR_LS100):0);
+	    return (lp->chipset == DC21143) ? (~inl(DE4X5_SISR)&SISR_LS100) : 0;
 
-        return ((lp->asBitValid&(lp->asPolarity^(gep_rd(dev)&lp->asBit))) |
-		(lp->linkOK & ~lp->asBitValid));
+        return (lp->asBitValid&(lp->asPolarity^(gep_rd(dev)&lp->asBit))) |
+		(lp->linkOK & ~lp->asBitValid);
     }
 }
 
@@ -3523,17 +3523,17 @@ is_10_up(struct net_device *dev)
     if (lp->useMII) {
 	/* Double read for sticky bits & temporary drops */
 	mii_rd(MII_SR, lp->phy[lp->active].addr, DE4X5_MII);
-	return (mii_rd(MII_SR, lp->phy[lp->active].addr, DE4X5_MII) & MII_SR_LKS);
+	return mii_rd(MII_SR, lp->phy[lp->active].addr, DE4X5_MII) & MII_SR_LKS;
     } else if (!lp->useSROM) {                       /* de500-xa */
-	return ((~gep_rd(dev)) & GEP_LNP);
+	return (~gep_rd(dev)) & GEP_LNP;
     } else {
 	if ((lp->ibn == 2) || !lp->asBitValid)
-	    return (((lp->chipset & ~0x00ff) == DC2114x) ?
+	    return ((lp->chipset & ~0x00ff) == DC2114x) ?
 		    (~inl(DE4X5_SISR)&SISR_LS10):
-		    0);
+		    0;
 
-	return ((lp->asBitValid&(lp->asPolarity^(gep_rd(dev)&lp->asBit))) |
-		(lp->linkOK & ~lp->asBitValid));
+	return	(lp->asBitValid&(lp->asPolarity^(gep_rd(dev)&lp->asBit))) |
+		(lp->linkOK & ~lp->asBitValid);
     }
 }
 
@@ -3544,7 +3544,7 @@ is_anc_capable(struct net_device *dev)
     u_long iobase = dev->base_addr;
 
     if (lp->phy[lp->active].id && (!lp->useSROM || lp->useMII)) {
-	return (mii_rd(MII_SR, lp->phy[lp->active].addr, DE4X5_MII));
+	return mii_rd(MII_SR, lp->phy[lp->active].addr, DE4X5_MII);
     } else if ((lp->chipset & ~0x00ff) == DC2114x) {
 	return (inl(DE4X5_SISR) & SISR_LPN) >> 12;
     } else {
@@ -4930,7 +4930,7 @@ getfrom_mii(u32 command, u_long ioaddr)
     outl(command | MII_MDC, ioaddr);
     udelay(1);
 
-    return ((inl(ioaddr) >> 19) & 1);
+    return (inl(ioaddr) >> 19) & 1;
 }
 
 /*
@@ -4975,8 +4975,8 @@ mii_get_oui(u_char phyaddr, u_long ioaddr)
     a.breg[0]=a.breg[1];
     a.breg[1]=i;
 
-    return ((a.reg<<8)|ret); */                 /* SEEQ and Cypress way */
-/*    return ((r2<<6)|(u_int)(r3>>10)); */      /* NATIONAL and BROADCOM way */
+    return (a.reg<<8)|ret; */                 /* SEEQ and Cypress way */
+/*    return (r2<<6)|(u_int)(r3>>10); */      /* NATIONAL and BROADCOM way */
     return r2;                                  /* (I did it) My way */
 }
 
@@ -5144,7 +5144,7 @@ gep_rd(struct net_device *dev)
     if (lp->chipset == DC21140) {
 	return inl(DE4X5_GEP);
     } else if ((lp->chipset & ~0x00ff) == DC2114x) {
-	return (inl(DE4X5_SIGR) & 0x000fffff);
+	return inl(DE4X5_SIGR) & 0x000fffff;
     }
 
     return 0;
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index 1dc27a5..74217db 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -1747,7 +1747,7 @@ static u16 phy_readby_cr10(unsigned long iobase, u8 phy_addr, u8 offset)
 		if(cr10_value&0x10000000)
 			break;
 	}
-	return (cr10_value&0x0ffff);
+	return cr10_value & 0x0ffff;
 }
 
 static void phy_writeby_cr10(unsigned long iobase, u8 phy_addr, u8 offset, u16 phy_data)
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 5dfb395..1cc6713 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -541,7 +541,7 @@ cleanup:
 
 	indexes->respCleared = cpu_to_le32(cleared);
 	wmb();
-	return (resp_save == NULL);
+	return resp_save == NULL;
 }
 
 static inline int
diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.c
index ee85c8b..d1ac15c 100644
--- a/drivers/net/usb/sierra_net.c
+++ b/drivers/net/usb/sierra_net.c
@@ -203,7 +203,7 @@ static inline void sierra_net_set_private(struct usbnet *dev,
 /* is packet IPv4 */
 static inline int is_ip(struct sk_buff *skb)
 {
-	return (skb->protocol == cpu_to_be16(ETH_P_IP));
+	return skb->protocol == cpu_to_be16(ETH_P_IP);
 }
 
 /*
@@ -354,7 +354,7 @@ static void sierra_net_set_ctx_index(struct sierra_net_data *priv, u8 ctx_ix)
 
 static inline int sierra_net_is_valid_addrlen(u8 len)
 {
-	return (len == sizeof(struct in_addr));
+	return len == sizeof(struct in_addr);
 }
 
 static int sierra_net_parse_lsi(struct usbnet *dev, char *data, int datalen)
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 5ec542d..0bbc0c3 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -250,7 +250,7 @@ static int veth_close(struct net_device *dev)
 
 static int is_valid_veth_mtu(int new_mtu)
 {
-	return (new_mtu >= MIN_MTU && new_mtu <= MAX_MTU);
+	return new_mtu >= MIN_MTU && new_mtu <= MAX_MTU;
 }
 
 static int veth_change_mtu(struct net_device *dev, int new_mtu)
diff --git a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
index 421d071..1481a44 100644
--- a/drivers/net/wan/dlci.c
+++ b/drivers/net/wan/dlci.c
@@ -97,11 +97,11 @@ static int dlci_header(struct sk_buff *skb, struct net_device *dev,
 
 	dest = skb_push(skb, hlen);
 	if (!dest)
-		return(0);
+		return 0;
 
 	memcpy(dest, &hdr, hlen);
 
-	return(hlen);
+	return hlen;
 }
 
 static void dlci_receive(struct sk_buff *skb, struct net_device *dev)
@@ -211,14 +211,14 @@ static int dlci_config(struct net_device *dev, struct dlci_conf __user *conf, in
 		if (copy_from_user(&config, conf, sizeof(struct dlci_conf)))
 			return -EFAULT;
 		if (config.flags & ~DLCI_VALID_FLAGS)
-			return(-EINVAL);
+			return -EINVAL;
 		memcpy(&dlp->config, &config, sizeof(struct dlci_conf));
 		dlp->configured = 1;
 	}
 
 	err = (*flp->dlci_conf)(dlp->slave, dev, get);
 	if (err)
-		return(err);
+		return err;
 
 	if (get)
 	{
@@ -226,7 +226,7 @@ static int dlci_config(struct net_device *dev, struct dlci_conf __user *conf, in
 			return -EFAULT;
 	}
 
-	return(0);
+	return 0;
 }
 
 static int dlci_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
@@ -234,7 +234,7 @@ static int dlci_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	struct dlci_local *dlp;
 
 	if (!capable(CAP_NET_ADMIN))
-		return(-EPERM);
+		return -EPERM;
 
 	dlp = netdev_priv(dev);
 
@@ -242,7 +242,7 @@ static int dlci_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	{
 		case DLCI_GET_SLAVE:
 			if (!*(short *)(dev->dev_addr))
-				return(-EINVAL);
+				return -EINVAL;
 
 			strncpy(ifr->ifr_slave, dlp->slave->name, sizeof(ifr->ifr_slave));
 			break;
@@ -250,15 +250,15 @@ static int dlci_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		case DLCI_GET_CONF:
 		case DLCI_SET_CONF:
 			if (!*(short *)(dev->dev_addr))
-				return(-EINVAL);
+				return -EINVAL;
 
-			return(dlci_config(dev, ifr->ifr_data, cmd == DLCI_GET_CONF));
+			return dlci_config(dev, ifr->ifr_data, cmd == DLCI_GET_CONF);
 			break;
 
 		default: 
-			return(-EOPNOTSUPP);
+			return -EOPNOTSUPP;
 	}
-	return(0);
+	return 0;
 }
 
 static int dlci_change_mtu(struct net_device *dev, int new_mtu)
@@ -277,15 +277,15 @@ static int dlci_open(struct net_device *dev)
 	dlp = netdev_priv(dev);
 
 	if (!*(short *)(dev->dev_addr))
-		return(-EINVAL);
+		return -EINVAL;
 
 	if (!netif_running(dlp->slave))
-		return(-ENOTCONN);
+		return -ENOTCONN;
 
 	flp = netdev_priv(dlp->slave);
 	err = (*flp->activate)(dlp->slave, dev);
 	if (err)
-		return(err);
+		return err;
 
 	netif_start_queue(dev);
 
@@ -365,14 +365,14 @@ static int dlci_add(struct dlci_add *dlci)
 	list_add(&dlp->list, &dlci_devs);
 	rtnl_unlock();
 
-	return(0);
+	return 0;
 
  err2:
 	rtnl_unlock();
 	free_netdev(master);
  err1:
 	dev_put(slave);
-	return(err);
+	return err;
 }
 
 static int dlci_del(struct dlci_add *dlci)
@@ -385,10 +385,10 @@ static int dlci_del(struct dlci_add *dlci)
 	/* validate slave device */
 	master = __dev_get_by_name(&init_net, dlci->devname);
 	if (!master)
-		return(-ENODEV);
+		return -ENODEV;
 
 	if (netif_running(master)) {
-		return(-EBUSY);
+		return -EBUSY;
 	}
 
 	dlp = netdev_priv(master);
@@ -406,7 +406,7 @@ static int dlci_del(struct dlci_add *dlci)
 	}
 	rtnl_unlock();
 
-	return(err);
+	return err;
 }
 
 static int dlci_ioctl(unsigned int cmd, void __user *arg)
@@ -415,7 +415,7 @@ static int dlci_ioctl(unsigned int cmd, void __user *arg)
 	int err;
 	
 	if (!capable(CAP_NET_ADMIN))
-		return(-EPERM);
+		return -EPERM;
 
 	if (copy_from_user(&add, arg, sizeof(struct dlci_add)))
 		return -EFAULT;
@@ -438,7 +438,7 @@ static int dlci_ioctl(unsigned int cmd, void __user *arg)
 			err = -EINVAL;
 	}
 
-	return(err);
+	return err;
 }
 
 static const struct header_ops dlci_header_ops = {
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index 43af85b..70feb84 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -1022,7 +1022,7 @@ static int lmc_open(struct net_device *dev)
 
     if (sc->lmc_ok){
         lmc_trace(dev, "lmc_open lmc_ok out");
-        return (0);
+        return 0;
     }
 
     lmc_softreset (sc);
@@ -1110,7 +1110,7 @@ static int lmc_open(struct net_device *dev)
 
     lmc_trace(dev, "lmc_open out");
 
-    return (0);
+    return 0;
 }
 
 /* Total reset to compensate for the AdTran DSU doing bad things
diff --git a/drivers/net/wan/n2.c b/drivers/net/wan/n2.c
index 7a3720f..17d408f 100644
--- a/drivers/net/wan/n2.c
+++ b/drivers/net/wan/n2.c
@@ -379,14 +379,14 @@ static int __init n2_run(unsigned long io, unsigned long irq,
 	if (request_irq(irq, sca_intr, 0, devname, card)) {
 		printk(KERN_ERR "n2: could not allocate IRQ\n");
 		n2_destroy_card(card);
-		return(-EBUSY);
+		return -EBUSY;
 	}
 	card->irq = irq;
 
 	if (!request_mem_region(winbase, USE_WINDOWSIZE, devname)) {
 		printk(KERN_ERR "n2: could not request RAM window\n");
 		n2_destroy_card(card);
-		return(-EBUSY);
+		return -EBUSY;
 	}
 	card->phy_winbase = winbase;
 	card->winbase = ioremap(winbase, USE_WINDOWSIZE);
diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index fbf1175..f875cfa 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -451,11 +451,11 @@ static int dma_get_rx_frame_size(pc300_t * card, int ch)
 		if ((status & DST_EOM) || (first_bd == card->chan[ch].rx_last_bd)) {
 			/* Return the size of a good frame or incomplete bad frame 
 			* (dma_buf_read will clean the buffer descriptors in this case). */
-			return (rcvd);
+			return rcvd;
 		}
 		ptdescr = (card->hw.rambase + cpc_readl(&ptdescr->next));
 	}
-	return (-1);
+	return -1;
 }
 
 /*
@@ -557,7 +557,7 @@ static int dma_buf_read(pc300_t * card, int ch, struct sk_buff *skb)
 		cpc_writel(card->hw.scabase + DRX_REG(EDAL, ch),
 			   RX_BD_ADDR(ch, chan->rx_last_bd));
 	}
-	return (rcvd);
+	return rcvd;
 }
 
 static void tx_dma_stop(pc300_t * card, int ch)
@@ -1733,7 +1733,7 @@ static u16 falc_pattern_test_error(pc300_t * card, int ch)
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
 
-	return (pfalc->bec);
+	return pfalc->bec;
 }
 
 /**********************************/
@@ -2819,7 +2819,7 @@ static int clock_rate_calc(u32 rate, u32 clock, int *br_io)
 	*br_io = 0;
 
 	if (rate == 0)
-		return (0);
+		return 0;
 
 	for (br = 0, br_pwr = 1; br <= 9; br++, br_pwr <<= 1) {
 		if ((tc = clock / br_pwr / rate) <= 0xff) {
@@ -2832,11 +2832,11 @@ static int clock_rate_calc(u32 rate, u32 clock, int *br_io)
 		error = ((rate - (clock / br_pwr / rate)) / rate) * 1000;
 		/* Errors bigger than +/- 1% won't be tolerated */
 		if (error < -10 || error > 10)
-			return (-1);
+			return -1;
 		else
-			return (tc);
+			return tc;
 	} else {
-		return (-1);
+		return -1;
 	}
 }
 
@@ -3207,7 +3207,7 @@ static u32 detect_ram(pc300_t * card)
 			break;
 		}
 	}
-	return (i);
+	return i;
 }
 
 static void plx_init(pc300_t * card)
diff --git a/drivers/net/wan/pc300_tty.c b/drivers/net/wan/pc300_tty.c
index 4293889..5d65f3e 100644
--- a/drivers/net/wan/pc300_tty.c
+++ b/drivers/net/wan/pc300_tty.c
@@ -540,7 +540,7 @@ static int cpc_tty_chars_in_buffer(struct tty_struct *tty)
 		return -ENODEV; 
 	}
    
-	return(0); 
+	return 0; 
 } 
 
 static int pc300_tiocmset(struct tty_struct *tty, struct file *file,
diff --git a/drivers/net/wan/sdla.c b/drivers/net/wan/sdla.c
index f4125da..1bc091a 100644
--- a/drivers/net/wan/sdla.c
+++ b/drivers/net/wan/sdla.c
@@ -178,7 +178,7 @@ static char sdla_byte(struct net_device *dev, int addr)
 	byte = *temp;
 	spin_unlock_irqrestore(&sdla_lock, flags);
 
-	return(byte);
+	return byte;
 }
 
 static void sdla_stop(struct net_device *dev)
@@ -267,7 +267,7 @@ static int sdla_z80_poll(struct net_device *dev, int z80_addr, int jiffs, char r
 			resp = *temp;
 		}
 	}
-	return(time_before(jiffies, done) ? jiffies - start : -1);
+	return time_before(jiffies, done) ? jiffies - start : -1;
 }
 
 /* constants for Z80 CPU speed */
@@ -283,13 +283,13 @@ static int sdla_cpuspeed(struct net_device *dev, struct ifreq *ifr)
 
 	sdla_start(dev);
 	if (sdla_z80_poll(dev, 0, 3*HZ, Z80_READY, 0) < 0)
-		return(-EIO);
+		return -EIO;
 
 	data = LOADER_READY;
 	sdla_write(dev, 0, &data, 1);
 
 	if ((jiffs = sdla_z80_poll(dev, 0, 8*HZ, Z80_SCC_OK, Z80_SCC_BAD)) < 0)
-		return(-EIO);
+		return -EIO;
 
 	sdla_stop(dev);
 	sdla_read(dev, 0, &data, 1);
@@ -297,11 +297,11 @@ static int sdla_cpuspeed(struct net_device *dev, struct ifreq *ifr)
 	if (data == Z80_SCC_BAD)
 	{
 		printk("%s: SCC bad\n", dev->name);
-		return(-EIO);
+		return -EIO;
 	}
 
 	if (data != Z80_SCC_OK)
-		return(-EINVAL);
+		return -EINVAL;
 
 	if (jiffs < 165)
 		ifr->ifr_mtu = SDLA_CPU_16M;
@@ -316,7 +316,7 @@ static int sdla_cpuspeed(struct net_device *dev, struct ifreq *ifr)
 	else
 		ifr->ifr_mtu = SDLA_CPU_3M;
  
-	return(0);
+	return 0;
 }
 
 /************************************************
@@ -493,7 +493,7 @@ static int sdla_cmd(struct net_device *dev, int cmd, short dlci, short flags,
 	if (ret != SDLA_RET_OK)
 	   	sdla_errors(dev, cmd, dlci, ret, len, &status);
 
-	return(ret);
+	return ret;
 }
 
 /***********************************************
@@ -516,14 +516,14 @@ static int sdla_activate(struct net_device *slave, struct net_device *master)
 			break;
 
 	if (i == CONFIG_DLCI_MAX)
-		return(-ENODEV);
+		return -ENODEV;
 
 	flp->dlci[i] = abs(flp->dlci[i]);
 
 	if (netif_running(slave) && (flp->config.station == FRAD_STATION_NODE))
 		sdla_cmd(slave, SDLA_ACTIVATE_DLCI, 0, 0, &flp->dlci[i], sizeof(short), NULL, NULL);
 
-	return(0);
+	return 0;
 }
 
 static int sdla_deactivate(struct net_device *slave, struct net_device *master)
@@ -538,14 +538,14 @@ static int sdla_deactivate(struct net_device *slave, struct net_device *master)
 			break;
 
 	if (i == CONFIG_DLCI_MAX)
-		return(-ENODEV);
+		return -ENODEV;
 
 	flp->dlci[i] = -abs(flp->dlci[i]);
 
 	if (netif_running(slave) && (flp->config.station == FRAD_STATION_NODE))
 		sdla_cmd(slave, SDLA_DEACTIVATE_DLCI, 0, 0, &flp->dlci[i], sizeof(short), NULL, NULL);
 
-	return(0);
+	return 0;
 }
 
 static int sdla_assoc(struct net_device *slave, struct net_device *master)
@@ -554,7 +554,7 @@ static int sdla_assoc(struct net_device *slave, struct net_device *master)
 	int               i;
 
 	if (master->type != ARPHRD_DLCI)
-		return(-EINVAL);
+		return -EINVAL;
 
 	flp = netdev_priv(slave);
 
@@ -563,11 +563,11 @@ static int sdla_assoc(struct net_device *slave, struct net_device *master)
 		if (!flp->master[i])
 			break;
 		if (abs(flp->dlci[i]) == *(short *)(master->dev_addr))
-			return(-EADDRINUSE);
+			return -EADDRINUSE;
 	} 
 
 	if (i == CONFIG_DLCI_MAX)
-		return(-EMLINK);  /* #### Alan: Comments on this ?? */
+		return -EMLINK;  /* #### Alan: Comments on this ?? */
 

 	flp->master[i] = master;
@@ -581,7 +581,7 @@ static int sdla_assoc(struct net_device *slave, struct net_device *master)
 			sdla_cmd(slave, SDLA_ADD_DLCI, 0, 0, master->dev_addr, sizeof(short), NULL, NULL);
 	}
 
-	return(0);
+	return 0;
 }
 
 static int sdla_deassoc(struct net_device *slave, struct net_device *master)
@@ -596,7 +596,7 @@ static int sdla_deassoc(struct net_device *slave, struct net_device *master)
 			break;
 
 	if (i == CONFIG_DLCI_MAX)
-		return(-ENODEV);
+		return -ENODEV;
 
 	flp->master[i] = NULL;
 	flp->dlci[i] = 0;
@@ -609,7 +609,7 @@ static int sdla_deassoc(struct net_device *slave, struct net_device *master)
 			sdla_cmd(slave, SDLA_DELETE_DLCI, 0, 0, master->dev_addr, sizeof(short), NULL, NULL);
 	}
 
-	return(0);
+	return 0;
 }
 
 static int sdla_dlci_conf(struct net_device *slave, struct net_device *master, int get)
@@ -626,7 +626,7 @@ static int sdla_dlci_conf(struct net_device *slave, struct net_device *master, i
 			break;
 
 	if (i == CONFIG_DLCI_MAX)
-		return(-ENODEV);
+		return -ENODEV;
 
 	dlp = netdev_priv(master);
 
@@ -641,7 +641,7 @@ static int sdla_dlci_conf(struct net_device *slave, struct net_device *master, i
 			            &dlp->config, sizeof(struct dlci_conf) - 4 * sizeof(short), NULL, NULL);
 	}
 
-	return(ret == SDLA_RET_OK ? 0 : -EIO);
+	return ret == SDLA_RET_OK ? 0 : -EIO;
 }
 
 /**************************
@@ -986,7 +986,7 @@ static int sdla_close(struct net_device *dev)
 
 	netif_stop_queue(dev);
 	
-	return(0);
+	return 0;
 }
 
 struct conf_data {
@@ -1006,10 +1006,10 @@ static int sdla_open(struct net_device *dev)
 	flp = netdev_priv(dev);
 
 	if (!flp->initialized)
-		return(-EPERM);
+		return -EPERM;
 
 	if (!flp->configured)
-		return(-EPERM);
+		return -EPERM;
 
 	/* time to send in the configuration */
 	len = 0;
@@ -1087,7 +1087,7 @@ static int sdla_open(struct net_device *dev)
 
 	netif_start_queue(dev);
 	
-	return(0);
+	return 0;
 }
 
 static int sdla_config(struct net_device *dev, struct frad_conf __user *conf, int get)
@@ -1098,48 +1098,48 @@ static int sdla_config(struct net_device *dev, struct frad_conf __user *conf, in
 	short             size;
 
 	if (dev->type == 0xFFFF)
-		return(-EUNATCH);
+		return -EUNATCH;
 
 	flp = netdev_priv(dev);
 
 	if (!get)
 	{
 		if (netif_running(dev))
-			return(-EBUSY);
+			return -EBUSY;
 
 		if(copy_from_user(&data.config, conf, sizeof(struct frad_conf)))
 			return -EFAULT;
 
 		if (data.config.station & ~FRAD_STATION_NODE)
-			return(-EINVAL);
+			return -EINVAL;
 
 		if (data.config.flags & ~FRAD_VALID_FLAGS)
-			return(-EINVAL);
+			return -EINVAL;
 
 		if ((data.config.kbaud < 0) || 
 			 ((data.config.kbaud > 128) && (flp->type != SDLA_S508)))
-			return(-EINVAL);
+			return -EINVAL;
 
 		if (data.config.clocking & ~(FRAD_CLOCK_INT | SDLA_S508_PORT_RS232))
-			return(-EINVAL);
+			return -EINVAL;
 
 		if ((data.config.mtu < 0) || (data.config.mtu > SDLA_MAX_MTU))
-			return(-EINVAL);
+			return -EINVAL;
 
 		if ((data.config.T391 < 5) || (data.config.T391 > 30))
-			return(-EINVAL);
+			return -EINVAL;
 
 		if ((data.config.T392 < 5) || (data.config.T392 > 30))
-			return(-EINVAL);
+			return -EINVAL;
 
 		if ((data.config.N391 < 1) || (data.config.N391 > 255))
-			return(-EINVAL);
+			return -EINVAL;
 
 		if ((data.config.N392 < 1) || (data.config.N392 > 10))
-			return(-EINVAL);
+			return -EINVAL;
 
 		if ((data.config.N393 < 1) || (data.config.N393 > 10))
-			return(-EINVAL);
+			return -EINVAL;
 
 		memcpy(&flp->config, &data.config, sizeof(struct frad_conf));
 		flp->config.flags |= SDLA_DIRECT_RECV;
@@ -1171,7 +1171,7 @@ static int sdla_config(struct net_device *dev, struct frad_conf __user *conf, in
 		{
 			size = sizeof(data);
 			if (sdla_cmd(dev, SDLA_READ_DLCI_CONFIGURATION, 0, 0, NULL, 0, &data, &size) != SDLA_RET_OK)
-				return(-EIO);
+				return -EIO;
 		}
 		else
 			if (flp->configured)
@@ -1185,7 +1185,7 @@ static int sdla_config(struct net_device *dev, struct frad_conf __user *conf, in
 		return copy_to_user(conf, &data.config, sizeof(struct frad_conf))?-EFAULT:0;
 	}
 
-	return(0);
+	return 0;
 }
 
 static int sdla_xfer(struct net_device *dev, struct sdla_mem __user *info, int read)
@@ -1200,7 +1200,7 @@ static int sdla_xfer(struct net_device *dev, struct sdla_mem __user *info, int r
 	{	
 		temp = kzalloc(mem.len, GFP_KERNEL);
 		if (!temp)
-			return(-ENOMEM);
+			return -ENOMEM;
 		sdla_read(dev, mem.addr, temp, mem.len);
 		if(copy_to_user(mem.data, temp, mem.len))
 		{
@@ -1217,7 +1217,7 @@ static int sdla_xfer(struct net_device *dev, struct sdla_mem __user *info, int r
 		sdla_write(dev, mem.addr, temp, mem.len);
 		kfree(temp);
 	}
-	return(0);
+	return 0;
 }
 
 static int sdla_reconfig(struct net_device *dev)
@@ -1241,7 +1241,7 @@ static int sdla_reconfig(struct net_device *dev)
 	sdla_cmd(dev, SDLA_SET_DLCI_CONFIGURATION, 0, 0, &data, len, NULL, NULL);
 	sdla_cmd(dev, SDLA_ENABLE_COMMUNICATIONS, 0, 0, NULL, 0, NULL, NULL);
 
-	return(0);
+	return 0;
 }
 
 static int sdla_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
@@ -1254,20 +1254,20 @@ static int sdla_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	flp = netdev_priv(dev);
 
 	if (!flp->initialized)
-		return(-EINVAL);
+		return -EINVAL;
 
 	switch (cmd)
 	{
 		case FRAD_GET_CONF:
 		case FRAD_SET_CONF:
-			return(sdla_config(dev, ifr->ifr_data, cmd == FRAD_GET_CONF));
+			return sdla_config(dev, ifr->ifr_data, cmd == FRAD_GET_CONF);
 
 		case SDLA_IDENTIFY:
 			ifr->ifr_flags = flp->type;
 			break;
 
 		case SDLA_CPUSPEED:
-			return(sdla_cpuspeed(dev, ifr)); 
+			return sdla_cpuspeed(dev, ifr); 
 
 /* ==========================================================
 NOTE:  This is rather a useless action right now, as the
@@ -1277,7 +1277,7 @@ NOTE:  This is rather a useless action right now, as the
 ============================================================*/
 		case SDLA_PROTOCOL:
 			if (flp->configured)
-				return(-EALREADY);
+				return -EALREADY;
 
 			switch (ifr->ifr_flags)
 			{
@@ -1285,7 +1285,7 @@ NOTE:  This is rather a useless action right now, as the
 					dev->type = ifr->ifr_flags;
 					break;
 				default:
-					return(-ENOPROTOOPT);
+					return -ENOPROTOOPT;
 			}
 			break;
 
@@ -1297,7 +1297,7 @@ NOTE:  This is rather a useless action right now, as the
 		case SDLA_READMEM:
 			if(!capable(CAP_SYS_RAWIO))
 				return -EPERM;
-			return(sdla_xfer(dev, ifr->ifr_data, cmd == SDLA_READMEM));
+			return sdla_xfer(dev, ifr->ifr_data, cmd == SDLA_READMEM);
 
 		case SDLA_START:
 			sdla_start(dev);
@@ -1308,9 +1308,9 @@ NOTE:  This is rather a useless action right now, as the
 			break;
 
 		default:
-			return(-EOPNOTSUPP);
+			return -EOPNOTSUPP;
 	}
-	return(0);
+	return 0;
 }
 
 static int sdla_change_mtu(struct net_device *dev, int new_mtu)
@@ -1320,10 +1320,10 @@ static int sdla_change_mtu(struct net_device *dev, int new_mtu)
 	flp = netdev_priv(dev);
 
 	if (netif_running(dev))
-		return(-EBUSY);
+		return -EBUSY;
 
 	/* for now, you can't change the MTU! */
-	return(-EOPNOTSUPP);
+	return -EOPNOTSUPP;
 }
 
 static int sdla_set_config(struct net_device *dev, struct ifmap *map)
@@ -1337,18 +1337,18 @@ static int sdla_set_config(struct net_device *dev, struct ifmap *map)
 	flp = netdev_priv(dev);
 
 	if (flp->initialized)
-		return(-EINVAL);
+		return -EINVAL;
 
 	for(i=0; i < ARRAY_SIZE(valid_port); i++)
 		if (valid_port[i] == map->base_addr)
 			break;   
 
 	if (i == ARRAY_SIZE(valid_port))
-		return(-EINVAL);
+		return -EINVAL;
 
 	if (!request_region(map->base_addr, SDLA_IO_EXTENTS, dev->name)){
 		printk(KERN_WARNING "SDLA: io-port 0x%04lx in use\n", dev->base_addr);
-		return(-EINVAL);
+		return -EINVAL;
 	}
 	base = map->base_addr;
 
diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index e47f5a9..d81ad83 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -648,7 +648,7 @@ static int x25_asy_esc(unsigned char *s, unsigned char *d, int len)
 		}
 	}
 	*ptr++ = X25_END;
-	return (ptr - d);
+	return ptr - d;
 }
 
 static void x25_asy_unesc(struct x25_asy *sl, unsigned char s)
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 788a9bc..630fb86 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -135,7 +135,7 @@ static void skb_entry_set_link(union skb_entry *list, unsigned short id)
 static int skb_entry_is_link(const union skb_entry *list)
 {
 	BUILD_BUG_ON(sizeof(list->skb) != sizeof(list->link));
-	return ((unsigned long)list->skb < PAGE_OFFSET);
+	return (unsigned long)list->skb < PAGE_OFFSET;
 }
 
 /*
@@ -203,8 +203,8 @@ static void rx_refill_timeout(unsigned long data)
 
 static int netfront_tx_slot_available(struct netfront_info *np)
 {
-	return ((np->tx.req_prod_pvt - np->tx.rsp_cons) <
-		(TX_MAX_TARGET - MAX_SKB_FRAGS - 2));
+	return (np->tx.req_prod_pvt - np->tx.rsp_cons) <
+		(TX_MAX_TARGET - MAX_SKB_FRAGS - 2);
 }
 
 static void xennet_maybe_wake_tx(struct net_device *dev)



