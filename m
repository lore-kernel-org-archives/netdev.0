From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 0/2] r8152: adjust runtime suspend/resume
Date: Mon, 12 Jun 2017 16:21:23 +0800
Message-ID: <1394712342-15778-272-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Improve the flow about runtime suspend/resume and make the code
easy to read.

Hayes Wang (2):
  r8152: split rtl8152_resume function
  r8152: move calling delay_autosuspend function

 drivers/net/usb/r8152.c | 107 ++++++++++++++++++++++++++++--------------------
 1 file changed, 62 insertions(+), 45 deletions(-)

-- 
2.7.4
