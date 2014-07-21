From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH 0/5] Misc. fix for cxgb4 and iw_cxgb4
Date: Mon, 21 Jul 2014 20:55:11 +0530
Message-ID: <1405956316-13591-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:32791
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752423AbaGUPTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 11:19:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
This patch series adds support to enchance error reporting, log detailed
warning for negative advice, support query_qp verb and advertise correct
device max attributes for iwarp.

The patches series is created against 'net-next' tree.
And includes patches on cxgb4 and iw_cxgb4 driver.

Since this patch-series contains changes which are dependent on commit id
4c2c5763 ("cxgb4/iw_cxgb4: use firmware ord/ird resource limits") of net-next
tree we would like to request this patch series to get merged via David Miller's
'net-next' tree.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks 

Hariprasad Shenai (5):
  cxgb4: Add the MC1 registers to read in the interrupt handler
  iw_cxgb4: log detailed warnings for negative advice
  iw_cxgb4: Support query_qp() verb
  iw_cxgb4: advertise the correct device max attributes
  iw_cxgb4: Don't limit TPTE count to 32KB

 drivers/infiniband/hw/cxgb4/cm.c             |   29 ++++++++++++++----
 drivers/infiniband/hw/cxgb4/cq.c             |    8 +----
 drivers/infiniband/hw/cxgb4/device.c         |   16 +++++-----
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h       |    2 +-
 drivers/infiniband/hw/cxgb4/provider.c       |    4 +-
 drivers/infiniband/hw/cxgb4/qp.c             |   41 +++++++++++++++++---------
 drivers/infiniband/hw/cxgb4/t4.h             |    3 --
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c   |   16 ++++++++--
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h |    3 ++
 9 files changed, 78 insertions(+), 44 deletions(-)
