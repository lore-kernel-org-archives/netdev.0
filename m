From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] man tc: Highlight minor & major, notice they are hex
Date: Mon,  9 Mar 2015 01:07:17 +0200
Message-ID: <1425856037-19986-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:43614 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473AbbCHXSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2015 19:18:51 -0400
Received: by labgf13 with SMTP id gf13so42938029lab.10
        for <netdev@vger.kernel.org>; Sun, 08 Mar 2015 16:18:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Also added some trivial form of the ID as "major:minor",
just for visualisation of explained words.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/tc.8 | 30 ++++++++++++++++++++----------
 1 file changed, 20 insertions(+), 10 deletions(-)

diff --git a/man/man8/tc.8 b/man/man8/tc.8
index a6aed0a..ea4d445 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -250,23 +250,33 @@ attached to that class. Check qdisc specific manpages for details, however.
 All qdiscs, classes and filters have IDs, which can either be specified
 or be automatically assigned.
 
-IDs consist of a major number and a minor number, separated by a colon.
-Both major and minor number are limited to 16 bits. There are two special
-values: root is signified by major and minor of all ones, and unspecified
-is all zeros.
+IDs consist of a
+.BR major " number and a " minor
+number, separated by a colon -
+.BR major ":" minor "."
+Both
+.BR major " and " minor
+are hexadecimal numbers and are limited to 16 bits. There are two special
+values: root is signified by
+.BR major " and " minor
+of all ones, and unspecified is all zeros.
 
 .TP
 QDISCS
-A qdisc, which potentially can have children,
-gets assigned a major number, called a 'handle', leaving the minor
+A qdisc, which potentially can have children, gets assigned a
+.B major
+number, called a 'handle', leaving the
+.B minor
 number namespace available for classes. The handle is expressed as '10:'.
-It is customary to explicitly assign a handle to qdiscs expected to have
-children.
+It is customary to explicitly assign a handle to qdiscs expected to have children.
 
 .TP
 CLASSES
-Classes residing under a qdisc share their qdisc major number, but each have
-a separate minor number called a 'classid' that has no relation to their
+Classes residing under a qdisc share their qdisc
+.B major
+number, but each have a separate
+.B minor
+number called a 'classid' that has no relation to their
 parent classes, only to their parent qdisc. The same naming custom as for
 qdiscs applies.
 
-- 
2.3.1
