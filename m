From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 00/13] bna: Update the Driver to v3.2.23.0
Date: Wed, 20 Nov 2013 21:54:04 -0800
Message-ID: <1385013257-32745-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	<adapter_linux_open_src_team@Brocade.COM>,
	Rasesh Mody <rmody@Brocade.COM>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:40603 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751250Ab3KUGVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 01:21:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch set consists of feature additions like s/w ptp support, multi-buffer
RX, firmware patch simplification, enhancements for RX filters, RX processing,
Bug fixes and updates the firmware version to v3.2.3.0.

This patch set updates the BNA driver to v3.2.23.0 and was tested against
net-next 3.12.0-rc6 kernel.

Thanks
Rasesh

Rasesh Mody (13):
  bna: Add software PTP support
  bna: Set Get IOC fw State
  bna: Fix Filter Add Del
  bna: RX Filter Enhancements
  bna: Enable Multi Buffer RX
  bna: UDP RX Processing Improvements
  bna: Fix Stale MTU used to Configure Multi-buffer RX
  bna: CQ Read Fix
  bna: Add NULL Check Before Dereferencing TCB
  bna: Handle the TX Setup Failures
  bna: Embed SKB Length in TX Vector
  bna: Firmware Patch Simplification
  bna: Update the Driver Version to 3.2.23.0

 drivers/net/ethernet/brocade/bna/bfa_ioc.c      | 653 ++++++++++++++++++++++--
 drivers/net/ethernet/brocade/bna/bfa_ioc.h      |   8 +
 drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c   |  40 ++
 drivers/net/ethernet/brocade/bna/bfi.h          |  33 +-
 drivers/net/ethernet/brocade/bna/bfi_enet.h     |   3 +-
 drivers/net/ethernet/brocade/bna/bna.h          |  24 +-
 drivers/net/ethernet/brocade/bna/bna_enet.c     |  58 ++-
 drivers/net/ethernet/brocade/bna/bna_hw_defs.h  |   4 +
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c    | 249 +++++++--
 drivers/net/ethernet/brocade/bna/bna_types.h    |  57 ++-
 drivers/net/ethernet/brocade/bna/bnad.c         | 543 ++++++++++++++------
 drivers/net/ethernet/brocade/bna/bnad.h         |  29 +-
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c |   1 +
 drivers/net/ethernet/brocade/bna/cna.h          |   4 +-
 14 files changed, 1414 insertions(+), 292 deletions(-)

-- 
1.8.2.3
