From: Priit Laes <plaes@plaes.org>
Subject: [PATCH 0/6] rtlwifi: Use common functions for driver stats
Date: Wed, 11 Mar 2015 22:03:23 +0200
Message-ID: <1426104209-6913-1-git-send-email-plaes@plaes.org>
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Priit Laes <plaes@plaes.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from plaes.org ([188.166.43.21]:51898 "EHLO plaes.org"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752497AbbCKUDq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2015 16:03:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This is a small fixup to unify make the drivers use common helper
functions for driver statistics.

Priit Laes (6):
  rtlwifi: Use common rtl_query_rxpwrpercentage function
  rtlwifi: Clean rtl_evm_db_to_percentage a bit
  rtlwifi: Use common rtl_evm_db_to_percentage
  rtlwifi: No need to export rtl_evm_dbm_jaguar anymore
  rtlwifi: Use common rtl_signal_scale_mapping
  rtlwifi: Rename rtl_translate_todbm to rtl_signalpower_todbm

 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c |  8 ++--
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c | 70 ++--------------------------
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c | 67 +++-----------------------
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c | 68 ++++-----------------------
 drivers/net/wireless/rtlwifi/rtl8192ee/trx.c |  8 ++--
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c |  8 ++--
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c |  8 ++--
 drivers/net/wireless/rtlwifi/rtl8723be/trx.c |  8 ++--
 drivers/net/wireless/rtlwifi/rtl8821ae/trx.c | 24 ++++++++--
 drivers/net/wireless/rtlwifi/stats.c         | 48 ++++---------------
 drivers/net/wireless/rtlwifi/stats.h         |  3 +-
 11 files changed, 69 insertions(+), 251 deletions(-)

-- 
2.3.1
