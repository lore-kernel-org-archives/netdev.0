From: Joe Perches <joe@perches.com>
Subject: [PATCH net/next] drivers/net: remove useless semicolons
Date: Fri, 14 May 2010 01:05:12 -0700
Message-ID: <1273824312.1583.47.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2240 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754262Ab0ENIFO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 May 2010 04:05:14 -0400
Received: from [192.168.1.151] (new-host-5.home [192.168.1.151])
	by mail.perches.com (Postfix) with ESMTP id A545F24368
	for <netdev@vger.kernel.org>; Fri, 14 May 2010 01:05:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

switch and while statements don't need semicolons at end of statement

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/cassini.c                         |    2 +-
 drivers/net/ehea/ehea_main.c                  |    6 +++---
 drivers/net/eql.c                             |    2 +-
 drivers/net/irda/via-ircc.h                   |    2 +-
 drivers/net/jme.c                             |    2 +-
 drivers/net/lib82596.c                        |    2 +-
 drivers/net/mlx4/eq.c                         |    2 +-
 drivers/net/myri_sbus.c                       |    2 +-
 drivers/net/pppoe.c                           |    2 +-
 drivers/net/ps3_gelic_wireless.c              |    4 ++--
 drivers/net/skfp/smt.c                        |    2 +-
 drivers/net/slip.c                            |    2 +-
 drivers/net/sunbmac.c                         |    4 ++--
 drivers/net/sunhme.c                          |    6 +++---
 drivers/net/sunlance.c                        |    2 +-
 drivers/net/tun.c                             |    2 +-
 drivers/net/wimax/i2400m/control.c            |    8 ++++----
 drivers/net/wireless/ath/ath9k/init.c         |    2 +-
 drivers/net/wireless/hostap/hostap_ap.c       |    2 +-
 drivers/net/wireless/hostap/hostap_download.c |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c    |    2 +-
 drivers/net/wireless/prism54/islpci_dev.c     |    2 +-
 drivers/net/wireless/rt2x00/rt2x00firmware.c  |    2 +-
 23 files changed, 32 insertions(+), 32 deletions(-)

diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 6d76236..04a03f7 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -4824,7 +4824,7 @@ static int cas_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		break;
 	default:
 		break;
-	};
+	}
 
 	mutex_unlock(&cp->pm_mutex);
 	return rc;
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 33a41e2..dd6e434 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -820,7 +820,7 @@ static struct ehea_cqe *ehea_proc_cqes(struct ehea_port_res *pr, int my_quota)
 		quota--;
 
 		cqe = ehea_poll_cq(send_cq);
-	};
+	}
 
 	ehea_update_feca(send_cq, cqe_counter);
 	atomic_add(swqe_av, &pr->swqe_avail);
@@ -3257,7 +3257,7 @@ static int ehea_setup_ports(struct ehea_adapter *adapter)
 			ehea_remove_adapter_mr(adapter);
 
 		i++;
-	};
+	}
 	return 0;
 }
 
@@ -3276,7 +3276,7 @@ static struct device_node *ehea_get_eth_dn(struct ehea_adapter *adapter,
 		if (dn_log_port_id)
 			if (*dn_log_port_id == logical_port_id)
 				return eth_dn;
-	};
+	}
 
 	return NULL;
 }
diff --git a/drivers/net/eql.c b/drivers/net/eql.c
index b34a2dd..dda2c79 100644
--- a/drivers/net/eql.c
+++ b/drivers/net/eql.c
@@ -288,7 +288,7 @@ static int eql_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			return eql_s_master_cfg(dev, ifr->ifr_data);
 		default:
 			return -EOPNOTSUPP;
-	};
+	}
 }
 
 /* queue->lock must be held */
diff --git a/drivers/net/irda/via-ircc.h b/drivers/net/irda/via-ircc.h
index d9d1db0..5a84822 100644
--- a/drivers/net/irda/via-ircc.h
+++ b/drivers/net/irda/via-ircc.h
@@ -774,7 +774,7 @@ static void SetBaudRate(__u16 iobase, __u32 rate)
 			break;
 		default:
 			break;
