From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH][BNX2X] round three
Date: Wed, 10 Oct 2007 18:28:57 -0700
Message-ID: <20071010182857.610893a3@freepuppy.rosehill>
References: <1192038559.29746.127.camel@eliezer>
	<470D2D7E.8080507@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"Michael Chan" <mchan@broadcom.com>
To: "Eliezer Tamir" <eliezert@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42175 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755260AbXJKB33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 21:29:29 -0400
In-Reply-To: <470D2D7E.8080507@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Minor formatting nits reported by checkpatch.pl script:

WARNING: braces {} are not necessary for single statement blocks
#506: FILE: drivers/net/bnx2x.c:451:
+	if (REG_RD(bp, GRCBASE_HC, addr) != val) {
+		BNX2X_ERR("BUG! proper val not read from IGU!\n");
+	}

WARNING: braces {} are not necessary for single statement blocks
#709: FILE: drivers/net/bnx2x.c:654:
+	if (unlikely(bp->panic)) {
+		return;
+	}

WARNING: braces {} are not necessary for single statement blocks
#736: FILE: drivers/net/bnx2x.c:681:
+		if (done == work) {
+			break;
+		}

WARNING: braces {} are not necessary for single statement blocks
#754: FILE: drivers/net/bnx2x.c:699:
+		if ((netif_queue_stopped(bp->dev)) &&
+		    (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3)) {
+			netif_wake_queue(bp->dev);
+		}

WARNING: no space between function name and open parenthesis '('
#777: FILE: drivers/net/bnx2x.c:722:
+	case (RAMROD_CMD_ID_ETH_PORT_SETUP | BNX2X_STATE_OPENING_WAIT4_PORT):

WARNING: no space between function name and open parenthesis '('
#782: FILE: drivers/net/bnx2x.c:727:
+	case (RAMROD_CMD_ID_ETH_HALT | BNX2X_STATE_CLOSING_WAIT4_HALT):

WARNING: no space between function name and open parenthesis '('
#788: FILE: drivers/net/bnx2x.c:733:
+	case (RAMROD_CMD_ID_ETH_PORT_DEL | BNX2X_STATE_CLOSING_WAIT4_DELETE):

WARNING: no space between function name and open parenthesis '('
#793: FILE: drivers/net/bnx2x.c:738:
+	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_OPEN):

WARNING: braces {} are not necessary for single statement blocks
#812: FILE: drivers/net/bnx2x.c:757:
+	if (unlikely(skb == NULL)) {
+		return -ENOMEM;
+	}

WARNING: braces {} are not necessary for single statement blocks
#873: FILE: drivers/net/bnx2x.c:818:
+	if (unlikely(bp->panic)) {
+		return 0;
+	}

WARNING: braces {} are not necessary for single statement blocks
#879: FILE: drivers/net/bnx2x.c:824:
+	if ((hw_comp_cons & MAX_RX_DESC_CNT) == MAX_RX_DESC_CNT) {
+		hw_comp_cons++;
+	}

WARNING: braces {} are not necessary for single statement blocks
#1018: FILE: drivers/net/bnx2x.c:963:
+		if ((cqe->fast_path_cqe.pars_flags.flags
+		     & PARSING_FLAGS_NUMBER_OF_NESTED_VLANS)
+		    && (bp->vlgrp != 0)) {
+			vlan_hwaccel_receive_skb(skb, bp->vlgrp,
+						 cqe->fast_path_cqe.vlan_tag);
+		} else

WARNING: braces {} are not necessary for single statement blocks
#1069: FILE: drivers/net/bnx2x.c:1014:
+	if (unlikely(bp->panic)) {
+		return IRQ_HANDLED;
+	}

WARNING: braces {} are not necessary for single statement blocks
#1096: FILE: drivers/net/bnx2x.c:1041:
+	if (unlikely(bp->panic)) {
+		return IRQ_HANDLED;
+	}

WARNING: braces {} are not necessary for single statement blocks
#1118: FILE: drivers/net/bnx2x.c:1063:
+		if (!status) {
+			return IRQ_HANDLED;
+		}

WARNING: braces {} are not necessary for single statement blocks
#1127: FILE: drivers/net/bnx2x.c:1072:
+		if (!status) {
+			return IRQ_HANDLED;
+		}

WARNING: braces {} are not necessary for single statement blocks
#1489: FILE: drivers/net/bnx2x.c:1434:
+		if (rd_val == val) {
+			return 0;
+		}

WARNING: braces {} are not necessary for single statement blocks
#1549: FILE: drivers/net/bnx2x.c:1494:
+		if (bp->req_flow_ctrl == FLOW_CTRL_AUTO) {
+			bp->flow_ctrl = FLOW_CTRL_BOTH;
+		}

WARNING: braces {} are not necessary for single statement blocks
#1661: FILE: drivers/net/bnx2x.c:1606:
+			if (gp_status & MDIO_AN_CL73_OR_37_COMPLETE) {
+				bp->link_status |=
+					LINK_STATUS_AUTO_NEGOTIATE_COMPLETE;
+			}

WARNING: braces {} are not necessary for single statement blocks
#1665: FILE: drivers/net/bnx2x.c:1610:
+			if (bp->autoneg & AUTONEG_PARALLEL) {
+				bp->link_status |=
+					LINK_STATUS_PARALLEL_DETECTION_USED;
+			}

WARNING: braces {} are not necessary for single statement blocks
#1671: FILE: drivers/net/bnx2x.c:1616:
+		if (bp->flow_ctrl & FLOW_CTRL_TX) {
+		       bp->link_status |= LINK_STATUS_TX_FLOW_CONTROL_ENABLED;
+		}

WARNING: braces {} are not necessary for single statement blocks
#1674: FILE: drivers/net/bnx2x.c:1619:
+		if (bp->flow_ctrl & FLOW_CTRL_RX) {
+		       bp->link_status |= LINK_STATUS_RX_FLOW_CONTROL_ENABLED;
+		}

