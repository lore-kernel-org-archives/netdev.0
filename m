From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 0/2] r8152: code adjustment
Date: Thu, 7 Jan 2016 17:51:10 +0800
Message-ID: <1394712342-15778-171-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adjust test_bit(), clear_bit(), disable_aldps(), and enable_aldps().

Hayes Wang (2):
  r8152: use test_and_clear_bit
  r8152: adjust ALDPS function

 drivers/net/usb/r8152.c | 92 +++++++++++++++++++++----------------------------
 1 file changed, 40 insertions(+), 52 deletions(-)

-- 
2.4.3
