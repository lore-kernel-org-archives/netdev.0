From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 00/45] Update bna driver version to 3.0.2.0
Date: Mon, 18 Jul 2011 01:19:28 -0700
Message-ID: <1310977178-312-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37700 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753054Ab1GRIUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:20:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

   The following patch set adds support for Brocade-1860 Fabric Adapter code
   re-org and cleaning.

   It updates the Brocade BNA driver to v3.0.2.0.

   The driver has been compiled & tested against net-next-2.6(3.0.0-rc7)

   Note: pathces 0007 to 0009 are split for ease of review.

Thanks,
Rasesh

Rasesh Mody (45):
  bna: Checkpatch Cleanup
  bna: Update ASIC Register Definition to Support New Hardware
  bna: Change IOC Event Notification Call Back Mechanism
  bna: State Machine Fault Handling Cleanup
  bna: MSGQ Implementation
  bna: Use DEFINE_PCI_DEVICE_TABLE and Print Driver Version
  bna: Introduce ENET as New Driver and FW Interface
  bna: Tx and Rx Redesign
  bna: ENET and Tx Rx Redesign Update
  bna: Remove Obsolete Files
  bna: Brocade-1860 Fabric Adapter Enablement
  bna: Hardware Clock Setup
  bna: IOC PLL changes and init cleanup
  bna: Brocade 1860 Register and ASIC Mode Changes
  bna: Set MBOX MSIX Index to Zero
  bna: IOC PCI Init & Enable Changes
  bna: Mailbox Interface Changes and FW MBOX fix
  bna: Implement Polling Mechanism for FW Ready
  bna: HW Type Check Fix
  bna: MBOX IRQ Sync Vector Num Fix
  bna: Remove Reset Call Back
  bna: Capability Map and MFG Block Changes for New HW
  bna: Added Defines for Multi TXQ Support
  bna: Mboxq Flush When Ioc Disabled
  bna: Move FW Init to HW Init and Disable Hang Unmapped Fix
  bna: Ethfn LPU DMA Read Fix
  bna: IOC Event Name Change
  bna: Add New IOC event
  bna: Add Sub-System Device ID Info
  bna: Add HW Semaphore Unlock Logic
  bna: Configuration changes
  bna: TxRx Coalesce Settings Fix and Reorg PCI Probe Failure
  bna: Device Init Fix
  bna: Add Multiple Tx Queue Support
  bna: Change TxQ Select Logic and Interrupt Handling
  bna: Data Path and API Changes
  bna: Adpater and Port Mode Settings
  bna: HW Error Counter Fix
  bna: RX Path Changes
  bna: Add IOC MBOX Call Back to Client
  bna: Ethtool Ring Param Set changes and Add Stats Attr
  bna: PLL Init Fix and Add Stats Attributes
  bna: Dropped BUG_ONs and Rx id init fix
  bna: Header File and Unused Code Cleanup
  bna: Driver Version changed to 3.0.2.0

 drivers/net/bna/Makefile            |    5 +-
 drivers/net/bna/bfa_cee.c           |   70 +-
 drivers/net/bna/bfa_cee.h           |    3 +-
 drivers/net/bna/bfa_cs.h            |  148 ++
 drivers/net/bna/bfa_defs.h          |   77 +-
 drivers/net/bna/bfa_defs_cna.h      |    8 +-
 drivers/net/bna/bfa_defs_mfg_comm.h |   93 +-
 drivers/net/bna/bfa_defs_status.h   |  143 +-
 drivers/net/bna/bfa_ioc.c           |  712 ++++--
 drivers/net/bna/bfa_ioc.h           |  106 +-
 drivers/net/bna/bfa_ioc_ct.c        |  498 ++++-
 drivers/net/bna/bfa_msgq.c          |  669 ++++++
 drivers/net/bna/bfa_msgq.h          |  130 +
 drivers/net/bna/bfi.h               |  280 ++-
 drivers/net/bna/bfi_ctreg.h         |  646 -----
 drivers/net/bna/bfi_enet.h          |  902 +++++++
 drivers/net/bna/bfi_ll.h            |  438 ----
 drivers/net/bna/bfi_reg.h           |  452 ++++
 drivers/net/bna/bna.h               |  456 +++--
 drivers/net/bna/bna_ctrl.c          | 3077 ------------------------
 drivers/net/bna/bna_enet.c          | 2202 +++++++++++++++++
 drivers/net/bna/bna_hw.h            | 1516 ++----------
 drivers/net/bna/bna_txrx.c          | 4417 +++++++++++++++++------------------
 drivers/net/bna/bna_types.h         |  696 +++----
 drivers/net/bna/bnad.c              | 1249 ++++++----
 drivers/net/bna/bnad.h              |  157 +-
 drivers/net/bna/bnad_ethtool.c      |  481 +---
 drivers/net/bna/cna.h               |   44 +-
 include/linux/pci_ids.h             |    1 +
 29 files changed, 9824 insertions(+), 9852 deletions(-)
 create mode 100644 drivers/net/bna/bfa_cs.h
 create mode 100644 drivers/net/bna/bfa_msgq.c
 create mode 100644 drivers/net/bna/bfa_msgq.h
 delete mode 100644 drivers/net/bna/bfi_ctreg.h
 create mode 100644 drivers/net/bna/bfi_enet.h
 delete mode 100644 drivers/net/bna/bfi_ll.h
 create mode 100644 drivers/net/bna/bfi_reg.h
 delete mode 100644 drivers/net/bna/bna_ctrl.c
 create mode 100644 drivers/net/bna/bna_enet.c

