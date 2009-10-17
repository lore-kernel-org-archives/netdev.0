From: Tomas Winkler <tomas.winkler@intel.com>
Subject: [PATCH net-next V2 2/3] iwmc3200wifi: select IWMC3200TOP in Kconfig
Date: Sat, 17 Oct 2009 21:09:35 +0200
Message-ID: <1255806576-26869-2-git-send-email-tomas.winkler@intel.com>
References: <1255806576-26869-1-git-send-email-tomas.winkler@intel.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yi.zhu@intel.com, inaky.perez-gonzalez@intel.com,
	cindy.h.kao@intel.com, guy.cohen@intel.com,
	ron.rindjunsky@intel.com, Tomas Winkler <tomas.winkler@intel.com>
To: davem@davemloft.net, linville@tuxdriver.com,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-mmc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13245 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752542AbZJQT0t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2009 15:26:49 -0400
In-Reply-To: <1255806576-26869-1-git-send-email-tomas.winkler@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iwmc3200wifi requires iwmc3200top  for its operation

Signed-off-by: Tomas Winkler <tomas.winkler@intel.com>
Acked-by: Zhu Yi <yi.zhu@intel.com>
---
 drivers/net/wireless/iwmc3200wifi/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/iwmc3200wifi/Kconfig b/drivers/net/wireless/iwmc3200wifi/Kconfig
index c25a043..9606b31 100644
--- a/drivers/net/wireless/iwmc3200wifi/Kconfig
+++ b/drivers/net/wireless/iwmc3200wifi/Kconfig
@@ -3,6 +3,7 @@ config IWM
 	depends on MMC && WLAN_80211 && EXPERIMENTAL
 	depends on CFG80211
 	select FW_LOADER
+	select IWMC3200TOP
 	help
 	  The Intel Wireless Multicomm 3200 hardware is a combo
 	  card with GPS, Bluetooth, WiMax and 802.11 radios. It
-- 
1.6.0.6

---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

