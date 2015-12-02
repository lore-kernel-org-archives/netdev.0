From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH v2 net 0/3] bnxt_en: set mac address and uc_list bug fixes.
Date: Wed, 2 Dec 2015 01:54:05 -0500
Message-ID: <1449039248-8745-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:18012 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751667AbbLBGyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 01:54:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix ndo_set_mac_address() for PF and VF.
Re-apply uc_list after chip reset.

v2: Fix compile error if CONFIG_BNXT_SRIOV is not set.

Michael Chan (3):
  bnxt_en: Fixed incorrect implementation of ndo_set_mac_address
  bnxt_en: enforce proper storing of MAC address
  bnxt_en: Setup uc_list mac filters after resetting the chip.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c       | 44 +++++++++++++++++--------
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c |  7 ++--
 2 files changed, 34 insertions(+), 17 deletions(-)

-- 
1.8.3.1
