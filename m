From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc-next-2.6 2011-02-15
Date: Tue, 15 Feb 2011 20:12:13 +0000
Message-ID: <1297800733.2584.15.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>,
	Tom Herbert <therbert@google.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:26331 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755313Ab1BOUMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Feb 2011 15:12:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit 263fb5b1bf9265d0e4ce59ff6ea92f478b5b61ea:

  Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6 (2011-02-08 17:19:01 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next-2.6.git for-davem

Multiqueue TX priority support for sfc, and some necessary fixes
elsewhere.

Ben.

Ben Hutchings (5):
      sch_mqprio: Always set num_tc to 0 in mqprio_destroy()
      net: Adjust TX queue kobjects if number of queues changes during unregister
      sfc: Move TX queue core queue mapping into tx.c
      sfc: Distinguish queue lookup from test for queue existence
      sfc: Add TX queues for high-priority traffic

 drivers/net/sfc/efx.c        |   31 ++++----------
 drivers/net/sfc/efx.h        |    2 +
 drivers/net/sfc/ethtool.c    |    6 +-
 drivers/net/sfc/net_driver.h |   64 +++++++++++++++++++++++-------
 drivers/net/sfc/nic.c        |   51 ++++++++++++++++++------
 drivers/net/sfc/regs.h       |    6 +++
 drivers/net/sfc/selftest.c   |    2 +-
 drivers/net/sfc/tx.c         |   90 ++++++++++++++++++++++++++++++++++++++++-
 net/core/dev.c               |    3 +-
 net/sched/sch_mqprio.c       |   14 +++---
 10 files changed, 204 insertions(+), 65 deletions(-)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

