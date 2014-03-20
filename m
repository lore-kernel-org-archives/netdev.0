From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next 2/2] ieee802154: dgram: cleanup set of broadcast panid
Date: Thu, 20 Mar 2014 14:57:03 +0100
Message-ID: <1395323823-20970-2-git-send-email-alex.aring@gmail.com>
References: <1395323823-20970-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, phoebe.buckheister@itwm.fraunhofer.de,
	jlu@pengutronix.de, Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:43661 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103AbaCTN5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 09:57:20 -0400
Received: by mail-ee0-f51.google.com with SMTP id c13so700554eek.10
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 06:57:19 -0700 (PDT)
In-Reply-To: <1395323823-20970-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is only a cleanup to use the right define for a panid field.
The broadcast address and panid broadcast is still the same value.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
Cc: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 net/ieee802154/dgram.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index 6d251a3..786437b 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -74,7 +74,7 @@ static int dgram_init(struct sock *sk)
 	struct dgram_sock *ro = dgram_sk(sk);
 
 	ro->dst_addr.mode = IEEE802154_ADDR_LONG;
-	ro->dst_addr.pan_id = cpu_to_le16(IEEE802154_ADDR_BROADCAST);
+	ro->dst_addr.pan_id = cpu_to_le16(IEEE802154_PANID_BROADCAST);
 	ro->want_ack = 1;
 	memset(&ro->dst_addr.extended_addr, 0xff, IEEE802154_ADDR_LEN);
 	return 0;
-- 
1.9.0
