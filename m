From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] batman-adv: remove pointless conditional before kfree_skb()
Date: Tue, 28 Aug 2012 21:06:08 +0800
Message-ID: <CAPgLHd8jAk-4C1w4Z-q=WeMT_SgB99HCrGCtEPa5Xe4VYnZCOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, b.a.t.m.a.n@lists.open-mesh.org,
	netdev@vger.kernel.org
To: lindner_marek@yahoo.de, siwu@hrz.tu-chemnitz.de,
	ordex@autistici.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:58588 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261Ab2H1NGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Aug 2012 09:06:08 -0400
Received: by qaas11 with SMTP id s11so2611837qaa.19
        for <netdev@vger.kernel.org>; Tue, 28 Aug 2012 06:06:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove pointless conditional before kfree_skb().

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/batman-adv/send.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 3b4b2da..534dc46 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -99,8 +99,7 @@ void batadv_schedule_bat_ogm(struct batadv_hard_iface *hard_iface)
 
 static void batadv_forw_packet_free(struct batadv_forw_packet *forw_packet)
 {
-	if (forw_packet->skb)
-		kfree_skb(forw_packet->skb);
+	kfree_skb(forw_packet->skb);
 	if (forw_packet->if_incoming)
 		batadv_hardif_free_ref(forw_packet->if_incoming);
 	kfree(forw_packet);
