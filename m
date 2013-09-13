From: Andre Naujoks <nautsch2@gmail.com>
Subject: [PATCH net 0/3] SLCAN/SLIP fixes and performance
Date: Fri, 13 Sep 2013 19:37:10 +0200
Message-ID: <1379093833-4949-1-git-send-email-nautsch2@gmail.com>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

these are some loosely related patches, that fix an ancient locking problem in
the slip and slcan drivers, add general ASCII-HEX to bin functions for
uppercase ASCII, fix the handling of CAN RTR frames in the slcan driver
and increase the performance for the slcan driver.

As these patches mainly contain fixes for the slip/slcan drivers that require
a tty layer fix included in 3.11, I would suggest to get the patches in via
the net tree for the 3.12 cycle. They should apply properly on the latest net
and mainline tree.

Best regards,
  Andre

Andre Naujoks (3):
  slip/slcan: added locking in wakeup function
  lib: introduce upper case hex ascii helpers
  slcan: rewrite of slc_bump and slc_encaps

 drivers/net/can/slcan.c | 139 +++++++++++++++++++++++++++++++-----------------
 drivers/net/slip/slip.c |   3 ++
 include/linux/kernel.h  |  11 ++++
 lib/hexdump.c           |   2 +
 4 files changed, 106 insertions(+), 49 deletions(-)

-- 
1.8.4.rc3

