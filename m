From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH net-next] sky2: Fix TX_MAP_PAGE misspelling
Date: Mon, 1 Feb 2010 10:19:07 +0000
Message-ID: <20100201101907.GA12132@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Breuer <mbreuer@majjas.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:36802 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751424Ab0BAKTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2010 05:19:14 -0500
Received: by fxm20 with SMTP id 20so4027600fxm.21
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2010 02:19:12 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Btw of the dma-debug problem reported by Michael Breuer I spotted
a tiny misspelling in TX_MAP_PAGE definition introduced by commit
6b84dacadbdc3.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 drivers/net/sky2.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index 365d79c..54cb303 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -2156,7 +2156,7 @@ struct tx_ring_info {
 	struct sk_buff	*skb;
 	unsigned long flags;
 #define TX_MAP_SINGLE   0x0001
-#define TX_MAP_PAGE     000002
+#define TX_MAP_PAGE     0x0002
 	DECLARE_PCI_UNMAP_ADDR(mapaddr);
 	DECLARE_PCI_UNMAP_LEN(maplen);
 };
