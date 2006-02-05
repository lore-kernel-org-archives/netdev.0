From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] let IPW2{1,2}00 select IEEE80211
Date: Sun, 5 Feb 2006 16:13:22 +0100
Message-ID: <20060205151322.GE5271@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jan Niehusmann <jan@gondor.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750877AbWBEPNZ@vger.kernel.org>
To: yi.zhu@intel.com, jketreno@linux.intel.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Niehusmann <jan@gondor.com>

This patch makes the IPW2100 and IPW2200 options available in
the configuration menu even if IEEE80211 has not been selected before.
This behaviour is more intuitive for people which are not familiar with
the driver internals.
The suggestion for this change was made by Alejandro Bonilla Beeche.

Signed-off-by: Jan Niehusmann <jan@gondor.com>
Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was sent by Jan Niehusmann on:
- 13 Nov 2005

--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -139,8 +139,9 @@ comment "Wireless 802.11b ISA/PCI cards 
 
 config IPW2100
 	tristate "Intel PRO/Wireless 2100 Network Connection"
-	depends on NET_RADIO && PCI && IEEE80211
+	depends on NET_RADIO && PCI
 	select FW_LOADER
+	select IEEE80211
 	---help---
           A driver for the Intel PRO/Wireless 2100 Network 
 	  Connection 802.11b wireless network adapter.
@@ -192,8 +193,9 @@ config IPW_DEBUG
 
 config IPW2200
 	tristate "Intel PRO/Wireless 2200BG and 2915ABG Network Connection"
-	depends on NET_RADIO && IEEE80211 && PCI
+	depends on NET_RADIO && PCI
 	select FW_LOADER
+	select IEEE80211
 	---help---
           A driver for the Intel PRO/Wireless 2200BG and 2915ABG Network
 	  Connection adapters. 
 
