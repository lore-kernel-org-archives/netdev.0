From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 01/16] packet: remove unnecessary break after return
Date: Mon, 14 Jul 2014 18:30:51 +0200
Message-ID: <1405355467-7350-2-git-send-email-fabf@skynet.be>
References: <1405355467-7350-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay006.isp.belgacom.be ([195.238.6.172]:31261 "EHLO
	mailrelay006.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755962AbaGNQbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 12:31:17 -0400
In-Reply-To: <1405355467-7350-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/packet/af_packet.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index b85c67c..614ca91 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -3071,10 +3071,8 @@ static int packet_dev_mc(struct net_device *dev, struct packet_mclist *i,
 		break;
 	case PACKET_MR_PROMISC:
 		return dev_set_promiscuity(dev, what);
-		break;
 	case PACKET_MR_ALLMULTI:
 		return dev_set_allmulti(dev, what);
-		break;
 	case PACKET_MR_UNICAST:
 		if (i->alen != dev->addr_len)
 			return -EINVAL;
-- 
1.8.4.5