-		};
+		}
 	} else if (IsMIROn(iobase)) {
 		value = 0;	// will automatically be fixed in 1.152M
 	} else if (IsFIROn(iobase)) {
diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 4e868ee..a86577b 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -2839,7 +2839,7 @@ jme_init_one(struct pci_dev *pdev,
 	default:
 		jme->reg_txcs = TXCS_DEFAULT | TXCS_DMASIZE_512B;
 		break;
-	};
+	}
 
 	/*
 	 * Must check before reset_mac_processor
diff --git a/drivers/net/lib82596.c b/drivers/net/lib82596.c
index de856d8..ce5d6e9 100644
--- a/drivers/net/lib82596.c
+++ b/drivers/net/lib82596.c
@@ -1091,7 +1091,7 @@ static int __devinit i82596_probe(struct net_device *dev)
 		DMA_FREE(dev->dev.parent, sizeof(struct i596_dma),
 				    (void *)dma, lp->dma_addr);
 		return i;
-	};
+	}
 
 	DEB(DEB_PROBE, printk(KERN_INFO "%s: 82596 at %#3lx, %pM IRQ %d.\n",
 			      dev->name, dev->base_addr, dev->dev_addr,
diff --git a/drivers/net/mlx4/eq.c b/drivers/net/mlx4/eq.c
index 7365bf4..4230534 100644
--- a/drivers/net/mlx4/eq.c
+++ b/drivers/net/mlx4/eq.c
@@ -239,7 +239,7 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
 			mlx4_warn(dev, "Unhandled event %02x(%02x) on EQ %d at index %u\n",
 				  eqe->type, eqe->subtype, eq->eqn, eq->cons_index);
 			break;
-		};
+		}
 
 		++eq->cons_index;
 		eqes_found = 1;
diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index b72e749..3898108 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -865,7 +865,7 @@ static inline void determine_reg_space_size(struct myri_eth *mp)
 		printk("myricom: AIEEE weird cpu version %04x assuming pre4.0\n",
 		       mp->eeprom.cpuvers);
 		mp->reg_size = (3 * 128 * 1024) + 4096;
-	};
+	}
 }
 
 #ifdef DEBUG_DETECT
diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index 99f031a..03fd582 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -362,7 +362,7 @@ static int pppoe_device_event(struct notifier_block *this,
 
 	default:
 		break;
-	};
+	}
 
 	return NOTIFY_DONE;
 }
diff --git a/drivers/net/ps3_gelic_wireless.c b/drivers/net/ps3_gelic_wireless.c
index d4ff627..313ec5f 100644
--- a/drivers/net/ps3_gelic_wireless.c
+++ b/drivers/net/ps3_gelic_wireless.c
@@ -897,7 +897,7 @@ static int gelic_wl_set_auth(struct net_device *netdev,
 	default:
 		ret = -EOPNOTSUPP;
 		break;
-	};
+	}
 
 	if (!ret)
 		set_bit(GELIC_WL_STAT_CONFIGURED, &wl->stat);
@@ -1992,7 +1992,7 @@ static int gelic_wl_associate_bss(struct gelic_wl_info *wl,
 	case GELIC_WL_WPA_LEVEL_WPA2:
 		ret = gelic_wl_do_wpa_setup(wl);
 		break;
-	};
+	}
 
 	if (ret) {
 		pr_debug("%s: WEP/WPA setup failed %d\n", __func__,
diff --git a/drivers/net/skfp/smt.c b/drivers/net/skfp/smt.c
index 83d16fe..6f35bb7 100644
--- a/drivers/net/skfp/smt.c
+++ b/drivers/net/skfp/smt.c
@@ -574,7 +574,7 @@ void smt_received_pack(struct s_smc *smc, SMbuf *mb, int fs)
 		if (smt_check_para(smc,sm,plist_nif)) {
 			DB_SMT("SMT: NIF with para problem, ignoring\n",0,0) ;
 			break ;
-		} ;
+		}
 		switch (sm->smt_type) {
 		case SMT_ANNOUNCE :
 		case SMT_REQUEST :
diff --git a/drivers/net/slip.c b/drivers/net/slip.c
index d92772e..fa434fb 100644
--- a/drivers/net/slip.c
+++ b/drivers/net/slip.c
@@ -1269,7 +1269,7 @@ static int sl_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 	case SIOCGLEASE:
 		*p = sl->leased;
-	};
+	}
 	spin_unlock_bh(&sl->lock);
 	return 0;
 }
diff --git a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
index 34446b6..4591fe9 100644
--- a/drivers/net/sunbmac.c
+++ b/drivers/net/sunbmac.c
@@ -362,7 +362,7 @@ static void bigmac_tcvr_write(struct bigmac *bp, void __iomem *tregs,
 	default:
 		printk(KERN_ERR "bigmac_tcvr_read: Whoops, no known transceiver type.\n");
 		return;
-	};
+	}
 
 	idle_transceiver(tregs);
 	write_tcvr_bit(bp, tregs, 0);
@@ -401,7 +401,7 @@ static unsigned short bigmac_tcvr_read(struct bigmac *bp,
 	default:
 		printk(KERN_ERR "bigmac_tcvr_read: Whoops, no known transceiver type.\n");
 		return 0xffff;
-	};
+	}
 
 	idle_transceiver(tregs);
 	write_tcvr_bit(bp, tregs, 0);
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index 377c0b5..13ee79c 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -855,7 +855,7 @@ static void happy_meal_timer(unsigned long data)
 		hp->timer_ticks = 0;
 		hp->timer_state = asleep; /* foo on you */
 		break;
