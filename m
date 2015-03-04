From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/2] cxgb4: RX Queue related cleanup and fixes
Date: Wed,  4 Mar 2015 18:16:26 +0530
Message-ID: <1425473188-13346-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	swise@opengridcomputing.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:8056 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758956AbbCDMk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 07:40:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

This patch series adds a common function to allocate RX queues and queue
allocation changes to RDMA CIQ

The patches series is created against 'net-next' tree.
And includes patches on cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (2):
  cxgb4: Move offload Rx queue allocation to separate function
  cxgb4: Try and provide an RDMA CIQ per cpu

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    6 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |    4 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  124 ++++++++++++--------
 3 files changed, 80 insertions(+), 54 deletions(-)
