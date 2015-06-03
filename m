From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/4] cxgb4: Adds support for various ethtool stats
Date: Wed,  3 Jun 2015 21:04:38 +0530
Message-ID: <1433345682-5846-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:15289 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751753AbbFCKVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 06:21:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series adds the following:
Adds support to dump adapter specific stats in ethtool
Adds support to dump channel stats in ethtool
Adds support to dump loopback port stats in ethtool
Remove wake-on-lan get/set ethtool support

This patch series has been created against net-next tree and includes
patches on cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (4):
  cxgb4: Add ethtool support to get adapter stats
  cxgb4: Add support in ethtool to dump channel stats
  cxgb4: Add support to dump loopback port stats
  cxgb4: Remove WOL get/set ethtool support

 drivers/infiniband/hw/cxgb4/provider.c             |   8 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  75 ++++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c | 276 ++++++++++++++++----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  10 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 288 ++++++++++++++-------
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |   2 -
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |  16 ++
 7 files changed, 499 insertions(+), 176 deletions(-)

-- 
2.3.4
