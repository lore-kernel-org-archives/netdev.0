From: Joe Perches <joe@perches.com>
Subject: [PATCH 20/21] net/ipv6/mcast.c: Remove unnecessary kmalloc casts
Date: Mon, 31 May 2010 20:23:22 -0700
Message-ID: <52b8781064af8d4b1051f5ac175f7b7f175ff1ed.1275360951.git.joe@perches.com>
References: <cover.1275360951.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1275360951.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv6/mcast.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 59f1881..7b5fb43 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1995,8 +1995,7 @@ static int sf_setstate(struct ifmcaddr6 *pmc)
 				    &psf->sf_addr))
 					break;
 			if (!dpsf) {
-				dpsf = (struct ip6_sf_list *)
-					kmalloc(sizeof(*dpsf), GFP_ATOMIC);
+				dpsf = kmalloc(sizeof(*dpsf), GFP_ATOMIC);
 				if (!dpsf)
 					continue;
 				*dpsf = *psf;
-- 
1.7.0.3.311.g6a6955
