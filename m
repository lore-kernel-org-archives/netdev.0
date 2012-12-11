From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 0/7] bna: Driver Version Updated to 3.1.2.1
Date: Tue, 11 Dec 2012 14:24:49 -0800
Message-ID: <1355264696-8927-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bhutchings@solarflare.com>, <David.Laight@ACULAB.COM>,
	<adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:38595 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754115Ab2LKWZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 17:25:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave,

        Resubmitting the patch set with review feedback addressed.

        The following patch-set includes Tx Rx changes, bug fixes, firmware
        update, code cleanup and enhancements.

        This also updates the BNA driver to v3.1.2.1.

        The patches have been compiled and tested against 3.7.0-rc3.

Thanks,
Rasesh

Rasesh Mody (7):
  bna: Code Cleanup and Enhancements
  bna: Tx and Rx Optimizations
  bna: TX Intr Coalescing Fix
  bna: Rx Page Based Allocation
  bna: Add RX State
  bna: Firmware update
  bna: Driver Version Updated to 3.1.2.1

 drivers/net/ethernet/brocade/bna/bfi_enet.h     |    1 +
 drivers/net/ethernet/brocade/bna/bna.h          |    2 +
 drivers/net/ethernet/brocade/bna/bna_hw_defs.h  |    3 +-
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c    |  138 +++--
 drivers/net/ethernet/brocade/bna/bna_types.h    |    9 +-
 drivers/net/ethernet/brocade/bna/bnad.c         |  937 +++++++++++++----------
 drivers/net/ethernet/brocade/bna/bnad.h         |   66 +-
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c |    1 +
 drivers/net/ethernet/brocade/bna/cna.h          |    4 +-
 9 files changed, 661 insertions(+), 500 deletions(-)
