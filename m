From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/2] net: rename vlan_tx_* helpers since "tx" is misleading there
Date: Tue, 13 Jan 2015 17:13:44 +0100
Message-ID: <1421165624-19882-2-git-send-email-jiri@resnulli.us>
References: <1421165624-19882-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:61230 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752057AbbAMQNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 11:13:50 -0500
Received: by mail-wg0-f48.google.com with SMTP id l2so3878518wgh.7
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 08:13:49 -0800 (PST)
In-Reply-To: <1421165624-19882-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The same macros are used for rx as well. So rename it.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 Documentation/networking/filter.txt                  |  4 ++--
 drivers/infiniband/hw/nes/nes_nic.c                  | 13 +++++++------
 drivers/net/ethernet/3com/typhoon.c                  |  4 ++--
 drivers/net/ethernet/alteon/acenic.c                 |  8 ++++----
 drivers/net/ethernet/amd/amd8111e.c                  |  4 ++--
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c             |  8 ++++----
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c      |  4 ++--
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c      |  4 ++--
 drivers/net/ethernet/atheros/atlx/atl1.c             |  4 ++--
 drivers/net/ethernet/atheros/atlx/atl2.c             |  4 ++--
 drivers/net/ethernet/broadcom/bnx2.c                 |  4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c      |  4 ++--
 drivers/net/ethernet/broadcom/tg3.c                  |  4 ++--
 drivers/net/ethernet/brocade/bna/bnad.c              |  4 ++--
 drivers/net/ethernet/chelsio/cxgb/sge.c              |  4 ++--
 drivers/net/ethernet/chelsio/cxgb3/sge.c             |  6 +++---
 drivers/net/ethernet/chelsio/cxgb4/sge.c             |  4 ++--
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c           |  4 ++--
 drivers/net/ethernet/cisco/enic/enic_main.c          |  4 ++--
 drivers/net/ethernet/emulex/benet/be_main.c          | 12 ++++++------
 drivers/net/ethernet/freescale/gianfar.c             |  4 ++--
 drivers/net/ethernet/ibm/ehea/ehea_main.c            |  4 ++--
 drivers/net/ethernet/intel/e1000/e1000_main.c        |  5 +++--
 drivers/net/ethernet/intel/e1000e/netdev.c           |  9 +++++----
 drivers/net/ethernet/intel/fm10k/fm10k_main.c        |  4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c      |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c          |  4 ++--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c        |  4 ++--
 drivers/net/ethernet/intel/igb/igb_main.c            |  4 ++--
 drivers/net/ethernet/intel/igbvf/netdev.c            |  5 +++--
 drivers/net/ethernet/intel/ixgb/ixgb_main.c          |  4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c        |  4 ++--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c    |  4 ++--
 drivers/net/ethernet/jme.c                           |  4 ++--
 drivers/net/ethernet/marvell/sky2.c                  |  6 +++---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c           | 12 ++++++------
 drivers/net/ethernet/natsemi/ns83820.c               |  4 ++--
 drivers/net/ethernet/neterion/s2io.c                 |  4 ++--
 drivers/net/ethernet/neterion/vxge/vxge-main.c       |  4 ++--
 drivers/net/ethernet/nvidia/forcedeth.c              |  4 ++--
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c |  4 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c       |  8 ++++----
 drivers/net/ethernet/qlogic/qlge/qlge_main.c         |  6 +++---
 drivers/net/ethernet/realtek/8139cp.c                |  4 ++--
 drivers/net/ethernet/realtek/r8169.c                 |  4 ++--
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c      |  2 +-
 drivers/net/ethernet/tehuti/tehuti.c                 |  4 ++--
 drivers/net/ethernet/via/via-rhine.c                 |  6 +++---
 drivers/net/ethernet/via/via-velocity.c              |  4 ++--
 drivers/net/macvtap.c                                |  6 +++---
 drivers/net/tun.c                                    |  4 ++--
 drivers/net/usb/r8152.c                              |  4 ++--
 drivers/net/vmxnet3/vmxnet3_drv.c                    |  4 ++--
 drivers/net/vxlan.c                                  |  4 ++--
 drivers/s390/net/qeth_l3_main.c                      |  8 ++++----
 drivers/vhost/net.c                                  |  2 +-
 include/linux/if_vlan.h                              | 16 ++++++++--------
 include/net/pkt_sched.h                              |  2 +-
 include/trace/events/net.h                           |  8 ++++----
 net/8021q/vlan_core.c                                |  2 +-
 net/bridge/br_netfilter.c                            | 12 ++++++------
 net/bridge/br_private.h                              |  4 ++--
 net/bridge/br_vlan.c                                 |  4 ++--
 net/bridge/netfilter/ebt_vlan.c                      |  4 ++--
 net/bridge/netfilter/ebtables.c                      |  2 +-
 net/core/dev.c                                       | 10 +++++-----
 net/core/netpoll.c                                   |  2 +-
 net/core/skbuff.c                                    |  8 ++++----
 net/ipv4/geneve.c                                    |  2 +-
 net/openvswitch/actions.c                            |  4 ++--
 net/openvswitch/datapath.c                           |  2 +-
 net/openvswitch/flow.c                               |  4 ++--
 net/openvswitch/vport-gre.c                          |  2 +-
 net/openvswitch/vport.c                              |  3 ++-
 net/packet/af_packet.c                               | 12 ++++++------
 net/sched/em_meta.c                                  |  2 +-
 net/wireless/util.c                                  |  4 ++--
 77 files changed, 195 insertions(+), 190 deletions(-)

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index 58d08f8..9930ecfb 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -279,8 +279,8 @@ Possible BPF extensions are shown in the following table:
   hatype                                skb->dev->type
   rxhash                                skb->hash
   cpu                                   raw_smp_processor_id()
-  vlan_tci                              vlan_tx_tag_get(skb)
-  vlan_pr                               vlan_tx_tag_present(skb)
+  vlan_tci                              skb_vlan_tag_get(skb)
+  vlan_pr                               skb_vlan_tag_present(skb)
   rand                                  prandom_u32()
 
 These extensions can also be prefixed with '#'.
diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index 49eb511..70acda9 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -373,11 +373,11 @@ static int nes_nic_send(struct sk_buff *skb, struct net_device *netdev)
 	wqe_fragment_length = (__le16 *)&nic_sqe->wqe_words[NES_NIC_SQ_WQE_LENGTH_0_TAG_IDX];
 
 	/* setup the VLAN tag if present */
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		nes_debug(NES_DBG_NIC_TX, "%s: VLAN packet to send... VLAN = %08X\n",
-				netdev->name, vlan_tx_tag_get(skb));
+				netdev->name, skb_vlan_tag_get(skb));
 		wqe_misc = NES_NIC_SQ_WQE_TAGVALUE_ENABLE;
-		wqe_fragment_length[0] = (__force __le16) vlan_tx_tag_get(skb);
+		wqe_fragment_length[0] = (__force __le16) skb_vlan_tag_get(skb);
 	} else
 		wqe_misc = 0;
 
@@ -576,11 +576,12 @@ tso_sq_no_longer_full:
 				wqe_fragment_length =
 						(__le16 *)&nic_sqe->wqe_words[NES_NIC_SQ_WQE_LENGTH_0_TAG_IDX];
 				/* setup the VLAN tag if present */
-				if (vlan_tx_tag_present(skb)) {
+				if (skb_vlan_tag_present(skb)) {
 					nes_debug(NES_DBG_NIC_TX, "%s: VLAN packet to send... VLAN = %08X\n",
-							netdev->name, vlan_tx_tag_get(skb) );
+							netdev->name,
+						  skb_vlan_tag_get(skb));
 					wqe_misc = NES_NIC_SQ_WQE_TAGVALUE_ENABLE;
-					wqe_fragment_length[0] = (__force __le16) vlan_tx_tag_get(skb);
+					wqe_fragment_length[0] = (__force __le16) skb_vlan_tag_get(skb);
 				} else
 					wqe_misc = 0;
 
diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index dede43f..8f8418d 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -769,11 +769,11 @@ typhoon_start_tx(struct sk_buff *skb, struct net_device *dev)
 		first_txd->processFlags |= TYPHOON_TX_PF_IP_CHKSUM;
 	}
 
