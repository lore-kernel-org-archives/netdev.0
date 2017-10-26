From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next 0/8] cxgb4: collect more hardware dumps via ethtool
Date: Thu, 26 Oct 2017 17:18:32 +0530
Message-ID: <cover.1509017929.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, ganeshgr@chelsio.com, nirranjan@chelsio.com,
        indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:32477 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752052AbdJZLuJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 07:50:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches collect more firmware and hardware dumps
via ethool --get-dump facility.

Patch 1 collects hardware logic analyzer dumps.

Patch 2 collects CIM queue configuration dump.

Patch 3 collects RSS dumps.

Patch 4 collects TID info dump.

Patch 5 collects MPS-TCAM dump.

Patch 6 collects PBT tables dump.

Patch 7 collects hardware scheduler and pace table dumps.

Patch 8 collects miscellaneous hardware information, including
path mtu, PM stats, TP clock info, congestion control, and VPD
data dumps.

Thanks,
Rahul

Rahul Lakkireddy (8):
  cxgb4: collect hardware LA dumps
  cxgb4: collect CIM queue configuration dump
  cxgb4: collect RSS dumps
  cxgb4: collect TID info dump
  cxgb4: collect MPS-TCAM dump
  cxgb4: collect PBT tables dump
  cxgb4: collect hardware scheduler dumps
  cxgb4: collect hardware misc dumps

 drivers/net/ethernet/chelsio/cxgb4/cudbg_entity.h  | 159 +++++
 drivers/net/ethernet/chelsio/cxgb4/cudbg_if.h      |  19 +
 drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c     | 746 +++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h     |  54 ++
 .../net/ethernet/chelsio/cxgb4/cudbg_lib_common.h  |   6 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   9 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c   |  82 +++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  57 ++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |   1 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |  31 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |   5 +-
 11 files changed, 1168 insertions(+), 1 deletion(-)

-- 
2.14.1
