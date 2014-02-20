From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH ethtool] ethtool: Report Backplane as supported port
Date: Thu, 20 Feb 2014 18:48:56 +0100
Message-ID: <1392918536-20444-1-git-send-email-ivecera@redhat.com>
Cc: bhutchings@solarflare.com, agospoda@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62725 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753098AbaBTRtB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Feb 2014 12:49:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 ethtool.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ethtool.c b/ethtool.c
index 315d00f..acb4397 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -496,6 +496,8 @@ static void dump_supported(struct ethtool_cmd *ep)
 		fprintf(stdout, "MII ");
 	if (mask & SUPPORTED_FIBRE)
 		fprintf(stdout, "FIBRE ");
+	if (mask & SUPPORTED_Backplane)
+		fprintf(stdout, "Backplane ");
 	fprintf(stdout, "]\n");
 
 	dump_link_caps("Supported", "Supports", mask, 0);
-- 
1.8.3.2
