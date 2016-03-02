From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 07/20] iprule: add missing nat keyword to help text
Date: Wed,  2 Mar 2016 19:19:55 +0100
Message-ID: <1456942808-15946-8-git-send-email-phil@nwl.cc>
References: <20160302093800.7e7dbe71@xeon-e3>
 <1456942808-15946-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:41088 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755845AbcCBSVR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 13:21:17 -0500
In-Reply-To: <1456942808-15946-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iprule.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ip/iprule.c b/ip/iprule.c
index 33b71976e7b5c..7e3b38b64c6e1 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -39,6 +39,7 @@ static void usage(void)
 	fprintf(stderr, "SELECTOR := [ not ] [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark FWMARK[/MASK] ]\n");
 	fprintf(stderr, "            [ iif STRING ] [ oif STRING ] [ pref NUMBER ]\n");
 	fprintf(stderr, "ACTION := [ table TABLE_ID ]\n");
+	fprintf(stderr, "          [ nat ADDRESS ]\n");
 	fprintf(stderr, "          [ realms [SRCREALM/]DSTREALM ]\n");
 	fprintf(stderr, "          [ goto NUMBER ]\n");
 	fprintf(stderr, "          SUPPRESSOR\n");
-- 
2.7.2
