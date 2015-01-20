From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/2] Add support to dump flash and rss config
Date: Tue, 20 Jan 2015 12:02:19 +0530
Message-ID: <1421735541-32400-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, praveenm@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:12809 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752787AbbATG0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 01:26:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series adds support to dump flash, rss, rss_key, rss_config,
rss_pf_config and rss_vf_config debugfs entries.

The patches series is created against 'net-next' tree.
And includes patches on cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks 

Hariprasad Shenai (2):
  cxgb4: Add debugfs entry to dump the contents of the flash
  cxgb4: Add debugfs options to dump the rss key, config for PF, VF,
    etc

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   13 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  480 +++++++++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h |   21 +
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  169 +++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |  402 ++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |    6 +
 6 files changed, 1088 insertions(+), 3 deletions(-)
