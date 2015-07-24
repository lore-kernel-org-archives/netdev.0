From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net v2 0/3] r8152: issues fix
Date: Fri, 24 Jul 2015 13:54:22 +0800
Message-ID: <1394712342-15778-152-Taiwan-albertk@realtek.com>
References: <1394712342-15778-148-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-148-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

v2:
Replace patch #2 with "r8152: fix wakeup settings".

v1:
These patches are used to fix issues.

Hayes Wang (3):
  r8152: fix the issue about U1/U2
-  r8152: fix remote wakeup
+  r8152: fix wakeup settings
  r8152: don't enable napi before rx ready

 drivers/net/usb/r8152.c | 103 ++++++++++++++++++++++++++++--------------------
 1 file changed, 60 insertions(+), 43 deletions(-)

-- 
2.4.2
