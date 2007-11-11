From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] net/ipv4/ipvs/: remove unused exports
Date: Sun, 11 Nov 2007 07:48:40 +0100
Message-ID: <20071111064840.GJ21669@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Rumen G. Bogdanovski" <rumen@voicecho.com>, wensong@linux-vs.org,
	horms@verge.net.au, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:32868 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752951AbXKKGtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2007 01:49:04 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes the following unused EXPORT_SYMBOL's:
- ip_vs_try_bind_dest
- ip_vs_find_dest

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 net/ipv4/ipvs/ip_vs_conn.c |    1 -
 net/ipv4/ipvs/ip_vs_ctl.c  |    1 -
 2 files changed, 2 deletions(-)

ad9f400d4f66ea3423f97e609d6ef2572055c603 
diff --git a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
index b7eeae6..0a9f3c3 100644
--- a/net/ipv4/ipvs/ip_vs_conn.c
+++ b/net/ipv4/ipvs/ip_vs_conn.c
@@ -441,7 +441,6 @@ struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp)
 	} else
 		return NULL;
 }
-EXPORT_SYMBOL(ip_vs_try_bind_dest);
 
 
 /*
diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index 3c4d22a..b64cf45 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -604,7 +604,6 @@ struct ip_vs_dest *ip_vs_find_dest(__be32 daddr, __be16 dport,
 	ip_vs_service_put(svc);
 	return dest;
 }
-EXPORT_SYMBOL(ip_vs_find_dest);
 
 /*
  *  Lookup dest by {svc,addr,port} in the destination trash.

