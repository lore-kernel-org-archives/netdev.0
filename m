From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 1/2] lnstat: describe -s option in help output
Date: Wed, 18 Nov 2015 16:57:46 +0100
Message-ID: <1447862267-13603-2-git-send-email-phil@nwl.cc>
References: <1447862267-13603-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:53594 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755191AbbKRP6G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2015 10:58:06 -0500
In-Reply-To: <1447862267-13603-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/lnstat.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/misc/lnstat.c b/misc/lnstat.c
index 1e547d0..529bc33 100644
--- a/misc/lnstat.c
+++ b/misc/lnstat.c
@@ -73,7 +73,10 @@ static int usage(char *name, int exit_code)
 	fprintf(stderr, "\t-i --interval <intv>\t"
 			"Set interval to 'intv' seconds\n");
 	fprintf(stderr, "\t-k --keys k,k,k,...\tDisplay only keys specified\n");
-	fprintf(stderr, "\t-s --subject [0-2]\t?\n");
+	fprintf(stderr, "\t-s --subject [0-2]\tControl header printing:\n");
+	fprintf(stderr, "\t\t\t\t0 = never\n");
+	fprintf(stderr, "\t\t\t\t1 = once\n");
+	fprintf(stderr, "\t\t\t\t2 = every 20 lines (default))\n");
 	fprintf(stderr, "\t-w --width n,n,n,...\tWidth for each field\n");
 	fprintf(stderr, "\n");
 
-- 
2.5.0
