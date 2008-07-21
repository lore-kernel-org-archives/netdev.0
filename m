From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking build fix.
Date: Sun, 20 Jul 2008 18:13:18 -0700 (PDT)
Message-ID: <20080720.181318.17443249.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38469
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754385AbYGUBNS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 21:13:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull to get this build fix for a problem Stephen
Rothwell reported with NET_SCHED disabled.

Thanks!

The following changes since commit fb65a7c091529bfffb1262515252c0d0f6241c5c:
  David S. Miller (1):
        iucv: Fix bad merging.

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

David S. Miller (1):
      pkt_sched: Fix build with NET_SCHED disabled.

 include/net/sch_generic.h |    2 ++
 net/sched/sch_generic.c   |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)
