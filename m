From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 00/14]  bna: Update bna driver version to 3.0.2.1
Date: Tue, 16 Aug 2011 14:19:37 -0700
Message-ID: <1313529591-3718-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:57365 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751422Ab1HPVUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2011 17:20:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

   The following patch set contains changes for adding support for feature like
   Multi TXQ, TX and RX path changes and Ethtool enhancements. This also fixes
   bugs found with new code. It cleans up unused code, formatting changes and
   comments addition/deletion.

   This updates the Brocade BNA driver to v3.0.2.1.

   The driver has been compiled & tested against net-next-2.6(3.0.0-rc7)

Thanks,
Rasesh

Rasesh Mody (14):
  bna: Naming Change and Minor Macro Fix
  bna: PCI Probe Fix
  bna: Interrupt Polling and NAPI Init Changes
  bna: Add Multiple Tx Queue Support
  bna: SKB Check and Drop Macros
  bna: TX Path and RX Path Changes
  bna: Formatting and Code Cleanup
  bna: Initialization and Locking Fix
  bna: Ethtool Enhancements and Fix
  bna: Async Mode Tx Rx Init Fix
  bna: MBOX IRQ Flag Check after Locking
  bna: Queue Depth and SKB Unmap Array Fix
  bna: SKB PCI UNMAP Fix
  bna: Driver Version changed to 3.0.2.1

 drivers/net/ethernet/brocade/bna/bfa_cee.c         |    2 -
 drivers/net/ethernet/brocade/bna/bfa_defs.h        |    8 +-
 .../net/ethernet/brocade/bna/bfa_defs_mfg_comm.h   |    1 -
 drivers/net/ethernet/brocade/bna/bfa_ioc.h         |    6 +-
 drivers/net/ethernet/brocade/bna/bfi.h             |   46 --
 drivers/net/ethernet/brocade/bna/bna.h             |   26 +-
 drivers/net/ethernet/brocade/bna/bna_enet.c        |   29 +-
 drivers/net/ethernet/brocade/bna/bna_hw_defs.h     |    5 +
 drivers/net/ethernet/brocade/bna/bna_types.h       |    2 +-
 drivers/net/ethernet/brocade/bna/bnad.c            |  628 ++++++++++++--------
 drivers/net/ethernet/brocade/bna/bnad.h            |   98 +++-
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c    |   96 +++-
 drivers/net/ethernet/brocade/bna/cna.h             |   11 +-
 13 files changed, 576 insertions(+), 382 deletions(-)

