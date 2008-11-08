From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 0/3] Fix WOL for e1000/e1000e/igb
Date: Fri, 07 Nov 2008 17:03:52 -0800
Message-ID: <20081108005940.18278.33953.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:39339
	"EHLO QMTA09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752305AbYKHBEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 20:04:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series implements fixes for WOL for e1000, e1000e, and igb.  Also correct the patch subject line.

---

Rafael J. Wysocki (3):
      igb: Use device_set_wakeup_enable
      e1000: Use device_set_wakeup_enable
      e1000e: Use device_set_wakeup_enable


 drivers/net/e1000/e1000_ethtool.c |    8 ++++++--
 drivers/net/e1000/e1000_main.c    |    1 +
 drivers/net/e1000e/ethtool.c      |    8 ++++++--
 drivers/net/e1000e/netdev.c       |    1 +
 drivers/net/igb/igb_ethtool.c     |    8 ++++++--
 drivers/net/igb/igb_main.c        |    1 +
 6 files changed, 21 insertions(+), 6 deletions(-)

-- 
Cheers,
Jeff
