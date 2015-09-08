From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net 0/2] Fix tx flit calculation and wc stat configuration
Date: Tue,  8 Sep 2015 16:25:38 +0530
Message-ID: <1441709740-7533-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:8191 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753254AbbIHKzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 06:55:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series fixes the following:
Patch 1/2 fixes tx flit calculation, which if wrong can lead to 
stall, hang, data corrpution, write combining failure. Patch 2/2 fixes 
PCI-E write combining stats configuration.

This patch series has been created against net tree and includes
patches on cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (2):
  cxgb4: Fix tx flit calculation
  cxgb4: Fix for write-combining stats configuration

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 7 +++++--
 drivers/net/ethernet/chelsio/cxgb4/sge.c        | 2 +-
 2 files changed, 6 insertions(+), 3 deletions(-)

-- 
2.3.4
