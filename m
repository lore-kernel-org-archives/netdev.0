From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH for 3.19 0/3] rtlwifi: Various updates/fixes
Date: Wed, 14 Jan 2015 11:37:13 -0600
Message-ID: <1421257036-5382-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:50741 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752361AbbANRh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 12:37:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first of these patches removes a logging statement that is no longer
needed. The other two fix a number of bugs in rtl8192ee that have been
found since the original inclusion of this driver.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>


Larry Finger (1):
  rtlwifi: Remove logging statement that is no longer needed

Troy Tan (2):
  rtlwifi: Fix handling of new style descriptors
  rtlwifi: rtl8192ee: Implement new handling of FIFO descriptor buffer

 drivers/net/wireless/rtlwifi/pci.c           |  36 ++++--
 drivers/net/wireless/rtlwifi/rtl8192ee/hw.c  | 167 +++++++++++++++++++++----
 drivers/net/wireless/rtlwifi/rtl8192ee/reg.h |   2 +
 drivers/net/wireless/rtlwifi/rtl8192ee/sw.c  |   3 +-
 drivers/net/wireless/rtlwifi/rtl8192ee/trx.c | 175 +++++++++++----------------
 drivers/net/wireless/rtlwifi/rtl8192ee/trx.h |   4 +-
 drivers/net/wireless/rtlwifi/wifi.h          |   1 +
 7 files changed, 242 insertions(+), 146 deletions(-)

-- 
2.1.2
