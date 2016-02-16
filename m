From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/2] cxgb4: Use __dev_[um]c_[un]sync for MAC address syncing
Date: Tue, 16 Feb 2016 10:07:08 +0530
Message-ID: <1455597430-17173-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, nirranjan@chelsio.com, leedom@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:36404 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751967AbcBPEex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 23:34:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

This patch series adds support to use __dev_uc_sync/__dev_mc_sync to add
MAC address and __dev_uc_unsync/__dev_mc_unsync to delete MAC address.

This patch series has been created against net-next tree and includes
patches on cxgb4 and cxgb4vf driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (2):
  cxgb4: Use __dev_uc_sync/__dev_mc_sync to sync MAC address
  cxgb4vf: Use __dev_uc_sync/__dev_mc_sync to sync MAC address

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  27 ++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 138 ++++++++++++---------
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  92 +++++++++++---
 drivers/net/ethernet/chelsio/cxgb4vf/adapter.h     |   8 ++
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    | 116 ++++++++++-------
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |  20 +++
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |  88 ++++++++++---
 7 files changed, 355 insertions(+), 134 deletions(-)

-- 
2.3.4
