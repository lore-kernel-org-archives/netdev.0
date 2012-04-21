From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 9/9] pch_gbe: remove suspicious comment
Date: Sat, 21 Apr 2012 06:50:36 +0200
Message-ID: <7d83edf3ac63ef1fd290a985bb617dcf98b6926e.1334983472.git.richardcochran@gmail.com>
References: <cover.1334983471.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Takahiro Shimizu <tshimizu818@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:47181 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751743Ab2DUEvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2012 00:51:12 -0400
Received: by mail-we0-f174.google.com with SMTP id x9so6444599wej.19
        for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 21:51:12 -0700 (PDT)
In-Reply-To: <cover.1334983471.git.richardcochran@gmail.com>
In-Reply-To: <cover.1334983471.git.richardcochran@gmail.com>
References: <cover.1334983471.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The time stamping code in this driver appears to have been copied from
the ixp4xx_eth.c driver, including this timing comment. I had actually
measured the time stamp delay on an IXP425, but I really doubt that this
value also applies here.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index e9b785e..89c6bcf 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -210,7 +210,6 @@ pch_tx_timestamp(struct pch_gbe_adapter *adapter, struct sk_buff *skb)
 
 	/*
 	 * This really stinks, but we have to poll for the Tx time stamp.
-	 * Usually, the time stamp is ready after 4 to 6 microseconds.
 	 */
 	for (cnt = 0; cnt < 100; cnt++) {
 		val = pch_ch_event_read(pdev);
-- 
1.7.2.5
