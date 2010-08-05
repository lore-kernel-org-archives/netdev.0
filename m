From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 38/42] drivers/net: Adjust confusing if indentation
Date: Thu, 5 Aug 2010 22:28:31 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1008052228120.31692@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Florian Fainelli <florian@openwrt.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:39082 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760276Ab0HEU2e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Aug 2010 16:28:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

Outdent the code following the if.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r disable braces4@
position p1,p2;
statement S1,S2;
@@

(
if (...) { ... }
|
if (...) S1@p1 S2@p2
)

@script:python@
p1 << r.p1;
p2 << r.p2;
@@

if (p1[0].column == p2[0].column):
  cocci.print_main("branch",p1)
  cocci.print_secs("after",p2)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/cpmac.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index e1f6156..ac3985c 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -506,7 +506,7 @@ static int cpmac_poll(struct napi_struct *napi, int budget)
 					"restart rx from a descriptor that's "
 					"not free: %p\n",
 					priv->dev->name, restart);
-				goto fatal_error;
+			goto fatal_error;
 		}
 
 		cpmac_write(priv->regs, CPMAC_RX_PTR(0), restart->mapping);
