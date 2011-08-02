From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 0/3] bna: Remove get_reg support and HW reg consolidation
Date: Tue, 2 Aug 2011 15:36:04 -0700
Message-ID: <1312324567-18487-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:40193 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752148Ab1HBWg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2011 18:36:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

   This patch-set removes get_regs ethtool support and consists of HW reg
   consolidation to support various Brocade HW.

   The driver has been compiled and tested against net-next-2.6(3.0.0-rc7)

Rasesh Mody (3):
  bna: Remove get_regs Ethtool Support
  bna: Consolidated HW Registers for Supported HWs
  bna: Remove Obsolete File bfi_ctreg.h

 drivers/net/bna/bfa_ioc.c      |    2 +-
 drivers/net/bna/bfa_ioc_ct.c   |   78 +++---
 drivers/net/bna/bfi_ctreg.h    |  646 ----------------------------------------
 drivers/net/bna/bfi_reg.h      |  452 ++++++++++++++++++++++++++++
 drivers/net/bna/bna_hw.h       |    6 +-
 drivers/net/bna/bnad_ethtool.c |  319 --------------------
 6 files changed, 497 insertions(+), 1006 deletions(-)
 delete mode 100644 drivers/net/bna/bfi_ctreg.h
 create mode 100644 drivers/net/bna/bfi_reg.h

