From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 0/2] r8152: adjust runtime suspend/resume
Date: Tue, 13 Jun 2017 15:14:38 +0800
Message-ID: <1394712342-15778-275-Taiwan-albertk@realtek.com>
References: <1394712342-15778-272-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-272-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

v2:
For #1, replace GFP_KERNEL with GFP_NOIO for usb_submit_urb().

v1:
Improve the flow about runtime suspend/resume and make the code
easy to read.

Hayes Wang (2):
  r8152: split rtl8152_resume function
  r8152: move calling delay_autosuspend function

 drivers/net/usb/r8152.c | 107 ++++++++++++++++++++++++++++--------------------
 1 file changed, 62 insertions(+), 45 deletions(-)

-- 
2.7.4
