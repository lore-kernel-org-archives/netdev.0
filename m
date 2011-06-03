From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 2/3] drivers/net: Remove unnecessary semicolons
Date: Fri,  3 Jun 2011 14:51:20 -0700
Message-ID: <ea04a5a9d2afa887383d26d8024a8665903317e9.1307137352.git.joe@perches.com>
References: <cover.1307137351.git.joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2501 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754247Ab1FCVvW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jun 2011 17:51:22 -0400
Received: from Joe-Laptop.home (unknown [192.168.1.162])
	by mail.perches.com (Postfix) with ESMTP id B460A2436C
	for <netdev@vger.kernel.org>; Fri,  3 Jun 2011 14:51:19 -0700 (PDT)
In-Reply-To: <cover.1307137351.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Semicolons are not necessary after switch/while/for/if braces
so remove them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/amd8111e.c                  |    2 +-
 drivers/net/cxgb4/cxgb4_main.c          |    2 +-
 drivers/net/enic/enic_main.c            |    2 +-
 drivers/net/irda/via-ircc.h             |    2 +-
 drivers/net/iseries_veth.c              |    4 ++--
 drivers/net/ixgbe/ixgbe_82599.c         |    4 ++--
 drivers/net/ixgbe/ixgbe_common.c        |    4 ++--
 drivers/net/myri10ge/myri10ge.c         |    2 +-
 drivers/net/netxen/netxen_nic_init.c    |    2 +-
 drivers/net/ps3_gelic_net.c             |    2 +-
 drivers/net/slhc.c                      |    2 +-
 drivers/net/sungem.c                    |    2 +-
 drivers/net/tokenring/3c359.c           |    6 ++++--
 drivers/net/tokenring/ibmtr.c           |    2 +-
 drivers/net/tun.c                       |    2 +-
 drivers/net/via-velocity.c              |    2 +-
 drivers/net/wireless/b43/main.c         |    2 +-
 drivers/net/wireless/b43legacy/main.c   |    2 +-
 drivers/net/wireless/iwmc3200wifi/fw.c  |    2 +-
 drivers/net/wireless/orinoco/main.c     |    2 +-
 drivers/net/wireless/rt2x00/rt2800lib.c |    2 +-
 drivers/net/wireless/rt2x00/rt2800pci.c |    2 +-
 drivers/net/znet.c                      |    2 +-
 23 files changed, 29 insertions(+), 27 deletions(-)

diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index 241b185..81475ea 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -1958,7 +1958,7 @@ static int __devinit amd8111e_probe_one(struct pci_dev *pdev,
 						 IPG_CONVERGE_JIFFIES;
 		lp->ipg_data.ipg = DEFAULT_IPG;
 		lp->ipg_data.ipg_state = CSTATE;
-	};
+	}
 
 	/*  display driver and device information */
 
diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 7e3cfbe..c9957b7 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -3704,7 +3704,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 	if (err) {
 		dev_warn(&pdev->dev, "only %d net devices registered\n", i);
 		err = 0;
-	};
+	}
 
 	if (cxgb4_debugfs_root) {
 		adapter->debugfs_root = debugfs_create_dir(pci_name(pdev),
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 2f433fb..5b087eb 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1560,7 +1560,7 @@ static void enic_notify_timer_start(struct enic *enic)
 	default:
 		/* Using intr for notification for INTx/MSI-X */
 		break;
-	};
+	}
 }
 
 /* rtnl lock is held, process context */
diff --git a/drivers/net/irda/via-ircc.h b/drivers/net/irda/via-ircc.h
index c6f5848..f903a6a 100644
--- a/drivers/net/irda/via-ircc.h
+++ b/drivers/net/irda/via-ircc.h
@@ -210,7 +210,7 @@ static void DisableDmaChannel(unsigned int channel)
 		break;
 	default:
 		break;
-	};			//Switch
+	}
 }
 
 static unsigned char ReadLPCReg(int iRegNum)
diff --git a/drivers/net/iseries_veth.c b/drivers/net/iseries_veth.c
index 9ece1fd..b6c296f 100644
--- a/drivers/net/iseries_veth.c
+++ b/drivers/net/iseries_veth.c
@@ -538,7 +538,7 @@ static void veth_handle_ack(struct veth_lpevent *event)
 	default:
 		veth_error("Unknown ack type %d from LPAR %d.\n",
 				event->base_event.xSubtype, rlp);
-	};
+	}
 }
 
 static void veth_handle_int(struct veth_lpevent *event)
@@ -584,7 +584,7 @@ static void veth_handle_int(struct veth_lpevent *event)
 	default:
 		veth_error("Unknown interrupt type %d from LPAR %d.\n",
 				event->base_event.xSubtype, rlp);
