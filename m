From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net] l2tp: fix PPP pseudo-wire auto-loading
Date: Mon, 3 Apr 2017 13:23:15 +0200
Message-ID: <4f0c437337252f267de92ae650cb39e48dbff192.1491218507.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:60412 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752038AbdDCLXU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 07:23:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PPP pseudo-wire type is 7 (11 is L2TP_PWTYPE_IP).

Fixes: f1f39f911027 ("l2tp: auto load type modules")
Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_ppp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 26501902d1a7..9eab1a13aa71 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -1849,4 +1849,4 @@ MODULE_DESCRIPTION("PPP over L2TP over UDP");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(PPPOL2TP_DRV_VERSION);
 MODULE_ALIAS_NET_PF_PROTO(PF_PPPOX, PX_PROTO_OL2TP);
-MODULE_ALIAS_L2TP_PWTYPE(11);
+MODULE_ALIAS_L2TP_PWTYPE(7);
-- 
2.11.0
