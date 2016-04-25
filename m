From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 0/3] bnxt_en: Bug fixes for net.
Date: Mon, 25 Apr 2016 02:30:48 -0400
Message-ID: <1461565851-32524-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:2753 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753420AbcDYGaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 02:30:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only use MSIX on VF, and fix rx page buffers on architectures with
PAGE_SIZE >= 64K.

Michael Chan (3):
  bnxt_en: Don't fallback to INTA on VF.
  bnxt_en: Limit RX BD pages to be no bigger than 32K.
  bnxt_en: Divide a page into 32K buffers for the aggregation ring if
    necessary.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 53 +++++++++++++++++++++++--------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h | 13 ++++++++
 2 files changed, 52 insertions(+), 14 deletions(-)

-- 
1.8.3.1
