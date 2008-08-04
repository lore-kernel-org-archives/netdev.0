From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [UPDATED PATCH 0/7] igb fixes and cleanups
Date: Mon, 04 Aug 2008 14:59:24 -0700
Message-ID: <20080804215531.16188.73257.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:6372 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752745AbYHDV7k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Aug 2008 17:59:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,
     There was a problem found in patches 4-6 in the last submission, where the changes made would cause problems for 82576 with 5 queues or more. So here is an undated patch set which resolves the problems seen.

---
Summary:
Alexander Duyck <alexander.h.duyck@intel.com>:
     igb: fix comments
     igb: fix null pointer dereference seen with fiber NICs
     igb: fixes 82576 serdes init to correctly support manual flow control changes
     igb: correct issue of set_mta member of mac.ops not being populated
     igb: remove three redundant functions left in the code
     igb: remove igb_init_managability as it is deprecated
     igb: remove 82576 quad adapter

---
 drivers/net/igb/e1000_82575.c   |   75 +++--------------------------------
 drivers/net/igb/e1000_82575.h   |    1 
 drivers/net/igb/e1000_defines.h |    1 
 drivers/net/igb/e1000_hw.h      |    2 
 drivers/net/igb/e1000_mac.c     |   84 ----------------------------------------
 drivers/net/igb/e1000_mac.h     |    5 --
 drivers/net/igb/e1000_regs.h    |    3 -
 drivers/net/igb/igb_ethtool.c   |    9 ----
 drivers/net/igb/igb_main.c      |   41 +------------------
 9 files changed, 14 insertions(+), 207 deletions(-)

-- 
Cheers,
Jeff
