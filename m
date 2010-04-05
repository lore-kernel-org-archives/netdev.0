From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 10/12] tg3: Cleanup if codestyle
Date: Mon, 5 Apr 2010 13:19:28 -0700
Message-ID: <1270498770-23765-11-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2530 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756494Ab0DEUTq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Apr 2010 16:19:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch cleans up the code style as it pertains to if statements.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   75 ++++++++++++++++++++++-------------------------------
 1 files changed, 31 insertions(+), 44 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 902fb9b..47dea55 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1858,8 +1858,7 @@ static int tg3_phy_reset_5703_4_5(struct tg3 *tp)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704) {
 		/* Set Extended packet length bit for jumbo frames */
 		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x4400);
-	}
-	else {
+	} else {
 		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0400);
 	}
 
@@ -1977,8 +1976,7 @@ out:
 		tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x401f);
 		tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x14e2);
 		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0400);
-	}
-	else if (tp->tg3_flags2 & TG3_FLG2_PHY_JITTER_BUG) {
+	} else if (tp->tg3_flags2 & TG3_FLG2_PHY_JITTER_BUG) {
 		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0c00);
 		tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x000a);
 		if (tp->tg3_flags2 & TG3_FLG2_PHY_ADJUST_TRIM) {
@@ -3466,11 +3464,10 @@ static int tg3_fiber_aneg_smachine(struct tg3 *tp,
 		/* fallthru */
 	case ANEG_STATE_RESTART:
 		delta = ap->cur_time - ap->link_time;
-		if (delta > ANEG_STATE_SETTLE_TIME) {
+		if (delta > ANEG_STATE_SETTLE_TIME)
 			ap->state = ANEG_STATE_ABILITY_DETECT_INIT;
-		} else {
+		else
 			ret = ANEG_TIMER_ENAB;
-		}
 		break;
 
 	case ANEG_STATE_DISABLE_LINK_OK:
@@ -3494,9 +3491,8 @@ static int tg3_fiber_aneg_smachine(struct tg3 *tp,
 		break;
 
 	case ANEG_STATE_ABILITY_DETECT:
-		if (ap->ability_match != 0 && ap->rxconfig != 0) {
+		if (ap->ability_match != 0 && ap->rxconfig != 0)
 			ap->state = ANEG_STATE_ACK_DETECT_INIT;
-		}
 		break;
 
 	case ANEG_STATE_ACK_DETECT_INIT:
@@ -4174,9 +4170,9 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
 					current_duplex = DUPLEX_FULL;
 				else
 					current_duplex = DUPLEX_HALF;
-			}
-			else
+			} else {
 				current_link_up = 0;
+			}
 		}
 	}
 
@@ -4244,10 +4240,9 @@ static void tg3_serdes_parallel_detect(struct tg3 *tp)
 				tp->tg3_flags2 |= TG3_FLG2_PARALLEL_DETECT;
 			}
 		}
-	}
-	else if (netif_carrier_ok(tp->dev) &&
-		 (tp->link_config.autoneg == AUTONEG_ENABLE) &&
-		 (tp->tg3_flags2 & TG3_FLG2_PARALLEL_DETECT)) {
+	} else if (netif_carrier_ok(tp->dev) &&
+		   (tp->link_config.autoneg == AUTONEG_ENABLE) &&
+		   (tp->tg3_flags2 & TG3_FLG2_PARALLEL_DETECT)) {
 		u32 phy2;
 
 		/* Select expansion interrupt status register */
@@ -4270,13 +4265,12 @@ static int tg3_setup_phy(struct tg3 *tp, int force_reset)
 {
 	int err;
 
-	if (tp->tg3_flags2 & TG3_FLG2_PHY_SERDES) {
+	if (tp->tg3_flags2 & TG3_FLG2_PHY_SERDES)
 		err = tg3_setup_fiber_phy(tp, force_reset);
-	} else if (tp->tg3_flags2 & TG3_FLG2_MII_SERDES) {
+	else if (tp->tg3_flags2 & TG3_FLG2_MII_SERDES)
 		err = tg3_setup_fiber_mii_phy(tp, force_reset);
-	} else {
+	else
 		err = tg3_setup_copper_phy(tp, force_reset);
-	}
 
 	if (GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5784_AX) {
 		u32 val, scale;
@@ -5560,9 +5554,10 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 
 		tcp_hdr(skb)->check = 0;
 
-	}
-	else if (skb->ip_summed == CHECKSUM_PARTIAL)
+	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		base_flags |= TXD_FLAG_TCPUDP_CSUM;
+	}
+
 #if TG3_VLAN_TAG_USED
 	if (tp->vlgrp != NULL && vlan_tx_tag_present(skb))
 		base_flags |= (TXD_FLAG_VLAN |
@@ -5932,9 +5927,9 @@ static inline void tg3_set_mtu(struct net_device *dev, struct tg3 *tp,
 		if (tp->tg3_flags2 & TG3_FLG2_5780_CLASS) {
 			tp->tg3_flags2 &= ~TG3_FLG2_TSO_CAPABLE;
 			ethtool_op_set_tso(dev, 0);
-		}
-		else
+		} else {
 			tp->tg3_flags |= TG3_FLAG_JUMBO_RING_ENABLE;
+		}
 	} else {
 		if (tp->tg3_flags2 & TG3_FLG2_5780_CLASS)
 			tp->tg3_flags2 |= TG3_FLG2_TSO_CAPABLE;
@@ -7585,9 +7580,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 
 	tg3_write_sig_pre_reset(tp, RESET_KIND_INIT);
 
-	if (tp->tg3_flags & TG3_FLAG_INIT_COMPLETE) {
+	if (tp->tg3_flags & TG3_FLAG_INIT_COMPLETE)
 		tg3_abort_hw(tp, 1);
-	}
 
 	if (reset_phy)
 		tg3_phy_reset(tp);
@@ -7740,8 +7734,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 			tw32(BUFMGR_MB_POOL_SIZE, NIC_SRAM_MBUF_POOL_SIZE96);
 		tw32(BUFMGR_DMA_DESC_POOL_ADDR, NIC_SRAM_DMA_DESC_POOL_BASE);
 		tw32(BUFMGR_DMA_DESC_POOL_SIZE, NIC_SRAM_DMA_DESC_POOL_SIZE);
-	}
-	else if (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) {
+	} else if (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) {
 		int fw_len;
 
 		fw_len = tp->fw_len;
@@ -9424,9 +9417,8 @@ static inline u32 calc_crc(unsigned char *buf, int len)
 
 			reg >>= 1;
 
-			if (tmp) {
+			if (tmp)
 				reg ^= 0xedb88320;
-			}
 		}
 	}
 
