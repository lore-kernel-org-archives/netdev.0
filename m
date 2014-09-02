From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH net-next 2/4] ipv6: coding style - min to min_t conversion
Date: Tue,  2 Sep 2014 20:16:02 +0100
Message-ID: <1409685364-4327-3-git-send-email-ipm@chirality.org.uk>
References: <1409685364-4327-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:36327 "EHLO
	oak.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754125AbaIBTQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 15:16:14 -0400
In-Reply-To: <1409685364-4327-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes a min to min_t as per checkpatch recomendation.

No change in the object output is detected by the objdiff script.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv6/addrconf.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 509c53e..23d8493 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2320,8 +2320,11 @@ ok:
 			else
 				stored_lft = 0;
 			if (!update_lft && !create && stored_lft) {
-				const u32 minimum_lft = min(
-					stored_lft, (u32)MIN_VALID_LIFETIME);
+				const u32 minimum_lft = min_t(
+							  u32,
+							  stored_lft,
+							  MIN_VALID_LIFETIME);
+
 				valid_lft = max(valid_lft, minimum_lft);
 
 				/* RFC4862 Section 5.5.3e:
-- 
1.7.9.5
