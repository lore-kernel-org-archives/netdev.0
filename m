From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net 0/4] bnxt_en: Bug fix and add tx timeout recovery.
Date: Tue, 8 Dec 2015 19:18:38 -0500
Message-ID: <1449620322-12961-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:64648 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739AbbLIASo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 19:18:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a bitmap declaration bug and add missing tx timeout recovery.

Michael Chan (4):
  bnxt_en: Fix bitmap declaration to work on 32-bit arches.
  bnxt_en: Change bp->state to bitmap.
  bnxt_en: Don't cancel sp_task from bnxt_close_nic().
  bnxt_en: Implement missing tx timeout reset logic.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c       | 48 +++++++++++++++++--------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h       |  6 ++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c |  2 +-
 3 files changed, 37 insertions(+), 19 deletions(-)

-- 
1.8.3.1
