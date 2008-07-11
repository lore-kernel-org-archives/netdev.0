From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 0/9] e1000: update and cleanups
Date: Fri, 11 Jul 2008 15:16:54 -0700
Message-ID: <20080711221442.3255.16180.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:5722 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754263AbYGKWQ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 18:16:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series implements several cleanups, removes non NAPI code and
allows for ioport free driver for silicon not needing ioport for e1000 driver.

---
Summary:
Francois Romieu <romieu@fr.zoreil.com>:
     e1000: delete non NAPI code from the driver

Jeff Kirsher <jeffrey.t.kirsher@intel.com>:
     e1000: remove email reference

Joe Perches <joe@perches.com>:
     e1000: neaten function declarations
     e1000: Use hw, er32, and ew32
     e1000: Move extern function definitions to e1000.h
     e1000: Remove spaces after casts and function names
     e1000: checkpatch clean
     e1000: Move assignments in tests before test

Taku Izumi <izumi.taku@jp.fugitsu.com>:
     e1000: make ioport free

---
 Documentation/networking/e1000.txt |   14 
 drivers/net/Kconfig                |   14 
 drivers/net/e1000/e1000.h          |   75 +
 drivers/net/e1000/e1000_ethtool.c  |  566 ++++++-------
 drivers/net/e1000/e1000_hw.c       | 1373 ++++++++++++++-------------------
 drivers/net/e1000/e1000_main.c     | 1516 +++++++++++++++++--------------------
 drivers/net/e1000/e1000_osdep.h    |   16 
 drivers/net/e1000/e1000_param.c    |   16 
 8 files changed, 1645 insertions(+), 1945 deletions(-)

-- 
Cheers,
Jeff
