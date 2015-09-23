From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH for-next 0/2]  RDMA/cxgb4: Add iWARP support for T6 adapter
Date: Wed, 23 Sep 2015 17:19:25 +0530
Message-ID: <1443008967-8942-1-git-send-email-hariprasad@chelsio.com>
Cc: dledford@redhat.com, davem@davemloft.net,
	swise@opengridcomputing.com, leedom@chelsio.com,
	nirranjan@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: linux-rdma@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:16031 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753239AbbIWLtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 07:49:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

PATCH 1/2 adds changes like new register, structure and functions in cxgb4
driver for iw_cxgb4 driver, and PATCH 2/2 adds iw_cxgb4 specific code to
support T6 adapter.

This patch series has been created against Doug's linux tree and includes
patches on cxgb4 and iw_cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (2):
  cxgb4: T6 adapter lld support for iw_cxgb4 driver
  iw_cxgb4: Adds support for T6 adapter

 drivers/infiniband/hw/cxgb4/cm.c                  | 317 +++++++++++++---------
 drivers/infiniband/hw/cxgb4/device.c              |  10 +-
 drivers/infiniband/hw/cxgb4/provider.c            |   2 +-
 drivers/infiniband/hw/cxgb4/qp.c                  |  16 +-
 drivers/infiniband/hw/cxgb4/t4.h                  |   5 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h        |  41 +--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c   |  22 ++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h    |   2 +
 drivers/net/ethernet/chelsio/cxgb4/t4_chip_type.h |  85 ++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h       |  48 ++++
 10 files changed, 362 insertions(+), 186 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/t4_chip_type.h

-- 
2.3.4