-	if(vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		first_txd->processFlags |=
 		    TYPHOON_TX_PF_INSERT_VLAN | TYPHOON_TX_PF_VLAN_PRIORITY;
 		first_txd->processFlags |=
-		    cpu_to_le32(htons(vlan_tx_tag_get(skb)) <<
+		    cpu_to_le32(htons(skb_vlan_tag_get(skb)) <<
 				TYPHOON_TX_PF_VLAN_TAG_SHIFT);
 	}
 
diff --git a/drivers/net/ethernet/alteon/acenic.c b/drivers/net/ethernet/alteon/acenic.c
index b680748..b90a26b 100644
--- a/drivers/net/ethernet/alteon/acenic.c
+++ b/drivers/net/ethernet/alteon/acenic.c
@@ -2429,9 +2429,9 @@ restart:
 		flagsize = (skb->len << 16) | (BD_FLG_END);
 		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			flagsize |= BD_FLG_TCP_UDP_SUM;
-		if (vlan_tx_tag_present(skb)) {
+		if (skb_vlan_tag_present(skb)) {
 			flagsize |= BD_FLG_VLAN_TAG;
-			vlan_tag = vlan_tx_tag_get(skb);
+			vlan_tag = skb_vlan_tag_get(skb);
 		}
 		desc = ap->tx_ring + idx;
 		idx = (idx + 1) % ACE_TX_RING_ENTRIES(ap);
@@ -2450,9 +2450,9 @@ restart:
 		flagsize = (skb_headlen(skb) << 16);
 		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			flagsize |= BD_FLG_TCP_UDP_SUM;
-		if (vlan_tx_tag_present(skb)) {
+		if (skb_vlan_tag_present(skb)) {
 			flagsize |= BD_FLG_VLAN_TAG;
-			vlan_tag = vlan_tx_tag_get(skb);
+			vlan_tag = skb_vlan_tag_get(skb);
 		}
 
 		ace_load_tx_bd(ap, ap->tx_ring + idx, mapping, flagsize, vlan_tag);
diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index 841e655..4c2ae22 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -1299,11 +1299,11 @@ static netdev_tx_t amd8111e_start_xmit(struct sk_buff *skb,
 	lp->tx_ring[tx_index].tx_flags = 0;
 
 #if AMD8111E_VLAN_TAG_USED
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		lp->tx_ring[tx_index].tag_ctrl_cmd |=
 				cpu_to_le16(TCC_VLAN_INSERT);
 		lp->tx_ring[tx_index].tag_ctrl_info =
-				cpu_to_le16(vlan_tx_tag_get(skb));
+				cpu_to_le16(skb_vlan_tag_get(skb));
 
 	}
 #endif
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 7bb5f07..2ba1dd2 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1165,8 +1165,8 @@ static void xgbe_prep_tx_tstamp(struct xgbe_prv_data *pdata,
 
 static void xgbe_prep_vlan(struct sk_buff *skb, struct xgbe_packet_data *packet)
 {
-	if (vlan_tx_tag_present(skb))
-		packet->vlan_ctag = vlan_tx_tag_get(skb);
+	if (skb_vlan_tag_present(skb))
+		packet->vlan_ctag = skb_vlan_tag_get(skb);
 }
 
 static int xgbe_prep_tso(struct sk_buff *skb, struct xgbe_packet_data *packet)
@@ -1247,9 +1247,9 @@ static void xgbe_packet_info(struct xgbe_prv_data *pdata,
 		XGMAC_SET_BITS(packet->attributes, TX_PACKET_ATTRIBUTES,
 			       CSUM_ENABLE, 1);
 
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		/* VLAN requires an extra descriptor if tag is different */
-		if (vlan_tx_tag_get(skb) != ring->tx.cur_vlan_ctag)
+		if (skb_vlan_tag_get(skb) != ring->tx.cur_vlan_ctag)
 			/* We can share with the TSO context descriptor */
 			if (!context_desc) {
 				context_desc = 1;
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index c9946c6..587f63e 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -2235,8 +2235,8 @@ static netdev_tx_t atl1c_xmit_frame(struct sk_buff *skb,
 		return NETDEV_TX_OK;
 	}
 
-	if (unlikely(vlan_tx_tag_present(skb))) {
-		u16 vlan = vlan_tx_tag_get(skb);
+	if (unlikely(skb_vlan_tag_present(skb))) {
+		u16 vlan = skb_vlan_tag_get(skb);
 		__le16 tag;
 
 		vlan = cpu_to_le16(vlan);
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index c88abf5..59a03a1 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -1892,8 +1892,8 @@ static netdev_tx_t atl1e_xmit_frame(struct sk_buff *skb,
 
 	tpd = atl1e_get_tpd(adapter);
 
-	if (vlan_tx_tag_present(skb)) {
-		u16 vlan_tag = vlan_tx_tag_get(skb);
+	if (skb_vlan_tag_present(skb)) {
+		u16 vlan_tag = skb_vlan_tag_get(skb);
 		u16 atl1e_vlan_tag;
 
 		tpd->word3 |= 1 << TPD_INS_VL_TAG_SHIFT;
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 2c8f398..eca1d11 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -2415,8 +2415,8 @@ static netdev_tx_t atl1_xmit_frame(struct sk_buff *skb,
 		(u16) atomic_read(&tpd_ring->next_to_use));
 	memset(ptpd, 0, sizeof(struct tx_packet_desc));
 
-	if (vlan_tx_tag_present(skb)) {
-		vlan_tag = vlan_tx_tag_get(skb);
+	if (skb_vlan_tag_present(skb)) {
+		vlan_tag = skb_vlan_tag_get(skb);
 		vlan_tag = (vlan_tag << 4) | (vlan_tag >> 13) |
 			((vlan_tag >> 9) & 0x8);
 		ptpd->word3 |= 1 << TPD_INS_VL_TAG_SHIFT;
diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
index 482a7ca..46a5353 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -887,8 +887,8 @@ static netdev_tx_t atl2_xmit_frame(struct sk_buff *skb,
 		offset = ((u32)(skb->len-copy_len + 3) & ~3);
 	}
 #ifdef NETIF_F_HW_VLAN_CTAG_TX
-	if (vlan_tx_tag_present(skb)) {
-		u16 vlan_tag = vlan_tx_tag_get(skb);
+	if (skb_vlan_tag_present(skb)) {
+		u16 vlan_tag = skb_vlan_tag_get(skb);
 		vlan_tag = (vlan_tag << 4) |
 			(vlan_tag >> 13) |
 			((vlan_tag >> 9) & 0x8);
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 823d01c..02bf0b8 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -6597,9 +6597,9 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		vlan_tag_flags |= TX_BD_FLAGS_TCP_UDP_CKSUM;
 	}
 
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		vlan_tag_flags |=
-			(TX_BD_FLAGS_VLAN_TAG | (vlan_tx_tag_get(skb) << 16));
+			(TX_BD_FLAGS_VLAN_TAG | (skb_vlan_tag_get(skb) << 16));
 	}
 
 	if ((mss = skb_shinfo(skb)->gso_size)) {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 1d1147c..b51a18a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3865,9 +3865,9 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	   "sending pkt %u @%p  next_idx %u  bd %u @%p\n",
 	   pkt_prod, tx_buf, txdata->tx_pkt_prod, bd_prod, tx_start_bd);
 
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		tx_start_bd->vlan_or_ethertype =
-		    cpu_to_le16(vlan_tx_tag_get(skb));
+		    cpu_to_le16(skb_vlan_tag_get(skb));
 		tx_start_bd->bd_flags.as_bitfield |=
 		    (X_ETH_OUTBAND_VLAN << ETH_TX_BD_FLAGS_VLAN_MODE_SHIFT);
 	} else {
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 356bd5b..4cf43bf 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -8002,9 +8002,9 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	    !mss && skb->len > VLAN_ETH_FRAME_LEN)
 		base_flags |= TXD_FLAG_JMB_PKT;
 
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		base_flags |= TXD_FLAG_VLAN;
-		vlan = vlan_tx_tag_get(skb);
+		vlan = skb_vlan_tag_get(skb);
 	}
 
 	if ((unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)) &&
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 3237218..7714d77 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -2824,8 +2824,8 @@ bnad_txq_wi_prepare(struct bnad *bnad, struct bna_tcb *tcb,
 	u32 gso_size;
 	u16 vlan_tag = 0;
 
-	if (vlan_tx_tag_present(skb)) {
-		vlan_tag = (u16)vlan_tx_tag_get(skb);
+	if (skb_vlan_tag_present(skb)) {
+		vlan_tag = (u16)skb_vlan_tag_get(skb);
 		flags |= (BNA_TXQ_WI_CF_INS_PRIO | BNA_TXQ_WI_CF_INS_VLAN);
 	}
 	if (test_bit(BNAD_RF_CEE_RUNNING, &bnad->run_flags)) {
diff --git a/drivers/net/ethernet/chelsio/cxgb/sge.c b/drivers/net/ethernet/chelsio/cxgb/sge.c
index babe2a9..526ea74 100644
--- a/drivers/net/ethernet/chelsio/cxgb/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb/sge.c
@@ -1860,9 +1860,9 @@ netdev_tx_t t1_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 	cpl->iff = dev->if_port;
 
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		cpl->vlan_valid = 1;
-		cpl->vlan = htons(vlan_tx_tag_get(skb));
+		cpl->vlan = htons(skb_vlan_tag_get(skb));
 		st->vlan_insert++;
 	} else
 		cpl->vlan_valid = 0;
diff --git a/drivers/net/ethernet/chelsio/cxgb3/sge.c b/drivers/net/ethernet/chelsio/cxgb3/sge.c
index 3dfcf60..d6aa602 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/sge.c
@@ -1148,8 +1148,8 @@ static void write_tx_pkt_wr(struct adapter *adap, struct sk_buff *skb,
 	cpl->len = htonl(skb->len);
 	cntrl = V_TXPKT_INTF(pi->port_id);
 
-	if (vlan_tx_tag_present(skb))
-		cntrl |= F_TXPKT_VLAN_VLD | V_TXPKT_VLAN(vlan_tx_tag_get(skb));
+	if (skb_vlan_tag_present(skb))
+		cntrl |= F_TXPKT_VLAN_VLD | V_TXPKT_VLAN(skb_vlan_tag_get(skb));
 
 	tso_info = V_LSO_MSS(skb_shinfo(skb)->gso_size);
 	if (tso_info) {
@@ -1282,7 +1282,7 @@ netdev_tx_t t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 		qs->port_stats[SGE_PSTAT_TX_CSUM]++;
 	if (skb_shinfo(skb)->gso_size)
 		qs->port_stats[SGE_PSTAT_TSO]++;
-	if (vlan_tx_tag_present(skb))
+	if (skb_vlan_tag_present(skb))
 		qs->port_stats[SGE_PSTAT_VLANINS]++;
 
 	/*
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index a79fa6a..f6f1bf0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -1154,9 +1154,9 @@ out_free:	dev_kfree_skb_any(skb);
 			cntrl = TXPKT_L4CSUM_DIS | TXPKT_IPCSUM_DIS;
 	}
 
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		q->vlan_ins++;
-		cntrl |= TXPKT_VLAN_VLD | TXPKT_VLAN(vlan_tx_tag_get(skb));
+		cntrl |= TXPKT_VLAN_VLD | TXPKT_VLAN(skb_vlan_tag_get(skb));
 	}
 
 	cpl->ctrl0 = htonl(TXPKT_OPCODE(CPL_TX_PKT_XT) |
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 4424277..0545f0d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -1326,9 +1326,9 @@ int t4vf_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * If there's a VLAN tag present, add that to the list of things to
 	 * do in this Work Request.
 	 */
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		txq->vlan_ins++;
-		cntrl |= TXPKT_VLAN_VLD | TXPKT_VLAN(vlan_tx_tag_get(skb));
+		cntrl |= TXPKT_VLAN_VLD | TXPKT_VLAN(skb_vlan_tag_get(skb));
 	}
 
 	/*
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 9a952df..0535f6f 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -520,10 +520,10 @@ static inline void enic_queue_wq_skb(struct enic *enic,
 	int loopback = 0;
 	int err;
 
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		/* VLAN tag from trunking driver */
 		vlan_tag_insert = 1;
-		vlan_tag = vlan_tx_tag_get(skb);
+		vlan_tag = skb_vlan_tag_get(skb);
 	} else if (enic->loop_enable) {
 		vlan_tag = enic->loop_tag;
 		loopback = 1;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 37a26b0..ed46610 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -694,7 +694,7 @@ static inline u16 be_get_tx_vlan_tag(struct be_adapter *adapter,
 	u8 vlan_prio;
 	u16 vlan_tag;
 
-	vlan_tag = vlan_tx_tag_get(skb);
+	vlan_tag = skb_vlan_tag_get(skb);
 	vlan_prio = (vlan_tag & VLAN_PRIO_MASK) >> VLAN_PRIO_SHIFT;
 	/* If vlan priority provided by OS is NOT in available bmap */
 	if (!(adapter->vlan_prio_bmap & (1 << vlan_prio)))
@@ -745,7 +745,7 @@ static void wrb_fill_hdr(struct be_adapter *adapter, struct be_eth_hdr_wrb *hdr,
 			SET_TX_WRB_HDR_BITS(udpcs, hdr, 1);
 	}
 
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		SET_TX_WRB_HDR_BITS(vlan, hdr, 1);
 		vlan_tag = be_get_tx_vlan_tag(adapter, skb);
 		SET_TX_WRB_HDR_BITS(vlan_tag, hdr, vlan_tag);
@@ -864,7 +864,7 @@ static struct sk_buff *be_insert_vlan_in_pkt(struct be_adapter *adapter,
 	if (unlikely(!skb))
 		return skb;
 
-	if (vlan_tx_tag_present(skb))
+	if (skb_vlan_tag_present(skb))
 		vlan_tag = be_get_tx_vlan_tag(adapter, skb);
 
 	if (qnq_async_evt_rcvd(adapter) && adapter->pvid) {
@@ -923,7 +923,7 @@ static bool be_ipv6_exthdr_check(struct sk_buff *skb)
 
 static int be_vlan_tag_tx_chk(struct be_adapter *adapter, struct sk_buff *skb)
 {
-	return vlan_tx_tag_present(skb) || adapter->pvid || adapter->qnq_vid;
+	return skb_vlan_tag_present(skb) || adapter->pvid || adapter->qnq_vid;
 }
 
 static int be_ipv6_tx_stall_chk(struct be_adapter *adapter, struct sk_buff *skb)
@@ -946,7 +946,7 @@ static struct sk_buff *be_lancer_xmit_workarounds(struct be_adapter *adapter,
 	eth_hdr_len = ntohs(skb->protocol) == ETH_P_8021Q ?
 						VLAN_ETH_HLEN : ETH_HLEN;
 	if (skb->len <= 60 &&
-	    (lancer_chip(adapter) || vlan_tx_tag_present(skb)) &&
+	    (lancer_chip(adapter) || skb_vlan_tag_present(skb)) &&
 	    is_ipv4_pkt(skb)) {
 		ip = (struct iphdr *)ip_hdr(skb);
 		pskb_trim(skb, eth_hdr_len + ntohs(ip->tot_len));
@@ -964,7 +964,7 @@ static struct sk_buff *be_lancer_xmit_workarounds(struct be_adapter *adapter,
 	 * Manually insert VLAN in pkt.
 	 */
 	if (skb->ip_summed != CHECKSUM_PARTIAL &&
-	    vlan_tx_tag_present(skb)) {
+	    skb_vlan_tag_present(skb)) {
 		skb = be_insert_vlan_in_pkt(adapter, skb, skip_hw_vlan);
 		if (unlikely(!skb))
 			goto err;
diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index e54b1e3..93ff846 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2170,7 +2170,7 @@ static inline void gfar_tx_checksum(struct sk_buff *skb, struct txfcb *fcb,
 void inline gfar_tx_vlan(struct sk_buff *skb, struct txfcb *fcb)
 {
 	fcb->flags |= TXFCB_VLN;
-	fcb->vlctl = vlan_tx_tag_get(skb);
+	fcb->vlctl = skb_vlan_tag_get(skb);
 }
 
 static inline struct txbd8 *skip_txbd(struct txbd8 *bdp, int stride,
@@ -2230,7 +2230,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	regs = tx_queue->grp->regs;
 
 	do_csum = (CHECKSUM_PARTIAL == skb->ip_summed);
-	do_vlan = vlan_tx_tag_present(skb);
+	do_vlan = skb_vlan_tag_present(skb);
 	do_tstamp = (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
 		    priv->hwts_tx_en;
 
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 566b17d..e8a1adb 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -2064,9 +2064,9 @@ static int ehea_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	memset(swqe, 0, SWQE_HEADER_SIZE);
 	atomic_dec(&pr->swqe_avail);
 
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		swqe->tx_control |= EHEA_SWQE_VLAN_INSERT;
-		swqe->vlan_tag = vlan_tx_tag_get(skb);
+		swqe->vlan_tag = skb_vlan_tag_get(skb);
 	}
 
 	pr->tx_packets++;
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 83140cb..9242982 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -3226,9 +3226,10 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 		return NETDEV_TX_BUSY;
 	}
 
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		tx_flags |= E1000_TX_FLAGS_VLAN;
-		tx_flags |= (vlan_tx_tag_get(skb) << E1000_TX_FLAGS_VLAN_SHIFT);
+		tx_flags |= (skb_vlan_tag_get(skb) <<
+			     E1000_TX_FLAGS_VLAN_SHIFT);
 	}
 
 	first = tx_ring->next_to_use;
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 332a298..38cb586 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5463,8 +5463,8 @@ static int e1000_transfer_dhcp_info(struct e1000_adapter *adapter,
 	struct e1000_hw *hw = &adapter->hw;
 	u16 length, offset;
 
-	if (vlan_tx_tag_present(skb) &&
-	    !((vlan_tx_tag_get(skb) == adapter->hw.mng_cookie.vlan_id) &&
+	if (skb_vlan_tag_present(skb) &&
+	    !((skb_vlan_tag_get(skb) == adapter->hw.mng_cookie.vlan_id) &&
 	      (adapter->hw.mng_cookie.status &
 	       E1000_MNG_DHCP_COOKIE_STATUS_VLAN)))
 		return 0;
@@ -5603,9 +5603,10 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	if (e1000_maybe_stop_tx(tx_ring, count + 2))
 		return NETDEV_TX_BUSY;
 
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		tx_flags |= E1000_TX_FLAGS_VLAN;
-		tx_flags |= (vlan_tx_tag_get(skb) << E1000_TX_FLAGS_VLAN_SHIFT);
+		tx_flags |= (skb_vlan_tag_get(skb) <<
+			     E1000_TX_FLAGS_VLAN_SHIFT);
 	}
 
 	first = tx_ring->next_to_use;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index eb088b1..caa43f7 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -965,8 +965,8 @@ static void fm10k_tx_map(struct fm10k_ring *tx_ring,
 	tx_desc = FM10K_TX_DESC(tx_ring, i);
 
 	/* add HW VLAN tag */
-	if (vlan_tx_tag_present(skb))
-		tx_desc->vlan = cpu_to_le16(vlan_tx_tag_get(skb));
+	if (skb_vlan_tag_present(skb))
+		tx_desc->vlan = cpu_to_le16(skb_vlan_tag_get(skb));
 	else
 		tx_desc->vlan = 0;
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 8811364..945b35d 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -609,7 +609,7 @@ static netdev_tx_t fm10k_xmit_frame(struct sk_buff *skb, struct net_device *dev)
 	int err;
 
 	if ((skb->protocol ==  htons(ETH_P_8021Q)) &&
-	    !vlan_tx_tag_present(skb)) {
+	    !skb_vlan_tag_present(skb)) {
 		/* FM10K only supports hardware tagging, any tags in frame
 		 * are considered 2nd level or "outer" tags
 		 */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 04b4414..9f536dd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1772,8 +1772,8 @@ static int i40e_tx_prepare_vlan_flags(struct sk_buff *skb,
 	u32  tx_flags = 0;
 
 	/* if we have a HW VLAN tag being added, default to the HW one */
-	if (vlan_tx_tag_present(skb)) {
-		tx_flags |= vlan_tx_tag_get(skb) << I40E_TX_FLAGS_VLAN_SHIFT;
+	if (skb_vlan_tag_present(skb)) {
+		tx_flags |= skb_vlan_tag_get(skb) << I40E_TX_FLAGS_VLAN_SHIFT;
 		tx_flags |= I40E_TX_FLAGS_HW_VLAN;
 	/* else if it is a SW VLAN, check the next protocol and store the tag */
 	} else if (protocol == htons(ETH_P_8021Q)) {
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 04c7c15..82c3798 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1122,8 +1122,8 @@ static int i40e_tx_prepare_vlan_flags(struct sk_buff *skb,
 	u32  tx_flags = 0;
 
 	/* if we have a HW VLAN tag being added, default to the HW one */
-	if (vlan_tx_tag_present(skb)) {
-		tx_flags |= vlan_tx_tag_get(skb) << I40E_TX_FLAGS_VLAN_SHIFT;
+	if (skb_vlan_tag_present(skb)) {
+		tx_flags |= skb_vlan_tag_get(skb) << I40E_TX_FLAGS_VLAN_SHIFT;
 		tx_flags |= I40E_TX_FLAGS_HW_VLAN;
 	/* else if it is a SW VLAN, check the next protocol and store the tag */
 	} else if (protocol == htons(ETH_P_8021Q)) {
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index ff59897..6c25ec3 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5035,9 +5035,9 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
 
 	skb_tx_timestamp(skb);
 
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		tx_flags |= IGB_TX_FLAGS_VLAN;
-		tx_flags |= (vlan_tx_tag_get(skb) << IGB_TX_FLAGS_VLAN_SHIFT);
+		tx_flags |= (skb_vlan_tag_get(skb) << IGB_TX_FLAGS_VLAN_SHIFT);
 	}
 
 	/* record initial flags and protocol */
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 63c807c..ad2b489 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -2234,9 +2234,10 @@ static netdev_tx_t igbvf_xmit_frame_ring_adv(struct sk_buff *skb,
 		return NETDEV_TX_BUSY;
 	}
 
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		tx_flags |= IGBVF_TX_FLAGS_VLAN;
-		tx_flags |= (vlan_tx_tag_get(skb) << IGBVF_TX_FLAGS_VLAN_SHIFT);
+		tx_flags |= (skb_vlan_tag_get(skb) <<
+			     IGBVF_TX_FLAGS_VLAN_SHIFT);
 	}
 
 	if (skb->protocol == htons(ETH_P_IP))
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index aa87605..11a1bdb 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -1532,9 +1532,9 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
                      DESC_NEEDED)))
 		return NETDEV_TX_BUSY;
 
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		tx_flags |= IXGB_TX_FLAGS_VLAN;
-		vlan_id = vlan_tx_tag_get(skb);
+		vlan_id = skb_vlan_tag_get(skb);
 	}
 
 	first = adapter->tx_ring.next_to_use;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 2ed2c7d..7bb421b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7217,8 +7217,8 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 	first->gso_segs = 1;
 
 	/* if we have a HW VLAN tag being added default to the HW one */
-	if (vlan_tx_tag_present(skb)) {
-		tx_flags |= vlan_tx_tag_get(skb) << IXGBE_TX_FLAGS_VLAN_SHIFT;
+	if (skb_vlan_tag_present(skb)) {
+		tx_flags |= skb_vlan_tag_get(skb) << IXGBE_TX_FLAGS_VLAN_SHIFT;
 		tx_flags |= IXGBE_TX_FLAGS_HW_VLAN;
 	/* else if it is a SW VLAN check the next protocol and store the tag */
 	} else if (protocol == htons(ETH_P_8021Q)) {
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 62a0d8e..c9b49bf 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3452,8 +3452,8 @@ static int ixgbevf_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	first->bytecount = skb->len;
 	first->gso_segs = 1;
 
-	if (vlan_tx_tag_present(skb)) {
-		tx_flags |= vlan_tx_tag_get(skb);
+	if (skb_vlan_tag_present(skb)) {
+		tx_flags |= skb_vlan_tag_get(skb);
 		tx_flags <<= IXGBE_TX_FLAGS_VLAN_SHIFT;
 		tx_flags |= IXGBE_TX_FLAGS_VLAN;
 	}
diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 44ce7d8..6e9a792 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -2154,9 +2154,9 @@ jme_tx_csum(struct jme_adapter *jme, struct sk_buff *skb, u8 *flags)
 static inline void
 jme_tx_vlan(struct sk_buff *skb, __le16 *vlan, u8 *flags)
 {
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		*flags |= TXFLAG_TAGON;
-		*vlan = cpu_to_le16(vlan_tx_tag_get(skb));
+		*vlan = cpu_to_le16(skb_vlan_tag_get(skb));
 	}
 }
 
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 867a6a3..d9f4498 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -1895,14 +1895,14 @@ static netdev_tx_t sky2_xmit_frame(struct sk_buff *skb,
 	ctrl = 0;
 
 	/* Add VLAN tag, can piggyback on LRGLEN or ADDR64 */
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		if (!le) {
 			le = get_tx_le(sky2, &slot);
 			le->addr = 0;
 			le->opcode = OP_VLAN|HW_OWNER;
 		} else
 			le->opcode |= OP_VLAN;
-		le->length = cpu_to_be16(vlan_tx_tag_get(skb));
+		le->length = cpu_to_be16(skb_vlan_tag_get(skb));
 		ctrl |= INS_VLAN;
 	}
 
@@ -2594,7 +2594,7 @@ static struct sk_buff *sky2_receive(struct net_device *dev,
 	sky2->rx_next = (sky2->rx_next + 1) % sky2->rx_pending;
 	prefetch(sky2->rx_ring + sky2->rx_next);
 
-	if (vlan_tx_tag_present(re->skb))
+	if (skb_vlan_tag_present(re->skb))
 		count -= VLAN_HLEN;	/* Account for vlan tag */
 
 	/* This chip has hardware problems that generates bogus status.
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index e3357bf..359bb12 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -682,8 +682,8 @@ u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb,
 	if (dev->num_tc)
 		return skb_tx_hash(dev, skb);
 
-	if (vlan_tx_tag_present(skb))
-		up = vlan_tx_tag_get(skb) >> VLAN_PRIO_SHIFT;
+	if (skb_vlan_tag_present(skb))
+		up = skb_vlan_tag_get(skb) >> VLAN_PRIO_SHIFT;
 
 	return fallback(dev, skb) % rings_p_up + up * rings_p_up;
 }
@@ -742,8 +742,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto tx_drop;
 	}
 
-	if (vlan_tx_tag_present(skb))
-		vlan_tag = vlan_tx_tag_get(skb);
+	if (skb_vlan_tag_present(skb))
+		vlan_tag = skb_vlan_tag_get(skb);
 
 
 	netdev_txq_bql_enqueue_prefetchw(ring->tx_queue);
@@ -930,7 +930,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	real_size = (real_size / 16) & 0x3f;
 
 	if (ring->bf_enabled && desc_size <= MAX_BF && !bounce &&
-	    !vlan_tx_tag_present(skb) && send_doorbell) {
+	    !skb_vlan_tag_present(skb) && send_doorbell) {
 		tx_desc->ctrl.bf_qpn = ring->doorbell_qpn |
 				       cpu_to_be32(real_size);
 
@@ -952,7 +952,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	} else {
 		tx_desc->ctrl.vlan_tag = cpu_to_be16(vlan_tag);
 		tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_VLAN *
-			!!vlan_tx_tag_present(skb);
+			!!skb_vlan_tag_present(skb);
 		tx_desc->ctrl.fence_size = real_size;
 
 		/* Ensure new descriptor hits memory
diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
index 2552e55..eb807b0 100644
--- a/drivers/net/ethernet/natsemi/ns83820.c
+++ b/drivers/net/ethernet/natsemi/ns83820.c
@@ -1122,12 +1122,12 @@ again:
 	}
 
 #ifdef NS83820_VLAN_ACCEL_SUPPORT
-	if(vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		/* fetch the vlan tag info out of the
 		 * ancillary data if the vlan code
 		 * is using hw vlan acceleration
 		 */
-		short tag = vlan_tx_tag_get(skb);
+		short tag = skb_vlan_tag_get(skb);
 		extsts |= (EXTSTS_VPKT | htons(tag));
 	}
 #endif
diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index f5e4b82..0529cad 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -4045,8 +4045,8 @@ static netdev_tx_t s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	queue = 0;
-	if (vlan_tx_tag_present(skb))
-		vlan_tag = vlan_tx_tag_get(skb);
+	if (skb_vlan_tag_present(skb))
+		vlan_tag = skb_vlan_tag_get(skb);
 	if (sp->config.tx_steering_type == TX_DEFAULT_STEERING) {
 		if (skb->protocol == htons(ETH_P_IP)) {
 			struct iphdr *ip;
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index cc0485e..50d5604 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -890,8 +890,8 @@ vxge_xmit(struct sk_buff *skb, struct net_device *dev)
 		dev->name, __func__, __LINE__,
 		fifo_hw, dtr, dtr_priv);
 
-	if (vlan_tx_tag_present(skb)) {
-		u16 vlan_tag = vlan_tx_tag_get(skb);
+	if (skb_vlan_tag_present(skb)) {
+		u16 vlan_tag = skb_vlan_tag_get(skb);
 		vxge_hw_fifo_txdl_vlan_set(dtr, vlan_tag);
 	}
 
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index f39cae6..a41bb5e 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -2462,9 +2462,9 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 			 NV_TX2_CHECKSUM_L3 | NV_TX2_CHECKSUM_L4 : 0;
 
 	/* vlan tag */
-	if (vlan_tx_tag_present(skb))
+	if (skb_vlan_tag_present(skb))
 		start_tx->txvlan = cpu_to_le32(NV_TX3_VLAN_TAG_PRESENT |
-					vlan_tx_tag_get(skb));
+					skb_vlan_tag_get(skb));
 	else
 		start_tx->txvlan = 0;
 
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 6130375..a47fe67 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -1893,9 +1893,9 @@ netxen_tso_check(struct net_device *netdev,
 		protocol = vh->h_vlan_encapsulated_proto;
 		flags = FLAGS_VLAN_TAGGED;
 
-	} else if (vlan_tx_tag_present(skb)) {
+	} else if (skb_vlan_tag_present(skb)) {
 		flags = FLAGS_VLAN_OOB;
-		vid = vlan_tx_tag_get(skb);
+		vid = skb_vlan_tag_get(skb);
 		netxen_set_tx_vlan_tci(first_desc, vid);
 		vlan_oob = 1;
 	}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index d166e53..4d2496f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -321,8 +321,8 @@ static void qlcnic_send_filter(struct qlcnic_adapter *adapter,
 		if (protocol == ETH_P_8021Q) {
 			vh = (struct vlan_ethhdr *)skb->data;
 			vlan_id = ntohs(vh->h_vlan_TCI);
-		} else if (vlan_tx_tag_present(skb)) {
-			vlan_id = vlan_tx_tag_get(skb);
+		} else if (skb_vlan_tag_present(skb)) {
+			vlan_id = skb_vlan_tag_get(skb);
 		}
 	}
 
@@ -473,9 +473,9 @@ static int qlcnic_tx_pkt(struct qlcnic_adapter *adapter,
 		flags = QLCNIC_FLAGS_VLAN_TAGGED;
 		vlan_tci = ntohs(vh->h_vlan_TCI);
 		protocol = ntohs(vh->h_vlan_encapsulated_proto);
-	} else if (vlan_tx_tag_present(skb)) {
+	} else if (skb_vlan_tag_present(skb)) {
 		flags = QLCNIC_FLAGS_VLAN_OOB;
-		vlan_tci = vlan_tx_tag_get(skb);
+		vlan_tci = skb_vlan_tag_get(skb);
 	}
 	if (unlikely(adapter->tx_pvid)) {
 		if (vlan_tci && !(adapter->flags & QLCNIC_TAGGING_ENABLED))
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 6c904a6..dc0058f 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -2660,11 +2660,11 @@ static netdev_tx_t qlge_send(struct sk_buff *skb, struct net_device *ndev)
 
 	mac_iocb_ptr->frame_len = cpu_to_le16((u16) skb->len);
 
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		netif_printk(qdev, tx_queued, KERN_DEBUG, qdev->ndev,
-			     "Adding a vlan tag %d.\n", vlan_tx_tag_get(skb));
+			     "Adding a vlan tag %d.\n", skb_vlan_tag_get(skb));
 		mac_iocb_ptr->flags3 |= OB_MAC_IOCB_V;
-		mac_iocb_ptr->vlan_tci = cpu_to_le16(vlan_tx_tag_get(skb));
+		mac_iocb_ptr->vlan_tci = cpu_to_le16(skb_vlan_tag_get(skb));
 	}
 	tso = ql_tso(skb, (struct ob_mac_tso_iocb_req *)mac_iocb_ptr);
 	if (tso < 0) {
diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 9c31e46..d79e33b 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -708,8 +708,8 @@ static void cp_tx (struct cp_private *cp)
 
 static inline u32 cp_tx_vlan_tag(struct sk_buff *skb)
 {
-	return vlan_tx_tag_present(skb) ?
-		TxVlanTag | swab16(vlan_tx_tag_get(skb)) : 0x00;
+	return skb_vlan_tag_present(skb) ?
+		TxVlanTag | swab16(skb_vlan_tag_get(skb)) : 0x00;
 }
 
 static void unwind_tx_frag_mapping(struct cp_private *cp, struct sk_buff *skb,
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 3a28059..cd286b0 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -2073,8 +2073,8 @@ static int rtl8169_set_features(struct net_device *dev,
 
 static inline u32 rtl8169_tx_vlan_tag(struct sk_buff *skb)
 {
-	return (vlan_tx_tag_present(skb)) ?
-		TxVlanTag | swab16(vlan_tx_tag_get(skb)) : 0x00;
+	return (skb_vlan_tag_present(skb)) ?
+		TxVlanTag | swab16(skb_vlan_tag_get(skb)) : 0x00;
 }
 
 static void rtl8169_rx_vlan_tag(struct RxDesc *desc, struct sk_buff *skb)
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index b6612d6..23545e1 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -1272,7 +1272,7 @@ static netdev_tx_t sxgbe_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(skb_is_gso(skb) && tqueue->prev_mss != cur_mss))
 		ctxt_desc_req = 1;
 
-	if (unlikely(vlan_tx_tag_present(skb) ||
+	if (unlikely(skb_vlan_tag_present(skb) ||
 		     ((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
 		      tqueue->hwts_tx_en)))
 		ctxt_desc_req = 1;
diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index 6ab36d9..a9cac84 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -1650,9 +1650,9 @@ static netdev_tx_t bdx_tx_transmit(struct sk_buff *skb,
 		    txd_mss);
 	}
 
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		/*Cut VLAN ID to 12 bits */
-		txd_vlan_id = vlan_tx_tag_get(skb) & BITS_MASK(12);
+		txd_vlan_id = skb_vlan_tag_get(skb) & BITS_MASK(12);
 		txd_vtag = 1;
 	}
 
diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index a191afc..0ac7610 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -1781,8 +1781,8 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 	rp->tx_ring[entry].desc_length =
 		cpu_to_le32(TXDESC | (skb->len >= ETH_ZLEN ? skb->len : ETH_ZLEN));
 
-	if (unlikely(vlan_tx_tag_present(skb))) {
-		u16 vid_pcp = vlan_tx_tag_get(skb);
+	if (unlikely(skb_vlan_tag_present(skb))) {
+		u16 vid_pcp = skb_vlan_tag_get(skb);
 
 		/* drop CFI/DEI bit, register needs VID and PCP */
 		vid_pcp = (vid_pcp & VLAN_VID_MASK) |
@@ -1803,7 +1803,7 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 
 	/* Non-x86 Todo: explicitly flush cache lines here. */
 
-	if (vlan_tx_tag_present(skb))
+	if (skb_vlan_tag_present(skb))
 		/* Tx queues are bits 7-0 (first Tx queue: bit 7) */
 		BYTE_REG_BITS_ON(1 << 7, ioaddr + TQWake);
 
diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index 282f83a..c20206f 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -2611,8 +2611,8 @@ static netdev_tx_t velocity_xmit(struct sk_buff *skb,
 
 	td_ptr->tdesc1.cmd = TCPLS_NORMAL + (tdinfo->nskb_dma + 1) * 16;
 
-	if (vlan_tx_tag_present(skb)) {
-		td_ptr->tdesc1.vlan = cpu_to_le16(vlan_tx_tag_get(skb));
+	if (skb_vlan_tag_present(skb)) {
+		td_ptr->tdesc1.vlan = cpu_to_le16(skb_vlan_tag_get(skb));
 		td_ptr->tdesc1.TCR |= TCR0_VETAG;
 	}
 
diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 7df2217..d0ed569 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -645,7 +645,7 @@ static void macvtap_skb_to_vnet_hdr(struct macvtap_queue *q,
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		vnet_hdr->flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
-		if (vlan_tx_tag_present(skb))
+		if (skb_vlan_tag_present(skb))
 			vnet_hdr->csum_start = cpu_to_macvtap16(q,
 				skb_checksum_start_offset(skb) + VLAN_HLEN);
 		else
@@ -821,13 +821,13 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 	total = vnet_hdr_len;
 	total += skb->len;
 
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		struct {
 			__be16 h_vlan_proto;
 			__be16 h_vlan_TCI;
 		} veth;
 		veth.h_vlan_proto = skb->vlan_proto;
-		veth.h_vlan_TCI = htons(vlan_tx_tag_get(skb));
+		veth.h_vlan_TCI = htons(skb_vlan_tag_get(skb));
 
 		vlan_offset = offsetof(struct vlan_ethhdr, h_vlan_proto);
 		total += VLAN_HLEN;
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 74fdf11..be196e8 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1260,7 +1260,7 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 	int vlan_hlen = 0;
 	int vnet_hdr_sz = 0;
 
-	if (vlan_tx_tag_present(skb))
+	if (skb_vlan_tag_present(skb))
 		vlan_hlen = VLAN_HLEN;
 
 	if (tun->flags & IFF_VNET_HDR)
@@ -1337,7 +1337,7 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 		} veth;
 
 		veth.h_vlan_proto = skb->vlan_proto;
-		veth.h_vlan_TCI = htons(vlan_tx_tag_get(skb));
+		veth.h_vlan_TCI = htons(skb_vlan_tag_get(skb));
 
 		vlan_offset = offsetof(struct vlan_ethhdr, h_vlan_proto);
 
diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index b23426e..e519e6a 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1421,10 +1421,10 @@ static int msdn_giant_send_check(struct sk_buff *skb)
 
 static inline void rtl_tx_vlan_tag(struct tx_desc *desc, struct sk_buff *skb)
 {
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		u32 opts2;
 
-		opts2 = TX_VLAN_TAG | swab16(vlan_tx_tag_get(skb));
+		opts2 = TX_VLAN_TAG | swab16(skb_vlan_tag_get(skb));
 		desc->opts2 |= cpu_to_le32(opts2);
 	}
 }
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 3143981..294214c 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1038,9 +1038,9 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 		le32_add_cpu(&tq->shared->txNumDeferred, 1);
 	}
 
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		gdesc->txd.ti = 1;
-		gdesc->txd.tci = vlan_tx_tag_get(skb);
+		gdesc->txd.tci = skb_vlan_tag_get(skb);
 	}
 
 	/* finally flips the GEN bit of the SOP desc. */
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 3a18d8e..985359dd 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1561,7 +1561,7 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 
 	min_headroom = LL_RESERVED_SPACE(dst->dev) + dst->header_len
 			+ VXLAN_HLEN + sizeof(struct ipv6hdr)
-			+ (vlan_tx_tag_present(skb) ? VLAN_HLEN : 0);
+			+ (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
 
 	/* Need space for new headers (invalidates iph ptr) */
 	err = skb_cow_head(skb, min_headroom);
@@ -1607,7 +1607,7 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 
 	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
 			+ VXLAN_HLEN + sizeof(struct iphdr)
-			+ (vlan_tx_tag_present(skb) ? VLAN_HLEN : 0);
+			+ (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
 
 	/* Need space for new headers (invalidates iph ptr) */
 	err = skb_cow_head(skb, min_headroom);
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 625227ad..dd4ab8d 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2800,12 +2800,12 @@ static void qeth_l3_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
 	 * before we're going to overwrite this location with next hop ip.
 	 * v6 uses passthrough, v4 sets the tag in the QDIO header.
 	 */
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		if ((ipv == 4) || (card->info.type == QETH_CARD_TYPE_IQD))
 			hdr->hdr.l3.ext_flags = QETH_HDR_EXT_VLAN_FRAME;
 		else
 			hdr->hdr.l3.ext_flags = QETH_HDR_EXT_INCLUDE_VLAN_TAG;
-		hdr->hdr.l3.vlan_id = vlan_tx_tag_get(skb);
+		hdr->hdr.l3.vlan_id = skb_vlan_tag_get(skb);
 	}
 
 	hdr->hdr.l3.length = skb->len - sizeof(struct qeth_hdr);
@@ -2986,7 +2986,7 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			skb_pull(new_skb, ETH_HLEN);
 		}
 
-		if (ipv != 4 && vlan_tx_tag_present(new_skb)) {
+		if (ipv != 4 && skb_vlan_tag_present(new_skb)) {
 			skb_push(new_skb, VLAN_HLEN);
 			skb_copy_to_linear_data(new_skb, new_skb->data + 4, 4);
 			skb_copy_to_linear_data_offset(new_skb, 4,
@@ -2995,7 +2995,7 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				new_skb->data + 12, 4);
 			tag = (u16 *)(new_skb->data + 12);
 			*tag = __constant_htons(ETH_P_8021Q);
-			*(tag + 1) = htons(vlan_tx_tag_get(new_skb));
+			*(tag + 1) = htons(skb_vlan_tag_get(new_skb));
 		}
 	}
 
diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 14419a8..bcaf4ca 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -469,7 +469,7 @@ static int peek_head_len(struct sock *sk)
 	head = skb_peek(&sk->sk_receive_queue);
 	if (likely(head)) {
 		len = head->len;
-		if (vlan_tx_tag_present(head))
+		if (skb_vlan_tag_present(head))
 			len += VLAN_HLEN;
 	}
 
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 515a35e..bea465f 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -78,9 +78,9 @@ static inline bool is_vlan_dev(struct net_device *dev)
         return dev->priv_flags & IFF_802_1Q_VLAN;
 }
 
-#define vlan_tx_tag_present(__skb)	((__skb)->vlan_tci & VLAN_TAG_PRESENT)
-#define vlan_tx_tag_get(__skb)		((__skb)->vlan_tci & ~VLAN_TAG_PRESENT)
-#define vlan_tx_tag_get_id(__skb)	((__skb)->vlan_tci & VLAN_VID_MASK)
+#define skb_vlan_tag_present(__skb)	((__skb)->vlan_tci & VLAN_TAG_PRESENT)
+#define skb_vlan_tag_get(__skb)		((__skb)->vlan_tci & ~VLAN_TAG_PRESENT)
+#define skb_vlan_tag_get_id(__skb)	((__skb)->vlan_tci & VLAN_VID_MASK)
 
 /**
  *	struct vlan_pcpu_stats - VLAN percpu rx/tx stats
@@ -376,7 +376,7 @@ static inline struct sk_buff *vlan_insert_tag_set_proto(struct sk_buff *skb,
 static inline struct sk_buff *__vlan_hwaccel_push_inside(struct sk_buff *skb)
 {
 	skb = vlan_insert_tag_set_proto(skb, skb->vlan_proto,
-					vlan_tx_tag_get(skb));
+					skb_vlan_tag_get(skb));
 	if (likely(skb))
 		skb->vlan_tci = 0;
 	return skb;
@@ -393,7 +393,7 @@ static inline struct sk_buff *__vlan_hwaccel_push_inside(struct sk_buff *skb)
  */
 static inline struct sk_buff *vlan_hwaccel_push_inside(struct sk_buff *skb)
 {
-	if (vlan_tx_tag_present(skb))
+	if (skb_vlan_tag_present(skb))
 		skb = __vlan_hwaccel_push_inside(skb);
 	return skb;
 }
@@ -442,8 +442,8 @@ static inline int __vlan_get_tag(const struct sk_buff *skb, u16 *vlan_tci)
 static inline int __vlan_hwaccel_get_tag(const struct sk_buff *skb,
 					 u16 *vlan_tci)
 {
-	if (vlan_tx_tag_present(skb)) {
-		*vlan_tci = vlan_tx_tag_get(skb);
+	if (skb_vlan_tag_present(skb)) {
+		*vlan_tci = skb_vlan_tag_get(skb);
 		return 0;
 	} else {
 		*vlan_tci = 0;
@@ -480,7 +480,7 @@ static inline __be16 vlan_get_protocol(const struct sk_buff *skb)
 {
 	__be16 protocol = 0;
 
-	if (vlan_tx_tag_present(skb) ||
+	if (skb_vlan_tag_present(skb) ||
 	     skb->protocol != cpu_to_be16(ETH_P_8021Q))
 		protocol = skb->protocol;
 	else {
diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index fe6e7aa..2342bf1 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -121,7 +121,7 @@ static inline __be16 tc_skb_protocol(const struct sk_buff *skb)
 	 * vlan accelerated path. In that case, use skb->vlan_proto
 	 * as the original vlan header was already stripped.
 	 */
-	if (vlan_tx_tag_present(skb))
+	if (skb_vlan_tag_present(skb))
 		return skb->vlan_proto;
 	return skb->protocol;
 }
diff --git a/include/trace/events/net.h b/include/trace/events/net.h
index 1de256b..49cc7c3 100644
--- a/include/trace/events/net.h
+++ b/include/trace/events/net.h
@@ -40,9 +40,9 @@ TRACE_EVENT(net_dev_start_xmit,
 		__assign_str(name, dev->name);
 		__entry->queue_mapping = skb->queue_mapping;
 		__entry->skbaddr = skb;
-		__entry->vlan_tagged = vlan_tx_tag_present(skb);
+		__entry->vlan_tagged = skb_vlan_tag_present(skb);
 		__entry->vlan_proto = ntohs(skb->vlan_proto);
-		__entry->vlan_tci = vlan_tx_tag_get(skb);
+		__entry->vlan_tci = skb_vlan_tag_get(skb);
 		__entry->protocol = ntohs(skb->protocol);
 		__entry->ip_summed = skb->ip_summed;
 		__entry->len = skb->len;
@@ -174,9 +174,9 @@ DECLARE_EVENT_CLASS(net_dev_rx_verbose_template,
 #endif
 		__entry->queue_mapping = skb->queue_mapping;
 		__entry->skbaddr = skb;
-		__entry->vlan_tagged = vlan_tx_tag_present(skb);
+		__entry->vlan_tagged = skb_vlan_tag_present(skb);
 		__entry->vlan_proto = ntohs(skb->vlan_proto);
-		__entry->vlan_tci = vlan_tx_tag_get(skb);
+		__entry->vlan_tci = skb_vlan_tag_get(skb);
 		__entry->protocol = ntohs(skb->protocol);
 		__entry->ip_summed = skb->ip_summed;
 		__entry->hash = skb->hash;
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 90cc2bd..61bf2a0 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -9,7 +9,7 @@ bool vlan_do_receive(struct sk_buff **skbp)
 {
 	struct sk_buff *skb = *skbp;
 	__be16 vlan_proto = skb->vlan_proto;
-	u16 vlan_id = vlan_tx_tag_get_id(skb);
+	u16 vlan_id = skb_vlan_tag_get_id(skb);
 	struct net_device *vlan_dev;
 	struct vlan_pcpu_stats *rx_stats;
 
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index c190d22..65728e0 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -66,17 +66,17 @@ static int brnf_pass_vlan_indev __read_mostly = 0;
 #endif
 
 #define IS_IP(skb) \
-	(!vlan_tx_tag_present(skb) && skb->protocol == htons(ETH_P_IP))
+	(!skb_vlan_tag_present(skb) && skb->protocol == htons(ETH_P_IP))
 
 #define IS_IPV6(skb) \
-	(!vlan_tx_tag_present(skb) && skb->protocol == htons(ETH_P_IPV6))
+	(!skb_vlan_tag_present(skb) && skb->protocol == htons(ETH_P_IPV6))
 
 #define IS_ARP(skb) \
-	(!vlan_tx_tag_present(skb) && skb->protocol == htons(ETH_P_ARP))
+	(!skb_vlan_tag_present(skb) && skb->protocol == htons(ETH_P_ARP))
 
 static inline __be16 vlan_proto(const struct sk_buff *skb)
 {
-	if (vlan_tx_tag_present(skb))
+	if (skb_vlan_tag_present(skb))
 		return skb->protocol;
 	else if (skb->protocol == htons(ETH_P_8021Q))
 		return vlan_eth_hdr(skb)->h_vlan_encapsulated_proto;
@@ -436,11 +436,11 @@ static struct net_device *brnf_get_logical_dev(struct sk_buff *skb, const struct
 	struct net_device *vlan, *br;
 
 	br = bridge_parent(dev);
-	if (brnf_pass_vlan_indev == 0 || !vlan_tx_tag_present(skb))
+	if (brnf_pass_vlan_indev == 0 || !skb_vlan_tag_present(skb))
 		return br;
 
 	vlan = __vlan_find_dev_deep_rcu(br, skb->vlan_proto,
-				    vlan_tx_tag_get(skb) & VLAN_VID_MASK);
+				    skb_vlan_tag_get(skb) & VLAN_VID_MASK);
 
 	return vlan ? vlan : br;
 }
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index aea3d13..d808d76 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -628,8 +628,8 @@ static inline int br_vlan_get_tag(const struct sk_buff *skb, u16 *vid)
 {
 	int err = 0;
 
-	if (vlan_tx_tag_present(skb))
-		*vid = vlan_tx_tag_get(skb) & VLAN_VID_MASK;
+	if (skb_vlan_tag_present(skb))
+		*vid = skb_vlan_tag_get(skb) & VLAN_VID_MASK;
 	else {
 		*vid = 0;
 		err = -EINVAL;
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 97b8ddf..13013fe 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -187,7 +187,7 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
 	 * sent from vlan device on the bridge device, it does not have
 	 * HW accelerated vlan tag.
 	 */
-	if (unlikely(!vlan_tx_tag_present(skb) &&
+	if (unlikely(!skb_vlan_tag_present(skb) &&
 		     skb->protocol == proto)) {
 		skb = skb_vlan_untag(skb);
 		if (unlikely(!skb))
@@ -200,7 +200,7 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
 			/* Protocol-mismatch, empty out vlan_tci for new tag */
 			skb_push(skb, ETH_HLEN);
 			skb = vlan_insert_tag_set_proto(skb, skb->vlan_proto,
-							vlan_tx_tag_get(skb));
+							skb_vlan_tag_get(skb));
 			if (unlikely(!skb))
 				return false;
 
diff --git a/net/bridge/netfilter/ebt_vlan.c b/net/bridge/netfilter/ebt_vlan.c
index 8d3f8c7..6185688 100644
--- a/net/bridge/netfilter/ebt_vlan.c
+++ b/net/bridge/netfilter/ebt_vlan.c
@@ -45,8 +45,8 @@ ebt_vlan_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	/* VLAN encapsulated Type/Length field, given from orig frame */
 	__be16 encap;
 
-	if (vlan_tx_tag_present(skb)) {
-		TCI = vlan_tx_tag_get(skb);
+	if (skb_vlan_tag_present(skb)) {
+		TCI = skb_vlan_tag_get(skb);
 		encap = skb->protocol;
 	} else {
 		const struct vlan_hdr *fp;
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index d9a8c05..91180a7 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -133,7 +133,7 @@ ebt_basic_match(const struct ebt_entry *e, const struct sk_buff *skb,
 	__be16 ethproto;
 	int verdict, i;
 
-	if (vlan_tx_tag_present(skb))
+	if (skb_vlan_tag_present(skb))
 		ethproto = htons(ETH_P_8021Q);
 	else
 		ethproto = h->h_proto;
diff --git a/net/core/dev.c b/net/core/dev.c
index 8054561..1e325ad 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2578,7 +2578,7 @@ netdev_features_t netif_skb_features(struct sk_buff *skb)
 	if (skb->encapsulation)
 		features &= dev->hw_enc_features;
 
-	if (!vlan_tx_tag_present(skb)) {
+	if (!skb_vlan_tag_present(skb)) {
 		if (unlikely(protocol == htons(ETH_P_8021Q) ||
 			     protocol == htons(ETH_P_8021AD))) {
 			struct vlan_ethhdr *veh = (struct vlan_ethhdr *)skb->data;
@@ -2659,7 +2659,7 @@ out:
 static struct sk_buff *validate_xmit_vlan(struct sk_buff *skb,
 					  netdev_features_t features)
 {
-	if (vlan_tx_tag_present(skb) &&
+	if (skb_vlan_tag_present(skb) &&
 	    !vlan_hw_offload_capable(features, skb->vlan_proto))
 		skb = __vlan_hwaccel_push_inside(skb);
 	return skb;
@@ -3676,7 +3676,7 @@ ncls:
 	if (pfmemalloc && !skb_pfmemalloc_protocol(skb))
 		goto drop;
 
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		if (pt_prev) {
 			ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = NULL;
@@ -3708,8 +3708,8 @@ ncls:
 		}
 	}
 
-	if (unlikely(vlan_tx_tag_present(skb))) {
-		if (vlan_tx_tag_get_id(skb))
+	if (unlikely(skb_vlan_tag_present(skb))) {
+		if (skb_vlan_tag_get_id(skb))
 			skb->pkt_type = PACKET_OTHERHOST;
 		/* Note: we might in the future use prio bits
 		 * and set skb->priority like in vlan_do_receive()
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index e0ad5d1..c126a87 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -77,7 +77,7 @@ static int netpoll_start_xmit(struct sk_buff *skb, struct net_device *dev,
 
 	features = netif_skb_features(skb);
 
-	if (vlan_tx_tag_present(skb) &&
+	if (skb_vlan_tag_present(skb) &&
 	    !vlan_hw_offload_capable(features, skb->vlan_proto)) {
 		skb = __vlan_hwaccel_push_inside(skb);
 		if (unlikely(!skb)) {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5a2a2e8..56db472 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4197,7 +4197,7 @@ struct sk_buff *skb_vlan_untag(struct sk_buff *skb)
 	struct vlan_hdr *vhdr;
 	u16 vlan_tci;
 
-	if (unlikely(vlan_tx_tag_present(skb))) {
+	if (unlikely(skb_vlan_tag_present(skb))) {
 		/* vlan_tci is already set-up so leave this for another time */
 		return skb;
 	}
@@ -4283,7 +4283,7 @@ int skb_vlan_pop(struct sk_buff *skb)
 	__be16 vlan_proto;
 	int err;
 
-	if (likely(vlan_tx_tag_present(skb))) {
+	if (likely(skb_vlan_tag_present(skb))) {
 		skb->vlan_tci = 0;
 	} else {
 		if (unlikely((skb->protocol != htons(ETH_P_8021Q) &&
@@ -4313,7 +4313,7 @@ EXPORT_SYMBOL(skb_vlan_pop);
 
 int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci)
 {
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		unsigned int offset = skb->data - skb_mac_header(skb);
 		int err;
 
@@ -4323,7 +4323,7 @@ int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci)
 		 */
 		__skb_push(skb, offset);
 		err = __vlan_insert_tag(skb, skb->vlan_proto,
-					vlan_tx_tag_get(skb));
+					skb_vlan_tag_get(skb));
 		if (err)
 			return err;
 		skb->protocol = skb->vlan_proto;
diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
index 5b52046..23744c7 100644
--- a/net/ipv4/geneve.c
+++ b/net/ipv4/geneve.c
@@ -119,7 +119,7 @@ int geneve_xmit_skb(struct geneve_sock *gs, struct rtable *rt,
 
 	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
 			+ GENEVE_BASE_HLEN + opt_len + sizeof(struct iphdr)
-			+ (vlan_tx_tag_present(skb) ? VLAN_HLEN : 0);
+			+ (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
 
 	err = skb_cow_head(skb, min_headroom);
 	if (unlikely(err)) {
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 770064c..b4cffe6 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -212,7 +212,7 @@ static int pop_vlan(struct sk_buff *skb, struct sw_flow_key *key)
 	int err;
 
 	err = skb_vlan_pop(skb);
-	if (vlan_tx_tag_present(skb))
+	if (skb_vlan_tag_present(skb))
 		invalidate_flow_key(key);
 	else
 		key->eth.tci = 0;
@@ -222,7 +222,7 @@ static int pop_vlan(struct sk_buff *skb, struct sw_flow_key *key)
 static int push_vlan(struct sk_buff *skb, struct sw_flow_key *key,
 		     const struct ovs_action_push_vlan *vlan)
 {
-	if (vlan_tx_tag_present(skb))
+	if (skb_vlan_tag_present(skb))
 		invalidate_flow_key(key);
 	else
 		key->eth.tci = vlan->vlan_tci;
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 4e9a5f0..54854e3 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -419,7 +419,7 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 	if (!dp_ifindex)
 		return -ENODEV;
 
-	if (vlan_tx_tag_present(skb)) {
+	if (skb_vlan_tag_present(skb)) {
 		nskb = skb_clone(skb, GFP_ATOMIC);
 		if (!nskb)
 			return -ENOMEM;
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index da2fae0..df334fe 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -70,7 +70,7 @@ void ovs_flow_stats_update(struct sw_flow *flow, __be16 tcp_flags,
 {
 	struct flow_stats *stats;
 	int node = numa_node_id();
-	int len = skb->len + (vlan_tx_tag_present(skb) ? VLAN_HLEN : 0);
+	int len = skb->len + (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
 
 	stats = rcu_dereference(flow->stats[node]);
 
@@ -472,7 +472,7 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 	 */
 
 	key->eth.tci = 0;
-	if (vlan_tx_tag_present(skb))
+	if (skb_vlan_tag_present(skb))
 		key->eth.tci = htons(skb->vlan_tci);
 	else if (eth->h_proto == htons(ETH_P_8021Q))
 		if (unlikely(parse_vlan(skb, key)))
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index d4168c4..e9aedb7 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -166,7 +166,7 @@ static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
 
 	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
 			+ tunnel_hlen + sizeof(struct iphdr)
-			+ (vlan_tx_tag_present(skb) ? VLAN_HLEN : 0);
+			+ (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
 	if (skb_headroom(skb) < min_headroom || skb_header_cloned(skb)) {
 		int head_delta = SKB_DATA_ALIGN(min_headroom -
 						skb_headroom(skb) +
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 2034c6d..464739a 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -480,7 +480,8 @@ void ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
 	stats = this_cpu_ptr(vport->percpu_stats);
 	u64_stats_update_begin(&stats->syncp);
 	stats->rx_packets++;
-	stats->rx_bytes += skb->len + (vlan_tx_tag_present(skb) ? VLAN_HLEN : 0);
+	stats->rx_bytes += skb->len +
+			   (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
 	u64_stats_update_end(&stats->syncp);
 
 	OVS_CB(skb)->input_vport = vport;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 0f02668..d37075b 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -986,8 +986,8 @@ static void prb_clear_rxhash(struct tpacket_kbdq_core *pkc,
 static void prb_fill_vlan_info(struct tpacket_kbdq_core *pkc,
 			struct tpacket3_hdr *ppd)
 {
-	if (vlan_tx_tag_present(pkc->skb)) {
-		ppd->hv1.tp_vlan_tci = vlan_tx_tag_get(pkc->skb);
+	if (skb_vlan_tag_present(pkc->skb)) {
+		ppd->hv1.tp_vlan_tci = skb_vlan_tag_get(pkc->skb);
 		ppd->hv1.tp_vlan_tpid = ntohs(pkc->skb->vlan_proto);
 		ppd->tp_status = TP_STATUS_VLAN_VALID | TP_STATUS_VLAN_TPID_VALID;
 	} else {
@@ -2000,8 +2000,8 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 		h.h2->tp_net = netoff;
 		h.h2->tp_sec = ts.tv_sec;
 		h.h2->tp_nsec = ts.tv_nsec;
-		if (vlan_tx_tag_present(skb)) {
-			h.h2->tp_vlan_tci = vlan_tx_tag_get(skb);
+		if (skb_vlan_tag_present(skb)) {
+			h.h2->tp_vlan_tci = skb_vlan_tag_get(skb);
 			h.h2->tp_vlan_tpid = ntohs(skb->vlan_proto);
 			status |= TP_STATUS_VLAN_VALID | TP_STATUS_VLAN_TPID_VALID;
 		} else {
@@ -3010,8 +3010,8 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 		aux.tp_snaplen = skb->len;
 		aux.tp_mac = 0;
 		aux.tp_net = skb_network_offset(skb);
-		if (vlan_tx_tag_present(skb)) {
-			aux.tp_vlan_tci = vlan_tx_tag_get(skb);
+		if (skb_vlan_tag_present(skb)) {
+			aux.tp_vlan_tci = skb_vlan_tag_get(skb);
 			aux.tp_vlan_tpid = ntohs(skb->vlan_proto);
 			aux.tp_status |= TP_STATUS_VLAN_VALID | TP_STATUS_VLAN_TPID_VALID;
 		} else {
diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index 2159981..b5294ce 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -176,7 +176,7 @@ META_COLLECTOR(int_vlan_tag)
 {
 	unsigned short tag;
 
-	tag = vlan_tx_tag_get(skb);
+	tag = skb_vlan_tag_get(skb);
 	if (!tag && __vlan_get_tag(skb, &tag))
 		*err = -1;
 	else
diff --git a/net/wireless/util.c b/net/wireless/util.c
index d0ac795..1d2fcfa 100644
--- a/net/wireless/util.c
+++ b/net/wireless/util.c
@@ -708,8 +708,8 @@ unsigned int cfg80211_classify8021d(struct sk_buff *skb,
 	if (skb->priority >= 256 && skb->priority <= 263)
 		return skb->priority - 256;
 
-	if (vlan_tx_tag_present(skb)) {
-		vlan_priority = (vlan_tx_tag_get(skb) & VLAN_PRIO_MASK)
+	if (skb_vlan_tag_present(skb)) {
+		vlan_priority = (skb_vlan_tag_get(skb) & VLAN_PRIO_MASK)
 			>> VLAN_PRIO_SHIFT;
 		if (vlan_priority > 0)
 			return vlan_priority;
-- 
1.9.3
