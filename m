From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCHv2 net-next-2.6 4/7] ethtool: Convert struct ethtool_ops
 comment to kernel-doc format
Date: Tue, 05 Apr 2011 19:03:48 +0100
Message-ID: <1302026628.2932.60.camel@bwh-desktop>
References: <1302026446.2932.56.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:15365 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752927Ab1DESDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 14:03:51 -0400
In-Reply-To: <1302026446.2932.56.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/ethtool.h |   80 ++++++++++++++++++++--------------------------
 1 files changed, 35 insertions(+), 45 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index c8fcbdd..ab12f84 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -683,63 +683,53 @@ void ethtool_ntuple_flush(struct net_device *dev);
 bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 supported);
 
 /**
- * &ethtool_ops - Alter and report network device settings
- * get_settings: Get device-specific settings
- * set_settings: Set device-specific settings
- * get_drvinfo: Report driver information
- * get_regs: Get device registers
- * get_wol: Report whether Wake-on-Lan is enabled
- * set_wol: Turn Wake-on-Lan on or off
- * get_msglevel: Report driver message level
- * set_msglevel: Set driver message level
- * nway_reset: Restart autonegotiation
- * get_link: Get link status
- * get_eeprom: Read data from the device EEPROM
- * set_eeprom: Write data to the device EEPROM
- * get_coalesce: Get interrupt coalescing parameters
- * set_coalesce: Set interrupt coalescing parameters
- * get_ringparam: Report ring sizes
- * set_ringparam: Set ring sizes
- * get_pauseparam: Report pause parameters
- * set_pauseparam: Set pause parameters
- * get_rx_csum: Report whether receive checksums are turned on or off
- * set_rx_csum: Turn receive checksum on or off
- * get_tx_csum: Report whether transmit checksums are turned on or off
- * set_tx_csum: Turn transmit checksums on or off
- * get_sg: Report whether scatter-gather is enabled
- * set_sg: Turn scatter-gather on or off
- * get_tso: Report whether TCP segmentation offload is enabled
- * set_tso: Turn TCP segmentation offload on or off
- * get_ufo: Report whether UDP fragmentation offload is enabled
- * set_ufo: Turn UDP fragmentation offload on or off
- * self_test: Run specified self-tests
- * get_strings: Return a set of strings that describe the requested objects
- * phys_id: Identify the device
- * get_stats: Return statistics about the device
- * get_flags: get 32-bit flags bitmap
- * set_flags: set 32-bit flags bitmap
- *
- * Description:
- *
- * get_settings:
+ * struct ethtool_ops - Alter and report network device settings
+ * @get_settings: Get device-specific settings.
  *	@get_settings is passed an &ethtool_cmd to fill in.  It returns
  *	an negative errno or zero.
- *
- * set_settings:
+ * @set_settings: Set device-specific settings.
  *	@set_settings is passed an &ethtool_cmd and should attempt to set
  *	all the settings this device supports.  It may return an error value
  *	if something goes wrong (otherwise 0).
- *
- * get_eeprom:
+ * @get_drvinfo: Report driver information
+ * @get_regs: Get device registers
+ * @get_wol: Report whether Wake-on-Lan is enabled
+ * @set_wol: Turn Wake-on-Lan on or off
+ * @get_msglevel: Report driver message level
+ * @set_msglevel: Set driver message level
+ * @nway_reset: Restart autonegotiation
+ * @get_link: Get link status
+ * @get_eeprom: Read data from the device EEPROM.
  *	Should fill in the magic field.  Don't need to check len for zero
  *	or wraparound.  Fill in the data argument with the eeprom values
  *	from offset to offset + len.  Update len to the amount read.
  *	Returns an error or zero.
- *
- * set_eeprom:
+ * @set_eeprom: Write data to the device EEPROM.
  *	Should validate the magic field.  Don't need to check len for zero
  *	or wraparound.  Update len to the amount written.  Returns an error
  *	or zero.
+ * @get_coalesce: Get interrupt coalescing parameters
+ * @set_coalesce: Set interrupt coalescing parameters
+ * @get_ringparam: Report ring sizes
+ * @set_ringparam: Set ring sizes
+ * @get_pauseparam: Report pause parameters
+ * @set_pauseparam: Set pause parameters
+ * @get_rx_csum: Report whether receive checksums are turned on or off
+ * @set_rx_csum: Turn receive checksum on or off
+ * @get_tx_csum: Report whether transmit checksums are turned on or off
+ * @set_tx_csum: Turn transmit checksums on or off
+ * @get_sg: Report whether scatter-gather is enabled
+ * @set_sg: Turn scatter-gather on or off
+ * @get_tso: Report whether TCP segmentation offload is enabled
+ * @set_tso: Turn TCP segmentation offload on or off
+ * @get_ufo: Report whether UDP fragmentation offload is enabled
+ * @set_ufo: Turn UDP fragmentation offload on or off
+ * @self_test: Run specified self-tests
+ * @get_strings: Return a set of strings that describe the requested objects
+ * @phys_id: Identify the device
+ * @get_stats: Return statistics about the device
+ * @get_flags: get 32-bit flags bitmap
+ * @set_flags: set 32-bit flags bitmap
  */
 struct ethtool_ops {
 	int	(*get_settings)(struct net_device *, struct ethtool_cmd *);
-- 
1.7.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

