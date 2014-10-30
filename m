From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/6 3.18] Fixes for iwlwifi drivers
Date: Wed, 29 Oct 2014 23:17:07 -0500
Message-ID: <1414642633-3700-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org,
	Murilo Opsfelder Araujo <mopsfelder@gmail.com>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:48772 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470AbaJ3ERU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 00:17:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some late changes to rtlwifi made some of the older drivers not start correctly.
These patches should be applied to 3.18.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Murilo Opsfelder Araujo <mopsfelder@gmail.com>

Larry Finger (6):
  rtlwifi: rtl8192ce: rtl8192de: rtl8192se: Fix handling for missing
    get_btc_status
  rtlwifi: rtl8192se: Fix duplicate calls to ieee80211_register_hw()
  rtlwifi: rtl8192se: Add missing section to read descriptor setting
  rtlwifi: rtl8192ce: Add missing section to read descriptor setting
  rtlwifi: rtl8821ae: Remove extra semicolons
  rtlwifi: rtl8192se: Fix firmware loading

 drivers/net/wireless/rtlwifi/core.c          |  6 ++++++
 drivers/net/wireless/rtlwifi/core.h          |  1 +
 drivers/net/wireless/rtlwifi/rtl8192ce/def.h |  2 ++
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c  |  1 +
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c |  3 +++
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c  |  1 +
 drivers/net/wireless/rtlwifi/rtl8192se/def.h |  2 ++
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c  | 22 +++-------------------
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c |  3 +++
 drivers/net/wireless/rtlwifi/rtl8821ae/phy.c | 12 ++++++------
 10 files changed, 28 insertions(+), 25 deletions(-)

-- 
2.1.1
