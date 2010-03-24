From: Frans Pop <elendil@planet.nl>
Subject: [PATCH 3/7] wireless/ipw2x00: remove trailing space in messages
Date: Wed, 24 Mar 2010 19:46:31 +0100
Message-ID: <1269456395-15343-3-git-send-email-elendil@planet.nl>
References: <201003241927.12434.elendil@planet.nl>
Cc: Frans Pop <elendil@planet.nl>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201003241927.12434.elendil@planet.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Frans Pop <elendil@planet.nl>
---
 drivers/net/wireless/ipw2x00/ipw2100.c |   38 ++++++++--------
 drivers/net/wireless/ipw2x00/ipw2200.c |   74 ++++++++++++++++----------------
 2 files changed, 56 insertions(+), 56 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index fe63bf2..2088ac0 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -2140,7 +2140,7 @@ static void isr_indicate_association_lost(struct ipw2100_priv *priv, u32 status)
 	DECLARE_SSID_BUF(ssid);
 
 	IPW_DEBUG(IPW_DL_NOTIF | IPW_DL_STATE | IPW_DL_ASSOC,
-		  "disassociated: '%s' %pM \n",
+		  "disassociated: '%s' %pM\n",
 		  print_ssid(ssid, priv->essid, priv->essid_len),
 		  priv->bssid);
 
@@ -3285,7 +3285,7 @@ static void ipw2100_irq_tasklet(struct ipw2100_priv *priv)
 
 	if (inta & IPW2100_INTA_PARITY_ERROR) {
 		printk(KERN_ERR DRV_NAME
-		       ": ***** PARITY ERROR INTERRUPT !!!! \n");
+		       ": ***** PARITY ERROR INTERRUPT !!!!\n");
 		priv->inta_other++;
 		write_register(dev, IPW_REG_INTA, IPW2100_INTA_PARITY_ERROR);
 	}
@@ -6753,7 +6753,7 @@ static int ipw2100_wx_set_freq(struct net_device *dev,
 		err = -EOPNOTSUPP;
 		goto done;
 	} else {		/* Set the channel */
-		IPW_DEBUG_WX("SET Freq/Channel -> %d \n", fwrq->m);
+		IPW_DEBUG_WX("SET Freq/Channel -> %d\n", fwrq->m);
 		err = ipw2100_set_channel(priv, fwrq->m, 0);
 	}
 
@@ -6782,7 +6782,7 @@ static int ipw2100_wx_get_freq(struct net_device *dev,
 	else
 		wrqu->freq.m = 0;
 
-	IPW_DEBUG_WX("GET Freq/Channel -> %d \n", priv->channel);
+	IPW_DEBUG_WX("GET Freq/Channel -> %d\n", priv->channel);
 	return 0;
 
 }
