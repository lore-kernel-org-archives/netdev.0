From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 07/20] iprule: add missing nat keyword to help text
Date: Wed, 24 Feb 2016 09:21:20 +0100
Message-ID: <1456302093-697-8-git-send-email-phil@nwl.cc>
References: <1456302093-697-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:49650 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758117AbcBXIW3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 03:22:29 -0500
In-Reply-To: <1456302093-697-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iprule.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ip/iprule.c b/ip/iprule.c
index 9923b8eb097d2..a7b53f43d4e17 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -38,6 +38,7 @@ static void usage(void)
 	fprintf(stderr, "SELECTOR := [ not ] [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark FWMARK[/MASK] ]\n");
 	fprintf(stderr, "            [ iif STRING ] [ oif STRING ] [ pref NUMBER ]\n");
 	fprintf(stderr, "ACTION := [ table TABLE_ID ]\n");
+	fprintf(stderr, "          [ nat ADDRESS ]\n");
 	fprintf(stderr, "          [ realms [SRCREALM/]DSTREALM ]\n");
 	fprintf(stderr, "          [ goto NUMBER ]\n");
 	fprintf(stderr, "          SUPPRESSOR\n");
-- 
2.6.4
