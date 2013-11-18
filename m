From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 00/12]  Fix various problems with the rtl8192cu driver
Date: Mon, 18 Nov 2013 11:11:24 -0600
Message-ID: <1384794696-20314-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:41398 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751199Ab3KRRLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 12:11:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver rtl8192cu has not had very high throughput, and it has not maintained
a stable connection. This set of patches improve the gain control routines,
which helps solve both problems.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>

Larry Finger (12):
  rtlwifi: rtl8192c: Prevent reconnect attempts if not connected
  rtlwifi: rtl8192cu: Add new firmware
  rtlwifi: Redo register save locations
  rtlwifi: Set the link state
  rtlwifi: rtl8192c: Add new definitions in the dm_common header
  rtlwifi: Increase the RX queue length for USB drivers
  rtlwifi: Update beacon statistics for USB driver
  rtlwifi: rtl8192c: Add routines to save/restore power index registers
  rtlwifi: rtl8192cu: Update the power index registers
  rtlwifi: rtl8192cu: Fix some code in RF handling
  rtlwifi:  Add missing code to PWDB statics routine
  rtlwifi: rtl8192c: Update dynamic gain calculations

 drivers/net/wireless/rtlwifi/base.c               |   3 +-
 drivers/net/wireless/rtlwifi/core.c               |  11 +
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c | 318 +++++++++++++++-------
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.h |  14 +
 drivers/net/wireless/rtlwifi/rtl8192cu/dm.c       |   6 +
 drivers/net/wireless/rtlwifi/rtl8192cu/dm.h       |   3 +
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.c       |  27 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c       |  16 +-
 drivers/net/wireless/rtlwifi/stats.c              |  14 +
 drivers/net/wireless/rtlwifi/usb.c                |   4 +-
 drivers/net/wireless/rtlwifi/wifi.h               |  33 +--
 11 files changed, 317 insertions(+), 132 deletions(-)

-- 
1.8.4
