From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 00/25] ixgb: update to latest
Date: Tue, 08 Jul 2008 15:51:01 -0700
Message-ID: <20080708224858.6925.29725.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18836 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752746AbYGHWvD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:51:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series implements a set of cleanups and bug fixes for the ixgb
driver. 

---
Summary:
Jesse Brandeburg <jesse.brandeburg@intel.com>:
     ixgb: maybe stop tx port missed a piece
     ixgb: repeat 32 bit ioremap cleanup
     ixgb: fix bug in descriptor ring due to prefetch corruption
     ixgb: leave room for extra hardware memory usage
     ixgb: check down state before enable irq
     ixgb: don't allow too small MTU
     ixgb: move time stamp set before setting dma pointer
     ixgb: fix race on rx_buffer_len in mtu change
     ixgb: fix unload race with timers
     ixgb: remove lltx support and update tx routine
     ixgb: update readme text
     ixgb: add copybreak parameter
     ixgb: clean up un-necessary declarations
     ixgb: format all if( to be if (
     ixgb: cleanup space after while
     ixgb: whitespace fixups
     ixgb: fix spelling errors
     ixgb: trivial fix space after for
     ixgb: cleanup checkpatch suggestions that are relevant
     ixgb: rx cleanup performance improvements
     ixgb: clean up assignments inside if statements
     ixgb: audit use of dev_kfree_skb_any
     ixgb: cleanup header
     ixgb: make NAPI the only option and the default
     ixgb: update copyright dates and versions

---
 Documentation/networking/ixgb.txt |  419 +++++++++++++++++++++++--------
 drivers/net/Kconfig               |   14 -
 drivers/net/ixgb/Makefile         |    2 
 drivers/net/ixgb/ixgb.h           |   23 -
 drivers/net/ixgb/ixgb_ee.c        |   28 +-
 drivers/net/ixgb/ixgb_ee.h        |   12 
 drivers/net/ixgb/ixgb_ethtool.c   |  120 ++++----
 drivers/net/ixgb/ixgb_hw.c        |   40 +-
 drivers/net/ixgb/ixgb_hw.h        |    2 
 drivers/net/ixgb/ixgb_ids.h       |   10 
 drivers/net/ixgb/ixgb_main.c      |  512 ++++++++++++++++----------------------
 drivers/net/ixgb/ixgb_osdep.h     |    4 
 drivers/net/ixgb/ixgb_param.c     |   46 +--

-- 
Cheers,
Jeff