WARNING: braces {} are not necessary for single statement blocks
#1871: FILE: drivers/net/bnx2x.c:1816:
+	if (bp->flow_ctrl & FLOW_CTRL_TX) {
+		val |= 0x800000;
+	}

WARNING: braces {} are not necessary for single statement blocks
#1898: FILE: drivers/net/bnx2x.c:1843:
+	if (bp->flow_ctrl & FLOW_CTRL_RX) {
+		val |= 0x20;
+	}

WARNING: braces {} are not necessary for single statement blocks
#1953: FILE: drivers/net/bnx2x.c:1898:
+	if (bp->flow_ctrl & FLOW_CTRL_TX) {
+		val = 1;
+	}

WARNING: braces {} are not necessary for single statement blocks
#2053: FILE: drivers/net/bnx2x.c:1998:
+		if (bp->flow_ctrl & FLOW_CTRL_RX) {
+			bnx2x_bits_en(bp, emac_base, EMAC_REG_EMAC_RX_MODE,
+				      EMAC_RX_MODE_FLOW_EN);
+		}

WARNING: braces {} are not necessary for single statement blocks
#2060: FILE: drivers/net/bnx2x.c:2005:
+		if (bp->flow_ctrl & FLOW_CTRL_TX) {
+			bnx2x_bits_en(bp, emac_base, EMAC_REG_EMAC_TX_MODE,
+				      EMAC_TX_MODE_EXT_PAUSE_EN);
+		}

WARNING: braces {} are not necessary for single statement blocks
#2100: FILE: drivers/net/bnx2x.c:2045:
+	if (bp->flow_ctrl & FLOW_CTRL_TX) {
+		val = 1;
+	}

WARNING: braces {} are not necessary for single statement blocks
#2153: FILE: drivers/net/bnx2x.c:2098:
+	if (bp->duplex == DUPLEX_HALF) {
+		mode |= EMAC_MODE_HALF_DUPLEX;
+	}

WARNING: braces {} are not necessary for single statement blocks
#2218: FILE: drivers/net/bnx2x.c:2163:
+	if (bp->flow_ctrl & FLOW_CTRL_RX) {
+		pause = 1;
+	}

WARNING: braces {} are not necessary for single statement blocks
#2273: FILE: drivers/net/bnx2x.c:2218:
+	if (!nomcp) {
+		SHMEM_WR(bp, drv_fw_mb[bp->port].link_status,
+			 bp->link_status);
+	}

ERROR: no space before that close parenthesis ')'
#2380: FILE: drivers/net/bnx2x.c:2325:
+	);

WARNING: braces {} are not necessary for single statement blocks
#2410: FILE: drivers/net/bnx2x.c:2355:
+				if (!(bp->phy_flags & PHY_SGMII_FLAG)) {
+					bnx2x_set_sgmii_tx_driver(bp);
+				}/* Not SGMII */

WARNING: braces {} are not necessary for single statement blocks
#2645: FILE: drivers/net/bnx2x.c:2590:
+	if (bp->req_duplex == DUPLEX_FULL) {
+		reg_val |= MDIO_COMBO_IEEO_MII_CONTROL_FULL_DUPLEX;
+	}

WARNING: braces {} are not necessary for single statement blocks
#2659: FILE: drivers/net/bnx2x.c:2604:
+		if (bp->req_line_speed == SPEED_10000) {
+			reg_val |=
+				MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_10G_CX4;
+		}

WARNING: braces {} are not necessary for single statement blocks
#2675: FILE: drivers/net/bnx2x.c:2620:
+	if (bp->advertising & ADVERTISED_2500baseT_Full) {
+		val |= MDIO_OVER_1G_UP1_2_5G;
+	}

WARNING: braces {} are not necessary for single statement blocks
#2678: FILE: drivers/net/bnx2x.c:2623:
+	if (bp->advertising & ADVERTISED_10000baseT_Full) {
+		val |= MDIO_OVER_1G_UP1_10G;
+	}

WARNING: braces {} are not necessary for single statement blocks
#2789: FILE: drivers/net/bnx2x.c:2734:
+		if (bp->req_duplex == DUPLEX_FULL) {
+			mii_control |=
+				MDIO_COMBO_IEEO_MII_CONTROL_FULL_DUPLEX;
+		}

WARNING: braces {} are not necessary for single statement blocks
#2991: FILE: drivers/net/bnx2x.c:2936:
+	if (bp->phy_flags & PHY_XGXS_FLAG) {
+		bnx2x_set_master_ln(bp);
+	}

WARNING: braces {} are not necessary for single statement blocks
#3007: FILE: drivers/net/bnx2x.c:2952:
+	if (bp->req_autoneg & AUTONEG_SPEED) {
+		bnx2x_set_parallel_detection(bp);
+	}

WARNING: no space between function name and open parenthesis '('
#3159: FILE: drivers/net/bnx2x.c:3104:
+static void bnx2x_set_xgxs_loopback (struct bnx2x *bp, int is_10g)

WARNING: braces {} are not necessary for single statement blocks
#3226: FILE: drivers/net/bnx2x.c:3171:
+	if (unlikely(bp->panic)) {
+		return -EIO;
+	}

ERROR: no space after that open parenthesis '('
#3273: FILE: drivers/net/bnx2x.c:3218:
+static int bnx2x_lock_alr( struct bnx2x *bp)

WARNING: braces {} are not necessary for single statement blocks
#3284: FILE: drivers/net/bnx2x.c:3229:
+		if (val & (1L << 31)) {
+			break;
+		}

ERROR: trailing whitespace
#3314: FILE: drivers/net/bnx2x.c:3259:
+^I$

WARNING: braces {} are not necessary for single statement blocks
#3381: FILE: drivers/net/bnx2x.c:3326:
+		if (asserted & ATTN_SW_TIMER_4_FUNC0) {
+			DP(NETIF_MSG_HW, "ATTN_SW_TIMER_4_FUNC!\n");
+		}

