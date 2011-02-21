From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 4/5] ethtool: Indent the no-options usage line
 consistently with the others
Date: Mon, 21 Feb 2011 19:18:46 +0000
Message-ID: <1298315926.2608.72.camel@bwh-desktop>
References: <1298315809.2608.68.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:10260 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752039Ab1BUTSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 14:18:49 -0500
In-Reply-To: <1298315809.2608.68.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 8246bda..32a97f6 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -286,7 +286,8 @@ static void show_usage(void)
 	fprintf(stdout, PACKAGE " version " VERSION "\n");
 	fprintf(stdout,
 		"Usage:\n"
-		"ethtool DEVNAME\tDisplay standard information about device\n");
+		"        ethtool DEVNAME\t"
+		"Display standard information about device\n");
 	for (i = 0; args[i].lng; i++) {
 		fputs("        ethtool ", stdout);
 		if (args[i].srt)
-- 
1.7.3.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

