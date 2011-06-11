From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/13][pull request] Intel Wired LAN Driver Update
Date: Fri, 10 Jun 2011 20:02:08 -0700
Message-ID: <1307761341-5267-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:29360 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756850Ab1FKDCY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2011 23:02:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates for ixgbe.  The updates are
mainly cleanup of DCB code.  There is the addition of Dell CEM
support and a couple of FCoE DDP patches.

The following are changes since commit 1057c42747ebf4d1cbaa2ab6125b92914b8ec622:
  ixgbevf: Update the driver string
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Emil Tantilov (1):
  ixgbe: add support for Dell CEM

John Fastabend (10):
  ixgbe: dcbnl reduce duplicated code and indentation
  ixgbe: consolidate packet buffer allocation
  ixgbe: consolidate MRQC and MTQC handling
  ixgbe: configure minimal packet buffers to support TC
  ixgbe: DCB use existing TX and RX queues
  ixgbe: DCB 82598 devices, tx_idx and rx_idx swapped
  ixgbe: setup redirection table for multiple packet buffers
  ixgbe: fix bit mask for DCB version
  ixgbe: DCB and perfect filters can coexist
  ixgbe: DCB, remove unneeded ixgbe_dcb_txq_to_tc() routine

Vasu Dev (2):
  ixgbe: setup per CPU PCI pool for FCoE DDP
  ixgbe: use per NUMA node lock for FCoE DDP

 drivers/net/ixgbe/ixgbe.h           |    2 -
 drivers/net/ixgbe/ixgbe_82598.c     |   43 ++++
 drivers/net/ixgbe/ixgbe_82599.c     |   40 +----
 drivers/net/ixgbe/ixgbe_common.c    |  240 +++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_common.h    |    5 +
 drivers/net/ixgbe/ixgbe_dcb.c       |   10 +-
 drivers/net/ixgbe/ixgbe_dcb.h       |    7 -
 drivers/net/ixgbe/ixgbe_dcb_82598.c |   43 +----
 drivers/net/ixgbe/ixgbe_dcb_82598.h |    3 +-
 drivers/net/ixgbe/ixgbe_dcb_82599.c |  119 +-----------
 drivers/net/ixgbe/ixgbe_dcb_82599.h |   14 +--
 drivers/net/ixgbe/ixgbe_dcb_nl.c    |   52 ++---
 drivers/net/ixgbe/ixgbe_fcoe.c      |  151 +++++++++++---
 drivers/net/ixgbe/ixgbe_fcoe.h      |   14 +-
 drivers/net/ixgbe/ixgbe_main.c      |  397 +++++++++++++++++------------------
 drivers/net/ixgbe/ixgbe_type.h      |   71 +++++++
 drivers/net/ixgbe/ixgbe_x540.c      |    2 +
 17 files changed, 716 insertions(+), 497 deletions(-)

-- 
1.7.5.2

