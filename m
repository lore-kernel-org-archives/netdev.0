From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/3i 3.18] Fix more problems with rtlwifi
Date: Wed,  5 Nov 2014 19:10:51 -0600
Message-ID: <1415236254-12274-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:41095 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbaKFBLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 20:11:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of patches fix some additional problems found for rtlwifi,
rtl8192se, and rtl8192ee.

It is certainly possible that rtlwifi is getting too large. For that reason,
my changes for 3.19 will be restricted to identifying common routines, and
moving such code from the individual drivers into driver rtlwifi.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>


Larry Finger (3):
  rtlwifi: Fix setting of tx descriptor for new trx flow
  rtlwifi: Fix errors in descriptor manipulation
  rtlwifi: rtl8192se: Fix connection problems

 drivers/net/wireless/rtlwifi/pci.c           |  16 ++--
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c  | 129 +++++++++++++--------------
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c |   8 +-
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c  |   4 +
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c |  23 +++++
 drivers/net/wireless/rtlwifi/rtl8192se/trx.h |   4 +
 6 files changed, 110 insertions(+), 74 deletions(-)

-- 
2.1.2
