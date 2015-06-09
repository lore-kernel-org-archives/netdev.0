From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/3] Add cim_ma_la, cim_pif_la and tx_rate debugfs entry
Date: Tue,  9 Jun 2015 18:27:49 +0530
Message-ID: <1433854672-6649-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:30464 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751640AbbFIHod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 03:44:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series adds the following.
Add debugfs entry to dump CIM MA logic analyzer and CIM PIF logic analyzer logs.
Also adds support to dump tx rate of the channels in the adapter

This patch series has been created against net-next tree and includes
patches on cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (3):
  cxgb4: Add a debugfs entry to dump CIM MA logic analyzer logs
  cxgb4: Add debugfs entry to dump CIM PIF logic analyzer contents
  cxgb4: Add debugfs entry to dump channel rate

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   5 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 125 +++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 101 +++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |   2 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |  63 +++++++++++
 5 files changed, 296 insertions(+)

-- 
2.3.4
