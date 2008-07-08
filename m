From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RESEND NET-NEXT PATCH 00/20] igb update for net-next
Date: Tue, 08 Jul 2008 15:06:12 -0700
Message-ID: <20080708220046.1518.88457.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
To: jeff@garzik.org, davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754911AbYGHWG1@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is the a resubmit of patches 8-18 from Davem's latest net-next tree.
Patches had to be updated with the changes made from Patrick McHardy's VLAN
patches.

In addition, 2 additional patches have been added to correct a un-used
variable warning and to improve multiqueue AIM support. 

---
Summary:
Alexander Duyck <alexander.h.duyck@intel.com>:
     igb: update ethtool stats to support multiqueue
     igb: add 82576 MAC support
     igb: Add support for quad port WOL and feature flags
     igb: add page recycling support
     igb: add support for in kernel LRO
     net: add netif_napi_del function to allow for removal of napistructs
     igb: update suspend resume
     [new] igb: unused variable warning in igb remove
     [new] igb: Improve multiqueue AIM support

Auke Kok <auke-jan.h.kok@intel.com>:
     igb: reenable CRC stripping in hardware
     igb: Increment driver version

Jeb Cramer <cramerj@intel.com>:
     igb: add DCA support

Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>:
     igb: Introduce multiple TX queues with infrastructure

---
 drivers/net/Kconfig             |    9 
 drivers/net/igb/e1000_82575.c   |  208 +++++++
 drivers/net/igb/e1000_82575.h   |   22 
 drivers/net/igb/e1000_defines.h |   10 
 drivers/net/igb/e1000_hw.h      |    8 
 drivers/net/igb/e1000_mac.c     |    3 
 drivers/net/igb/e1000_mac.h     |    1 
 drivers/net/igb/e1000_regs.h    |    9 
 drivers/net/igb/igb.h           |   53 +
 drivers/net/igb/igb_ethtool.c   |  205 +++++--
 drivers/net/igb/igb_main.c      | 1076 ++++++++++++++++++++++++++++------------
 include/linux/netdevice.h       |   13 
 12 files changed, 1243 insertions(+), 374 deletions(-)

-- 
Cheers,
Jeff
