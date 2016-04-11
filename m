From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 0/4] bnxt_en: Update for net-next
Date: Mon, 11 Apr 2016 04:11:10 -0400
Message-ID: <1460362274-21771-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:12225 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310AbcDKILQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 04:11:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Misc. changes for link speed and VF MAC address change.

Michael Chan (4):
  bnxt_en: Disallow forced speed for 10GBaseT devices.
  bnxt_en: Shutdown link when device is closed.
  bnxt_en: Call firmware to approve VF MAC address change.
  bnxt_en: Add async event handling for speed config changes.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 40 ++++++++++++++++++++---
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  1 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |  8 +++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c   | 30 +++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h   |  1 +
 5 files changed, 76 insertions(+), 4 deletions(-)

-- 
1.8.3.1
