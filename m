From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/3] cxgb4/cxgb4vf: Adds VI loopback, FL starvation support and cleanup
Date: Sun, 17 May 2015 16:15:20 +0530
Message-ID: <1431859523-7423-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:10053 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751126AbbEQFci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 01:32:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series adds the following.
Adds support for Loopback between VI of same port, adds debugfs entry to
inject freelist starvation and cleansup some function and argument

This patch series has been created against net-next tree and includes
patches on cxgb4 and cxgb4vf driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (3):
  cxgb4: Add support for loopback between VI of same port
  cxgb4: Add debugfs facility to inject FL starvation
  cxgb4/cxgb4vf: function and argument name cleanup

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   6 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  58 +++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c |  16 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 113 +++---
 drivers/net/ethernet/chelsio/cxgb4/sge.c           | 384 ++++++++++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  14 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_values.h     |   2 +
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |   4 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |  10 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |  12 +-
 10 files changed, 531 insertions(+), 88 deletions(-)

-- 
2.3.4
