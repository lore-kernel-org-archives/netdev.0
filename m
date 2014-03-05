From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/3] rtlwifi: Miscellaneous fixups
Date: Wed,  5 Mar 2014 17:25:58 -0600
Message-ID: <1394061961-11682-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:35192 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757235AbaCEX0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 18:26:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of patches fixes a logged warning of a switch case that is not
handled, and some Sparse/Smatch warnings for rtl8723be.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>

Larry Finger (3):
  rtlwifi: rtl8192ce: Handle unused switch case
  rtlwifi: rtl8723be: Fix sparse errors
  rtlwifi: rtl8723be: Fix smatch warnings

 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c | 4 +++-
 drivers/net/wireless/rtlwifi/rtl8723be/fw.c | 8 --------
 drivers/net/wireless/rtlwifi/rtl8723be/hw.c | 3 +--
 drivers/net/wireless/rtlwifi/rtl8723be/sw.c | 2 +-
 drivers/net/wireless/rtlwifi/wifi.h         | 2 +-
 5 files changed, 6 insertions(+), 13 deletions(-)

-- 
1.8.4.5
