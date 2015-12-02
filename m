From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net 0/3] bnxt_en: set mac address and uc_list bug fixes.
Date: Tue, 1 Dec 2015 22:15:38 -0500
Message-ID: <1449026141-31225-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:23605 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753742AbbLBDPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 22:15:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix ndo_set_mac_address() for PF and VF.
Re-apply uc_list after chip reset.

Michael Chan (3):
  bnxt_en: Fixed incorrect implemenation of ndo_set_mac_address
  bnxt_en: enforce properly storing of MAC address
  bnxt_en: Setup uc_list mac filters after resetting the chip.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c       | 42 +++++++++++++++++--------
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c |  7 ++---
 2 files changed, 32 insertions(+), 17 deletions(-)

-- 
1.8.3.1
