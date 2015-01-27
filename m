From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/5] Add support to dump cim ibq, obq and qinfo, etc
Date: Tue, 27 Jan 2015 13:47:44 +0530
Message-ID: <1422346669-26913-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, praveenm@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:24745 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753524AbbA0IMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 03:12:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series adds support to dump cim_ibq, cim_obq, sge_qinfo, pm_stats
and clk debugfs entries.

The patches series is created against 'net-next' tree.
And includes patches on cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (5):
  cxgb4: Added support in debugfs to dump sge_qinfo
  cxgb4: Added support in debugfs to dump cim ingress bound queue
    contents
  cxgb4: Addded support in debugfs to dump CIM outbound queue content
  cxgb4: Added support in debugfs to dump PM module stats
  cxgb4: Added support in debugfs to dump different timer and clock
    values of the adapter

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    8 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  439 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |    4 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  139 ++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |    3 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   68 +++
 6 files changed, 659 insertions(+), 2 deletions(-)
