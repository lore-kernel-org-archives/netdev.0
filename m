From: Benjamin Poirier <bpoirier@suse.com>
Subject: [PATCH 2/2] igmp: Document sysctl_igmp_max_msf
Date: Mon, 21 Mar 2016 13:21:40 -0700
Message-ID: <1458591700-5547-2-git-send-email-bpoirier@suse.com>
References: <1458591700-5547-1-git-send-email-bpoirier@suse.com>
Cc: Jonathan Corbet <corbet@lwn.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:60929 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932345AbcCUUWK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2016 16:22:10 -0400
In-Reply-To: <1458591700-5547-1-git-send-email-bpoirier@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
---
 Documentation/networking/ip-sysctl.txt | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index d3768e8..b183e2b 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -946,10 +946,15 @@ igmp_max_memberships - INTEGER
 	The value 5459 assumes no IP header options, so in practice
 	this number may be lower.
 
+igmp_max_msf - INTEGER
+	Maximum number of addresses allowed in the source filter list for a
+	multicast group.
+	Default: 10
+
 igmp_qrv - INTEGER
-	 Controls the IGMP query robustness variable (see RFC2236 8.1).
-	 Default: 2 (as specified by RFC2236 8.1)
-	 Minimum: 1 (as specified by RFC6636 4.5)
+	Controls the IGMP query robustness variable (see RFC2236 8.1).
+	Default: 2 (as specified by RFC2236 8.1)
+	Minimum: 1 (as specified by RFC6636 4.5)
 
 conf/interface/*  changes special settings per interface (where
 "interface" is the name of your network interface)
-- 
2.7.2
