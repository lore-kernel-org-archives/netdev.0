From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 0/2] r8152: fix autosuspend issue
Date: Tue, 10 Jan 2017 17:04:05 +0800
Message-ID: <1394712342-15778-229-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Avoid rx is split into two parts when runtime suspend occurs.

Hayes Wang (2):
  r8152: split rtl8152_suspend function
  r8152: fix rx issue for runtime suspend

 drivers/net/usb/r8152.c | 80 +++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 64 insertions(+), 16 deletions(-)

-- 
2.7.4
