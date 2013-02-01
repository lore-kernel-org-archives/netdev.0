From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/6] Fix a number of warnings that show up when using "make W=1"
Date: Fri,  1 Feb 2013 10:40:21 -0600
Message-ID: <1359736827-30977-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:50823 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756115Ab3BAQkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 11:40:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several of the rtlwifi family of drivers show warnings when W=1 is added to
the make command. This set of patches fixes all ot them. None of them are
serious and they may be applied to some future kernel.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

Larry Finger (6):
  rtlwifi: Fix many compile warnings when using W=1
  rtlwifi: Fix warnings in usb.c
  rtlwifi: rtl8192c: Fix W=1 warning
  rtlwifi: rtl8192cu: Fix W=1 build warning
  rtlwifi: rtl8192de: Fix W=1 build warnings
  rtlwifi: rtl8723ae: Fix W=1 compile warnings

 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c |  3 ++-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c       |  2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c       |  4 ++--
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.c       |  2 --
 drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.c  |  2 --
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c       |  8 ++------
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.c      | 20 ++------------------
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c      |  2 --
 drivers/net/wireless/rtlwifi/usb.c                |  4 ----
 drivers/net/wireless/rtlwifi/wifi.h               |  2 +-
 10 files changed, 10 insertions(+), 39 deletions(-)

-- 
1.8.1
