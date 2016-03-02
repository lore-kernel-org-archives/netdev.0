From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 08/20] man: ip-address.8: Minor syntax fixes
Date: Wed,  2 Mar 2016 19:19:56 +0100
Message-ID: <1456942808-15946-9-git-send-email-phil@nwl.cc>
References: <20160302093800.7e7dbe71@xeon-e3>
 <1456942808-15946-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:53014 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752106AbcCBSVt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 13:21:49 -0500
In-Reply-To: <1456942808-15946-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clarify that the optional '-' prefix of the 'tentative', 'deprecated'
and 'dadfailed' keywords has to be put right in front of them, no
whitespace is allowed in between.

In addition to that, clarify that it is valid to pass both 'valid_lft'
and 'preferred_lft' at the same time to 'ip address'.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-address.8.in | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/man/man8/ip-address.8.in b/man/man8/ip-address.8.in
index 159d9065f0c9b..ff3fe0b96b02a 100644
--- a/man/man8/ip-address.8.in
+++ b/man/man8/ip-address.8.in
@@ -58,9 +58,9 @@ ip-address \- protocol address management
 
 .ti -8
 .IR FLAG " := "
-.RB "[ " permanent " | " dynamic " | " secondary " | " primary " | \
-[ - ] " tentative " | [ - ] " deprecated " | [ - ] " dadfailed " | "\
-temporary " | " CONFFLAG-LIST " ]"
+.RB "[ " permanent " | " dynamic " | " secondary " | " primary " |"
+.RB [ - ] tentative " | [" - ] deprecated " | [" - ] dadfailed " |"
+.BR temporary " | " CONFFLAG-LIST " ]"
 
 .ti -8
 .IR CONFFLAG-LIST " := [ "  CONFFLAG-LIST " ] " CONFFLAG
@@ -72,7 +72,7 @@ temporary " | " CONFFLAG-LIST " ]"
 .ti -8
 .IR LIFETIME " := [ "
 .BI valid_lft " LFT"
-.RB "| " preferred_lft
+.RB "] [ " preferred_lft
 .IR  LFT " ]"
 
 .ti -8
-- 
2.7.2
