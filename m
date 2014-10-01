From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 0/2] r8152: patches about firmware
Date: Wed, 1 Oct 2014 13:25:09 +0800
Message-ID: <1394712342-15778-51-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patches fix the issues when the firmware exists.

For the multiple OS, the firmware may be loaded by the
driver of the other OS. And the Linux driver has influences
on it.

Hayes Wang (2):
  r8152: remove clearing bp
  r8152: disable power cut for RTL8153

 drivers/net/usb/r8152.c | 30 ++----------------------------
 1 file changed, 2 insertions(+), 28 deletions(-)

-- 
1.9.3
