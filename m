From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 0/7] bna: H/W enablement and update driver version to 3.0.2.2
Date: Tue, 27 Sep 2011 13:39:04 -0700
Message-ID: <1317155951-17242-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:35166 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752574Ab1I0UjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 16:39:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

   The following series is re-submitted. These patches add support for
   Brocade-1860 Fabric Adapter and address the comments received from
   upstream community.

   It updates the Brocade BNA driver to v3.0.2.2.

   The driver has been compiled & tested against net-next-2.6(3.0.0-rc7).

Thanks,
Rasesh

Rasesh Mody (7):
  bna: Brocade 1860 IOC PLL, Reg Defs and ASIC Mode Changes
  bna: Capability Map and MFG Block Changes for New HW
  bna: Implement FW Download for New HW
  bna: Brocade 1860 HW Enablement
  bna: PLL Init Fix and Add Stats Attributes
  bna: Add Callback to Fix RXQ Stop
  bna: Driver Version changed to 3.0.2.2

 drivers/net/ethernet/brocade/bna/bfa_defs.h        |   35 ++-
 drivers/net/ethernet/brocade/bna/bfa_defs_cna.h    |    8 +-
 .../net/ethernet/brocade/bna/bfa_defs_mfg_comm.h   |   44 +--
 drivers/net/ethernet/brocade/bna/bfa_ioc.c         |   49 ++-
 drivers/net/ethernet/brocade/bna/bfa_ioc.h         |   15 +-
 drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c      |  407 +++++++++++++++++++-
 drivers/net/ethernet/brocade/bna/bfi.h             |   20 +-
 drivers/net/ethernet/brocade/bna/bna_hw_defs.h     |    4 +
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c       |   11 +
 drivers/net/ethernet/brocade/bna/bna_types.h       |    2 +
 drivers/net/ethernet/brocade/bna/bnad.c            |   35 ++-
 drivers/net/ethernet/brocade/bna/bnad.h            |    3 +-
 drivers/net/ethernet/brocade/bna/cna.h             |    1 +
 drivers/net/ethernet/brocade/bna/cna_fwimg.c       |   48 ++-
 14 files changed, 582 insertions(+), 100 deletions(-)