-	};
+	}
 
 	if (restart_timer) {
 		hp->happy_timer.expires = jiffies + ((12 * HZ)/10); /* 1.2 sec. */
@@ -1488,7 +1488,7 @@ static int happy_meal_init(struct happy_meal *hp)
 		HMD(("external, disable MII, "));
 		hme_write32(hp, bregs + BMAC_XIFCFG, BIGMAC_XCFG_MIIDISAB);
 		break;
-	};
+	}
 
 	if (happy_meal_tcvr_reset(hp, tregs))
 		return -EAGAIN;
@@ -1734,7 +1734,7 @@ static void happy_meal_set_initial_advertisement(struct happy_meal *hp)
 	case external:
 		hme_write32(hp, bregs + BMAC_XIFCFG, BIGMAC_XCFG_MIIDISAB);
 		break;
-	};
+	}
 	if (happy_meal_tcvr_reset(hp, tregs))
 		return;
 
diff --git a/drivers/net/sunlance.c b/drivers/net/sunlance.c
index f88a60f..386af7b 100644
--- a/drivers/net/sunlance.c
+++ b/drivers/net/sunlance.c
@@ -1054,7 +1054,7 @@ static void lance_piocopy_from_skb(void __iomem *dest, unsigned char *src, int l
 		}
 		src = (char *) p16;
 		break;
-	};
+	}
 	if (len >= 2) {
 		u16 val = src[0] << 8 | src[1];
 		sbus_writew(val, piobuf);
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index dbdfb1f..bbb7864 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1368,7 +1368,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 	default:
 		ret = -EINVAL;
 		break;
-	};
+	}
 
 unlock:
 	rtnl_unlock();
diff --git a/drivers/net/wimax/i2400m/control.c b/drivers/net/wimax/i2400m/control.c
index 6180772..7fcdd4b 100644
--- a/drivers/net/wimax/i2400m/control.c
+++ b/drivers/net/wimax/i2400m/control.c
@@ -346,7 +346,7 @@ void i2400m_report_tlv_system_state(struct i2400m *i2400m,
 			i2400m_state);
 		i2400m_reset(i2400m, I2400M_RT_WARM);
 		break;
-	};
+	}
 	d_fnend(3, dev, "(i2400m %p ss %p [%u]) = void\n",
 		i2400m, ss, i2400m_state);
 }
@@ -524,7 +524,7 @@ void i2400m_report_hook(struct i2400m *i2400m,
 			}
 		}
 		break;
-	};
+	}
 	d_fnend(3, dev, "(i2400m %p l3l4_hdr %p size %zu) = void\n",
 		i2400m, l3l4_hdr, size);
 }
