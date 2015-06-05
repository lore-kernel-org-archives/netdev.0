From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/6] Free VI, flush sge ec and some other misc. fixes
Date: Fri,  5 Jun 2015 14:24:46 +0530
Message-ID: <1433494492-7638-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:24396 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753758AbbFEDlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 23:41:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series adds the following.
Free VI interface during remove, flush SGE ec routine, rename
t4_link_start to t4_link_l1cfg since it only does l1 configuration, set
mac addr from when we can't contact firmware for debug purpose, set pcie
completion timeout and use fw interface to access TP_PIO_XXX registers

This patch series has been created against net-next tree and includes
patches on cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (6):
  cxgb4: Free Virtual Interfaces in remove routine
  cxgb4: Add sge ec context flush service
  cxgb4: Rename t4_link_start() to t4_link_l1cfg
  cxgb4: Set mac addr from vpd, when we can't contact firmware
  cxgb4: program pci completion timeout
  cxgb4: Use FW LDST cmd to access TP_PIO_{ADDR,DATA} register first

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  38 +++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c |   4 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  35 +++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 225 ++++++++++++++++++---
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |   6 +-
 5 files changed, 257 insertions(+), 51 deletions(-)

-- 
2.3.4
