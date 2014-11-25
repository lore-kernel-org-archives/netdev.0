From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/2 3.18] Fixes for Bug #88811
Date: Tue, 25 Nov 2014 10:32:05 -0600
Message-ID: <1416933127-25912-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Valerio Passini <valerio.passini@unicam.it>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:64851 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbaKYQcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 11:32:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches are needed to fix a regression introduced when
driver rtl8821ae was moved from staging to the regular wireless tree.

I am sorry that these fixes are so late in the 3.18 cycle.

Larry


Larry Finger (2):
  rtlwifi: rtl8821ae: Fix 5G detection problem
  rtlwifi: Change order in device startup

 drivers/net/wireless/rtlwifi/pci.c          | 20 ++++++++++----------
 drivers/net/wireless/rtlwifi/rtl8821ae/hw.c |  5 +++--
 2 files changed, 13 insertions(+), 12 deletions(-)

-- 
2.1.2
