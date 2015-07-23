From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 0/3] r8152: issues fix
Date: Thu, 23 Jul 2015 15:09:04 +0800
Message-ID: <1394712342-15778-148-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:40234 "EHLO
	rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbbGWHIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 03:08:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches are used to fix issues.

Hayes Wang (3):
  r8152: fix the issue about U1/U2
  r8152: fix remote wakeup
  r8152: don't enable napi before rx ready

 drivers/net/usb/r8152.c | 103 ++++++++++++++++++++++++++++--------------------
 1 file changed, 60 insertions(+), 43 deletions(-)

-- 
2.4.2
