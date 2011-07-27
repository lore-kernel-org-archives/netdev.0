From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 0/8] bna: Driver Fixes and Support for Re-architecture
Date: Tue, 26 Jul 2011 19:10:40 -0700
Message-ID: <1311732648-29876-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:58587 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751532Ab1G0CdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2011 22:33:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

   This patch-set consists of few fixes, HW reg consolidation and adds support
   for re-architecture and re-organisation of the driver.

   The driver has been compiled and tested against net-next-2.6(3.0.0-rc7)

   Please note the tx rx redesign & enet changes are not enabled. They will get
   enabled in the subsequent submission when all the other supporting code is
   ready.

Rasesh Mody (8):
  bna: Remove get_regs Ethtool Support
  bna: Consolidated HW Registers for Supported HWs
  bna: Remove Obsolete File bfi_ctreg.h
  bna: MSGQ Implementation
  bna: Remove Unnecessary CNA Check
  bna: HW Interface Init Update
  bna: Introduce ENET as New Driver and FW Interface
  bna: Tx and Rx Redesign

 drivers/net/bna/Makefile       |    3 +-
 drivers/net/bna/bfa_ioc.c      |   16 +-
 drivers/net/bna/bfa_ioc.h      |    4 +-
 drivers/net/bna/bfa_ioc_ct.c   |  118 +-
 drivers/net/bna/bfa_msgq.c     |  669 +++++++
 drivers/net/bna/bfa_msgq.h     |  130 ++
 drivers/net/bna/bfi.h          |  101 +
 drivers/net/bna/bfi_ctreg.h    |  646 -------
 drivers/net/bna/bfi_enet.h     |  902 +++++++++
 drivers/net/bna/bfi_reg.h      |  452 +++++
 drivers/net/bna/bna_ctrl.c     |    6 +-
 drivers/net/bna/bna_enet.c     | 2199 ++++++++++++++++++++++
 drivers/net/bna/bna_hw.h       |    6 +-
 drivers/net/bna/bna_tx_rx.c    | 3966 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/bna/bnad_ethtool.c |  319 ----
 15 files changed, 8499 insertions(+), 1038 deletions(-)
 create mode 100644 drivers/net/bna/bfa_msgq.c
 create mode 100644 drivers/net/bna/bfa_msgq.h
 delete mode 100644 drivers/net/bna/bfi_ctreg.h
 create mode 100644 drivers/net/bna/bfi_enet.h
 create mode 100644 drivers/net/bna/bfi_reg.h
 create mode 100644 drivers/net/bna/bna_enet.c
 create mode 100644 drivers/net/bna/bna_tx_rx.c

