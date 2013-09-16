From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/8i V2] rtlwifi: Patches to fix problems shown by smatch
Date: Mon, 16 Sep 2013 13:55:14 -0500
Message-ID: <1379357722-17687-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:60241 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753Ab3IPSzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 14:55:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix smatch warnings and errors in the rtlwifi family of drivers.

V2 addresses comments by David Laight and Sergei Shtylyov.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

Larry Finger (8):
  rtlwifi: rtl8192du: Fix smatch errors in /rtl8192de/dm.c
  rtlwifi: rtl8192de: Fix smatch warnings in rtl8192de/hw.c
  rtlwifi: rtl8192cu: Fix smatch warning in rtl8192cu/trx.c
  rtlwifi: rtl8192_common: Fix smatch errors and warnings in
    rtl8192c/dm_common.c
  [PATCH 5/7: rtlwifi: Fix smatch warning in pci.c
  rtlwifi: Fix smatch warnings in usb.c
  rtlwifi: rtl8188ee: Fix smatch warning in rtl8188ee/hw.c
  rtlwifi: Remove variable 'noise' from rtl_stats struct

 drivers/net/wireless/rtlwifi/pci.c                | 1 -
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c       | 1 +
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c      | 1 -
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c | 4 +++-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c      | 1 -
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c      | 2 --
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c       | 8 ++++++--
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c       | 2 ++
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c      | 1 -
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c      | 1 -
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c      | 1 -
 drivers/net/wireless/rtlwifi/usb.c                | 8 +++++---
 drivers/net/wireless/rtlwifi/wifi.h               | 1 -
 13 files changed, 17 insertions(+), 15 deletions(-)

-- 
1.8.1.4
