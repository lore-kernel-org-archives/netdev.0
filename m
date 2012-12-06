From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 0/7] bna: Driver Version Updated to 3.1.2.1
Date: Thu, 6 Dec 2012 15:17:41 -0800
Message-ID: <1354835868-27016-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bhutchings@solarflare.com>,
	<adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:40234 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932239Ab2LFXSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 18:18:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

        Resubmitting the patch set. It addresses comments by Ben.

        The following patch-set includes Tx Rx changes, bug fixes, firmware
        naming change, code cleanup and enhancements.

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
 drivers/net/ethernet/brocade/bna/bna.h          |    7 +
 drivers/net/ethernet/brocade/bna/bna_hw_defs.h  |    3 +-
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c    |  138 +++--
 drivers/net/ethernet/brocade/bna/bna_types.h    |    9 +-
 drivers/net/ethernet/brocade/bna/bnad.c         |  937 +++++++++++++----------
 drivers/net/ethernet/brocade/bna/bnad.h         |   66 +-
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c |    1 +
 drivers/net/ethernet/brocade/bna/cna.h          |    4 +-
 9 files changed, 666 insertions(+), 500 deletions(-)
