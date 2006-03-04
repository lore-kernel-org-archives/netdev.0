From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/net/wireless/ipw2200.c: make ipw_qos_current_mode() static
Date: Sat, 4 Mar 2006 13:14:31 +0100
Message-ID: <20060304121431.GN9295@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linville@tuxdriver.com,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751709AbWCDMOy@vger.kernel.org>
To: yi.zhu@intel.com, jketreno@linux.intel.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes the needlessly global function ipw_qos_current_mode() 
static.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.16-rc5-mm2-full/drivers/net/wireless/ipw2200.c.old	2006-03-03 17:49:37.000000000 +0100
+++ linux-2.6.16-rc5-mm2-full/drivers/net/wireless/ipw2200.c	2006-03-03 17:50:00.000000000 +0100
@@ -6566,7 +6566,7 @@
 * get the modulation type of the current network or
 * the card current mode
 */
-u8 ipw_qos_current_mode(struct ipw_priv * priv)
+static u8 ipw_qos_current_mode(struct ipw_priv * priv)
 {
 	u8 mode = 0;
 
