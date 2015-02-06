From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 0/5] Add support to dump some hw debug info
Date: Fri,  6 Feb 2015 19:32:50 +0530
Message-ID: <1423231375-28004-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:28185 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752535AbbBFN5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 08:57:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series adds support to dump sensor info, dump Transport Processor
event trace, dump Upper Layer Protocol RX module command trace, dump mailbox
contents and dump Transport Processor congestion control configuration. 

Will send a separate patch series for all the hw stats patches, by moving them
to ethtool.

The patches series is created against 'net-next' tree.
And includes patches on cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks 

V2: Dopped all hw stats related patches. Added a new patch which adds support to
dump congestion control table. 

Hariprasad Shenai (5):
  cxgb4: Add support in debugfs to display sensor information
  cxgb4: Added support in debugfs to display TP logic analyzer output
  cxgb4: Add support for ULP RX logic analyzer output in debugfs
  cxgb4: Add support to dump mailbox content in debugfs
  cxgb4: Add support in debugfs to dump the congestion control table

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    5 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  433 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |   83 ++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |    2 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   30 ++
 drivers/net/ethernet/chelsio/cxgb4/t4_values.h     |    5 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |    6 +
 7 files changed, 564 insertions(+), 0 deletions(-)
