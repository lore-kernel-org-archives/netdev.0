From: Tomas Winkler <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/3] iwmc3200wifi: select IWMC3200TOP in Kconfig
Date: Wed, 23 Sep 2009 02:38:43 +0300
Message-ID: <1253662724-16497-3-git-send-email-tomas.winkler@intel.com>
References: <1253662724-16497-1-git-send-email-tomas.winkler@intel.com>
 <1253662724-16497-2-git-send-email-tomas.winkler@intel.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, inaky.perez-gonzalez-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	cindy.h.kao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, guy.cohen-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Tomas Winkler <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1253662724-16497-2-git-send-email-tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

iwmc3200wifi requires iwmc3200top  for its operation

Signed-off-by: Tomas Winkler <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/iwmc3200wifi/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/iwmc3200wifi/Kconfig b/drivers/net/wireless/iwmc3200wifi/Kconfig
index c62da43..69faaf1 100644
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

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
