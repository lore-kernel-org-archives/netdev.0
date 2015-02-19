From: Rasesh Mody <rasesh.mody@qlogic.com>
Subject: [net-next v2 0/2] bna: Update the Driver and Firmware Version
Date: Thu, 19 Feb 2015 16:02:30 -0500
Message-ID: <1424379752-4246-1-git-send-email-rasesh.mody@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NetDev <netdev@vger.kernel.org>,
	Rasesh Mody <rasesh.mody@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:40259 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752950AbbBSVmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 16:42:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

These patches re-brands the BNA driver to QLogic. The patches update the BNA
driver version to 3.2.25.1 and firmware version to 3.2.5.1.

The patches are tested against 3.19.0.

Thanks,
Rasesh

Rasesh Mody (2):
  bna: QLogic BR-series Adapters Driver Rebranding
  bna: Update the Driver and Firmware Version

 drivers/net/ethernet/brocade/Kconfig                 |  8 ++++----
 drivers/net/ethernet/brocade/Makefile                |  2 +-
 drivers/net/ethernet/brocade/bna/Kconfig             | 12 ++++++------
 drivers/net/ethernet/brocade/bna/Makefile            |  3 ++-
 drivers/net/ethernet/brocade/bna/bfa_cee.c           |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfa_cee.h           |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfa_cs.h            |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfa_defs.h          |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfa_defs_cna.h      |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfa_defs_status.h   |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfa_ioc.c           |  9 +++++----
 drivers/net/ethernet/brocade/bna/bfa_ioc.h           |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c        |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfa_msgq.c          |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfa_msgq.h          |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfi.h               |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfi_cna.h           |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfi_enet.h          |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfi_reg.h           | 13 +++++++------
 drivers/net/ethernet/brocade/bna/bna.h               |  7 ++++---
 drivers/net/ethernet/brocade/bna/bna_enet.c          |  7 ++++---
 drivers/net/ethernet/brocade/bna/bna_hw_defs.h       |  7 ++++---
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c         |  7 ++++---
 drivers/net/ethernet/brocade/bna/bna_types.h         |  7 ++++---
 drivers/net/ethernet/brocade/bna/bnad.c              | 11 ++++++-----
 drivers/net/ethernet/brocade/bna/bnad.h              |  9 +++++----
 drivers/net/ethernet/brocade/bna/bnad_debugfs.c      |  7 ++++---
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c      |  7 ++++---
 drivers/net/ethernet/brocade/bna/cna.h               | 11 ++++++-----
 drivers/net/ethernet/brocade/bna/cna_fwimg.c         |  7 ++++---
 31 files changed, 130 insertions(+), 102 deletions(-)

-- 
1.8.2.3
