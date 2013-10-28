From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next v3 5/5] 6lowpan: remove unnecessary break
Date: Mon, 28 Oct 2013 10:24:20 +0100
Message-ID: <1382952260-23174-6-git-send-email-alex.aring@gmail.com>
References: <1382952260-23174-1-git-send-email-alex.aring@gmail.com>
Cc: linux-zigbee-devel@lists.sourceforge.net, werner@almesberger.net,
	dbaryshkov@gmail.com, netdev@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:58859 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754581Ab3J1JYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 05:24:31 -0400
Received: by mail-ee0-f54.google.com with SMTP id t10so3087701eei.27
        for <netdev@vger.kernel.org>; Mon, 28 Oct 2013 02:24:30 -0700 (PDT)
In-Reply-To: <1382952260-23174-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
Reviewed-by: Werner Almesberger <werner@almesberger.net>
---
 net/ieee802154/6lowpan.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 3bc32fb..fde90e6 100644
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
