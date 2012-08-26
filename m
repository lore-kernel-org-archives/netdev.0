From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/5] dev_<level> and dynamic_debug cleanups
Date: Sun, 26 Aug 2012 04:25:25 -0700
Message-ID: <cover.1345978012.git.joe@perches.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Baron <jbaron@redhat.com>,
	Jim Cromie <jim.cromie@gmail.com>, Kay Sievers <kay@vrfy.org>,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The recent commit to fix dynamic_debug was a bit unclean.
Neaten the style for dynamic_debug.
Reduce the stack use of message logging that uses netdev_printk
Add utility functions dev_printk_emit and dev_vprintk_emit for /dev/kmsg.

Joe Perches (5):
  dev_dbg/dynamic_debug: Update to use printk_emit, optimize stack
  netdev_printk/dynamic_netdev_dbg: Directly call printk_emit
  netdev_printk/netif_printk: Remove a superfluous logging colon
  dev: Add dev_vprintk_emit and dev_printk_emit
  device and dynamic_debug: Use dev_vprintk_emit and dev_printk_emit

 drivers/base/core.c       |   87 +++++++++++++++++++++++++++++---------------
 include/linux/device.h    |   17 +++++++--
 include/linux/netdevice.h |    3 --
 lib/dynamic_debug.c       |   56 ++++++++++++++++++++++-------
 net/core/dev.c            |   20 +++++++----
 5 files changed, 126 insertions(+), 57 deletions(-)

-- 
1.7.8.111.gad25c.dirty
