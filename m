From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 0/3] r8152: fix known issues
Date: Thu, 16 Jun 2016 10:55:16 +0800
Message-ID: <1394712342-15778-179-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:51742 "EHLO
	rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753224AbcFPCzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 22:55:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches fix some known issues.

Hayes Wang (3):
  r8152: disable MAC clock speed down
  r8152: reset the bmu
  r8152: correct the rx early size

 drivers/net/usb/r8152.c | 37 ++++++++++++++++++++++++++-----------
 1 file changed, 26 insertions(+), 11 deletions(-)

-- 
2.4.11
