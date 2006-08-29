From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 00/26] e100, e1000, ixgb updates
Date: Tue, 29 Aug 2006 09:41:53 -0700
Message-ID: <20060829164153.6872.1713.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:22794 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S965072AbWH2QgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:36:00 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

Here are updates targeted to branch #upstream from netdev-2.6,
including updates to e100, e1000 and ixgb.

These changes are available through git.

git pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream

and against
 netdev-2.6#upstream 699a71238856b19091503c671bac8abb1e3f9a3a


Summary:

Vasily Averin <vvs@sw.ru>
     e1000: IRQ resources cleanup
     e1000: e1000_probe resources cleanup
     e1000: ring buffers resources cleanup

Jesse Brandeburg <jesse.brandeburg@intel.com>
     e1000: unify WoL capability detection code
     e1000: Add PCI ID 0x10a4 for our new 4-port PCI-Express device
     ixgb: Set a constant blink rate for ixgb adapter identify (1sec on, 1sec off)
     ixgb: Cache-align all TX components of the adapter struct.
     ixgb: Add buffer_info and test like e1000 has.

Christoph Hellwig <hch@lst.de>
     e1000: clean up skb allocation code, patch submitted by Christoph

Jeff Kirsher <jeffrey.t.kirsher@intel.com>
     e1000: Deprecate mii-tool SIOCMIIREG ioctl

Auke Kok <auke-jan.h.kok@intel.com>
     e1000: Whitespace cleanup, cosmetic changes
     e1000: error out if we cannot enable PCI device on resume
     e1000: remove unused part_num reading code
     e1000: Use module param array code
     e1000: Increment driver version to 7.2.7-k2
     e100: Convert e100 to use netdev_alloc_skb().
     e100: reduce time under spinlock
     e100: remove skb->dev assignment
     e100: increment version to 3.5.16-k2
     ixgb: Convert dev_alloc_skb to netdev_alloc_skb.
     ixgb: convert dev->priv to netdev_priv(dev).
     ixgb: recalculate after how many descriptors to wake the queue
     ixgb: remove skb->dev assignment
     ixgb: Increment version to 1.0.112-k2

Linas Vepstas <linas@austin.ibm.com>
     e100: fix error recovery
     ixgb: Add PCI Error recovery callbacks


Cheers,

Auke

---

 drivers/net/e100.c                |   12
 drivers/net/e1000/e1000.h         |    6
 drivers/net/e1000/e1000_ethtool.c |  219 ++++---
 drivers/net/e1000/e1000_hw.c      | 1059 ++++++++++++++++++--------------------
 drivers/net/e1000/e1000_hw.h      |   26
 drivers/net/e1000/e1000_main.c    |  214 +++----
 drivers/net/e1000/e1000_param.c   |  161 +++--
 drivers/net/ixgb/ixgb.h           |    5
 drivers/net/ixgb/ixgb_ethtool.c   |    6
 drivers/net/ixgb/ixgb_main.c      |  140 ++++-
 10 files changed, 981 insertions(+), 867 deletions(-)

---
Auke Kok <auke-jan.h.kok@intel.com>
