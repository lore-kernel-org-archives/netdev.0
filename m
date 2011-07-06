From: Jason Baron <jbaron@redhat.com>
Subject: [PATCH 00/10] dynamic_debug: various fixes
Date: Wed, 6 Jul 2011 13:24:31 -0400
Message-ID: <cover.1309967232.git.root@dhcp-100-18-164.bos.redhat.com>
Cc: joe@perches.com, jim.cromie@gmail.com, bvanassche@acm.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	aloisio.almeida@openbossa.org, netdev@vger.kernel.org
To: gregkh@suse.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Various dynamic debug fixes and cleanups, and a patch to add myself as
maintainer. Hopefully, nobody will object too loudly :)

Thanks,

-Jason


Joe Perches (4):
  dynamic_debug: Add __dynamic_dev_dbg
  dynamic_debug: Consolidate prefix output to single routine
  dynamic_debug: Remove uses of KERN_CONT in dynamic_emit_prefix
  dynamic_debug: Convert printks to pr_<level>

Jason Baron (6):
  dynamic_debug: remove unused control variables
  dynamic_debug: add myslef as maintainer
  dynamic_debug: make netdev_dbg() call __netdev_printk()
  dynamic_debug: make netif_dbg() call __netdev_printk()
  dynamic_debug: consolidate repetitive struct _ddebug descriptor
    definitions
  dynamic_debug: remove num_enabled accounting

 MAINTAINERS                   |    6 ++
 drivers/base/core.c           |    5 +-
 include/linux/device.h        |    5 +
 include/linux/dynamic_debug.h |   58 ++++++++++-----
 include/linux/netdevice.h     |   12 ++--
 lib/dynamic_debug.c           |  165 ++++++++++++++++++++++++++++-------------
 net/core/dev.c                |    3 +-
 7 files changed, 172 insertions(+), 82 deletions(-)

-- 
1.7.5.4
