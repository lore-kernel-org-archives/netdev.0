From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 0/8] bna: Update bna driver version to 3.0.2.0
Date: Mon, 8 Aug 2011 19:21:34 -0700
Message-ID: <1312856502-31242-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:44195 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750953Ab1HICWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 22:22:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

   The following patch set contains changes for driver re-architecture and
   code re-organisazion. This includes driver firmware interface change,
   tx and rx re-design and corresponding changes required to use/enable new
   code and also keep the patch set bisectable. It also removes obsolete
   files and cleans up unused code.

   This updates the Brocade BNA driver to v3.0.2.0.

   The driver has been compiled & tested against net-next-2.6(3.0.0-rc7)

Thanks,
Rasesh

Rasesh Mody (8):
  bna: MSGQ Implementation
  bna: Introduce ENET as New Driver and FW Interface
  bna: Tx and Rx Redesign
  bna: Add New HW Defs
  bna: ENET and Tx Rx Redesign Enablement
  bna: Remove Unused Code
  bna: Remove Obsolete Files
  bna: Driver Version changed to 3.0.2.0

 drivers/net/bna/Makefile            |    5 +-
 drivers/net/bna/bfa_cee.c           |    3 -
 drivers/net/bna/bfa_defs.h          |   25 +-
 drivers/net/bna/bfa_defs_mfg_comm.h |   28 +-
 drivers/net/bna/bfa_ioc.c           |  403 +++--
 drivers/net/bna/bfa_ioc.h           |   45 +-
 drivers/net/bna/bfa_ioc_ct.c        |   41 +-
 drivers/net/bna/bfa_msgq.c          |  669 ++++++
 drivers/net/bna/bfa_msgq.h          |  130 ++
 drivers/net/bna/bfi.h               |  195 ++-
 drivers/net/bna/bfi_enet.h          |  901 ++++++++
 drivers/net/bna/bfi_ll.h            |  438 ----
 drivers/net/bna/bna.h               |  337 ++--
 drivers/net/bna/bna_ctrl.c          | 3076 -------------------------
 drivers/net/bna/bna_enet.c          | 2129 ++++++++++++++++++
 drivers/net/bna/bna_hw.h            | 1492 -------------
 drivers/net/bna/bna_hw_defs.h       |  413 ++++
 drivers/net/bna/bna_tx_rx.c         | 3787 +++++++++++++++++++++++++++++++
 drivers/net/bna/bna_txrx.c          | 4185 -----------------------------------
 drivers/net/bna/bna_types.h         |  654 +++----
 drivers/net/bna/bnad.c              |  643 ++++---
 drivers/net/bna/bnad.h              |   38 +-
 drivers/net/bna/bnad_ethtool.c      |   65 +-
 drivers/net/bna/cna.h               |   31 +-
 24 files changed, 9443 insertions(+), 10290 deletions(-)
 create mode 100644 drivers/net/bna/bfa_msgq.c
 create mode 100644 drivers/net/bna/bfa_msgq.h
 create mode 100644 drivers/net/bna/bfi_enet.h
 delete mode 100644 drivers/net/bna/bfi_ll.h
 delete mode 100644 drivers/net/bna/bna_ctrl.c
 create mode 100644 drivers/net/bna/bna_enet.c
 delete mode 100644 drivers/net/bna/bna_hw.h
 create mode 100644 drivers/net/bna/bna_hw_defs.h
 create mode 100644 drivers/net/bna/bna_tx_rx.c
 delete mode 100644 drivers/net/bna/bna_txrx.c

