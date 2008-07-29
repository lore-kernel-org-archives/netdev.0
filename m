From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 3/6] dccp ccid-3: Dependency without effect
Date: Tue, 29 Jul 2008 15:06:10 +0100
Message-ID: <1217340373-12620-4-git-send-email-gerrit@erg.abdn.ac.uk>
References: <dccp_ccid3_sender_side_updates_last_batch>
 <1217340373-12620-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1217340373-12620-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1217340373-12620-3-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: netdev@vger.kernel.org, Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:36141 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756491AbYG2OG0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2008 10:06:26 -0400
In-Reply-To: <1217340373-12620-3-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This removes a menu-item dependency which is without effect since the
enclosing menu "DCCP CCIDs Configuration (EXPERIMENTAL)" already has
this dependency.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/Kconfig |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -98,7 +98,6 @@ endchoice
 config IP_DCCP_CCID3_RTO
 	  int "Use higher bound for nofeedback timer"
 	  default 100
-	  depends on EXPERIMENTAL
 	  ---help---
 	    Use higher lower bound for nofeedback timer expiration.
 
