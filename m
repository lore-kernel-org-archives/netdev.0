From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] iprule: Align help text with man page synopsis
Date: Thu, 25 Feb 2016 13:07:35 +0100
Message-ID: <1456402055-15112-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:52099 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752706AbcBYMHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2016 07:07:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The help text was misleading: One could think it is possible to list
rules by selector, which would be nice but isn't. This change also
clarifies that 'ip rule' defaults to 'list' if no further arguments are
given.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iprule.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/ip/iprule.c b/ip/iprule.c
index a7b53f43d4e17..7e3b38b64c6e1 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -33,8 +33,9 @@ static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip rule [ list | add | del | flush | save ] SELECTOR ACTION\n");
-	fprintf(stderr, "       ip rule restore\n");
+	fprintf(stderr, "Usage: ip rule { add | del } SELECTOR ACTION\n");
+	fprintf(stderr, "       ip rule { flush | save | restore }\n");
+	fprintf(stderr, "       ip rule [ list ]\n");
 	fprintf(stderr, "SELECTOR := [ not ] [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark FWMARK[/MASK] ]\n");
 	fprintf(stderr, "            [ iif STRING ] [ oif STRING ] [ pref NUMBER ]\n");
 	fprintf(stderr, "ACTION := [ table TABLE_ID ]\n");
-- 
2.6.4