WARNING: braces {} are not necessary for single statement blocks
#3384: FILE: drivers/net/bnx2x.c:3329:
+		if (asserted & GPIO_2_FUNC0) {
+			DP(NETIF_MSG_HW, "GPIO_2_FUNC!\n");
+		}

WARNING: braces {} are not necessary for single statement blocks
#3387: FILE: drivers/net/bnx2x.c:3332:
+		if (asserted & GPIO_3_FUNC0) {
+			DP(NETIF_MSG_HW, "GPIO_3_FUNC!\n");
+		}

WARNING: braces {} are not necessary for single statement blocks
#3390: FILE: drivers/net/bnx2x.c:3335:
+		if (asserted & GPIO_4_FUNC0) {
+			DP(NETIF_MSG_HW, "GPIO_4_FUNC!\n");
+		}

WARNING: braces {} are not necessary for single statement blocks
#3399: FILE: drivers/net/bnx2x.c:3344:
+		if (asserted & ATTN_GENERAL_ATTN_2) {
+			DP(NETIF_MSG_HW, "ATTN_GENERAL_ATTN_2!\n");
+		}

WARNING: braces {} are not necessary for single statement blocks
#3402: FILE: drivers/net/bnx2x.c:3347:
+		if (asserted & ATTN_GENERAL_ATTN_3) {
+			DP(NETIF_MSG_HW, "ATTN_GENERAL_ATTN_3!\n");
+		}

WARNING: braces {} are not necessary for single statement blocks
#3412: FILE: drivers/net/bnx2x.c:3357:
+	if (asserted & (ATTN_NIG_FOR_FUNC0 | ATTN_NIG_FOR_FUNC1)) {
+		REG_WR(bp, GRCBASE_NIG, nig_mask_addr, bp->nig_mask);
+	}

WARNING: braces {} are not necessary for single statement blocks
#3482: FILE: drivers/net/bnx2x.c:3427:
+				if (val & 0x2) {
+					BNX2X_ERR("FATAL error from DORQ\n");
+				}

WARNING: braces {} are not necessary for single statement blocks
#3494: FILE: drivers/net/bnx2x.c:3439:
+				if (val & 0x18000) {
+					BNX2X_ERR("FATAL error from PXP\n");
+				}

WARNING: braces {} are not necessary for single statement blocks
#3554: FILE: drivers/net/bnx2x.c:3499:
+	if (~(attn_bits ^ attn_ack) & (attn_bits ^ attn_state)) {
+		BNX2X_ERR("bad attention state\n");
+	}

WARNING: braces {} are not necessary for single statement blocks
#3559: FILE: drivers/net/bnx2x.c:3504:
+	if (asserted) {
+		bnx2x_attn_int_asserted(bp, asserted);
+	}

WARNING: braces {} are not necessary for single statement blocks
#3563: FILE: drivers/net/bnx2x.c:3508:
+	if (deasserted) {
+		bnx2x_attn_int_deasserted(bp, deasserted);
+	}

WARNING: braces {} are not necessary for single statement blocks
#3580: FILE: drivers/net/bnx2x.c:3525:
+	if (status == 0) {
+		BNX2X_ERR("spurious slowpath interrupt!\n");
+	}

WARNING: braces {} are not necessary for single statement blocks
#3592: FILE: drivers/net/bnx2x.c:3537:
+	if (status & 0x2) {
+		bp->stat_pending = 0;
+	}

WARNING: braces {} are not necessary for single statement blocks
#3623: FILE: drivers/net/bnx2x.c:3568:
+	if (unlikely(bp->panic)) {
+		return IRQ_HANDLED;
+	}

WARNING: braces {} are not necessary for single statement blocks
#3926: FILE: drivers/net/bnx2x.c:3871:
+		while (bp->stats_state != STATS_STATE_DISABLE) {
+			msleep(100);
+		}

WARNING: braces {} are not necessary for single statement blocks
#4234: FILE: drivers/net/bnx2x.c:4179:
+	if (bp->msglevel & NETIF_MSG_TIMER) {
+		printk(KERN_DEBUG "%s:\n"
+		       KERN_DEBUG "  tx avail (%4x)  tx hc idx (%x)"
+				  "  tx pkt (%lx)\n"
+		       KERN_DEBUG "  rx usage (%4x)  rx hc idx (%x)"
+				  "  rx pkt (%lx)\n"
+		       KERN_DEBUG "  %s (Xoff events %u)  brb drops %u\n"
+		       KERN_DEBUG "  tstats: no_buff_discard %u"
+				  "  errors_discard %u  mac_filter_discard %u"
+				  "  xxovrflow_discard %u  ttl0_discard %u\n",
+		       bp->dev->name, bnx2x_tx_avail(bp->fp),
+		       *bp->fp->tx_cons_sb, bp->dev->stats.tx_packets,
+		       (u16)(*bp->fp->rx_cons_sb - bp->fp->rx_comp_cons),
+		       *bp->fp->rx_cons_sb, bp->dev->stats.rx_packets,
+		       netif_queue_stopped(bp->dev)? "Xoff" : "Xon",
+		       bp->slowpath->eth_stats.driver_xoff,
+		       bp->slowpath->eth_stats.brb_discard,
+		       bp->slowpath->eth_stats.no_buff_discard,
+		       bp->slowpath->eth_stats.errors_discard,
+		       bp->slowpath->eth_stats.mac_filter_discard,
+		       bp->slowpath->eth_stats.xxoverflow_discard,
+		       bp->slowpath->eth_stats.ttl0_discard);
+	}

WARNING: braces {} are not necessary for single statement blocks
#4264: FILE: drivers/net/bnx2x.c:4209:
+	if (unlikely(bp->panic)) {
+		return;
+	}

