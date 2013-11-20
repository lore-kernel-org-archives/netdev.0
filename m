From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net v5 0/4] r8152 bug fixes
Date: Wed, 20 Nov 2013 17:30:53 +0800
Message-ID: <1384939857-13519-1-git-send-email-hayeswang@realtek.com>
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

For the patch #3, I add netif_tx_lock() before checking the
netif_queue_stopped(). Besides, I add checking the skb queue
length before waking the tx queue.

Hayes Wang (4):
  r8152: fix tx/rx memory overflow
  r8152: modify the tx flow
  r8152: support stopping/waking tx queue
  r8152: fix incorrect type in assignment

 drivers/net/usb/r8152.c | 114 +++++++++++++++++++++---------------------------
 1 file changed, 50 insertions(+), 64 deletions(-)

-- 
1.8.3.1
