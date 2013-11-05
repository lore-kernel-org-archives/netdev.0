From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/3] Fix incorrect returned signal strengths
Date: Tue,  5 Nov 2013 15:15:27 -0600
Message-ID: <1383686130-5113-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:32870 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754726Ab3KEVPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 16:15:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In rtl8192se, rtl8192cu, and rtl8192du, the routines that process the
received frames get the signal strength from the RSSI value. Unfortunately,
that value is non-zero only if the interface is associated with the AP. As
a result, scans return incorrect values for the strength, which causes
unwanted attempts to roam.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

Larry Finger (3):
  rtlwifi: rtl8192se: Fix incorrect signal strength for unassociated AP
  rtlwifi: rtl8192cu: Fix incorrect signal strength for unassociated AP
  rtlwifi: rtl8192de: Fix incorrect signal strength for unassociated AP

 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c | 2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c | 2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

-- 
1.8.4
