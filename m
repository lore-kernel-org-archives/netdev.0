From: skallam <siva.kallam@broadcom.com>
Subject: [PATCH net 0/2] tg3: Disallow 0 rx coalesce time and correctly report RSS queues in tg3_get_rxnfc
Date: Wed,  3 Aug 2016 09:43:58 +0530
Message-ID: <1470197640-13587-1-git-send-email-siva.kallam@broadcom.com>
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com,
	prashant@broadcom.com, satish.baddipadige@broadcom.com,
	Siva Reddy Kallam <siva.kallam@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:23881 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331AbcHCEPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 00:15:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Siva Reddy Kallam <siva.kallam@broadcom.com>

First patch:
        Diasllow rx coalescing time to be 0

Second patch:
        Report the correct number of RSS queues through tg3_get_rxnfc

Satish Baddipadige (1):
  tg3: Fix for diasllow rx coalescing time to be 0

Siva Reddy Kallam (1):
  tg3: Report the correct number of RSS queues through tg3_get_rxnfc

 drivers/net/ethernet/broadcom/tg3.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)
