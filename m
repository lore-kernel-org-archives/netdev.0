From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 4/6] ip-link.8: Place 'ip link set' warning more prominently
Date: Sat,  9 Jul 2016 11:22:48 +0200
Message-ID: <1468056170-6056-5-git-send-email-phil@nwl.cc>
References: <1468056170-6056-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:57645 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933103AbcGIJXf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2016 05:23:35 -0400
In-Reply-To: <1468056170-6056-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This moves the warning to the beginning of the section about 'ip link
set' which makes it still stand out after adding more text to it's end.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-link.8.in | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 4fc5f3c6257e5..2678d37df7478 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -1015,6 +1015,18 @@ specifies the type of the device.
 
 .SS ip link set - change device attributes
 
+.PP
+.B Warning:
+If multiple parameter changes are requested,
+.B ip
+aborts immediately after any of the changes have failed.
+This is the only case when
+.B ip
+can move the system to an unpredictable state. The solution
+is to avoid changing several parameters with one
+.B ip link set
+call.
+
 .TP
 .BI dev " DEVICE "
 .I DEVICE
@@ -1235,18 +1247,6 @@ set the IPv6 address generation mode
 .BR "link-netnsid "
 set peer netnsid for a cross-netns interface
 
-.PP
-.B Warning:
-If multiple parameter changes are requested,
-.B ip
-aborts immediately after any of the changes have failed.
-This is the only case when
-.B ip
-can move the system to an unpredictable state. The solution
-is to avoid changing several parameters with one
-.B ip link set
-call.
-
 .SS  ip link show - display device attributes
 
 .TP
-- 
2.8.2
