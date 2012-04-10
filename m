From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: [PATCH] iproute: show metrics as an unsigned value
Date: Tue, 10 Apr 2012 17:20:26 +0200
Message-ID: <1334071226-17865-1-git-send-email-jorge@dti2.net>
Reply-To: jorge@dti2.net
Cc: shemminger@vyatta.com, "Jorge Boncompte [DTI2]" <jorge@dti2.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:52176 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754415Ab2DJP1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 11:27:30 -0400
Received: from nikopol.intranet.dti2.net ([81.24.160.13])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v12.5.2)
	with ESMTP id md50021942928.msg
	for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 17:20:48 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>

Avoids showing negative metrics.

Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
---
 ip/iproute.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index c97f979..2d15c01 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -404,7 +404,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 				    abuf, sizeof(abuf)));
 	}
 	if (tb[RTA_PRIORITY])
-		fprintf(fp, " metric %d ", *(__u32*)RTA_DATA(tb[RTA_PRIORITY]));
+		fprintf(fp, " metric %u ", *(__u32*)RTA_DATA(tb[RTA_PRIORITY]));
 	if (r->rtm_flags & RTNH_F_DEAD)
 		fprintf(fp, "dead ");
 	if (r->rtm_flags & RTNH_F_ONLINK)
-- 
1.7.8.3
