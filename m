From: roopa@cumulusnetworks.com
Subject: [PATCH iproute2] Add missing space
Date: Wed, 13 Mar 2013 21:14:58 -0700
Message-ID: <1363234498-14545-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext.cumulusnetworks.com ([66.175.223.20]:47079 "EHLO
	ext.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782Ab3CNEO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 00:14:59 -0400
To: shemminger@vyatta.com
To: roopa@cumulusnetworks.com
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa <roopa@cumulusnetworks.com>

Reported-by: Andreas Henriksson <andreas@fatal.se>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 ip/ipaddress.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index fdd2a74..0712164 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -470,7 +470,7 @@ int print_linkinfo(const struct sockaddr_nl *who,
 
 	if (do_link && tb[IFLA_IFALIAS]) {
 		fprintf(fp, "%s", _SL_);
-		fprintf(fp,"    alias %s",
+		fprintf(fp, "    alias %s",
 			rta_getattr_str(tb[IFLA_IFALIAS]));
 	}
 
-- 
1.7.2.5
