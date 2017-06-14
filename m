From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next 07/11] batman-adv: skb_put_zero() used to optimize code
Date: Wed, 14 Jun 2017 22:48:26 +0800
Message-ID: <1497451706-4606-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-13.163.com ([220.181.12.13]:33000 "EHLO m12-13.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751980AbdFNOs4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 10:48:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 net/batman-adv/bat_v_elp.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/batman-adv/bat_v_elp.c b/net/batman-adv/bat_v_elp.c
index b58007b..bd1064d 100644
--- a/net/batman-adv/bat_v_elp.c
+++ b/net/batman-adv/bat_v_elp.c
@@ -346,9 +346,8 @@ int batadv_v_elp_iface_enable(struct batadv_hard_iface *hard_iface)
 		goto out;
 
 	skb_reserve(hard_iface->bat_v.elp_skb, ETH_HLEN + NET_IP_ALIGN);
-	elp_buff = skb_put(hard_iface->bat_v.elp_skb, BATADV_ELP_HLEN);
+	elp_buff = skb_put_zero(hard_iface->bat_v.elp_skb, BATADV_ELP_HLEN);
 	elp_packet = (struct batadv_elp_packet *)elp_buff;
-	memset(elp_packet, 0, BATADV_ELP_HLEN);
 
 	elp_packet->packet_type = BATADV_ELP;
 	elp_packet->version = BATADV_COMPAT_VERSION;
-- 
2.7.4
