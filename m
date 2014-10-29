From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 0/3] r8152: patches for autosuspend
Date: Wed, 29 Oct 2014 11:12:14 +0800
Message-ID: <1394712342-15778-69-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are unexpected processes when enabling autosuspend.
These patches are used to fix them.

Hayes Wang (3):
  r8152: clear SELECTIVE_SUSPEND when autoresuming
  r8152: reset tp->speed before autoresuming in open function
  r8152: check WORK_ENABLE in suspend function

 drivers/net/usb/r8152.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

-- 
1.9.3
