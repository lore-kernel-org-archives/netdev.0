From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/8] Adds support for Chelsio T5 40G adapter and Misc. fixes
Date: Tue, 18 Feb 2014 17:56:07 +0530
Message-ID: <1392726375-32001-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, dm@chelsio.com, leedom@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, santosh@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:31324 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754917AbaBRNgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 08:36:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

This patch series adds support for Chelsio T5 40G adapters and provides
miscelleneous fixes for cxgb4 driver.

It also adds device ids of two new T5 adapters.

We would like to request this patch series to get merged via David Miller's
'net-next' tree.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks,
Hari 

Hariprasad Shenai (1):
  cxgb4: Add more PCI device ids.

Kumar Sanghvi (7):
  cxgb4: Add support to recognize 40G links
  cxgb4: Print adapter VPD Part Number instead of Engineering Change
    field
  cxgb4: Allow >10G ports to have multiple queues
  cxgb4: LE-Workaround is not atomic in firmware
  cxgb4: Query firmware for T5 ULPTX MEMWRITE DSGL capabilities
  cxgb4: Remove unused registers and add missing ones
  cxgb4: Don't assume LSO only uses SGL path in t4_eth_xmit()

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  5 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 61 ++++++++++++++++++-------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |  1 +
 drivers/net/ethernet/chelsio/cxgb4/sge.c        | 38 ++++++++++-----
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      | 40 +++++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |  4 ++
 6 files changed, 119 insertions(+), 30 deletions(-)

-- 
1.8.0
