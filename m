From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Tue, 25 Aug 2009 20:50:59 -0700 (PDT)
Message-ID: <20090825.205059.205531620.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43406
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756648AbZHZDuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 23:50:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Fix for warning introduced unintentionally last round, spotted by
   Stephen Rothwell.

2) Fix for two incorrect netdev_ops conversions in IRDA, from
   Alex Beregalov.

Please pull, thanks a lot!

The following changes since commit 7c0a57d5c47bcfc492b3139e77400f888a935c44:
  Linus Torvalds (1):
        Merge branch 'fixes' of git://git.marvell.com/orion

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexander Beregalov (2):
      irda/au1k_ir: fix broken netdev_ops conversion
      irda/sa1100_ir: fix broken netdev_ops conversion

David S. Miller (1):
      pkt_sched: Fix bogon in tasklet_hrtimer changes.

 drivers/net/irda/au1k_ir.c   |    4 ----
 drivers/net/irda/sa1100_ir.c |    4 ----
 net/sched/sch_api.c          |    2 +-
 net/sched/sch_cbq.c          |    2 +-
 4 files changed, 2 insertions(+), 10 deletions(-)
