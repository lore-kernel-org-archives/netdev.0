From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 0/3] cxgb4/cxgb4i: add iscsi LRO  support for chelsio t4/t5 adapters
Date: Thu,  7 Jan 2016 14:54:04 +0530
Message-ID: <1452158647-9714-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, JBottomley@odin.com,
	martin.petersen@oracle.com, leedom@chelsio.com, kxie@chelsio.com,
	manojmalviya@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:8568 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750707AbcAGJWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 04:22:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

This patch series adds LRO iscsi support for chelsio T4/T5 adapters.

This patch series has been created against net-next tree and includes
patches on cxgb4 and cxgb4i driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

V2:
 Missed a new header file cxgbi_lro.h in PATCH 2/3. Adding it.
 Based on failure reported by by kbuild test bot <lkp@intel.com>

Hariprasad Shenai (3):
  cxgb4: Add LRO infrastructure for cxgb4i driver
  libcxgbi: add pdu parsing of LRO'ed skbs
  cxgb4i: add iscsi LRO for chelsio t4/t5 adapters

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  15 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  40 ++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |   5 +
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |  10 +-
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c              | 396 +++++++++++++++++++++-
 drivers/scsi/cxgbi/cxgbi_lro.h                  |  72 ++++
 drivers/scsi/cxgbi/libcxgbi.c                   | 415 +++++++++++++++++++-----
 drivers/scsi/cxgbi/libcxgbi.h                   |   4 +
 8 files changed, 840 insertions(+), 117 deletions(-)
 create mode 100644 drivers/scsi/cxgbi/cxgbi_lro.h

-- 
2.3.4
