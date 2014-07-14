From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 13/16] caif: remove unnecessary break after goto
Date: Mon, 14 Jul 2014 18:36:36 +0200
Message-ID: <1405355799-7691-4-git-send-email-fabf@skynet.be>
References: <1405355799-7691-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay008.isp.belgacom.be ([195.238.6.174]:28504 "EHLO
	mailrelay008.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932157AbaGNQfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 12:35:38 -0400
In-Reply-To: <1405355799-7691-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/caif/cfctrl.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/caif/cfctrl.c b/net/caif/cfctrl.c
index 0f45522..f5afda1 100644
--- a/net/caif/cfctrl.c
+++ b/net/caif/cfctrl.c
@@ -547,7 +547,6 @@ static int cfctrl_recv(struct cflayer *layer, struct cfpkt *pkt)
 	default:
 		pr_err("Unrecognized Control Frame\n");
 		goto error;
-		break;
 	}
 	ret = 0;
 error:
-- 
1.8.4.5
