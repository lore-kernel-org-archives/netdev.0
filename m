From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net 0/3] namespace collision fix and update FW version check on cxgb4
Date: Mon, 23 Dec 2013 17:01:57 +0530
Message-ID: <1387798320-29255-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, dm@chelsio.com, leedom@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, santosh@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:3062 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756868Ab3LWLjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 06:39:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

This patch series provides namespace collision fix for cxgb4 & cxgb4vf driver.
Also updated FW version check for cxgb4 driver.

Patch 1/3 (cxgb4: make functions static and remove dead code) was provided by
Stephen Hemminger on netdev mailing list.
http://www.spinics.net/lists/linux-rdma/msg18148.html

Patch series is created against David Miller's net tree.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks,
Hari

Hariprasad Shenai (2):
  cxgb4: Fix namespace collision issue.
  cxgb4: Changed FW check version to match FW binary version

Stephen Hemminger (1):
  cxgb4: make functions static and remove dead code

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  20 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 238 +++++----------------
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |   1 -
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |   4 +-
 4 files changed, 62 insertions(+), 201 deletions(-)

-- 
1.8.0
