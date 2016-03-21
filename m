From: Benjamin Poirier <bpoirier@suse.com>
Subject: [PATCH 1/2] net: Fix indentation of the conf/ documentation block
Date: Mon, 21 Mar 2016 13:21:39 -0700
Message-ID: <1458591700-5547-1-git-send-email-bpoirier@suse.com>
Cc: Jonathan Corbet <corbet@lwn.net>, Jeremy Eder <jeder@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:60899 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753841AbcCUUWB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2016 16:22:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit d67ef35fff67 ("clarify documentation for
net.ipv4.igmp_max_memberships") mistakenly indented a block of
documentation such that it now looks like it belongs to a specific sysctl.
Restore that block's original position.

Cc: Jeremy Eder <jeder@redhat.com>
Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
---
 Documentation/networking/ip-sysctl.txt | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index d5df40c..d3768e8 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -946,16 +946,16 @@ igmp_max_memberships - INTEGER
 	The value 5459 assumes no IP header options, so in practice
 	this number may be lower.
 
-	conf/interface/*  changes special settings per interface (where
-	"interface" is the name of your network interface)
-
-	conf/all/*	  is special, changes the settings for all interfaces
-
 igmp_qrv - INTEGER
 	 Controls the IGMP query robustness variable (see RFC2236 8.1).
 	 Default: 2 (as specified by RFC2236 8.1)
 	 Minimum: 1 (as specified by RFC6636 4.5)
 
+conf/interface/*  changes special settings per interface (where
+"interface" is the name of your network interface)
+
+conf/all/*	  is special, changes the settings for all interfaces
+
 log_martians - BOOLEAN
 	Log packets with impossible addresses to kernel log.
 	log_martians for the interface will be enabled if at least one of
-- 
2.7.2
