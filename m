From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 0/2] bnxt_en: 2 bug fixes.
Date: Wed,  4 May 2016 16:56:42 -0400
Message-ID: <1462395404-21875-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:31606 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148AbcEDU4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 16:56:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix crash on ppc64 due to missing memory barrier and restore multicast
after reset.

Michael Chan (2):
  bnxt_en: Need memory barrier when processing the completion ring.
  bnxt_en: Setup multicast properly after resetting device.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 23 +++++++++++++++++++----
 1 file changed, 19 insertions(+), 4 deletions(-)

-- 
1.8.3.1
