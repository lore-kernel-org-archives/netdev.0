From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/3] More fixes to Update rtl8192cu to latest vendor version
Date: Mon, 18 Nov 2013 13:06:54 -0600
Message-ID: <1384801617-22920-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:36155 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450Ab3KRTHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 14:07:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are some additional bits that are in the latest vendor driver.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>

Mark Cave-Ayland (3):
  Bring _rtl92c_phy_iq_calibrate() in line with the vendor driver
    function _PHY_IQCalibrate().
  rtlwifi: rtl8192cu: Bring rtl92cu_phy_bb_config() up to date
  rtlwifi: rtl8192cu: Update table.c

 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c | 39 +++++++++++++++------
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |  2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/phy.c       |  6 +++-
 drivers/net/wireless/rtlwifi/rtl8192cu/table.c     | 40 +++++++++++-----------
 4 files changed, 54 insertions(+), 33 deletions(-)

-- 
1.8.4
