From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 0/3] bnxt_en: Phy related fixes.
Date: Fri, 19 Feb 2016 19:43:18 -0500
Message-ID: <1455929001-12039-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:63396
	"EHLO mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1428903AbcBTAnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 19:43:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

3 small patches to fix PHY related code.

Michael Chan (3):
  bnxt_en: Poll link at the end of __bnxt_open_nic().
  bnxt_en: Remove unnecessary call to update PHY settings.
  bnxt_en: Failure to update PHY is not fatal condition.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

-- 
1.8.3.1
