From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 14/15] pktgen_dst_metrics[] can be static
Date: Tue, 14 Jan 2014 07:49:18 +0100
Message-ID: <1389682159-3260-15-git-send-email-steffen.klassert@secunet.com>
References: <1389682159-3260-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60107 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752545AbaANGto (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 01:49:44 -0500
In-Reply-To: <1389682159-3260-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fengguang Wu <fengguang.wu@intel.com>

CC: Fan Du <fan.du@windriver.com>
CC: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/core/pktgen.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 45ba476..a37ec53 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2500,7 +2500,7 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 
 
 #ifdef CONFIG_XFRM
-u32 pktgen_dst_metrics[RTAX_MAX + 1] = {
+static u32 pktgen_dst_metrics[RTAX_MAX + 1] = {
 
 	[RTAX_HOPLIMIT] = 0x5, /* Set a static hoplimit */
 };
-- 
1.7.9.5
