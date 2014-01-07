From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/2] namespace collision fix and update FW version check on cxgb4
Date: Tue,  7 Jan 2014 16:58:06 +0530
Message-ID: <1389094088-6261-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, dm@chelsio.com, leedom@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, santosh@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:27071 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbaAGLfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 06:35:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

This patch series provides namespace collision fix for cxgb4 driver.
Also updated FW version check for cxgb4 driver.

Patch series is created against David Miller's net-next tree.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks,
Hari

Hariprasad Shenai (2):
  cxgb4: Fix namespace collision issue.
  cxgb4: Changed FW check version to match FW binary version

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h |  12 ++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 100 ++++++++++++++---------------
 2 files changed, 54 insertions(+), 58 deletions(-)

-- 
1.8.0
