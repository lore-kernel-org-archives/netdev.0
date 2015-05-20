From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/2] cxgb4: Cleanup and update T4/T4 register ranges
Date: Wed, 20 May 2015 17:53:44 +0530
Message-ID: <1432124626-22948-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:28307 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751004AbbETHKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 03:10:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This series cleans and optimizes setup_memwin function and also updates
T4/T5 adapter register ranges by removing incorrect register addresses
 
This patch series has been created against net-next tree and includes
patches on cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks


Hariprasad Shenai (2):
  cxgb4: Optimize and cleanup setup memory window code
  cxgb4: Update T4/T5 adapter register ranges

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |   4 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  79 +----------
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      | 171 +++++++++++++++++++-----
 3 files changed, 146 insertions(+), 108 deletions(-)

-- 
2.3.4
