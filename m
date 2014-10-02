From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/2 NEXT] Some late fixes for rtlwifi
Date: Thu,  2 Oct 2014 12:00:52 -0500
Message-ID: <1412269254-19983-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, troy_tan@realsil.com.cn,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:49995 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751834AbaJBRBK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 13:01:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches fix a Kconfig error for RTL8192EE, and some static checker warnings
reported by Dan Carpenter.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

Larry Finger (2):
  rtlwifi: Fix Kconfig for RTL8192EE
  rtlwifi: Fix static checker warnings for various drivers

 drivers/net/wireless/rtlwifi/Kconfig         |  3 ++-
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c |  7 -------
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c |  4 ----
 drivers/net/wireless/rtlwifi/rtl8192ee/hw.c  | 24 ++++++++++++------------
 drivers/net/wireless/rtlwifi/rtl8192ee/trx.c |  7 -------
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c |  4 ----
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c |  6 ------
 drivers/net/wireless/rtlwifi/rtl8723be/trx.c |  7 -------
 drivers/net/wireless/rtlwifi/rtl8821ae/trx.c |  7 -------
 9 files changed, 14 insertions(+), 55 deletions(-)

-- 
1.8.4.5
