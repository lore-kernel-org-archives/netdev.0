From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next v1 0/4] Update the driver version to 3.2.21.1
Date: Mon, 20 May 2013 13:08:00 -0700
Message-ID: <1369080484-29926-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	<adapter_linux_open_src_team@Brocade.COM>,
	Rasesh Mody <rmody@Brocade.COM>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:58480 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757998Ab3ETUIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 16:08:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Re-submitting the following patch series. It includes enhancements, bug fixes
and firmware updates for BNA driver. It updates the Brocade BFA driver to
v3.2.21.1.

The patches have been compiled and tested against net-next 3.9.0.

Thanks,
Rasesh

Rasesh Mody (4):
  bna: Clear Driver Config Flags When HW Resets
  bna: Fix Ucast Failure Handling
  bna: Enahncement to Identify Default IOC Function
  bna: Driver and Firmware Updated

 drivers/net/ethernet/brocade/bna/bfa_defs.h  |    3 ++-
 drivers/net/ethernet/brocade/bna/bfa_ioc.c   |    7 ++++---
 drivers/net/ethernet/brocade/bna/bfa_ioc.h   |    2 ++
 drivers/net/ethernet/brocade/bna/bna.h       |    2 ++
 drivers/net/ethernet/brocade/bna/bna_enet.c  |    7 ++++++-
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c |   15 +++++++++++++++
 drivers/net/ethernet/brocade/bna/bnad.c      |    3 +++
 drivers/net/ethernet/brocade/bna/bnad.h      |    2 +-
 drivers/net/ethernet/brocade/bna/cna.h       |    4 ++--
 9 files changed, 37 insertions(+), 8 deletions(-)
