From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH iproute2] bridge: trivial: Fix typo in error message (hairpin)
Date: Thu, 7 Nov 2013 12:09:24 +0100
Message-ID: <20131107110924.GF1172@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:37082 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753260Ab3KGLS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 06:18:58 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Option name is hairpin (without 'g').

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 bridge/link.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/bridge/link.c b/bridge/link.c
index 38dfaea..a82cce0 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -271,7 +271,7 @@ static int brlink_modify(int argc, char **argv)
 				exit(-1);
 		} else if (strcmp(*argv, "hairpin") == 0) {
 			NEXT_ARG();
-			if (!on_off("hairping", &hairpin, *argv))
+			if (!on_off("hairpin", &hairpin, *argv))
 				exit(-1);
 		} else if (strcmp(*argv, "fastleave") == 0) {
 			NEXT_ARG();
-- 
1.8.4.2
