From: Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH 5/8] net/ipv6/exthdrs_core.c: Checkpatch cleanups
Date: Sun,  1 Apr 2012 19:49:05 +0200
Message-ID: <1333302548-9187-5-git-send-email-eldad@fogrefinery.com>
References: <1333302548-9187-1-git-send-email-eldad@fogrefinery.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eldad Zack <eldad@fogrefinery.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1333302548-9187-1-git-send-email-eldad@fogrefinery.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

exthdrs_core.c:113: WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
exthdrs_core.c:114: WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable

Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
---
 net/ipv6/exthdrs_core.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv6/exthdrs_core.c b/net/ipv6/exthdrs_core.c
index 72957f4..7b1a884 100644
--- a/net/ipv6/exthdrs_core.c
+++ b/net/ipv6/exthdrs_core.c
@@ -21,6 +21,7 @@ int ipv6_ext_hdr(u8 nexthdr)
 		 (nexthdr == NEXTHDR_NONE)	||
 		 (nexthdr == NEXTHDR_DEST);
 }
+EXPORT_SYMBOL(ipv6_ext_hdr);
 
 /*
  * Skip any extension headers. This is used by the ICMP module.
@@ -109,6 +110,4 @@ int ipv6_skip_exthdr(const struct sk_buff *skb, int start, u8 *nexthdrp,
 	*nexthdrp = nexthdr;
 	return start;
 }
-
-EXPORT_SYMBOL(ipv6_ext_hdr);
 EXPORT_SYMBOL(ipv6_skip_exthdr);
-- 
1.7.9.5
