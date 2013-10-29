From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 0/3] r8152 bug fixes
Date: Tue, 29 Oct 2013 15:56:14 +0800
Message-ID: <1383033377-1178-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These could fix some driver issues.

Hayes Wang (3):
  r8152: fix tx/rx memory overflow
  r8152: modify the tx flow
  r8152: fix incorrect type in assignment

 drivers/net/usb/r8152.c | 100 +++++++++++++++++-------------------------------
 1 file changed, 36 insertions(+), 64 deletions(-)

-- 
1.8.3.1
