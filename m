From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net 0/5] bnxt_en: Bug fixes.
Date: Thu, 5 Nov 2015 16:25:46 -0500
Message-ID: <1446758751-27999-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:29804 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757020AbbKEVZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 16:25:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Miscellaneous small bug fixes.

Michael Chan (5):
  bnxt_en: Change sp events definitions to represent bit position.
  bnxt_en: Determine tcp/ipv6 RSS hash type correctly.
  bnxt_en: map CAG_REG_LEGACY_INT_STATUS_MASK to GRC window #4
  bnxt_en: Fix comparison of u16 sw_id against negative value.
  bnxt_en: More robust SRIOV cleanup sequence.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c       | 28 ++++++++++++-----
 drivers/net/ethernet/broadcom/bnxt/bnxt.h       | 26 +++++++++-------
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c | 40 +++++++++++++++++--------
 3 files changed, 64 insertions(+), 30 deletions(-)

-- 
1.8.3.1
