From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 1/6] man: ip-address: align synopsis with help output
Date: Fri, 18 Sep 2015 20:17:00 +0200
Message-ID: <1442600225-18355-2-git-send-email-phil@nwl.cc>
References: <1442600225-18355-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:52673 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752160AbbIRSRI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Sep 2015 14:17:08 -0400
In-Reply-To: <1442600225-18355-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When fixing the BNF syntax error, I overlooked that 'ip address help'
prints a more correct synopsis. This patch aligns them.

Fixes: 715296b ("ip-address.8.in: fix BNF syntax error")
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-address.8.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/ip-address.8.in b/man/man8/ip-address.8.in
index f1efc43..43611b9 100644
--- a/man/man8/ip-address.8.in
+++ b/man/man8/ip-address.8.in
@@ -60,7 +60,7 @@ ip-address \- protocol address management
 .IR FLAG " := "
 .RB "[ " permanent " | " dynamic " | " secondary " | " primary " | \
 [ - ] " tentative " | [ - ] " deprecated " | [ - ] " dadfailed " | "\
-temporary " ] [ " CONFFLAG-LIST " ]"
+temporary " | " CONFFLAG-LIST " ]"
 
 .ti -8
 .IR CONFFLAG-LIST " := [ "  CONFFLAG-LIST " ] " CONFFLAG
-- 
2.1.2
