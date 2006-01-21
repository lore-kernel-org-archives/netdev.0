From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/net/wireless/ipw2100.c: make ipw2100_wpa_assoc_frame() static
Date: Sat, 21 Jan 2006 01:36:36 +0100
Message-ID: <20060121003636.GK31803@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932325AbWAUAgi@vger.kernel.org>
To: yi.zhu@intel.com, jketreno@linux.intel.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes the needlessly global ipw2100_wpa_assoc_frame() static.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.16-rc1-mm2-full/drivers/net/wireless/ipw2100.c.old	2006-01-21 00:53:47.000000000 +0100
+++ linux-2.6.16-rc1-mm2-full/drivers/net/wireless/ipw2100.c	2006-01-21 00:53:59.000000000 +0100
@@ -5771,8 +5771,8 @@
 	return ret;
 }
 
-void ipw2100_wpa_assoc_frame(struct ipw2100_priv *priv,
-			     char *wpa_ie, int wpa_ie_len)
+static void ipw2100_wpa_assoc_frame(struct ipw2100_priv *priv,
+				    char *wpa_ie, int wpa_ie_len)
 {
 
 	struct ipw2100_wpa_assoc_frame frame;