-	};
+	}
 }
 
 static void veth_handle_event(struct HvLpEvent *event)
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 8ee6612..0d7bc91 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -1157,7 +1157,7 @@ s32 ixgbe_init_fdir_signature_82599(struct ixgbe_hw *hw, u32 pballoc)
 	default:
 		/* bad value */
 		return IXGBE_ERR_CONFIG;
-	};
+	}
 
 	/* Move the flexible bytes to use the ethertype - shift 6 words */
 	fdirctrl |= (0x6 << IXGBE_FDIRCTRL_FLEX_SHIFT);
@@ -1245,7 +1245,7 @@ s32 ixgbe_init_fdir_perfect_82599(struct ixgbe_hw *hw, u32 pballoc)
 	default:
 		/* bad value */
 		return IXGBE_ERR_CONFIG;
-	};
+	}
 
 	/* Turn perfect match filtering on */
 	fdirctrl |= IXGBE_FDIRCTRL_PERFECT_MATCH;
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index b894b42..de65643 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1292,7 +1292,7 @@ static s32 ixgbe_ready_eeprom(struct ixgbe_hw *hw)
 
 		udelay(5);
 		ixgbe_standby_eeprom(hw);
-	};
+	}
 
 	/*
 	 * On some parts, SPI write time could vary from 0-20mSec on 3.3V
@@ -1374,7 +1374,7 @@ static void ixgbe_shift_out_eeprom_bits(struct ixgbe_hw *hw, u16 data,
 		 * EEPROM
 		 */
 		mask = mask >> 1;
-	};
+	}
 
 	/* We leave the "DI" bit set to "0" when we leave this routine. */
 	eec &= ~IXGBE_EEC_DI;
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index bf84849..3f33870 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1013,7 +1013,7 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 		cmd.data2 = i;
 		status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_INTRQ_DMA,
 					    &cmd, 0);
-	};
+	}
 
 	status |=
 	    myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_IRQ_ACK_OFFSET, &cmd, 0);
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 7f99967..ca59b4f 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1279,7 +1279,7 @@ void netxen_free_dummy_dma(struct netxen_adapter *adapter)
 
 			if (--i == 0)
 				break;
-		};
+		}
 	}
 
 	if (i) {
diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ps3_gelic_net.c
index b1f251d..d47abb4 100644
--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -1009,7 +1009,7 @@ static int gelic_card_decode_one_descr(struct gelic_card *card)
 				netdev = card->netdev[i];
 				break;
 			}
-		};
+		}
 		if (GELIC_PORT_MAX <= i) {
 			pr_info("%s: unknown packet vid=%x\n", __func__, vid);
 			goto refill;
diff --git a/drivers/net/slhc.c b/drivers/net/slhc.c
index ab9e3b7..0a0a664 100644
--- a/drivers/net/slhc.c
+++ b/drivers/net/slhc.c
@@ -297,7 +297,7 @@ slhc_compress(struct slcompress *comp, unsigned char *icp, int isize,
 		lcs = cs;
 		cs = cs->next;
 		comp->sls_o_searches++;
-	};
+	}
 	/*
 	 * Didn't find it -- re-use oldest cstate.  Send an
 	 * uncompressed packet that tells the other side what
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index f0bcbe4..71d4a03 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -2716,7 +2716,7 @@ static int gem_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			    data->val_in);
 		rc = 0;
 		break;
-	};
+	}
 	return rc;
 }
 
diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index ff32bef..b6162fe 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -304,7 +304,7 @@ static int __devinit xl_probe(struct pci_dev *pdev,
 
 	if ((i = pci_request_regions(pdev,"3c359"))) { 
 		return i ; 
-	} ; 
+	}
 
 	/* 
 	 * Allowing init_trdev to allocate the private data will align
@@ -1773,7 +1773,9 @@ static void xl_wait_misr_flags(struct net_device *dev)
 	if (readb(xl_mmio + MMIO_MACDATA) != 0) {  /* Misr not clear */
 		for (i=0; i<6; i++) { 
 			writel(MEM_BYTE_READ | 0xDFFE0 | i, xl_mmio + MMIO_MAC_ACCESS_CMD) ; 
-			while (readb(xl_mmio + MMIO_MACDATA) != 0 ) {} ; /* Empty Loop */
+			while (readb(xl_mmio + MMIO_MACDATA) != 0) {
+				;	/* Empty Loop */
+			}
 		} 
 	}
 
diff --git a/drivers/net/tokenring/ibmtr.c b/drivers/net/tokenring/ibmtr.c
index 4786497..e896ad0 100644
--- a/drivers/net/tokenring/ibmtr.c
+++ b/drivers/net/tokenring/ibmtr.c
@@ -177,7 +177,7 @@ static char __devinit *adapter_def(char type)
 	case 0xD: return "16/4 Adapter/A (short) | 16/4 ISA-16 Adapter";
 	case 0xC: return "Auto 16/4 Adapter";
 	default: return "adapter (unknown type)";
