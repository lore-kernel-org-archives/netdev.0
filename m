From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH 0/5] r8152 bug fixes
Date: Mon, 28 Oct 2013 19:58:09 +0800
Message-ID: <1382961494-2272-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These could fix some driver issues.

Hayes Wang (5):
  net/usb/r8152: fix tx/rx memory overflow
  net/usb/r8152: make sure the tx checksum setting is correct
  net/usb/r8152: modify the tx flow
  net/usb/r8152: fix incorrect type in assignment
  net/usb/r8152: code adjust

 drivers/net/usb/r8152.c | 145 +++++++++++++++++++-----------------------------
 1 file changed, 57 insertions(+), 88 deletions(-)

-- 
1.8.3.1
