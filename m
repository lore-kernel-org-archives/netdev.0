From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 14 May 2012 00:05:55 -0400 (EDT)
Message-ID: <20120514.000555.1842884084717866000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The main purpose of this pull request is to fix up the erroneous
bonding patch I applied last round.  I meant to apply v4 of the patch
from Jiri but I applied v3 by accident.  Mea culpa.

Also, eagle eyed Dan Carpenter noticed that openvswitch has one of
those "X = alloc(); if (!Y)" mistakes, test the proper pointer
instead.

Please pull, thanks a lot!

The following changes since commit cf00c55e3d30b242d6f6530e61a7bc828124f0a3:

  Merge tag 'scsi-fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi (2012-05-12 13:02:31 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 8aa51d64c1f526e43b1e7f89fb8b98c2fd583f4b:

  openvswitch: checking wrong variable in queue_userspace_packet() (2012-05-13 15:47:34 -0400)

----------------------------------------------------------------
Dan Carpenter (1):
      openvswitch: checking wrong variable in queue_userspace_packet()

David S. Miller (1):
      bonding: Fix LACPDU rx_dropped commit.

 drivers/net/bonding/bond_alb.c |   12 +++++++-----
 drivers/net/bonding/bonding.h  |    2 +-
 net/openvswitch/datapath.c     |    2 +-
 3 files changed, 9 insertions(+), 7 deletions(-)
