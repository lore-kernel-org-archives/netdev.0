From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 26 Aug 2009 20:50:05 -0700 (PDT)
Message-ID: <20090826.205005.08658813.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752750AbZH0Dty@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Two fixes:

1) Fix smc91x build on SMP, from Alexey Dobriyan

2) Handle out-of-memory situations more correctly when trying
   to refill the RX ring buffers in virtio_net driver.  From Rusty
   Russell.  Based upon user reports.

Please pull, thanks a lot!

The following changes since commit f415c413f458837bd0c27086b79aca889f9435e4:
  Linus Torvalds (1):
        Merge git://git.kernel.org/.../davem/net-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexey Dobriyan (1):
      smc91x: fix compilation on SMP

Rusty Russell (1):
      virtio: net refill on out-of-memory

 drivers/net/smc91x.c     |    2 +-
 drivers/net/virtio_net.c |   61 ++++++++++++++++++++++++++++++++++-----------
 2 files changed, 47 insertions(+), 16 deletions(-)