@@ -6794,7 +6794,7 @@ static int ipw2100_wx_set_mode(struct net_device *dev,
 	struct ipw2100_priv *priv = libipw_priv(dev);
 	int err = 0;
 
-	IPW_DEBUG_WX("SET Mode -> %d \n", wrqu->mode);
+	IPW_DEBUG_WX("SET Mode -> %d\n", wrqu->mode);
 
 	if (wrqu->mode == priv->ieee->iw_mode)
 		return 0;
@@ -7149,7 +7149,7 @@ static int ipw2100_wx_set_nick(struct net_device *dev,
 	memset(priv->nick, 0, sizeof(priv->nick));
 	memcpy(priv->nick, extra, wrqu->data.length);
 
-	IPW_DEBUG_WX("SET Nickname -> %s \n", priv->nick);
+	IPW_DEBUG_WX("SET Nickname -> %s\n", priv->nick);
 
 	return 0;
 }
@@ -7168,7 +7168,7 @@ static int ipw2100_wx_get_nick(struct net_device *dev,
 	memcpy(extra, priv->nick, wrqu->data.length);
 	wrqu->data.flags = 1;	/* active */
 
-	IPW_DEBUG_WX("GET Nickname -> %s \n", extra);
+	IPW_DEBUG_WX("GET Nickname -> %s\n", extra);
 
 	return 0;
 }
@@ -7207,7 +7207,7 @@ static int ipw2100_wx_set_rate(struct net_device *dev,
 
 	err = ipw2100_set_tx_rates(priv, rate, 0);
 
-	IPW_DEBUG_WX("SET Rate -> %04X \n", rate);
+	IPW_DEBUG_WX("SET Rate -> %04X\n", rate);
       done:
 	mutex_unlock(&priv->action_mutex);
 	return err;
@@ -7258,7 +7258,7 @@ static int ipw2100_wx_get_rate(struct net_device *dev,
 		wrqu->bitrate.value = 0;
 	}
 
-	IPW_DEBUG_WX("GET Rate -> %d \n", wrqu->bitrate.value);
+	IPW_DEBUG_WX("GET Rate -> %d\n", wrqu->bitrate.value);
 
       done:
 	mutex_unlock(&priv->action_mutex);
@@ -7294,7 +7294,7 @@ static int ipw2100_wx_set_rts(struct net_device *dev,
 
 	err = ipw2100_set_rts_threshold(priv, value);
 
-	IPW_DEBUG_WX("SET RTS Threshold -> 0x%08X \n", value);
+	IPW_DEBUG_WX("SET RTS Threshold -> 0x%08X\n", value);
       done:
 	mutex_unlock(&priv->action_mutex);
 	return err;
@@ -7316,7 +7316,7 @@ static int ipw2100_wx_get_rts(struct net_device *dev,
 	/* If RTS is set to the default value, then it is disabled */
 	wrqu->rts.disabled = (priv->rts_threshold & RTS_DISABLED) ? 1 : 0;
 
-	IPW_DEBUG_WX("GET RTS Threshold -> 0x%08X \n", wrqu->rts.value);
+	IPW_DEBUG_WX("GET RTS Threshold -> 0x%08X\n", wrqu->rts.value);
 
 	return 0;
 }
@@ -7355,7 +7355,7 @@ static int ipw2100_wx_set_txpow(struct net_device *dev,
 
 	err = ipw2100_set_tx_power(priv, value);
 
-	IPW_DEBUG_WX("SET TX Power -> %d \n", value);
+	IPW_DEBUG_WX("SET TX Power -> %d\n", value);
 
       done:
 	mutex_unlock(&priv->action_mutex);
@@ -7384,7 +7384,7 @@ static int ipw2100_wx_get_txpow(struct net_device *dev,
 
 	wrqu->txpower.flags = IW_TXPOW_DBM;
 
-	IPW_DEBUG_WX("GET TX Power -> %d \n", wrqu->txpower.value);
+	IPW_DEBUG_WX("GET TX Power -> %d\n", wrqu->txpower.value);
 
 	return 0;
 }
@@ -7414,7 +7414,7 @@ static int ipw2100_wx_set_frag(struct net_device *dev,
 		priv->frag_threshold = priv->ieee->fts;
 	}
 
-	IPW_DEBUG_WX("SET Frag Threshold -> %d \n", priv->ieee->fts);
+	IPW_DEBUG_WX("SET Frag Threshold -> %d\n", priv->ieee->fts);
 
 	return 0;
 }
@@ -7432,7 +7432,7 @@ static int ipw2100_wx_get_frag(struct net_device *dev,
 	wrqu->frag.fixed = 0;	/* no auto select */
 	wrqu->frag.disabled = (priv->frag_threshold & FRAG_DISABLED) ? 1 : 0;
 
-	IPW_DEBUG_WX("GET Frag Threshold -> %d \n", wrqu->frag.value);
+	IPW_DEBUG_WX("GET Frag Threshold -> %d\n", wrqu->frag.value);
 
 	return 0;
 }
@@ -7458,14 +7458,14 @@ static int ipw2100_wx_set_retry(struct net_device *dev,
 
 	if (wrqu->retry.flags & IW_RETRY_SHORT) {
 		err = ipw2100_set_short_retry(priv, wrqu->retry.value);
-		IPW_DEBUG_WX("SET Short Retry Limit -> %d \n",
+		IPW_DEBUG_WX("SET Short Retry Limit -> %d\n",
 			     wrqu->retry.value);
 		goto done;
 	}
 
 	if (wrqu->retry.flags & IW_RETRY_LONG) {
 		err = ipw2100_set_long_retry(priv, wrqu->retry.value);
-		IPW_DEBUG_WX("SET Long Retry Limit -> %d \n",
+		IPW_DEBUG_WX("SET Long Retry Limit -> %d\n",
 			     wrqu->retry.value);
 		goto done;
 	}
@@ -7474,7 +7474,7 @@ static int ipw2100_wx_set_retry(struct net_device *dev,
 	if (!err)
 		err = ipw2100_set_long_retry(priv, wrqu->retry.value);
 
-	IPW_DEBUG_WX("SET Both Retry Limits -> %d \n", wrqu->retry.value);
+	IPW_DEBUG_WX("SET Both Retry Limits -> %d\n", wrqu->retry.value);
 
       done:
 	mutex_unlock(&priv->action_mutex);
@@ -7508,7 +7508,7 @@ static int ipw2100_wx_get_retry(struct net_device *dev,
 		wrqu->retry.value = priv->short_retry_limit;
 	}
 
-	IPW_DEBUG_WX("GET Retry -> %d \n", wrqu->retry.value);
+	IPW_DEBUG_WX("GET Retry -> %d\n", wrqu->retry.value);
 
 	return 0;
 }
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 6dc0733..d006ae8 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -458,7 +458,7 @@ static u8 _ipw_read_reg8(struct ipw_priv *priv, u32 reg)
 {
 	u32 word;
 	_ipw_write32(priv, IPW_INDIRECT_ADDR, reg & IPW_INDIRECT_ADDR_MASK);
-	IPW_DEBUG_IO(" reg = 0x%8X : \n", reg);
+	IPW_DEBUG_IO(" reg = 0x%8X :\n", reg);
 	word = _ipw_read32(priv, IPW_INDIRECT_DATA);
 	return (word >> ((reg & 0x3) * 8)) & 0xff;
 }
@@ -472,7 +472,7 @@ static u32 _ipw_read_reg32(struct ipw_priv *priv, u32 reg)
 
 	_ipw_write32(priv, IPW_INDIRECT_ADDR, reg);
 	value = _ipw_read32(priv, IPW_INDIRECT_DATA);
-	IPW_DEBUG_IO(" reg = 0x%4X : value = 0x%4x \n", reg, value);
+	IPW_DEBUG_IO(" reg = 0x%4X : value = 0x%4x\n", reg, value);
 	return value;
 }
 
@@ -2738,7 +2738,7 @@ static inline void ipw_fw_dma_reset_command_blocks(struct ipw_priv *priv)
 static int ipw_fw_dma_enable(struct ipw_priv *priv)
 {				/* start dma engine but no transfers yet */
 
-	IPW_DEBUG_FW(">> : \n");
+	IPW_DEBUG_FW(">> :\n");
 
 	/* Start the dma */
 	ipw_fw_dma_reset_command_blocks(priv);
@@ -2746,7 +2746,7 @@ static int ipw_fw_dma_enable(struct ipw_priv *priv)
 	/* Write CB base address */
 	ipw_write_reg32(priv, IPW_DMA_I_CB_BASE, IPW_SHARED_SRAM_DMA_CONTROL);
 
-	IPW_DEBUG_FW("<< : \n");
+	IPW_DEBUG_FW("<< :\n");
 	return 0;
 }
 
@@ -2761,7 +2761,7 @@ static void ipw_fw_dma_abort(struct ipw_priv *priv)
 	ipw_write_reg32(priv, IPW_DMA_I_DMA_CONTROL, control);
 	priv->sram_desc.last_cb_index = 0;
 
-	IPW_DEBUG_FW("<< \n");
+	IPW_DEBUG_FW("<<\n");
 }
 
 static int ipw_fw_dma_write_command_block(struct ipw_priv *priv, int index,
@@ -2812,29 +2812,29 @@ static void ipw_fw_dma_dump_command_block(struct ipw_priv *priv)
 
 	IPW_DEBUG_FW(">> :\n");
 	address = ipw_read_reg32(priv, IPW_DMA_I_CURRENT_CB);
-	IPW_DEBUG_FW_INFO("Current CB is 0x%x \n", address);
+	IPW_DEBUG_FW_INFO("Current CB is 0x%x\n", address);
 
 	/* Read the DMA Controlor register */
 	register_value = ipw_read_reg32(priv, IPW_DMA_I_DMA_CONTROL);
-	IPW_DEBUG_FW_INFO("IPW_DMA_I_DMA_CONTROL is 0x%x \n", register_value);
+	IPW_DEBUG_FW_INFO("IPW_DMA_I_DMA_CONTROL is 0x%x\n", register_value);
 
 	/* Print the CB values */
 	cb_fields_address = address;
 	register_value = ipw_read_reg32(priv, cb_fields_address);
-	IPW_DEBUG_FW_INFO("Current CB ControlField is 0x%x \n", register_value);
+	IPW_DEBUG_FW_INFO("Current CB Control Field is 0x%x\n", register_value);
 
 	cb_fields_address += sizeof(u32);
 	register_value = ipw_read_reg32(priv, cb_fields_address);
-	IPW_DEBUG_FW_INFO("Current CB Source Field is 0x%x \n", register_value);
+	IPW_DEBUG_FW_INFO("Current CB Source Field is 0x%x\n", register_value);
 
 	cb_fields_address += sizeof(u32);
 	register_value = ipw_read_reg32(priv, cb_fields_address);
-	IPW_DEBUG_FW_INFO("Current CB Destination Field is 0x%x \n",
+	IPW_DEBUG_FW_INFO("Current CB Destination Field is 0x%x\n",
 			  register_value);
 
 	cb_fields_address += sizeof(u32);
 	register_value = ipw_read_reg32(priv, cb_fields_address);
-	IPW_DEBUG_FW_INFO("Current CB Status Field is 0x%x \n", register_value);
+	IPW_DEBUG_FW_INFO("Current CB Status Field is 0x%x\n", register_value);
 
 	IPW_DEBUG_FW(">> :\n");
 }
@@ -2850,7 +2850,7 @@ static int ipw_fw_dma_command_block_index(struct ipw_priv *priv)
 	current_cb_index = (current_cb_address - IPW_SHARED_SRAM_DMA_CONTROL) /
 	    sizeof(struct command_block);
 
-	IPW_DEBUG_FW_INFO("Current CB index 0x%x address = 0x%X \n",
+	IPW_DEBUG_FW_INFO("Current CB index 0x%x address = 0x%X\n",
 			  current_cb_index, current_cb_address);
 
 	IPW_DEBUG_FW(">> :\n");
@@ -2909,7 +2909,7 @@ static int ipw_fw_dma_add_buffer(struct ipw_priv *priv, dma_addr_t *src_address,
 	int ret, i;
 	u32 size;
 
-	IPW_DEBUG_FW(">> \n");
+	IPW_DEBUG_FW(">>\n");
 	IPW_DEBUG_FW_INFO("nr=%d dest_address=0x%x len=0x%x\n",
 			  nr, dest_address, len);
 
@@ -2926,7 +2926,7 @@ static int ipw_fw_dma_add_buffer(struct ipw_priv *priv, dma_addr_t *src_address,
 			IPW_DEBUG_FW_INFO(": Added new cb\n");
 	}
 
-	IPW_DEBUG_FW("<< \n");
+	IPW_DEBUG_FW("<<\n");
 	return 0;
 }
 
@@ -2935,7 +2935,7 @@ static int ipw_fw_dma_wait(struct ipw_priv *priv)
 	u32 current_index = 0, previous_index;
 	u32 watchdog = 0;
 
-	IPW_DEBUG_FW(">> : \n");
+	IPW_DEBUG_FW(">> :\n");
 
 	current_index = ipw_fw_dma_command_block_index(priv);
 	IPW_DEBUG_FW_INFO("sram_desc.last_cb_index:0x%08X\n",
@@ -2964,7 +2964,7 @@ static int ipw_fw_dma_wait(struct ipw_priv *priv)
 	ipw_set_bit(priv, IPW_RESET_REG,
 		    IPW_RESET_REG_MASTER_DISABLED | IPW_RESET_REG_STOP_MASTER);
 
-	IPW_DEBUG_FW("<< dmaWaitSync \n");
+	IPW_DEBUG_FW("<< dmaWaitSync\n");
 	return 0;
 }
 
@@ -3025,7 +3025,7 @@ static int ipw_stop_master(struct ipw_priv *priv)
 {
 	int rc;
 
-	IPW_DEBUG_TRACE(">> \n");
+	IPW_DEBUG_TRACE(">>\n");
 	/* stop master. typical delay - 0 */
 	ipw_set_bit(priv, IPW_RESET_REG, IPW_RESET_REG_STOP_MASTER);
 
@@ -3044,7 +3044,7 @@ static int ipw_stop_master(struct ipw_priv *priv)
 
 static void ipw_arc_release(struct ipw_priv *priv)
 {
-	IPW_DEBUG_TRACE(">> \n");
+	IPW_DEBUG_TRACE(">>\n");
 	mdelay(5);
 
 	ipw_clear_bit(priv, IPW_RESET_REG, CBD_RESET_REG_PRINCETON_RESET);
@@ -3066,7 +3066,7 @@ static int ipw_load_ucode(struct ipw_priv *priv, u8 * data, size_t len)
 
 	image = (__le16 *) data;
 
-	IPW_DEBUG_TRACE(">> \n");
+	IPW_DEBUG_TRACE(">>\n");
 
 	rc = ipw_stop_master(priv);
 
@@ -3180,7 +3180,7 @@ static int ipw_load_firmware(struct ipw_priv *priv, u8 * data, size_t len)
 	void **virts;
 	dma_addr_t *phys;
 
-	IPW_DEBUG_TRACE("<< : \n");
+	IPW_DEBUG_TRACE("<< :\n");
 
 	virts = kmalloc(sizeof(void *) * CB_NUMBER_OF_ELEMENTS_SMALL,
 			GFP_KERNEL);
@@ -4481,7 +4481,7 @@ static void ipw_rx_notification(struct ipw_priv *priv,
 			case CMAS_ASSOCIATED:{
 					IPW_DEBUG(IPW_DL_NOTIF | IPW_DL_STATE |
 						  IPW_DL_ASSOC,
-						  "associated: '%s' %pM \n",
+						  "associated: '%s' %pM\n",
 						  print_ssid(ssid, priv->essid,
 							     priv->essid_len),
 						  priv->bssid);
@@ -4562,7 +4562,7 @@ static void ipw_rx_notification(struct ipw_priv *priv,
 							  IPW_DL_ASSOC,
 							  "deauthenticated: '%s' "
 							  "%pM"
-							  ": (0x%04X) - %s \n",
+							  ": (0x%04X) - %s\n",
 							  print_ssid(ssid,
 								     priv->
 								     essid,
@@ -4613,7 +4613,7 @@ static void ipw_rx_notification(struct ipw_priv *priv,
 
 					IPW_DEBUG(IPW_DL_NOTIF | IPW_DL_STATE |
 						  IPW_DL_ASSOC,
-						  "disassociated: '%s' %pM \n",
+						  "disassociated: '%s' %pM\n",
 						  print_ssid(ssid, priv->essid,
 							     priv->essid_len),
 						  priv->bssid);
@@ -4651,7 +4651,7 @@ static void ipw_rx_notification(struct ipw_priv *priv,
 			switch (auth->state) {
 			case CMAS_AUTHENTICATED:
 				IPW_DEBUG(IPW_DL_NOTIF | IPW_DL_STATE,
-					  "authenticated: '%s' %pM \n",
+					  "authenticated: '%s' %pM\n",
 					  print_ssid(ssid, priv->essid,
 						     priv->essid_len),
 					  priv->bssid);
@@ -6924,7 +6924,7 @@ static u8 ipw_qos_current_mode(struct ipw_priv * priv)
 	} else {
 		mode = priv->ieee->mode;
 	}
-	IPW_DEBUG_QOS("QoS network/card mode %d \n", mode);
+	IPW_DEBUG_QOS("QoS network/card mode %d\n", mode);
 	return mode;
 }
 
@@ -6964,7 +6964,7 @@ static int ipw_qos_handle_probe_response(struct ipw_priv *priv,
 			       &def_parameters_OFDM, size);
 
 		if ((network->qos_data.active == 1) && (active_network == 1)) {
-			IPW_DEBUG_QOS("QoS was disabled call qos_activate \n");
+			IPW_DEBUG_QOS("QoS was disabled call qos_activate\n");
 			schedule_work(&priv->qos_activate);
 		}
 
@@ -7541,7 +7541,7 @@ static int ipw_associate_network(struct ipw_priv *priv,
 		return err;
 	}
 
-	IPW_DEBUG(IPW_DL_STATE, "associating: '%s' %pM \n",
+	IPW_DEBUG(IPW_DL_STATE, "associating: '%s' %pM\n",
 		  print_ssid(ssid, priv->essid, priv->essid_len),
 		  priv->bssid);
 
@@ -8792,7 +8792,7 @@ static int ipw_wx_set_freq(struct net_device *dev,
 		}
 	}
 
-	IPW_DEBUG_WX("SET Freq/Channel -> %d \n", fwrq->m);
+	IPW_DEBUG_WX("SET Freq/Channel -> %d\n", fwrq->m);
 	mutex_lock(&priv->mutex);
 	ret = ipw_set_channel(priv, channel);
 	mutex_unlock(&priv->mutex);
@@ -8834,7 +8834,7 @@ static int ipw_wx_get_freq(struct net_device *dev,
 		wrqu->freq.m = 0;
 
 	mutex_unlock(&priv->mutex);
-	IPW_DEBUG_WX("GET Freq/Channel -> %d \n", priv->channel);
+	IPW_DEBUG_WX("GET Freq/Channel -> %d\n", priv->channel);
 	return 0;
 }
 
@@ -9229,7 +9229,7 @@ static int ipw_wx_get_sens(struct net_device *dev,
 	wrqu->sens.value = priv->roaming_threshold;
 	mutex_unlock(&priv->mutex);
 
-	IPW_DEBUG_WX("GET roaming threshold -> %s %d \n",
+	IPW_DEBUG_WX("GET roaming threshold -> %s %d\n",
 		     wrqu->power.disabled ? "OFF" : "ON", wrqu->power.value);
 
 	return 0;
@@ -9357,7 +9357,7 @@ static int ipw_wx_get_rate(struct net_device *dev,
 	wrqu->bitrate.value = priv->last_rate;
 	wrqu->bitrate.fixed = (priv->config & CFG_FIXED_RATE) ? 1 : 0;
 	mutex_unlock(&priv->mutex);
-	IPW_DEBUG_WX("GET Rate -> %d \n", wrqu->bitrate.value);
+	IPW_DEBUG_WX("GET Rate -> %d\n", wrqu->bitrate.value);
 	return 0;
 }
 
@@ -9380,7 +9380,7 @@ static int ipw_wx_set_rts(struct net_device *dev,
 
 	ipw_send_rts_threshold(priv, priv->rts_threshold);
 	mutex_unlock(&priv->mutex);
-	IPW_DEBUG_WX("SET RTS Threshold -> %d \n", priv->rts_threshold);
+	IPW_DEBUG_WX("SET RTS Threshold -> %d\n", priv->rts_threshold);
 	return 0;
 }
 
@@ -9394,7 +9394,7 @@ static int ipw_wx_get_rts(struct net_device *dev,
 	wrqu->rts.fixed = 0;	/* no auto select */
 	wrqu->rts.disabled = (wrqu->rts.value == DEFAULT_RTS_THRESHOLD);
 	mutex_unlock(&priv->mutex);
-	IPW_DEBUG_WX("GET RTS Threshold -> %d \n", wrqu->rts.value);
+	IPW_DEBUG_WX("GET RTS Threshold -> %d\n", wrqu->rts.value);
 	return 0;
 }
 
@@ -9444,7 +9444,7 @@ static int ipw_wx_get_txpow(struct net_device *dev,
 	wrqu->power.disabled = (priv->status & STATUS_RF_KILL_MASK) ? 1 : 0;
 	mutex_unlock(&priv->mutex);
 
-	IPW_DEBUG_WX("GET TX Power -> %s %d \n",
+	IPW_DEBUG_WX("GET TX Power -> %s %d\n",
 		     wrqu->power.disabled ? "OFF" : "ON", wrqu->power.value);
 
 	return 0;
@@ -9470,7 +9470,7 @@ static int ipw_wx_set_frag(struct net_device *dev,
 
 	ipw_send_frag_threshold(priv, wrqu->frag.value);
 	mutex_unlock(&priv->mutex);
-	IPW_DEBUG_WX("SET Frag Threshold -> %d \n", wrqu->frag.value);
+	IPW_DEBUG_WX("SET Frag Threshold -> %d\n", wrqu->frag.value);
 	return 0;
 }
 
@@ -9484,7 +9484,7 @@ static int ipw_wx_get_frag(struct net_device *dev,
 	wrqu->frag.fixed = 0;	/* no auto select */
 	wrqu->frag.disabled = (wrqu->frag.value == DEFAULT_FTS);
 	mutex_unlock(&priv->mutex);
-	IPW_DEBUG_WX("GET Frag Threshold -> %d \n", wrqu->frag.value);
+	IPW_DEBUG_WX("GET Frag Threshold -> %d\n", wrqu->frag.value);
 
 	return 0;
 }
@@ -9548,7 +9548,7 @@ static int ipw_wx_get_retry(struct net_device *dev,
 	}
 	mutex_unlock(&priv->mutex);
 
-	IPW_DEBUG_WX("GET retry -> %d \n", wrqu->retry.value);
+	IPW_DEBUG_WX("GET retry -> %d\n", wrqu->retry.value);
 
 	return 0;
 }
-- 
1.6.6.1
