From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 00/13] r8152: new features
Date: Wed, 5 Mar 2014 14:49:15 +0800
Message-ID: <1394002168-3193-1-git-send-email-hayeswang@realtek.com>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Besides the adjustment of the code, support rx checksum,
TCP large send, and IPv6.

v2:
 - Split "support rx checksum" into two patches.
 - Don't drop the packet, even though the rx checksum fail for
   "support rx checksum".
 - Replace r8152_xmit_frags() with skb_copy_bits() for "support TSO".
 - Fix the issue of reording the packets for "support IPv6".

Hayes Wang (13):
  r8152: deal with the empty line and space
  r8152: replace tp->netdev with netdev
  r8152: remove rtl8152_get_stats
  r8152: replace spin_lock_irqsave and spin_unlock_irqrestore
  r8152: check tx agg list before spin lock
  r8152: up the priority of the transmission
  r8152: calculate the dropped packets for rx
  r8152: support rx checksum
  r8152: support TSO
  r8152: support IPv6
  r8152: reduce the numbers of the bulks
  r8152: add additional parameter for non x86 platform
  r8152: modify the tx timeout funcfion

 drivers/net/usb/r8152.c | 411 +++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 318 insertions(+), 93 deletions(-)

--
1.8.4.2
