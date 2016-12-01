From: Varun Prakash <varun@chelsio.com>
Subject: [PATCH scsi 0/3] cxgb4i: add support for Chelsio T6 adapters
Date: Thu,  1 Dec 2016 20:28:26 +0530
Message-ID: <cover.1480603332.git.varun@chelsio.com>
Cc: linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
        davem@davemloft.net, indranil@chelsio.com, varun@chelsio.com
To: martin.petersen@oracle.com, jejb@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:64194 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbcLAO7f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 09:59:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support for Chelsio T6 adapters
in iSCSI initiator offload driver(cxgb4i).

Varun Prakash (3):
  scsi: cxgb4i: use cxgb4_tp_smt_idx() to get smt_idx
  scsi: cxgb4i,libcxgbi: add active open cmd for T6 adapters
  scsi: cxgb4i,libcxgbi,cxgb4: add T6 iSCSI completion feature

 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h |  13 ++
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c          | 309 ++++++++++++++++++++++++----
 drivers/scsi/cxgbi/libcxgbi.c               |  25 ++-
 drivers/scsi/cxgbi/libcxgbi.h               |   1 +
 4 files changed, 305 insertions(+), 43 deletions(-)

-- 
2.0.2
