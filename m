From: David Miller <davem@davemloft.net>
Subject: [GIT] IDE
Date: Fri, 05 Aug 2011 03:28:57 -0700 (PDT)
Message-ID: <20110805.032857.238496289247403195.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Two small fixups, that's all this merge window:

1) Fix abuse of resource IRQ flags, from Thomas Gleixner.

2) Fix PCI device ref leak, from Julia Lawall.

Please pull, thanks a lot!

The following changes since commit 140d0b2108faebc77c6523296e211e509cb9f5f9:

  Do 'shm_init_ns()' in an early pure_initcall (2011-08-04 19:35:59 -1000)

are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/davem/ide.git master

Julia Lawall (1):
      drivers/ide/cy82c693.c: Add missing pci_dev_put

Thomas Gleixner (1):
      ide: Fix irq flags madness

 drivers/ide/cy82c693.c     |    2 ++
 drivers/ide/ide_platform.c |    6 +++++-
 2 files changed, 7 insertions(+), 1 deletions(-)
