From: Ben Greear <greearb@candelatech.com>
Subject: [PATCH 1/2] docs: Add neigh/gc_thresh3 and route/max_size documentation.
Date: Mon,  8 Nov 2010 11:13:48 -0800
Message-ID: <1289243629-20789-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:50715 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649Ab0KHTNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 14:13:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 f350c69... 7c5cca2... M	Documentation/networking/ip-sysctl.txt
 Documentation/networking/ip-sysctl.txt |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index f350c69..7c5cca2 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -20,6 +20,15 @@ ip_no_pmtu_disc - BOOLEAN
 min_pmtu - INTEGER
 	default 562 - minimum discovered Path MTU
 
+route/max_size - INTEGER
+	Maximum number of routes allowed in the kernel.  Increase
+	this when using large numbers of interfaces and/or routes.
+
+neigh/default/gc_thresh3 - INTEGER
+	Maximum number of neighbor entries allowed.  Increase this
+	when using large numbers of interfaces and when communicating
+	with large numbers of directly-connected peers. 
+
 mtu_expires - INTEGER
 	Time, in seconds, that cached PMTU information is kept.
 
-- 
1.6.2.5

