From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/5] Misc. fixes for cxgb4
Date: Thu, 13 Mar 2014 20:50:45 +0530
Message-ID: <1394724050-9291-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, dm@chelsio.com, swise@opengridcomputing.com,
	leedom@chelsio.com, santosh@chelsio.com, kumaras@chelsio.com,
	nirranjan@chelsio.com, hariprasad@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:10950 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753802AbaCMP3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 11:29:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

This patch series provides miscelleneous fixes for Chelsio T4/T5 adapters
cxgb4 driver related to SGE and MTU.

Also fixes regression in LSO calcuation path.
("cxgb4: Calculate len properly for LSO path")

The patches series is created against David Miller's 'net-next' tree.
And includes patches on cxgb4 driver.

We would like to request this patch series to get merged via David Miller's
'net-next' tree.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Kumar Sanghvi (5):
  cxgb4: Fix some small bugs in t4_sge_init_soft() when our Page Size is
    64KB
  cxgb4: Add code to dump SGE registers when hitting idma hangs
  cxgb4: Rectify emitting messages about SGE Ingress DMA channels being
    potentially stuck
  cxgb4: Updates for T5 SGE's Egress Congestion Threshold
  cxgb4: Calculate len properly for LSO path

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h   |  10 ++-
 drivers/net/ethernet/chelsio/cxgb4/sge.c     | 122 +++++++++++++++++++++------
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c   | 106 +++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h |   9 ++
 4 files changed, 219 insertions(+), 28 deletions(-)

-- 
1.8.4
