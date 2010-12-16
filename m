From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] pktgen: Remove unnecessary prefix from pr_<level>
Date: Thu, 16 Dec 2010 11:02:33 -0800
Message-ID: <1292526153.29894.37.camel@Joe-Laptop>
References: <20101216172800.GA8404@spritelink.se>
	 <1292522532.29894.33.camel@Joe-Laptop>
	 <20101216183004.GC8404@spritelink.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Kristian Larsson <kristian@spritelink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2716 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754873Ab0LPTCf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Dec 2010 14:02:35 -0500
In-Reply-To: <20101216183004.GC8404@spritelink.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove "pktgen: " prefix string from one pr_info.
pr_fmt adds it, so this is a duplicate.

Signed-off-by: Joe Perches <joe@perches.com>

---

> > trivia:
> > pr_<foo> calls are already prefixed with pktgen via pr_fmt,
> > you don't need to add it to the format string.
> Same thing here, will look over it. I think I copied most of this
> from some other part of pktgen.c :)

 net/core/pktgen.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 18fe20d..a9e7fc4 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3553,8 +3553,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		break;
 	default: /* Drivers are not supposed to return other values! */
 		if (net_ratelimit())
-			pr_info("pktgen: %s xmit error: %d\n",
-				pkt_dev->odevname, ret);
+			pr_info("%s xmit error: %d\n", pkt_dev->odevname, ret);
 		pkt_dev->errors++;
 		/* fallthru */
 	case NETDEV_TX_LOCKED:


