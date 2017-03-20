From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 0/2] r8152: fix the rx settings of RTL8153
Date: Mon, 20 Mar 2017 16:13:43 +0800
Message-ID: <1394712342-15778-256-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The RMS and the rx early size should base on the same rx size. However,
the RMS is set to 9K bytes now and the rx early depends on mtu. For using
the rx buffer effectively, sync the two settings according to the mtu.

Hayes Wang (2):
  r8152: set the RMS of RTL8153 according to the mtu
  r8152: fix the rx early size of RTL8153

 drivers/net/usb/r8152.c | 23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

-- 
2.7.4
