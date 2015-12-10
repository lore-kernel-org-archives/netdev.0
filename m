From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net v2 0/4] bnxt_en: Bug fix and add tx timeout recovery.
Date: Wed, 9 Dec 2015 19:35:40 -0500
Message-ID: <1449707744-7844-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:32297 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751219AbbLJAfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 19:35:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a bitmap declaration bug and add missing tx timeout recovery.

v2: Fixed white space error.  Thanks Dave.

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
