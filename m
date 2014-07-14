From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 15/16] ieee802154: remove unnecessary break after goto
Date: Mon, 14 Jul 2014 18:36:38 +0200
Message-ID: <1405355799-7691-6-git-send-email-fabf@skynet.be>
References: <1405355799-7691-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay008.isp.belgacom.be ([195.238.6.174]:28504 "EHLO
	mailrelay008.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932209AbaGNQfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 12:35:44 -0400
In-Reply-To: <1405355799-7691-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/ieee802154/6lowpan_iphc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ieee802154/6lowpan_iphc.c b/net/ieee802154/6lowpan_iphc.c
index 211b568..11aa235 100644
--- a/net/ieee802154/6lowpan_iphc.c
+++ b/net/ieee802154/6lowpan_iphc.c
@@ -300,7 +300,6 @@ uncompress_udp_header(struct sk_buff *skb, struct udphdr *uh)
 		default:
 			pr_debug("ERROR: unknown UDP format\n");
 			goto err;
-			break;
 		}
 
 		pr_debug("uncompressed UDP ports: src = %d, dst = %d\n",
-- 
1.8.4.5
