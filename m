From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 02/20] ipaddrlabel: Improve help text precision
Date: Wed,  2 Mar 2016 19:19:50 +0100
Message-ID: <1456942808-15946-3-git-send-email-phil@nwl.cc>
References: <20160302093800.7e7dbe71@xeon-e3>
 <1456942808-15946-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:33827 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756262AbcCBSVz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 13:21:55 -0500
In-Reply-To: <1456942808-15946-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neither 'list' nor 'flush' actions accept parameters, and with given
prefix the action keyword is not optional anymore.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipaddrlabel.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ip/ipaddrlabel.c b/ip/ipaddrlabel.c
index f01bc269e8f41..ef093cbe6c30d 100644
--- a/ip/ipaddrlabel.c
+++ b/ip/ipaddrlabel.c
@@ -49,7 +49,8 @@ static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip addrlabel [ list | add | del | flush ] prefix PREFIX [ dev DEV ] [ label LABEL ]\n");
+	fprintf(stderr, "Usage: ip addrlabel { add | del } prefix PREFIX [ dev DEV ] [ label LABEL ]\n");
+	fprintf(stderr, "       ip addrlabel [ list | flush | help ]\n");
 	exit(-1);
 }
 
-- 
2.7.2