WARNING: braces {} are not necessary for single statement blocks
#4269: FILE: drivers/net/bnx2x.c:4214:
+	if (bp->fw_mb) {
+		REG_WR32(bp, GRCBASE_DMAE,
+			 (bp->port ? DMAE_REGISTERS_GO_C13 :
+				     DMAE_REGISTERS_GO_C12), 1);
+	}

WARNING: braces {} are not necessary for single statement blocks
#4332: FILE: drivers/net/bnx2x.c:4277:
+		if ((drv_pulse != mcp_pulse) &&
+		    (drv_pulse != ((mcp_pulse + 1) & MCP_PULSE_SEQ_MASK))) {
+			BNX2X_ERR("drv_pulse (0x%x) != mcp_pulse (0x%x)\n",
+				  drv_pulse, mcp_pulse);
+		}

WARNING: braces {} are not necessary for single statement blocks
#4374: FILE: drivers/net/bnx2x.c:4319:
+	for (index = 0; index < HC_USTORM_SB_NUM_INDICES; index++) {
+		REG_WR16(bp, BAR_USTRORM_INTMEM,
+			 USTORM_SB_HC_DISABLE_OFFSET(port, id, index), 0x1);
+	}

WARNING: braces {} are not necessary for single statement blocks
#4390: FILE: drivers/net/bnx2x.c:4335:
+	for (index = 0; index < HC_CSTORM_SB_NUM_INDICES; index++) {
+		REG_WR16(bp, BAR_CSTRORM_INTMEM,
+			 CSTORM_SB_HC_DISABLE_OFFSET(port, id, index), 0x1);
+	}

WARNING: braces {} are not necessary for single statement blocks
#4458: FILE: drivers/net/bnx2x.c:4403:
+	for (index = 0; index < HC_USTORM_DEF_SB_NUM_INDICES; index++) {
+		REG_WR16(bp, BAR_USTRORM_INTMEM,
+			 USTORM_DEF_SB_HC_DISABLE_OFFSET(port, index), 0x1);
+	}

WARNING: braces {} are not necessary for single statement blocks
#4476: FILE: drivers/net/bnx2x.c:4421:
+	for (index = 0; index < HC_CSTORM_DEF_SB_NUM_INDICES; index++) {
+		REG_WR16(bp, BAR_CSTRORM_INTMEM,
+			 CSTORM_DEF_SB_HC_DISABLE_OFFSET(port, index), 0x1);
+	}

WARNING: braces {} are not necessary for single statement blocks
#4494: FILE: drivers/net/bnx2x.c:4439:
+	for (index = 0; index < HC_TSTORM_DEF_SB_NUM_INDICES; index++) {
+		REG_WR16(bp, BAR_TSTRORM_INTMEM,
+			 TSTORM_DEF_SB_HC_DISABLE_OFFSET(port, index), 0x1);
+	}

WARNING: braces {} are not necessary for single statement blocks
#4512: FILE: drivers/net/bnx2x.c:4457:
+	for (index = 0; index < HC_XSTORM_DEF_SB_NUM_INDICES; index++) {
+		REG_WR16(bp, BAR_XSTRORM_INTMEM,
+			 XSTORM_DEF_SB_HC_DISABLE_OFFSET(port, index), 0x1);
+	}

WARNING: multiple assignments should be avoided
#4566: FILE: drivers/net/bnx2x.c:4511:
+		fp->last_alloc = fp->next_free = 0;

WARNING: multiple assignments should be avoided
#4594: FILE: drivers/net/bnx2x.c:4539:
+		fp->rx_comp_cons = ring_prod = 0;

WARNING: multiple assignments should be avoided
#4606: FILE: drivers/net/bnx2x.c:4551:
+		fp->rx_bd_prod = fp->rx_comp_prod = ring_prod;

WARNING: multiple assignments should be avoided
#4607: FILE: drivers/net/bnx2x.c:4552:
+		fp->rx_pkt = fp->rx_calls = 0;

WARNING: braces {} are not necessary for single statement blocks
#5072: FILE: drivers/net/bnx2x.c:5017:
+		if (val == 0x10) {
+			break;
+		}

WARNING: braces {} are not necessary for single statement blocks
#5088: FILE: drivers/net/bnx2x.c:5033:
+		if (val == 0x1) {
+			break;
+		}

WARNING: braces {} are not necessary for single statement blocks
#5119: FILE: drivers/net/bnx2x.c:5064:
+	for (i = 0; i < 10; i++) {
+		bnx2x_lb_pckt(bp);
+	}

WARNING: braces {} are not necessary for single statement blocks
#5135: FILE: drivers/net/bnx2x.c:5080:
+		if (val == 0xb0) {
+			break;
+		}

WARNING: braces {} are not necessary for single statement blocks
#5149: FILE: drivers/net/bnx2x.c:5094:
+	if (val != 0x2) {
+		BNX2X_ERR("PRS timeout val = 0x%x\n", val);
+	}

WARNING: braces {} are not necessary for single statement blocks
#5161: FILE: drivers/net/bnx2x.c:5106:
+	if (val != 0x3) {
+		BNX2X_ERR("PRS timeout val = 0x%x\n", val);
+	}

WARNING: braces {} are not necessary for single statement blocks
#5165: FILE: drivers/net/bnx2x.c:5110:
+	for (i = 0; i < 11; i++) {
+		REG_RD(bp, GRCBASE_NIG, NIG_REGISTERS_INGRESS_EOP_LB_FIFO);
+	}

WARNING: braces {} are not necessary for single statement blocks
#5394: FILE: drivers/net/bnx2x.c:5339:
+		if (sizeof(union cdu_context) != 1024) {
+			printk(KERN_ALERT PFX "please adjust the size of"
+			       " cdu_context(%ld)\n",
+			       (long)sizeof(union cdu_context));
+		}

