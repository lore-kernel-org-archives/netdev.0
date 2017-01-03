From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next v2 15/27] ipv4/tunnel: use __vlan_hwaccel helpers
Date: Tue,  3 Jan 2017 21:52:36 +0100 (CET)
Message-ID: <64e8a2b40e0e7cc8344281bd26386768eab1bfe4.1483475202.git.mirq-linux@rere.qmqm.pl>
References: <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:34708 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935908AbdACUwm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 15:52:42 -0500
In-Reply-To: <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 net/ipv4/ip_tunnel_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index fed3d29f9eb3..0004a54373f0 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -120,7 +120,7 @@ int __iptunnel_pull_header(struct sk_buff *skb, int hdr_len,
 	}
 
 	skb_clear_hash_if_not_l4(skb);
-	skb->vlan_tci = 0;
+	__vlan_hwaccel_clear_tag(skb);
 	skb_set_queue_mapping(skb, 0);
 	skb_scrub_packet(skb, xnet);
 
-- 
2.11.0
