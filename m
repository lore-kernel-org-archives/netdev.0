From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 01 Jun 2009 03:25:00 -0700 (PDT)
Message-ID: <20090601.032500.54712490.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46743
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752438AbZFAKZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 06:25:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Things are really winding down, and the bug fix rate is down
to at best a trickle.  It might be time to do that final
release soon :-)

1) Fix data access synchronization error in cls_cgroup

2) Add some missing device IDs to 3c505, ath1e, and rtl8187

3) Several small netfilter fixes via Patrick McHardy and the
   netfilter crew.

4) mac8390 and bfin_mac build fixes

5) Bad mlx4_en TX locking causes crash.

6) CXGB3 bug fixes vis Divy Le ray

Please pull, thanks a lot!

The following changes since commit 3218911f839b6c85acbf872ad264ea69aa4d89ad:
  Linus Torvalds (1):
        Merge git://git.infradead.org/~dwmw2/mtd-2.6.30

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alex Chiang (1):
      atlx: move modinfo data from atlx.h to atl1.c

David S. Miller (2):
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

Divy Le Ray (2):
      cxgb3: fix dma mapping regression
      cxgb3: link fault fixes

Finn Thain (1):
      mac8390: fix build with NET_POLL_CONTROLLER

Florian Fainelli (1):
      MAINTAINERS: take maintainership of the cpmac Ethernet driver

Greg Kroah-Hartman (1):
      ath1e: add new device id for asus hardware

Jesper Dangaard Brouer (1):
      netfilter: xt_hashlimit does a wrong SEQ_SKIP

John W. Linville (2):
      at76c50x-usb: avoid mutex deadlock in at76_dwork_hw_scan
      rtl8187: add USB ID for Linksys WUSB54GC-EU v2 USB wifi dongle

Jozsef Kadlecsik (1):
      netfilter: nf_ct_tcp: fix accepting invalid RST segments

Maciej W. Rozycki (1):
      3c509: Add missing EISA IDs

Matt Kraai (1):
      net/firmare: Ignore .cis files

Mike Frysinger (1):
      bfin_mac: fix build error due to net_device_ops convert

Pablo Neira Ayuso (2):
      netfilter: nf_ct_dccp: add missing DCCP protocol changes in event cache
      netfilter: nfnetlink_log: fix wrong skbuff size	calculation

Paul Menage (1):
      cls_cgroup: read classid atomically in classifier

Xiaotian Feng (1):
      gianfar: fix babbling rx error event bug

Yevgeny Petrilin (1):
      mlx4_en: Fix a kernel panic when waking tx queue

 MAINTAINERS                                |    7 ++++++
 drivers/net/3c509.c                        |    4 +++
 drivers/net/atl1e/atl1e_main.c             |    1 +
 drivers/net/atlx/atl1.c                    |    6 +++++
 drivers/net/atlx/atlx.h                    |    6 -----
 drivers/net/bfin_mac.c                     |   29 +++++++++++++--------------
 drivers/net/cxgb3/adapter.h                |    4 +-
 drivers/net/cxgb3/cxgb3_main.c             |    8 ++++--
 drivers/net/cxgb3/sge.c                    |   11 ++++-----
 drivers/net/cxgb3/t3_hw.c                  |    5 ++++
 drivers/net/gianfar.h                      |    2 +-
 drivers/net/mac8390.c                      |    2 +-
 drivers/net/mlx4/en_tx.c                   |    8 +++---
 drivers/net/wireless/Kconfig               |    1 +
 drivers/net/wireless/at76c50x-usb.c        |   12 +++++-----
 drivers/net/wireless/rtl818x/rtl8187_dev.c |    2 +
 firmware/cis/.gitignore                    |    1 +
 include/linux/netfilter/nf_conntrack_tcp.h |    4 +++
 net/netfilter/nf_conntrack_proto_dccp.c    |    4 +++
 net/netfilter/nf_conntrack_proto_tcp.c     |   18 +++++++++++++++++
 net/netfilter/nfnetlink_log.c              |    6 +++++
 net/netfilter/xt_hashlimit.c               |    2 +-
 net/sched/cls_cgroup.c                     |   22 ++++++++++----------
 23 files changed, 109 insertions(+), 56 deletions(-)
 create mode 100644 firmware/cis/.gitignore
