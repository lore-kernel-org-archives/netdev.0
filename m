From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 0/3] r8152: support setting eee by ethtool
Date: Thu, 25 Sep 2014 20:53:59 +0800
Message-ID: <1394712342-15778-46-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Modify some definitions about EEE, and add the support of setting
the EEE through ethtool.

Hayes Wang (3):
  r8152: change the EEE definition
  r8152: add functions to set EEE
  r8152: support ethtool eee

 drivers/net/usb/r8152.c | 246 ++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 209 insertions(+), 37 deletions(-)

-- 
1.9.3
