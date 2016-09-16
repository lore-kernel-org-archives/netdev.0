From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH 0/2] cxgb4 FR_NSMR_TPTE_WR support
Date: Fri, 16 Sep 2016 07:54:55 -0700
Message-ID: <cover.1474037695.git.swise@opengridcomputing.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
To: dledford@redhat.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:49722 "EHLO
        smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1757207AbcIPO7I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 10:59:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series enables a new work request to optimize small REG_MR
operations.  This is intended for 4.9.  If everyone agrees, I suggest
Doug take both the cxgb4 and iw_cxgb4 patches through his tree.

Thanks,

Steve.

---

Steve Wise (2):
  cxgb4: advertise support for FR_NSMR_TPTE_WR
  iw_cxgb4: add fast-path for small REG_MR operations

 drivers/infiniband/hw/cxgb4/cq.c                | 17 +++++++
 drivers/infiniband/hw/cxgb4/mem.c               |  2 +-
 drivers/infiniband/hw/cxgb4/qp.c                | 67 +++++++++++++++++++++----
 drivers/infiniband/hw/cxgb4/t4.h                |  4 +-
 drivers/infiniband/hw/cxgb4/t4fw_ri_api.h       | 12 +++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  7 +++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |  1 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |  2 +
 9 files changed, 102 insertions(+), 11 deletions(-)

-- 
2.7.0
