From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 0/2] r8152: adjust r8152_submit_rx
Date: Fri, 19 Dec 2014 16:55:58 +0800
Message-ID: <1394712342-15778-107-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Avoid r8152_submit_rx() from submitting rx during unexpected
moment. This could reduce the time of stopping rx.

For patch #1, the tp->speed should be updated early. Then,
the patch #2 could use it to check the current linking status.

Hayes Wang (2):
  r8152: adjust set_carrier
  r8152: check the status before submitting rx

 drivers/net/usb/r8152.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

-- 
2.1.0
