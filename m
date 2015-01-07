From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/4] Add support for few debugfs entries
Date: Wed,  7 Jan 2015 08:47:59 +0530
Message-ID: <1420600683-23289-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	anish@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:24443 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751748AbbAGDN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 22:13:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series adds support for devlog, cim_la, cim_qcfg and mps_tcam
debugfs entries.

The patches series is created against 'net-next' tree.
And includes patches on cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (4):
  cxgb4: Add support for devlog
  cxgb4: Add support for cim_la entry in debugfs
  cxgb4: Add support for cim_qcfg entry in debugfs
  cxgb4: Add support for mps_tcam debugfs

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   16 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  524 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h |   12 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   26 +
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  155 ++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |   19 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |  149 ++++++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |   81 +++
 8 files changed, 982 insertions(+), 0 deletions(-)
