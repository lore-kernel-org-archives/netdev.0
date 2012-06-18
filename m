From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH] tc: man: Fix incorrect parameter format in prio.
Date: Mon, 18 Jun 2012 14:23:05 +0800
Message-ID: <4FDEC949.30207@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:17436 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751816Ab2FRGXo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jun 2012 02:23:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Parameter priomap use blank instead of comma to separate bands,
update manpage to confirms to this.
---
 man/man8/tc-prio.8 |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/man8/tc-prio.8 b/man/man8/tc-prio.8
index 1625fcc..55a5f3d 100644
--- a/man/man8/tc-prio.8
+++ b/man/man8/tc-prio.8
@@ -11,7 +11,7 @@ major:
 .B ] prio [ bands 
 bands
 .B ] [ priomap
-band,band,band... 
+band band band... 
 .B ] [ estimator 
 interval timeconstant
 .B ]
@@ -134,7 +134,7 @@ showing to which Priority they are mapped.
 The last column shows the result of the default priomap. On the command line,
 the default priomap looks like this:
 
-    1, 2, 2, 2, 1, 2, 0, 0 , 1, 1, 1, 1, 1, 1, 1, 1
+    1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 
 This means that priority 4, for example, gets mapped to band number 1.
 The priomap also allows you to list higher priorities (> 7) which do not
-- 
1.7.1
