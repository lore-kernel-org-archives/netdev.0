From: Jason Baron <jbaron@redhat.com>
Subject: [PATCH 00/11] various fixes v2
Date: Thu, 14 Jul 2011 12:09:06 -0400
Message-ID: <cover.1310657068.git.jbaron@redhat.com>
Cc: joe@perches.com, jim.cromie@gmail.com, bvanassche@acm.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	aloisio.almeida@openbossa.org, netdev@vger.kernel.org
To: gregkh@suse.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

A bunch of dynamic debug fixes and cleanups. Since the last post I've
incorporated review feedback, and added an additional patch, so that
we no longer need to use KERN_CONT.

Thanks,

-Jason

Joe Perches (4):
  dynamic_debug: Add __dynamic_dev_dbg
  dynamic_debug: Consolidate prefix output to single routine
  dynamic_debug: Remove uses of KERN_CONT in dynamic_emit_prefix
  dynamic_debug: Convert printks to pr_<level>

Jason Baron (7):
  dynamic_debug: remove unused control variables
  dynamic_debug: add Jason Baron as maintainer
  dynamic_debug: make netdev_dbg() call __netdev_printk()
  dynamic_debug: make netif_dbg() call __netdev_printk()
  dynamic_debug: consolidate repetitive struct _ddebug descriptor definitions
  dynamic_debug: remove num_enabled accounting
  dynamic_debug: use a single printk() to emit msgs

 MAINTAINERS                   |    6 ++
 drivers/base/core.c           |    5 +-
 include/linux/device.h        |    5 +
 include/linux/dynamic_debug.h |   51 +++++++-----
 include/linux/netdevice.h     |   10 +-
 lib/dynamic_debug.c           |  173 ++++++++++++++++++++++++++++-------------
 net/core/dev.c                |    3 +-
 7 files changed, 171 insertions(+), 82 deletions(-)

-- 
1.7.5.4
