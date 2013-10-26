From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next v2 5/5] 6lowpan: remove unnecessary break
Date: Sat, 26 Oct 2013 15:54:02 +0200
Message-ID: <1382795642-12501-6-git-send-email-alex.aring@gmail.com>
References: <1382795642-12501-1-git-send-email-alex.aring@gmail.com>
Cc: linux-zigbee-devel@lists.sourceforge.net, werner@almesberger.net,
	dbaryshkov@gmail.com, netdev@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:49657 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753422Ab3JZNyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Oct 2013 09:54:22 -0400
Received: by mail-ee0-f49.google.com with SMTP id e52so799864eek.22
        for <netdev@vger.kernel.org>; Sat, 26 Oct 2013 06:54:21 -0700 (PDT)
In-Reply-To: <1382795642-12501-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
Reviewed-by: Werner Almesberger <werner@almesberger.net>
---
 net/ieee802154/6lowpan.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 665b118..6d75038 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -440,7 +440,6 @@ lowpan_uncompress_udp_header(struct sk_buff *skb, struct udphdr *uh)
 		default:
 			pr_debug("ERROR: unknown UDP format\n");
 			goto err;
-			break;
 		}
 
 		pr_debug("uncompressed UDP ports: src = %d, dst = %d\n",
-- 
1.8.4.1
