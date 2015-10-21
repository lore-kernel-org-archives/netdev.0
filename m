From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/8] Trivial fixes for cxgb4 driver
Date: Wed, 21 Oct 2015 14:39:49 +0530
Message-ID: <1445418597-771-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.115.98]:32344 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753201AbbJUJKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 05:10:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series updates driver description for next gen. adapters, updates
firmware info., returns error for setup_rss error case, restores L1
configuration in case of FW rejects new config, updates and aligns ethtool
get stats settings, etc

 This patch series has been created against net-next tree and includes
patches on cxgb4 and cxgb4vf driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks


Hariprasad Shenai (8):
  cxgb4: Align ethtool get stat settings
  cxgb4: Don't disallow turning off auto-negotiation
  cxgb4: Restore L1 cfg, if FW rejects new L1 cfg settings
  cxgb4: Add info print to display number of MSI-X vectors allocated
  cxgb4/cxgb4vf: Update driver desc. to include Chelsio T6 adapter
  cxgb4: Return error if setup_rss is called before probe
  cxgb4: Use vmalloc, if kmalloc fails
  cxgb4: Update ethtool get_drvinfo to get regdump len

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c | 191 +++++++++++----------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   7 +-
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |   2 +-
 3 files changed, 108 insertions(+), 92 deletions(-)

-- 
2.3.4
