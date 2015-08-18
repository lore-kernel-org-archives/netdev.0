From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] ip-address.8.in: fix BNF syntax error
Date: Tue, 18 Aug 2015 18:11:12 +0200
Message-ID: <1439914272-3918-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:41986 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752430AbbHRQLO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 12:11:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The previous man page fixup introduced a syntax error due to missing
opening bracket, which might crash some humanoid BNF parsers.

Fixes: 4e972d5 ("ip-address: fix and extend documentation")
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-address.8.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/ip-address.8.in b/man/man8/ip-address.8.in
index 2ea3e67..f1efc43 100644
--- a/man/man8/ip-address.8.in
+++ b/man/man8/ip-address.8.in
@@ -60,7 +60,7 @@ ip-address \- protocol address management
 .IR FLAG " := "
 .RB "[ " permanent " | " dynamic " | " secondary " | " primary " | \
 [ - ] " tentative " | [ - ] " deprecated " | [ - ] " dadfailed " | "\
-temporary " ] " CONFFLAG-LIST " ]"
+temporary " ] [ " CONFFLAG-LIST " ]"
 
 .ti -8
 .IR CONFFLAG-LIST " := [ "  CONFFLAG-LIST " ] " CONFFLAG
-- 
2.1.2
