From: Priit Laes <plaes-q/aMd4JkU83YtjvyW6yDsg@public.gmane.org>
Subject: [PATCH v2 0/4] rtlwifi: Use common functions for driver stats
Date: Sun, 22 Mar 2015 15:35:16 +0200
Message-ID: <1427031320-10913-1-git-send-email-plaes@plaes.org>
Cc: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, Priit Laes <plaes-q/aMd4JkU83YtjvyW6yDsg@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi all,

This is a small fixup to unify make the drivers use common helper
functions for driver statistics.

There are no functional changes since the first posting, except dropping
patches already applied and addressing the comments by Joe Perches.

Priit Laes (4):
  rtlwifi: Use common rtl_evm_db_to_percentage
  rtlwifi: Use common rtl_signal_scale_mapping
  rtlwifi: Rename rtl_translate_todbm to rtl_signalpower_todbm
  rtlwifi: Use common rtl_query_rxpwrpercentage function

 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c |  8 ++--
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c | 70 ++--------------------------
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c | 67 +++-----------------------
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c | 68 ++++-----------------------
 drivers/net/wireless/rtlwifi/rtl8192ee/trx.c |  8 ++--
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c |  8 ++--
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c |  8 ++--
 drivers/net/wireless/rtlwifi/rtl8723be/trx.c |  8 ++--
 drivers/net/wireless/rtlwifi/rtl8821ae/trx.c |  8 ++--
 drivers/net/wireless/rtlwifi/stats.c         | 27 +++++------
 drivers/net/wireless/rtlwifi/stats.h         |  2 +-
 11 files changed, 55 insertions(+), 227 deletions(-)

-- 
2.3.3

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
