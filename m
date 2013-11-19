From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net v4 0/4] r8152 bug fixes
Date: Tue, 19 Nov 2013 11:25:07 +0800
Message-ID: <1384831511-1625-1-git-send-email-hayeswang@realtek.com>
References: <1384502279-9959-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1384502279-9959-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For the patch #1, I modify the type of the variable "pkt_len" from "unsigned"
to "unsigned int".

Hayes Wang (4):
  r8152: fix tx/rx memory overflow
  r8152: modify the tx flow
  r8152: support stopping/waking tx queue
  r8152: fix incorrect type in assignment

 drivers/net/usb/r8152.c | 109 ++++++++++++++++++++----------------------------
 1 file changed, 45 insertions(+), 64 deletions(-)

-- 
1.8.3.1
