From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/8]  Add support for adaptive-rx, dump mbox and various adapter stats
Date: Mon,  2 Feb 2015 20:23:01 +0530
Message-ID: <1422888789-12016-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, praveenm@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:29864 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750922AbbBBOre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 09:47:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series adds support to dump sensor, tp_la, tp_tcp_stats, looback
stats of port, mailbox dumps, upper layer protocols RX LA dumps debugfs entries.
Also adds support for adaptive-rx feature for cxgb4 driver.

The patches series is created against 'net-next' tree.
And includes patches on cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks


Hariprasad Shenai (8):
  cxgb4: Add support in debugfs to display sensor information
  cxgb4: Added support in debugfs to display tp_la stats
  cxgb4: Add support for ULP RX la dump in debugfs
  cxgb4: Add support to dump mbox in debugfs
  cxgb4: Add support to dump HW port loopback stats in debugfs
  cxgb4: Add support to display TP module tcp stats in debugfs
  cxgb4: Added support in debugfs to display tp_err_stats
  cxgb4: Add low latency socket busy_poll support

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  139 +++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  514 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   16 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |   47 ++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  133 +++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |    2 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   28 ++
 drivers/net/ethernet/chelsio/cxgb4/t4_values.h     |    6 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |    6 +
 9 files changed, 878 insertions(+), 13 deletions(-)
