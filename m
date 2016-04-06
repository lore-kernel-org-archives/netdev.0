From: Abdelmajid Mlayeh <abdelmajidx.mlayeh@intel.com>
Subject: [PATCH] neigh: remove duplicated log msg
Date: Wed,  6 Apr 2016 14:42:06 +0200
Message-ID: <1459946535-6015-1-git-send-email-abdelmajidx.mlayeh@intel.com>
Cc: Abdelmajid MLAYEH <abdelmajidx.mlayeh@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Eric Dumazet <edumazet@google.com>,
	Martin Zhang <martinbj2008@gmail.com>,
	Konstantin Khlebnikov <koct9i@gmail.com>,
	Julian Anastasov <ja@ssi.bg>, Rick Jones <rick.jones2@hp.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:36672 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932909AbcDFMmd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2016 08:42:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Abdelmajid MLAYEH <abdelmajidx.mlayeh@intel.com>

This will be printed anyways by neigh_suspect

Signed-off-by: Abdelmajid Mlayeh <abdelmajidx.mlayeh@intel.com>
---
 net/core/neighbour.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index f18ae91..bf20118 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -896,7 +896,6 @@ static void neigh_timer_handler(unsigned long arg)
 			neigh_suspect(neigh);
 			next = now + NEIGH_VAR(neigh->parms, DELAY_PROBE_TIME);
 		} else {
-			neigh_dbg(2, "neigh %p is suspected\n", neigh);
 			neigh->nud_state = NUD_STALE;
 			neigh->updated = jiffies;
 			neigh_suspect(neigh);
-- 
1.9.1

---------------------------------------------------------------------
Intel Corporation SAS (French simplified joint stock company)
Registered headquarters: "Les Montalets"- 2, rue de Paris, 
92196 Meudon Cedex, France
Registration Number:  302 456 199 R.C.S. NANTERRE
Capital: 4,572,000 Euros

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.
