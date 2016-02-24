From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 17/20] man: ip-xfrm.8: Document missing parameters
Date: Wed, 24 Feb 2016 09:21:30 +0100
Message-ID: <1456302093-697-18-git-send-email-phil@nwl.cc>
References: <1456302093-697-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:46139 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758097AbcBXIWR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 03:22:17 -0500
In-Reply-To: <1456302093-697-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Namely, 'extra-flag' of 'ip xfrm state' and 'flag' of 'ip xfrm policy'.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-xfrm.8 | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/man/man8/ip-xfrm.8 b/man/man8/ip-xfrm.8
index dae0728811b2e..11f710470377f 100644
--- a/man/man8/ip-xfrm.8
+++ b/man/man8/ip-xfrm.8
@@ -57,6 +57,8 @@ ip-xfrm \- transform configuration
 .IR ADDR "[/" PLEN "] ]"
 .RB "[ " ctx
 .IR CTX " ]"
+.RB "[ " extra-flag
+.IR EXTRA-FLAG-LIST " ]"
 
 .ti -8
 .B "ip xfrm state allocspi"
@@ -196,6 +198,13 @@ ip-xfrm \- transform configuration
 .IR SPORT " " DPORT " " OADDR
 
 .ti -8
+.IR EXTRA-FLAG-LIST " := [ " EXTRA-FLAG-LIST " ] " EXTRA-FLAG
+
+.ti -8
+.IR EXTRA-FLAG " := "
+.B dont-encap-dscp
+
+.ti -8
 .BR "ip xfrm policy" " { " add " | " update " }"
 .I SELECTOR
 .B dir
@@ -247,6 +256,8 @@ ip-xfrm \- transform configuration
 .IR ACTION " ]"
 .RB "[ " priority
 .IR PRIORITY " ]"
+.RB "[ " flag
+.IR FLAG-LIST "]"
 
 .ti -8
 .B "ip xfrm policy flush"
-- 
2.6.4