-	};
+	}
 };
 
 #define TRC_INIT 0x01		/*  Trace initialization & PROBEs */
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 74e9405..8a27cbf 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -666,7 +666,7 @@ static __inline__ ssize_t tun_get_user(struct tun_struct *tun,
 	case TUN_TAP_DEV:
 		skb->protocol = eth_type_trans(skb, tun->dev);
 		break;
-	};
+	}
 
 	if (gso.gso_type != VIRTIO_NET_HDR_GSO_NONE) {
 		pr_debug("GSO!\n");
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 06daa9d..f929242 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1887,7 +1887,7 @@ static void velocity_error(struct velocity_info *vptr, int status)
 		else
 			netif_wake_queue(vptr->dev);
 
-	};
+	}
 	if (status & ISR_MIBFI)
 		velocity_update_hw_mibs(vptr);
 	if (status & ISR_LSTEI)
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index eb41596..d74bc5f 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -4085,7 +4085,7 @@ static int b43_phy_versioning(struct b43_wldev *dev)
 #endif
 	default:
 		unsupported = 1;
-	};
+	}
 	if (unsupported) {
 		b43err(dev->wl, "FOUND UNSUPPORTED PHY "
 		       "(Analog %u, Type %u, Revision %u)\n",
diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/b43legacy/main.c
index 1ab8861..60107b8 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -2974,7 +2974,7 @@ static int b43legacy_phy_versioning(struct b43legacy_wldev *dev)
 		break;
 	default:
 		unsupported = 1;
-	};
+	}
 	if (unsupported) {
 		b43legacyerr(dev->wl, "FOUND UNSUPPORTED PHY "
 		       "(Analog %u, Type %u, Revision %u)\n",
diff --git a/drivers/net/wireless/iwmc3200wifi/fw.c b/drivers/net/wireless/iwmc3200wifi/fw.c
index 4906709..6f1afe6 100644
--- a/drivers/net/wireless/iwmc3200wifi/fw.c
+++ b/drivers/net/wireless/iwmc3200wifi/fw.c
@@ -187,7 +187,7 @@ static int iwm_load_img(struct iwm_priv *iwm, const char *img_name)
 		if (ret < 0)
 			goto err_release_fw;
 		opcode_idx++;
-	};
+	}
 
 	/* Read firmware version */
 	fw_offset = iwm_fw_op_offset(iwm, fw, IWM_HDR_REC_OP_SW_VER, 0);
diff --git a/drivers/net/wireless/orinoco/main.c b/drivers/net/wireless/orinoco/main.c
index 62c6b2b..b0f233f 100644
--- a/drivers/net/wireless/orinoco/main.c
+++ b/drivers/net/wireless/orinoco/main.c
@@ -1958,7 +1958,7 @@ irqreturn_t orinoco_interrupt(int irq, void *dev_id)
 
 		evstat = hermes_read_regn(hw, EVSTAT);
 		events = evstat & hw->inten;
-	};
+	}
 
 	orinoco_unlock(priv, &flags);
 	return IRQ_HANDLED;
diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless/rt2x00/rt2800lib.c
index 2a6aa85..8f92dfc 100644
--- a/drivers/net/wireless/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/rt2x00/rt2800lib.c
@@ -1355,7 +1355,7 @@ static void rt2800_config_ht_opmode(struct rt2x00_dev *rt2x00dev,
 			gf20_rate = gf40_rate = 0x0003;
 		}
 		break;
-	};
+	}
 
 	/* check for STAs not supporting greenfield mode */
 	if (any_sta_nongf)
diff --git a/drivers/net/wireless/rt2x00/rt2800pci.c b/drivers/net/wireless/rt2x00/rt2800pci.c
index cc4a54f..3ac0943 100644
--- a/drivers/net/wireless/rt2x00/rt2800pci.c
+++ b/drivers/net/wireless/rt2x00/rt2800pci.c
@@ -219,7 +219,7 @@ static void rt2800pci_start_queue(struct data_queue *queue)
 		break;
 	default:
 		break;
-	};
+	}
 }
 
 static void rt2800pci_kick_queue(struct data_queue *queue)
diff --git a/drivers/net/znet.c b/drivers/net/znet.c
index ec2800f..8b88817 100644
--- a/drivers/net/znet.c
+++ b/drivers/net/znet.c
@@ -731,7 +731,7 @@ static void znet_rx(struct net_device *dev)
 		cur_frame_end_offset -= ((count + 1)>>1) + 3;
 		if (cur_frame_end_offset < 0)
 		  cur_frame_end_offset += RX_BUF_SIZE/2;
-	};
+	}
 
 	/* Now step  forward through the list. */
 	do {
-- 
1.7.5.rc3.dirty

