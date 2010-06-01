From: Joe Perches <joe@perches.com>
Subject: [PATCH 19/21] net/ipv4/igmp.c: Remove unnecessary kmalloc casts
Date: Mon, 31 May 2010 20:23:21 -0700
Message-ID: <cac9f44ad085db78698681859236a7c3a0983e49.1275360951.git.joe@perches.com>
References: <cover.1275360951.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2498 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754375Ab0FADXf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 May 2010 23:23:35 -0400
In-Reply-To: <cover.1275360951.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv4/igmp.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 5fff865..250cb5e 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1646,8 +1646,7 @@ static int sf_setstate(struct ip_mc_list *pmc)
 				if (dpsf->sf_inaddr == psf->sf_inaddr)
 					break;
 			if (!dpsf) {
-				dpsf = (struct ip_sf_list *)
-					kmalloc(sizeof(*dpsf), GFP_ATOMIC);
+				dpsf = kmalloc(sizeof(*dpsf), GFP_ATOMIC);
 				if (!dpsf)
 					continue;
 				*dpsf = *psf;
-- 
1.7.0.3.311.g6a6955

