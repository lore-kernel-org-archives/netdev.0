From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH] ip-rule: neither prohibit nor reject or unreachable flags exist
Date: Thu, 15 Oct 2015 22:32:17 +0200
Message-ID: <1444941137-12375-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:49354 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750759AbbJOUcT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 16:32:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This has been inconsistent since the beginning of Git and seems to be
merely a documentation leftover, therefore just remove it from help
output and man page.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iprule.c        | 1 -
 man/man8/ip-rule.8 | 2 +-
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/ip/iprule.c b/ip/iprule.c
index 714278a..2fa9ade 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -36,7 +36,6 @@ static void usage(void)
 	fprintf(stderr, "SELECTOR := [ not ] [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark FWMARK[/MASK] ]\n");
 	fprintf(stderr, "            [ iif STRING ] [ oif STRING ] [ pref NUMBER ]\n");
 	fprintf(stderr, "ACTION := [ table TABLE_ID ]\n");
-	fprintf(stderr, "          [ prohibit | reject | unreachable ]\n");
 	fprintf(stderr, "          [ realms [SRCREALM/]DSTREALM ]\n");
 	fprintf(stderr, "          [ goto NUMBER ]\n");
 	fprintf(stderr, "          SUPPRESSOR\n");
diff --git a/man/man8/ip-rule.8 b/man/man8/ip-rule.8
index dd925be..6245d8c 100644
--- a/man/man8/ip-rule.8
+++ b/man/man8/ip-rule.8
@@ -41,7 +41,7 @@ ip-rule \- routing policy database management
 .IR TABLE_ID " ] [ "
 .B  nat
 .IR ADDRESS " ] [ "
-.BR prohibit " | " reject " | " unreachable " ] [ " realms
+.B realms
 .RI "[" SRCREALM "/]" DSTREALM " ]"
 .I  SUPPRESSOR
 
-- 
2.5.0
