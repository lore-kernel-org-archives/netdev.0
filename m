From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/5] cxgb4/cxgb4vf: Cleanup and minor fixes
Date: Tue,  1 Mar 2016 17:19:31 +0530
Message-ID: <1456832976-12840-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, nirranjan@chelsio.com, leedom@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:29232 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752680AbcCALqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 06:46:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

This series sets FBMIN to 64 bytes for Chelsio's T6 series of adapters,
check to replenish fl is revised, some code cleanup in cxgb4vf sge
initialization code and removes dead code. 

This patch series has been created against net-next tree and includes
patches on cxgb4 and cxgb4vf driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks


Hariprasad Shenai (5):
  cxgb4/cxgb4vf: Use fl capacity to check if fl needs to be replenished
  cxgb4/cxgb4vf: For T6 adapter, set FBMIN to 64 bytes
  cxgb4vf: Make sge init code more readable
  cxgb4vf: Remove redundant adapter ready check during probe
  cxgb4vf: Remove dead functions collect_netdev_[um]c_list_addrs

 drivers/net/ethernet/chelsio/cxgb4/sge.c           | 14 +++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_values.h     |  1 +
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    | 56 ----------------------
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         | 55 +++++++--------------
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |  1 +
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     | 55 +++++++++++++++++++++
 6 files changed, 85 insertions(+), 97 deletions(-)

-- 
2.3.4
