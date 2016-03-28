From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 0/4] misc. small fixes.
Date: Mon, 28 Mar 2016 19:46:03 -0400
Message-ID: <1459208767-4225-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:36099 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755543AbcC1Xzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 19:55:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Misc. small fixes for net.

Michael Chan (4):
  bnxt_en: Initialize CP doorbell value before ring allocation
  bnxt_en: Implement proper firmware message padding.
  bnxt_en: Fix typo in bnxt_hwrm_set_pause_common().
  bnxt_en: Fix ethtool -a reporting.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 10 +++++++---
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  2 ++
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |  6 ++----
 3 files changed, 11 insertions(+), 7 deletions(-)

-- 
1.8.3.1