WARNING: braces {} are not necessary for single statement blocks
#5415: FILE: drivers/net/bnx2x.c:5360:
+		if (CHIP_REV_IS_SLOW(bp)) {
+			msleep(200);
+		}

WARNING: braces {} are not necessary for single statement blocks
#5713: FILE: drivers/net/bnx2x.c:5658:
+		for (word = 0; word < 8; word++) {
+			data[word] = htonl(REG_RD(bp, GRCBASE_MCP,
+						  MCP_REG_MCPR_SCRATCH +
+						  offset + 4*word));
+		}

WARNING: braces {} are not necessary for single statement blocks
#5741: FILE: drivers/net/bnx2x.c:5686:
+	if (CHIP_REV_IS_SLOW(bp)) {
+		msleep(900);
+	}

WARNING: braces {} are not necessary for single statement blocks
#5909: FILE: drivers/net/bnx2x.c:5854:
+	for (i = 0; i < 16*1024; i += 64) {
+		*(u64 *)((char *)bp->t2 + i + 56) = bp->t2_mapping + i + 64;
+	}

WARNING: braces {} are not necessary for single statement blocks
#6044: FILE: drivers/net/bnx2x.c:5989:
+			if (rc) {
+				return -1;
+			}

WARNING: braces {} are not necessary for single statement blocks
#6056: FILE: drivers/net/bnx2x.c:6001:
+				if (rc) {
+					goto out_irq;
+				}

WARNING: braces {} are not necessary for single statement blocks
#6066: FILE: drivers/net/bnx2x.c:6011:
+		if (rc) {
+			return -1;
+		}

WARNING: braces {} are not necessary for single statement blocks
#6167: FILE: drivers/net/bnx2x.c:6112:
+		if (i++ == 5000) {
+			return -EBUSY;
+		}

WARNING: braces {} are not necessary for single statement blocks
#6213: FILE: drivers/net/bnx2x.c:6158:
+		if (rc) {
+			goto out_error;
+		}

WARNING: braces {} are not necessary for single statement blocks
#6229: FILE: drivers/net/bnx2x.c:6174:
+	if (rc) {
+		goto out_skbs;
+	}

WARNING: braces {} are not necessary for single statement blocks
#6237: FILE: drivers/net/bnx2x.c:6182:
+		if (!rc) {
+			goto int_disable;
+		}

WARNING: braces {} are not necessary for single statement blocks
#6258: FILE: drivers/net/bnx2x.c:6203:
+	if (rc) {
+		goto stop_netif;
+	}

WARNING: braces {} are not necessary for single statement blocks
#6271: FILE: drivers/net/bnx2x.c:6216:
+		if (bp->flags & USING_MSIX_FLAG) {
+			printk(KERN_INFO PFX "%s: using MSI-X\n",
+			       bp->dev->name);
+		}

WARNING: braces {} are not necessary for single statement blocks
#6366: FILE: drivers/net/bnx2x.c:6311:
+	while (bp->stat_pending && (bp->spq_left != MAX_SPQ_PENDING)) {
+		msleep(1);
+	}

WARNING: braces {} are not necessary for single statement blocks
#6404: FILE: drivers/net/bnx2x.c:6349:
+	if (rc) {
+		goto error;
+	}

WARNING: braces {} are not necessary for single statement blocks
#6439: FILE: drivers/net/bnx2x.c:6384:
+	if (!nomcp) {
+		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE);
+	}

WARNING: braces {} are not necessary for single statement blocks
#6580: FILE: drivers/net/bnx2x.c:6525:
+	if (!(bp->speed_cap_mask &
+	      PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_HALF)) {
+		bp->supported &= ~SUPPORTED_10baseT_Half;
+	}

WARNING: braces {} are not necessary for single statement blocks
#6584: FILE: drivers/net/bnx2x.c:6529:
+	if (!(bp->speed_cap_mask &
+	      PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL)) {
+		bp->supported &= ~SUPPORTED_10baseT_Full;
+	}

WARNING: braces {} are not necessary for single statement blocks
#6588: FILE: drivers/net/bnx2x.c:6533:
+	if (!(bp->speed_cap_mask &
+	      PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_HALF)) {
+		bp->supported &= ~SUPPORTED_100baseT_Half;
+	}

WARNING: braces {} are not necessary for single statement blocks
#6592: FILE: drivers/net/bnx2x.c:6537:
+	if (!(bp->speed_cap_mask &
+	      PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_FULL)) {
+		bp->supported &= ~SUPPORTED_100baseT_Full;
+	}

WARNING: braces {} are not necessary for single statement blocks
#6596: FILE: drivers/net/bnx2x.c:6541:
+	if (!(bp->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_1G)) {
+		bp->supported &= ~(SUPPORTED_1000baseT_Half |
+				   SUPPORTED_1000baseT_Full);
+	}

WARNING: braces {} are not necessary for single statement blocks
#6600: FILE: drivers/net/bnx2x.c:6545:
+	if (!(bp->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_2_5G)) {
+		bp->supported &= ~SUPPORTED_2500baseT_Full;
+	}

WARNING: braces {} are not necessary for single statement blocks
#6603: FILE: drivers/net/bnx2x.c:6548:
+	if (!(bp->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)) {
+		bp->supported &= ~SUPPORTED_10000baseT_Full;
+	}

