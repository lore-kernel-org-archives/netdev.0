From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tg3: Remove prev_vlan_tag from struct tx_ring_info
Date: Wed, 30 Sep 2009 16:07:52 +0200
Message-ID: <4AC36638.8070304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52636 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752299AbZI3OHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 10:07:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

prev_vlan_tag field is not used.

Patch saves 512*8 bytes per tx queue ring on 64bit arches.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 82b45d8..524691c 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2412,7 +2412,6 @@ struct ring_info {
 
 struct tx_ring_info {
 	struct sk_buff                  *skb;
-	u32                             prev_vlan_tag;
 };
 
 struct tg3_config_info {
