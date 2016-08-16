From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] ip-link: add missing {min,max}_tx_rate to help text
Date: Tue, 16 Aug 2016 16:08:38 +0200
Message-ID: <1471356518-17731-1-git-send-email-phil@nwl.cc>
Cc: Jakub Sitnicki <jkbs@redhat.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:53656 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753185AbcHPOJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2016 10:09:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These vf options are described in man page already, they're just missing
in help output.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iplink.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ip/iplink.c b/ip/iplink.c
index f9a7e0909747c..6b1db18a6135d 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -79,6 +79,8 @@ void iplink_usage(void)
 	fprintf(stderr, "				   [ vlan VLANID [ qos VLAN-QOS ] ]\n");
 
 	fprintf(stderr, "				   [ rate TXRATE ]\n");
+	fprintf(stderr, "				   [ max_tx_rate TXRATE ]\n");
+	fprintf(stderr, "				   [ min_tx_rate TXRATE ]\n");
 
 	fprintf(stderr, "				   [ spoofchk { on | off} ]\n");
 	fprintf(stderr, "				   [ query_rss { on | off} ]\n");
-- 
2.8.2
