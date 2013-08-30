From: Daniel Borkmann <dborkman@redhat.com>
Subject: [RFC PATCH net-next 7/7] net: ipv6: mld: document force_mld_version in ip-sysctl.txt
Date: Fri, 30 Aug 2013 18:58:28 +0200
Message-ID: <1377881908-8022-8-git-send-email-dborkman@redhat.com>
References: <1377881908-8022-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16100 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756879Ab3H3Q6n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Aug 2013 12:58:43 -0400
In-Reply-To: <1377881908-8022-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Document force_mld_version parameter in ip-sysctl.txt.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 Documentation/networking/ip-sysctl.txt | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 1cb3aeb..a46d785 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1358,6 +1358,11 @@ mldv2_unsolicited_report_interval - INTEGER
 	MLDv2 report retransmit will take place.
 	Default: 1000 (1 second)
 
+force_mld_version - INTEGER
+	0 - (default) No enforcement of a MLD version, MLDv1 fallback allowed
+	1 - Enforce to use MLD version 1
+	2 - Enforce to use MLD version 2
+
 suppress_frag_ndisc - INTEGER
 	Control RFC 6980 (Security Implications of IPv6 Fragmentation
 	with IPv6 Neighbor Discovery) behavior:
-- 
1.7.11.7
