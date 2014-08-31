From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 6/6] l2tp: Enable checksum unnecessary conversions for l2tp/UDP sockets
Date: Sun, 31 Aug 2014 15:12:46 -0700
Message-ID: <1409523166-9215-7-git-send-email-therbert@google.com>
References: <1409523166-9215-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:54566 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043AbaHaWNe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Aug 2014 18:13:34 -0400
Received: by mail-pd0-f171.google.com with SMTP id y13so4561937pdi.16
        for <netdev@vger.kernel.org>; Sun, 31 Aug 2014 15:13:33 -0700 (PDT)
In-Reply-To: <1409523166-9215-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/l2tp/l2tp_core.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 1109d3b..797c0af 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1392,6 +1392,8 @@ static int l2tp_tunnel_sock_create(struct net *net,
 		if (err < 0)
 			goto out;
 
+		udp_set_convert_csum(sock->sk, true);
+
 		break;
 
 	case L2TP_ENCAPTYPE_IP:
-- 
2.1.0.rc2.206.gedb03e5