@@ -567,7 +567,7 @@ void i2400m_msg_ack_hook(struct i2400m *i2400m,
 					 size);
 		}
 		break;
-	};
+	}
 	return;
 }
 
@@ -740,7 +740,7 @@ struct sk_buff *i2400m_msg_to_dev(struct i2400m *i2400m,
 		break;
 	default:
 		ack_timeout = HZ;
-	};
+	}
 
 	if (unlikely(i2400m->trace_msg_from_user))
 		wimax_msg(&i2400m->wimax_dev, "echo", buf, buf_len, GFP_KERNEL);
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
index 8c79548..d457cb3 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -308,7 +308,7 @@ int ath_descdma_setup(struct ath_softc *sc, struct ath_descdma *dd,
 			dd->dd_desc_len += dma_len;
 
 			ndesc_skipped = ATH_DESC_4KB_BOUND_NUM_SKIPPED(dma_len);
-		};
+		}
 	}
 
 	/* allocate descriptors */
diff --git a/drivers/net/wireless/hostap/hostap_ap.c b/drivers/net/wireless/hostap/hostap_ap.c
index 7e72ac1..231dbd7 100644
--- a/drivers/net/wireless/hostap/hostap_ap.c
+++ b/drivers/net/wireless/hostap/hostap_ap.c
@@ -349,7 +349,7 @@ static int ap_control_proc_read(char *page, char **start, off_t off,
 	default:
 		policy_txt = "unknown";
 		break;
-	};
+	}
 	p += sprintf(p, "MAC policy: %s\n", policy_txt);
 	p += sprintf(p, "MAC entries: %u\n", ap->mac_restrictions.entries);
 	p += sprintf(p, "MAC list:\n");
diff --git a/drivers/net/wireless/hostap/hostap_download.c b/drivers/net/wireless/hostap/hostap_download.c
index 89d3849..e73bf73 100644
--- a/drivers/net/wireless/hostap/hostap_download.c
+++ b/drivers/net/wireless/hostap/hostap_download.c
@@ -744,7 +744,7 @@ static int prism2_download(local_info_t *local,
 		       local->dev->name, param->dl_cmd);
 		ret = -EINVAL;
 		break;
-	};
+	}
 
  out:
 	if (ret == 0 && dl &&
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
index a273474..05df73b 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
@@ -931,7 +931,7 @@ static u32 iwlagn_translate_rx_status(struct iwl_priv *priv, u32 decrypt_in)
 		else
 			decrypt_out |= RX_RES_STATUS_DECRYPT_OK;
 		break;
-	};
+	}
 
 	IWL_DEBUG_RX(priv, "decrypt_in:0x%x  decrypt_out = 0x%x\n",
 					decrypt_in, decrypt_out);
diff --git a/drivers/net/wireless/prism54/islpci_dev.c b/drivers/net/wireless/prism54/islpci_dev.c
index 10d91af..2c8cc95 100644
--- a/drivers/net/wireless/prism54/islpci_dev.c
+++ b/drivers/net/wireless/prism54/islpci_dev.c
@@ -946,7 +946,7 @@ islpci_set_state(islpci_private *priv, islpci_state_t new_state)
 		if (!priv->state_off)
 			priv->state = new_state;
 		break;
-	};
+	}
 #if 0
 	printk(KERN_DEBUG "%s: state transition %d -> %d (off#%d)\n",
 	       priv->ndev->name, old_state, new_state, priv->state_off);
diff --git a/drivers/net/wireless/rt2x00/rt2x00firmware.c b/drivers/net/wireless/rt2x00/rt2x00firmware.c
index 34beb00..b818a43 100644
--- a/drivers/net/wireless/rt2x00/rt2x00firmware.c
+++ b/drivers/net/wireless/rt2x00/rt2x00firmware.c
@@ -79,7 +79,7 @@ static int rt2x00lib_request_firmware(struct rt2x00_dev *rt2x00dev)
 		ERROR(rt2x00dev,
 		      "Current firmware does not support detected chipset.\n");
 		goto exit;
-	};
+	}
 
 	rt2x00dev->fw = fw;
 


