From: Alexander Kuznetsov <alr.kuznetsov@gmail.com>
Subject: [PATCH] 8139too: Fix a typo in the function name.
Date: Mon, 19 Apr 2010 23:43:37 +0300
Message-ID: <1271709817-11169-1-git-send-email-alr.kuznetsov@gmail.com>
Cc: netdev@vger.kernel.org,
	Alexander Kuznetsov <alr.kuznetsov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:46565 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201Ab0DSUpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 16:45:31 -0400
Received: by bwz19 with SMTP id 19so3036bwz.21
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 13:45:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexander Kuznetsov <alr.kuznetsov@gmail.com>
---
 drivers/net/8139too.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index a03d291..f0d23de 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -1944,7 +1944,7 @@ static int rtl8139_rx(struct net_device *dev, struct rtl8139_private *tp,
 		netif_dbg(tp, rx_status, dev, "%s() status %04x, size %04x, cur %04x\n",
 			  __func__, rx_status, rx_size, cur_rx);
 #if RTL8139_DEBUG > 2
-		print_dump_hex(KERN_DEBUG, "Frame contents: ",
+		print_hex_dump(KERN_DEBUG, "Frame contents: ",
 			       DUMP_PREFIX_OFFSET, 16, 1,
 			       &rx_ring[ring_offset], 70, true);
 #endif
-- 
1.6.4.4

