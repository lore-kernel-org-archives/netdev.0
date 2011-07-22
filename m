From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 00/10] bna: driver fixes and cleanup
Date: Fri, 22 Jul 2011 11:07:39 -0700
Message-ID: <1311358069-32067-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:39762 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754003Ab1GVSIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 14:08:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

   The following patch set adds fixes and clean ups for current upstream driver.

   The driver has been compiled and tested against net-next-2.6(3.0.0-rc7)

Thanks,
Rasesh

Rasesh Mody (10):
  bna: Print Driver Version
  bna: CheckPatch Cleanup
  bna: IOC Event Notification Enhancement
  bna: State Machine Fault Handling Cleanup
  bna: Minor IRQ Index and Definition Change
  bna: Mboxq Flush When IOC Disabled
  bna: IOC Event Name Change
  bna: Add HW Semaphore Unlock Logic
  bna: HW Error Counter Fix
  bna: Header File Consolidation

 drivers/net/bna/bfa_cee.c           |   65 +++++++++------
 drivers/net/bna/bfa_cee.h           |    3 +-
 drivers/net/bna/bfa_cs.h            |  140 +++++++++++++++++++++++++++++++
 drivers/net/bna/bfa_defs.h          |    5 +-
 drivers/net/bna/bfa_defs_mfg_comm.h |   20 ++--
 drivers/net/bna/bfa_defs_status.h   |  134 +++++++++++++++---------------
 drivers/net/bna/bfa_ioc.c           |  157 ++++++++++++++++++++++-------------
 drivers/net/bna/bfa_ioc.h           |   51 ++++++++---
 drivers/net/bna/bfa_sm.h            |   88 -------------------
 drivers/net/bna/bfa_wc.h            |   69 ---------------
 drivers/net/bna/bfi.h               |   20 +++--
 drivers/net/bna/bna.h               |   18 ++--
 drivers/net/bna/bna_ctrl.c          |   45 +++++-----
 drivers/net/bna/bna_hw.h            |   92 ++++++++++----------
 drivers/net/bna/bna_txrx.c          |   44 +++++-----
 drivers/net/bna/bna_types.h         |   58 +++++++-------
 drivers/net/bna/bnad.c              |   64 +++++++-------
 drivers/net/bna/bnad.h              |   27 ++++---
 drivers/net/bna/bnad_ethtool.c      |    2 +-
 drivers/net/bna/cna.h               |    2 +-
 20 files changed, 587 insertions(+), 517 deletions(-)
 create mode 100644 drivers/net/bna/bfa_cs.h
 delete mode 100644 drivers/net/bna/bfa_sm.h
 delete mode 100644 drivers/net/bna/bfa_wc.h

