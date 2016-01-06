From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/3] cxgb4/cxgb4i: add iscsi LRO  support for chelsio t4/t5 adapters
Date: Wed,  6 Jan 2016 17:59:33 +0530
Message-ID: <1452083376-7180-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, JBottomley@odin.com,
	martin.petersen@oracle.com, leedom@chelsio.com, kxie@chelsio.com,
	manojmalviya@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:12191 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752152AbcAFM2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 07:28:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

This patch series adds LRO iscsi support for chelsio T4/T5 adapters.

This patch series has been created against net-next tree and includes
patches on cxgb4 and cxgb4i driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks


Hariprasad Shenai (3):
  cxgb4: Add LRO infrastructure for cxgb4i driver
  libcxgbi: add pdu parsing of LRO'ed skbs
  cxgb4i: add iscsi LRO for chelsio t4/t5 adapters

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  15 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  40 ++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |   5 +
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |  10 +-
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c              | 396 +++++++++++++++++++++-
 drivers/scsi/cxgbi/libcxgbi.c                   | 415 +++++++++++++++++++-----
 drivers/scsi/cxgbi/libcxgbi.h                   |   4 +
 7 files changed, 768 insertions(+), 117 deletions(-)

-- 
2.3.4
