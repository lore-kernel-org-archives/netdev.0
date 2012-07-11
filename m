From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH] tc: man: add 'delete' command.
Date: Wed, 11 Jul 2012 16:31:21 +0800
Message-ID: <4FFD39D9.4040403@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:35738 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751215Ab2GKIcD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 04:32:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add the missing 'delete' command for qdisc, class and filter, and
correct 'remove' to 'delete'.
---
 man/man8/tc.8 |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/man/man8/tc.8 b/man/man8/tc.8
index 958ab98..346c545 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -2,7 +2,7 @@
 .SH NAME
 tc \- show / manipulate traffic control settings
 .SH SYNOPSIS
-.B tc qdisc [ add | change | replace | link ] dev
+.B tc qdisc [ add | change | replace | link | delete ] dev
 DEV
 .B
 [ parent
@@ -13,7 +13,7 @@ qdisc-id ] qdisc
 [ qdisc specific parameters ]
 .P
 
-.B tc class [ add | change | replace ] dev
+.B tc class [ add | change | replace | delete ] dev
 DEV
 .B parent
 qdisc-id
@@ -22,7 +22,7 @@ class-id ] qdisc
 [ qdisc specific parameters ]
 .P
 
-.B tc filter [ add | change | replace ] dev
+.B tc filter [ add | change | replace | delete ] dev
 DEV
 .B  [ parent
 qdisc-id
@@ -316,8 +316,8 @@ parameter. A class is named with the
 parameter.
 
 .TP
-remove
-A qdisc can be removed by specifying its handle, which may also be 'root'. All subclasses and their leaf qdiscs
+delete
+A qdisc can be deleted by specifying its handle, which may also be 'root'. All subclasses and their leaf qdiscs
 are automatically deleted, as well as any filters attached to them.
 
 .TP
-- 
1.7.1
