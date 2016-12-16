From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH] ip: vfinfo: remove code duplication for IFLA_VF_RSS_QUERY_EN
Date: Fri, 16 Dec 2016 17:36:05 +0100
Message-ID: <20161216163605.19728-1-julien@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: phil@nwl.cc, Julien Fortin <julien@cumulusnetworks.com>
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35860 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934030AbcLPQgZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 11:36:25 -0500
Received: by mail-wm0-f50.google.com with SMTP id g23so39258379wme.1
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2016 08:36:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Fixes: 4fb4a10e120b1 ("ipaddress: Print IFLA_VF_QUERY_RSS_EN setting”)

Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
---
 ip/ipaddress.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index de64877..400ebb4 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -414,14 +414,6 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 			fprintf(fp, ", query_rss %s",
 			        rss_query->setting ? "on" : "off");
 	}
-	if (vf[IFLA_VF_RSS_QUERY_EN]) {
-		struct ifla_vf_rss_query_en *rss_query =
-			RTA_DATA(vf[IFLA_VF_RSS_QUERY_EN]);
-
-		if (rss_query->setting != -1)
-			fprintf(fp, ", query_rss %s",
-			        rss_query->setting ? "on" : "off");
-	}
 	if (vf[IFLA_VF_STATS] && show_stats)
 		print_vf_stats64(fp, vf[IFLA_VF_STATS]);
 }
-- 
2.11.0
