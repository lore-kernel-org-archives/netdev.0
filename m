From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/6 V2] Some changes for rtlwifi
Date: Mon, 26 Jan 2015 14:42:08 -0600
Message-ID: <1422304934-9239-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:60078 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752869AbbAZUmY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 15:42:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first of these patches changes the logging when an encryption key
is changed. The rest are for changes in the btcoexist driver. Most
contain the code needed to handle the RTL8812AE chips.

All patches are for -next.

V2 - Add license for btcoexist/halbtc8812a1ant.{c,h}
     Improve subject and commit message for patch 5 of series.
     Add comments explaining routine that formats and sends kernel socket.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

Larry Finger (2):
  rtlwifi: Change logging level for key change
  rtlwifi: btcoexist: Remove typedef statements

Troy Tan (4):
  rtlwifi: btcoexist: Add routines for RTL8812AE with single antenna
  rtlwifi: btcoexist: Add routines for RTL8812AE with dual antennae
  rtlwifi: btcoexist: Add routines for RTL8812AE kernel socket
  rtlwifi: btcoexist: Enable new routines for RTL8812AE

 drivers/net/wireless/rtlwifi/btcoexist/Makefile    |    9 +
 .../net/wireless/rtlwifi/btcoexist/halbt_precomp.h |    3 +
 .../wireless/rtlwifi/btcoexist/halbtc8192e2ant.c   |    6 +-
 .../wireless/rtlwifi/btcoexist/halbtc8723b2ant.h   |    6 +-
 .../wireless/rtlwifi/btcoexist/halbtc8812a1ant.c   | 2073 ++++++++++
 .../wireless/rtlwifi/btcoexist/halbtc8812a1ant.h   |  152 +
 .../wireless/rtlwifi/btcoexist/halbtc8812a2ant.c   | 4207 ++++++++++++++++++++
 .../wireless/rtlwifi/btcoexist/halbtc8812a2ant.h   |  177 +
 .../wireless/rtlwifi/btcoexist/halbtc8812a_ext.c   |  921 +++++
 .../wireless/rtlwifi/btcoexist/halbtc8812a_ext.h   |  359 ++
 .../net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c  |  713 +++-
 .../net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h  |  108 +-
 drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.c   |   37 +
 drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.h   |    6 +-
 drivers/net/wireless/rtlwifi/cam.c                 |    2 +-
 drivers/net/wireless/rtlwifi/core.c                |   17 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.h   |   14 -
 drivers/net/wireless/rtlwifi/wifi.h                |   12 +-
 18 files changed, 8590 insertions(+), 232 deletions(-)
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtc8812a1ant.c
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtc8812a1ant.h
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtc8812a2ant.c
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtc8812a2ant.h
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtc8812a_ext.c
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtc8812a_ext.h

-- 
2.1.2