WARNING: braces {} are not necessary for single statement blocks
#6818: FILE: drivers/net/bnx2x.c:6763:
+	if ((val & (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
+		!= (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB)) {
+		BNX2X_ERR("MCP validity signature bad\n");
+	}

WARNING: multiple assignments should be avoided
#6880: FILE: drivers/net/bnx2x.c:6825:
+		bp->bc_ver = val = ((SHMEM_RD(bp, dev_info.bc_rev)) >> 8);

WARNING: braces {} are not necessary for single statement blocks
#6973: FILE: drivers/net/bnx2x.c:6918:
+		if (!(bp->supported & SUPPORTED_TP)) {
+			return -EINVAL;
+		}

WARNING: braces {} are not necessary for single statement blocks
#6984: FILE: drivers/net/bnx2x.c:6929:
+		if (!(bp->supported & SUPPORTED_FIBRE)) {
+			return -EINVAL;
+		}

WARNING: braces {} are not necessary for single statement blocks
#7012: FILE: drivers/net/bnx2x.c:6957:
+				if (!(bp->supported &
+						SUPPORTED_10baseT_Full)) {
+					return -EINVAL;
+				}

WARNING: braces {} are not necessary for single statement blocks
#7019: FILE: drivers/net/bnx2x.c:6964:
+				if (!(bp->supported &
+						SUPPORTED_10baseT_Half)) {
+					return -EINVAL;
+				}

WARNING: braces {} are not necessary for single statement blocks
#7030: FILE: drivers/net/bnx2x.c:6975:
+				if (!(bp->supported &
+						SUPPORTED_100baseT_Full)) {
+					return -EINVAL;
+				}

WARNING: braces {} are not necessary for single statement blocks
#7037: FILE: drivers/net/bnx2x.c:6982:
+				if (!(bp->supported &
+						SUPPORTED_100baseT_Half)) {
+					return -EINVAL;
+				}

WARNING: braces {} are not necessary for single statement blocks
#7047: FILE: drivers/net/bnx2x.c:6992:
+			if (cmd->duplex != DUPLEX_FULL) {
+				return -EINVAL;
+			}

WARNING: braces {} are not necessary for single statement blocks
#7050: FILE: drivers/net/bnx2x.c:6995:
+			if (!(bp->supported & SUPPORTED_1000baseT_Full)) {
+				return -EINVAL;
+			}

WARNING: braces {} are not necessary for single statement blocks
#7058: FILE: drivers/net/bnx2x.c:7003:
+			if (cmd->duplex != DUPLEX_FULL) {
+				return -EINVAL;
+			}

WARNING: braces {} are not necessary for single statement blocks
#7061: FILE: drivers/net/bnx2x.c:7006:
+			if (!(bp->supported & SUPPORTED_2500baseT_Full)) {
+				return -EINVAL;
+			}

WARNING: braces {} are not necessary for single statement blocks
#7069: FILE: drivers/net/bnx2x.c:7014:
+			if (cmd->duplex != DUPLEX_FULL) {
+				return -EINVAL;
+			}

WARNING: braces {} are not necessary for single statement blocks
#7072: FILE: drivers/net/bnx2x.c:7017:
+			if (!(bp->supported & SUPPORTED_10000baseT_Full)) {
+				return -EINVAL;
+			}

WARNING: braces {} are not necessary for single statement blocks
#7202: FILE: drivers/net/bnx2x.c:7147:
+		if (val & (MCPR_NVM_SW_ARB_ARB_ARB1 << port)) {
+			break;
+		}

WARNING: braces {} are not necessary for single statement blocks
#7234: FILE: drivers/net/bnx2x.c:7179:
+		if (!(val & (MCPR_NVM_SW_ARB_ARB_ARB1 << port))) {
+			break;
+		}

WARNING: braces {} are not necessary for single statement blocks
#7345: FILE: drivers/net/bnx2x.c:7290:
+	if (rc) {
+		return rc;
+	}

WARNING: braces {} are not necessary for single statement blocks
#7457: FILE: drivers/net/bnx2x.c:7402:
+	if (rc) {
+		return rc;
+	}

WARNING: braces {} are not necessary for single statement blocks
#7517: FILE: drivers/net/bnx2x.c:7462:
+	if (rc) {
+		return rc;
+	}

WARNING: braces {} are not necessary for single statement blocks
#7603: FILE: drivers/net/bnx2x.c:7548:
+	if (netif_running(bp->dev)) {
+		bnx2x_update_coalesce(bp);
+	}

WARNING: braces {} are not necessary for single statement blocks
#7632: FILE: drivers/net/bnx2x.c:7577:
+	if ((ering->rx_pending > MAX_RX_AVAIL) ||
+	    (ering->tx_pending > MAX_TX_AVAIL) ||
+	    (ering->tx_pending <= MAX_SKB_FRAGS + 4)) {
+
+		return -EINVAL;
+	}

WARNING: braces {} are not necessary for single statement blocks
#7948: FILE: drivers/net/bnx2x.c:7893:
+	if (bp->link_up) {
+		bnx2x_leds_set(bp, bp->line_speed);
+	}

WARNING: braces {} are not necessary for single statement blocks
#8017: FILE: drivers/net/bnx2x.c:7962:
+		if (bp->wol) {
+			pmcsr |= PCI_PM_CTRL_PME_ENABLE;
+		}

WARNING: braces {} are not necessary for single statement blocks
#8049: FILE: drivers/net/bnx2x.c:7994:
+	if (dev->flags & IFF_PROMISC) {
+		rx_mode = BNX2X_RX_MODE_PROMISC;
+
+	} else if (dev->flags & IFF_ALLMULTI ||

WARNING: braces {} are not necessary for single statement blocks
#8135: FILE: drivers/net/bnx2x.c:8080:
+	if (*fp->tx_cons_sb != fp->tx_pkt_cons) {
+		bnx2x_tx_int(fp, budget);
+	}

WARNING: braces {} are not necessary for single statement blocks
#8139: FILE: drivers/net/bnx2x.c:8084:
+	if (*fp->rx_cons_sb != fp->rx_comp_cons) {
+		work_done = bnx2x_rx_int(fp, budget);
+	}

WARNING: braces {} are not necessary for single statement blocks
#8173: FILE: drivers/net/bnx2x.c:8118:
+	if (unlikely(bp->panic)) {
+		return NETDEV_TX_BUSY;
+	}

WARNING: braces {} are not necessary for single statement blocks
#8267: FILE: drivers/net/bnx2x.c:8212:
+	else {
+		txbd->vlan = pkt_prod;
+	}

WARNING: multiple assignments should be avoided
#8277: FILE: drivers/net/bnx2x.c:8222:
+	txbd->nbd = nbd = skb_shinfo(skb)->nr_frags + ((pbd == NULL)? 1 : 2);

WARNING: braces {} are not necessary for single statement blocks
#8398: FILE: drivers/net/bnx2x.c:8343:
+	if (pbd) {
+		DP(NETIF_MSG_TX_QUEUED,
+		   "PBD @%p  ip_data %x  ip_hlen %u  ip_id %u  lso_mss %u"
+		   "  tcp_flags %x  xsum %x  seq %u  hlen %u\n",
+		   pbd, pbd->global_data, pbd->ip_hlen, pbd->ip_id,
+		   pbd->lso_mss, pbd->tcp_flags, pbd->tcp_pseudo_csum,
+		   pbd->tcp_send_seq, pbd->total_hlen);
+	}

WARNING: braces {} are not necessary for single statement blocks
#8507: FILE: drivers/net/bnx2x.c:8452:
+		if (!capable(CAP_NET_ADMIN)) {
+			return -EPERM;
+		}

WARNING: braces {} are not necessary for single statement blocks
#8556: FILE: drivers/net/bnx2x.c:8501:
+	if (!bp->panic) {
+		bnx2x_panic();
+	}

WARNING: multiple assignments should be avoided
#8696: FILE: drivers/net/bnx2x.c:8641:
+	dev->base_addr = dev->mem_start = pci_resource_start(pdev, 0);

WARNING: braces {} are not necessary for single statement blocks
#8921: FILE: drivers/net/bnx2x.c:8866:
+	if (!rc) {
+		return rc;
+	}

WARNING: braces {} are not necessary for single statement blocks
#8945: FILE: drivers/net/bnx2x.c:8890:
+	if (rc) {
+		return rc;
+	}

CHECK: spinlock_t definition without comment
#9486: FILE: drivers/net/bnx2x.h:508:
+	spinlock_t		spq_lock;  /* Used to serialize slowpath

ERROR: need a space before the open brace '{'
#9824: FILE: drivers/net/bnx2x.h:846:
+	do{ \

ERROR: need consistent spacing around '+' (ctx:VxW)
#19015: FILE: drivers/net/bnx2x_hsi.h:4129:
+#define GENERAL_ATTEN_WORD(atten_name) ((94+ atten_name) / 32)
                                            ^

ERROR: no space before that close parenthesis ')'
#19016: FILE: drivers/net/bnx2x_hsi.h:4130:
+#define GENERAL_ATTEN_OFFSET(atten_name) (1 << ((94 + atten_name) % 32 ))

ERROR: trailing whitespace
#21068: FILE: drivers/net/bnx2x_init.h:10:
+ */         $

ERROR: Macros with complex values should be enclosed in parenthesis
#21196: FILE: drivers/net/bnx2x_init.h:138:
+#define INIT_INTERNAL0_MEM_WR(block_bar, block, reg, \
+			      part, hw, value, off, len) \

WARNING: braces {} are not necessary for single statement blocks
#21307: FILE: drivers/net/bnx2x_init.h:249:
+	for (i = 0; i < 4; i++) {
+		DMAE_CLR(bp, storms[i], 0UL, STORM_INTMEM_SIZE / 4);
+	}

ERROR: need a space after that close brace '}'
#21329: FILE: drivers/net/bnx2x_init.h:271:
+	{{ 8 , 64 , 25}, { 16 , 64 , 25}, { 32 , 64 , 25}, { 64 , 64 , 41}},

ERROR: need a space after that close brace '}'
#21330: FILE: drivers/net/bnx2x_init.h:272:
+	{{ 4 , 8 , 4},   { 4 , 8 , 4},    { 4 , 8 , 4},    { 4 , 8 , 4}},

ERROR: need a space after that close brace '}'
#21331: FILE: drivers/net/bnx2x_init.h:273:
+	{{ 4 , 3 , 3},   { 4 , 3 , 3},    { 4 , 3 , 3},    { 4 , 3 , 3}},

ERROR: need a space after that close brace '}'
#21332: FILE: drivers/net/bnx2x_init.h:274:
+	{{ 8 , 3 , 6},   { 16 , 3 , 11},  { 16 , 3 , 11},  { 16 , 3 , 11}},

ERROR: need a space after that close brace '}'
#21333: FILE: drivers/net/bnx2x_init.h:275:
+	{{ 8 , 64 , 25}, { 16 , 64 , 25}, { 32 , 64 , 25}, { 64 , 64 , 41}},

ERROR: need a space after that close brace '}'
#21334: FILE: drivers/net/bnx2x_init.h:276:
+	{{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 64 , 3 , 41}},

ERROR: need a space after that close brace '}'
#21335: FILE: drivers/net/bnx2x_init.h:277:
+	{{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 64 , 3 , 41}},

ERROR: need a space after that close brace '}'
#21336: FILE: drivers/net/bnx2x_init.h:278:
+	{{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 64 , 3 , 41}},

ERROR: need a space after that close brace '}'
#21337: FILE: drivers/net/bnx2x_init.h:279:
+	{{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 64 , 3 , 41}},

ERROR: need a space after that close brace '}'
#21338: FILE: drivers/net/bnx2x_init.h:280:
+	{{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},

ERROR: need a space after that close brace '}'
#21339: FILE: drivers/net/bnx2x_init.h:281:
+	{{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},

ERROR: need a space after that close brace '}'
#21340: FILE: drivers/net/bnx2x_init.h:282:
+	{{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},

ERROR: need a space after that close brace '}'
#21341: FILE: drivers/net/bnx2x_init.h:283:
+	{{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},

ERROR: need a space after that close brace '}'
#21342: FILE: drivers/net/bnx2x_init.h:284:
+	{{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},

ERROR: need a space after that close brace '}'
#21343: FILE: drivers/net/bnx2x_init.h:285:
+	{{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},

ERROR: need a space after that close brace '}'
#21344: FILE: drivers/net/bnx2x_init.h:286:
+	{{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},

ERROR: need a space after that close brace '}'
#21345: FILE: drivers/net/bnx2x_init.h:287:
+	{{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},

ERROR: need a space after that close brace '}'
#21346: FILE: drivers/net/bnx2x_init.h:288:
+	{{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},

ERROR: need a space after that close brace '}'
#21347: FILE: drivers/net/bnx2x_init.h:289:
+	{{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},

ERROR: need a space after that close brace '}'
#21348: FILE: drivers/net/bnx2x_init.h:290:
+	{{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},

ERROR: need a space after that close brace '}'
#21349: FILE: drivers/net/bnx2x_init.h:291:
+	{{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},

ERROR: need a space after that close brace '}'
#21350: FILE: drivers/net/bnx2x_init.h:292:
+	{{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},

ERROR: need a space after that close brace '}'
#21351: FILE: drivers/net/bnx2x_init.h:293:
+	{{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},

ERROR: need a space after that close brace '}'
#21352: FILE: drivers/net/bnx2x_init.h:294:
+	{{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},

ERROR: need a space after that close brace '}'
#21353: FILE: drivers/net/bnx2x_init.h:295:
+	{{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},

ERROR: need a space after that close brace '}'
#21354: FILE: drivers/net/bnx2x_init.h:296:
+	{{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},

ERROR: need a space after that close brace '}'
#21355: FILE: drivers/net/bnx2x_init.h:297:
+	{{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},

ERROR: need a space after that close brace '}'
#21356: FILE: drivers/net/bnx2x_init.h:298:
+	{{ 8 , 3 , 6},   { 16 , 3 , 11},  { 32 , 3 , 21},  { 32 , 3 , 21}},

ERROR: need a space after that close brace '}'
#21357: FILE: drivers/net/bnx2x_init.h:299:
+	{{ 8 , 64 , 25}, { 16 , 64 , 41}, { 32 , 64 , 81}, { 64 , 64 , 120}}};

ERROR: need a space after that close brace '}'
#21360: FILE: drivers/net/bnx2x_init.h:302:
+	{{ 4 , 6 , 3},   { 4 , 6 , 3},    { 4 , 6 , 3}},

ERROR: need a space after that close brace '}'
#21361: FILE: drivers/net/bnx2x_init.h:303:
+	{{ 4 , 2 , 3},   { 4 , 2 , 3},    { 4 , 2 , 3}},

ERROR: need a space after that close brace '}'
#21362: FILE: drivers/net/bnx2x_init.h:304:
+	{{ 8 , 2 , 6},   { 16 , 2 , 11},  { 16 , 2 , 11}},

ERROR: need a space after that close brace '}'
#21363: FILE: drivers/net/bnx2x_init.h:305:
+	{{ 8 , 2 , 6},   { 16 , 2 , 11},  { 32 , 2 , 21}},

ERROR: need a space after that close brace '}'
#21364: FILE: drivers/net/bnx2x_init.h:306:
+	{{ 8 , 2 , 6},   { 16 , 2 , 11},  { 32 , 2 , 21}},

ERROR: need a space after that close brace '}'
#21365: FILE: drivers/net/bnx2x_init.h:307:
+	{{ 8 , 2 , 6},   { 16 , 2 , 11},  { 32 , 2 , 21}},

ERROR: need a space after that close brace '}'
#21366: FILE: drivers/net/bnx2x_init.h:308:
+	{{ 8 , 64 , 25}, { 16 , 64 , 25}, { 32 , 64 , 25}},

ERROR: need a space after that close brace '}'
#21367: FILE: drivers/net/bnx2x_init.h:309:
+	{{ 8 , 2 , 6},   { 16 , 2 , 11},  { 16 , 2 , 11}},

ERROR: need a space after that close brace '}'
#21368: FILE: drivers/net/bnx2x_init.h:310:
+	{{ 8 , 2 , 6},   { 16 , 2 , 11},  { 16 , 2 , 11}},

ERROR: need a space after that close brace '}'
#21369: FILE: drivers/net/bnx2x_init.h:311:
+	{{ 8 , 9 , 6},   { 16 , 9 , 11},  { 32 , 9 , 21}},

ERROR: need a space after that close brace '}'
#21370: FILE: drivers/net/bnx2x_init.h:312:
+	{{ 8 , 47 , 19}, { 16 , 47 , 19}, { 32 , 47 , 21}},

ERROR: need a space after that close brace '}'
#21371: FILE: drivers/net/bnx2x_init.h:313:
+	{{ 8 , 9 , 6},   { 16 , 9 , 11},  { 16 , 9 , 11}},

ERROR: need a space after that close brace '}'
#21372: FILE: drivers/net/bnx2x_init.h:314:
+	{{ 8 , 64 , 25}, { 16 , 64 , 41}, { 32 , 64 , 81}}};

ERROR: need a space after that close brace '}'
#21430: FILE: drivers/net/bnx2x_init.h:372:
+		PXP2_REGISTERS_PSWRQ_BW_UB28}};

ERROR: need a space after that close brace '}'
#21456: FILE: drivers/net/bnx2x_init.h:398:
+		PXP2_REGISTERS_RQ_BW_WR_UBOUND30}};

ERROR: no space before that close parenthesis ')'
#21573: FILE: drivers/net/bnx2x_init.h:515:
+	for (i = 0; i < 8; i++ ) {

WARNING: braces {} are not necessary for single statement blocks
#21604: FILE: drivers/net/bnx2x_init.h:546:
+	for (i = 0; i < 8; i++) {
+		crc_res |= (NewCRC[i] << i);
+	}

Your patch has style problems, please review.  If any of these errors
are false positives report them to the maintainer, see
CHECKPATCH in MAINTAINERS.
