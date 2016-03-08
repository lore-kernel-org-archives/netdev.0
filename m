From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/4] cxgb4vf: Interrupt and queue configuration changes
Date: Tue,  8 Mar 2016 10:50:16 +0530
Message-ID: <1457414420-5237-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:59580 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751839AbcCHFWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 00:22:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This series fixes some issues and some changes in the queue and interrupt
configuration for cxgb4vf driver. We need to enable interrupts before we
register our network device, so that we don't loose link up interrupts.
Allocate rx queues based on interrupt type. Set number of tx/rx queues in
probe function only. Also adds check for some invalid configurations.

This patch series has been created against net-next tree and includes
patches on cxgb4vf driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (4):
  cxgb4vf: Enable interrupts before we register our network devices
  cxgb4vf: Configure queue based on resource and interrupt type
  cxgb4vf: Add a couple more checks for invalid provisioning
    configurations
  cxgb4vf : Set number of queues in pci probe only

 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |  221 +++++++++++---------
 1 files changed, 125 insertions(+), 96 deletions(-)

-- 
1.7.3
