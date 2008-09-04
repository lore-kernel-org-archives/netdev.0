From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/4] sky2: add more generic ethtool hooks
Date: Thu, 04 Sep 2008 13:56:41 -0700
Message-ID: <20080904205718.902156207@vyatta.com>
References: <20080904205636.130211321@vyatta.com>
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org
To: Jesse Barnes <jbarnes@virtuousgeek.org>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline; filename=sky2-ethtool-ops.patch
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for some missing status queries.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2008-09-04 11:48:30.000000000 -0700
+++ b/drivers/net/sky2.c	2008-09-04 11:48:31.000000000 -0700
@@ -3840,7 +3840,9 @@ static const struct ethtool_ops sky2_eth
 	.get_eeprom_len	= sky2_get_eeprom_len,
 	.get_eeprom	= sky2_get_eeprom,
 	.set_eeprom	= sky2_set_eeprom,
+	.get_sg		= ethtool_op_get_sg,
 	.set_sg 	= ethtool_op_set_sg,
+	.get_tx_csum	= ethtool_op_get_tx_csum,
 	.set_tx_csum	= sky2_set_tx_csum,
 	.set_tso	= sky2_set_tso,
 	.get_rx_csum	= sky2_get_rx_csum,
@@ -3855,6 +3857,8 @@ static const struct ethtool_ops sky2_eth
 	.phys_id	= sky2_phys_id,
 	.get_sset_count = sky2_get_sset_count,
 	.get_ethtool_stats = sky2_get_ethtool_stats,
+	.get_flags      = ethtool_op_get_flags,
+	.get_ufo	= ethtool_op_get_ufo,
 };
 
 #ifdef CONFIG_SKY2_DEBUG

-- 