@@ -10380,8 +10372,7 @@ static int tg3_test_nvram(struct tg3 *tp)
 				for (l = 0, msk = 0x80; l < 7; l++, msk >>= 1)
 					parity[k++] = buf8[i] & msk;
 				i++;
-			}
-			else if (i == 16) {
+			} else if (i == 16) {
 				int l;
 				u8 msk;
 
@@ -10844,9 +10835,9 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 				     MII_TG3_EXT_CTRL_LNK3_LED_MODE);
 		}
 		tw32(MAC_MODE, mac_mode);
-	}
-	else
+	} else {
 		return -EINVAL;
+	}
 
 	err = -EIO;
 
@@ -12048,8 +12039,7 @@ static int tg3_nvram_write_block(struct tg3 *tp, u32 offset, u32 len, u8 *buf)
 
 	if (!(tp->tg3_flags & TG3_FLAG_NVRAM)) {
 		ret = tg3_nvram_write_block_using_eeprom(tp, offset, len, buf);
-	}
-	else {
+	} else {
 		u32 grc_mode;
 
 		ret = tg3_nvram_lock(tp);
@@ -12069,8 +12059,7 @@ static int tg3_nvram_write_block(struct tg3 *tp, u32 offset, u32 len, u8 *buf)
 
 			ret = tg3_nvram_write_block_buffered(tp, offset, len,
 				buf);
-		}
-		else {
+		} else {
 			ret = tg3_nvram_write_block_unbuffered(tp, offset, len,
 				buf);
 		}
@@ -13119,8 +13108,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		tp->tg3_flags2 |= TG3_FLG2_5780_CLASS;
 		tp->tg3_flags |= TG3_FLAG_40BIT_DMA_BUG;
 		tp->msi_cap = pci_find_capability(tp->pdev, PCI_CAP_ID_MSI);
-	}
-	else {
+	} else {
 		struct pci_dev *bridge = NULL;
 
 		do {
@@ -14018,11 +14006,10 @@ static int __devinit tg3_do_test_dma(struct tg3 *tp, u32 *buf, dma_addr_t buf_dm
 	}
 	pci_write_config_dword(tp->pdev, TG3PCI_MEM_WIN_BASE_ADDR, 0);
 
-	if (to_device) {
+	if (to_device)
 		tw32(FTQ_DMA_HIGH_READ_FIFO_ENQDEQ, sram_dma_descs);
-	} else {
+	else
 		tw32(FTQ_DMA_HIGH_WRITE_FIFO_ENQDEQ, sram_dma_descs);
-	}
 
 	ret = -ENODEV;
 	for (i = 0; i < 40; i++) {
@@ -14227,10 +14214,10 @@ static int __devinit tg3_test_dma(struct tg3 *tp)
 		if (pci_dev_present(dma_wait_state_chipsets)) {
 			tp->dma_rwctrl &= ~DMA_RWCTRL_WRITE_BNDRY_MASK;
 			tp->dma_rwctrl |= DMA_RWCTRL_WRITE_BNDRY_16;
-		}
-		else
+		} else {
 			/* Safe to use the calculated DMA boundary. */
 			tp->dma_rwctrl = saved_dma_rwctrl;
+		}
 
 		tw32(TG3PCI_DMA_RW_CTRL, tp->dma_rwctrl);
 	}
-- 
1.6.4.4


