From: Atul Gupta <atul.gupta@chelsio.com>
Subject: [PATCH net-next v3 0/2] cxgb4: Add PTP Hardware Clock (PHC) support
Date: Fri, 30 Jun 2017 17:17:54 +0530
Message-ID: <1498823276-21791-1-git-send-email-atul.gupta@chelsio.com>
Cc: venkatesh@chelsio.com, richardcochran@gmail.com,
        ganeshgr@chelsio.com, Atul Gupta <atul.gupta@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:16657 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752001AbdF3Lwl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 07:52:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds PTP IEEE-1588 support for Chelsio T5/T6 adapters

V3:
	Releasing lock in the exit paths
V2:
	Splitting the patch

Atul Gupta (2):
  cxgb4: Add PTP Hardware Clock (PHC) support
  cxgb4: Support for get_ts_info ethtool method

 drivers/net/ethernet/chelsio/cxgb4/Makefile        |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   9 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c |  19 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  82 +++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c     | 476 +++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.h     |  74 ++++
 drivers/net/ethernet/chelsio/cxgb4/sge.c           | 173 +++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h        |  28 ++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   2 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |  50 +++
 10 files changed, 901 insertions(+), 14 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.h

-- 
1.8.3.1
