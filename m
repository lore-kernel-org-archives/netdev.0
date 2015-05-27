From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/2] cxgb4/cxgb4vf: Adds FL starvation support and cleanup
Date: Wed, 27 May 2015 22:30:22 +0530
Message-ID: <1432746024-22065-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:16624 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751129AbbE0LrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 07:47:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series adds the following.
Adds debugfs entry to inject freelist starvation and some function and
argument cleanup

This patch series has been created against net-next tree and includes
patches on cxgb4 and cxgb4vf driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

V2:
Skipping patch "cxgb4: Add support for loopback between VI of same port".
This needs some major code change, since module param is not recommended.

Hariprasad Shenai (2):
  cxgb4: Add debugfs facility to inject FL starvation
  cxgb4/cxgb4vf: function and argument name cleanup

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  5 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 58 ++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c | 16 ++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 98 +++++++++++++---------
 drivers/net/ethernet/chelsio/cxgb4/sge.c           | 35 ++++----
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 22 ++---
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |  4 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h | 10 +--
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     | 12 +--
 9 files changed, 170 insertions(+), 90 deletions(-)

-- 
2.3.4
