From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 8/9] lg-vl600: Convert uses of __constant_<foo> to <foo>
Date: Wed, 12 Mar 2014 10:22:37 -0700
Message-ID: <90c51467c9cc8ca3b8e4d74a63da42b28d8d51ec.1394644825.git.joe@perches.com>
References: <cover.1394644825.git.joe@perches.com>
Cc: linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0147.hostedemail.com ([216.40.44.147]:58297 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756351AbaCLRXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 13:23:19 -0400
In-Reply-To: <cover.1394644825.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The use of __constant_<foo> has been unnecessary for quite awhile now.

Make these uses consistent with the rest of the kernel.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/usb/lg-vl600.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/lg-vl600.c b/drivers/net/usb/lg-vl600.c
index acfcc32..8f37efd 100644
--- a/drivers/net/usb/lg-vl600.c
+++ b/drivers/net/usb/lg-vl600.c
@@ -210,7 +210,7 @@ static int vl600_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 			 * (0x86dd) so Linux can understand it.
 			 */
 			if ((buf->data[sizeof(*ethhdr)] & 0xf0) == 0x60)
-				ethhdr->h_proto = __constant_htons(ETH_P_IPV6);
+				ethhdr->h_proto = htons(ETH_P_IPV6);
 		}
 
 		if (count) {
-- 
1.8.1.2.459.gbcd45b4.dirty
