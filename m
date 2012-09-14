From: John Fastabend <john.r.fastabend@intel.com>
Subject: [PATCH] iproute2: bridge: finish removing replace option in man pages
Date: Thu, 13 Sep 2012 23:50:36 -0700
Message-ID: <20120914065036.9063.86401.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:33007 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754655Ab2INHHM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2012 03:07:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch finishes removing the replace option from the bridge
man page which I missed in this commit

commit 57b9785de32404da3d2ac5483469b7fcc5a9c9e7
Author: John Fastabend <john.r.fastabend@intel.com>
Date:   Mon Aug 27 10:52:31 2012 -0700

    iproute2: bridge: remove replace and change options

Also add documentation for "{ self | embedded }" already shown on
the cmd line help msg.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 man/man8/bridge.8 |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index 63d166b..5ce8219 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -22,11 +22,12 @@ bridge \- show / manipulate bridge addresses and devices
 \fB\-s\fR[\fItatistics\fR]
 
 .ti -8
-.BR "bridge fdb" " { " add " | " del " | " change " | " replace " } "
+.BR "bridge fdb" " { " add " | " del " } "
 .I LLADDR
 .B  dev
 .IR DEV " { "
-.BR local " | " temp " }"
+.BR local " | " temp " } { "
+.BR self " } { " embedded " } "
 
 .ti -8
 .BR "bridge fdb" " [ " show " ] [ "
@@ -92,11 +93,9 @@ objects contain known Ethernet addresses on a  link.
 The corresponding commands display fdb entries, add new entries,
 and delete old ones.
 
-.SS bridge fdb add - add a new neighbor entry
-.SS bridge fdb change - change an existing entry
-.SS bridge fdb replace - add a new entry or change an existing one
+.SS bridge fdb add - add a new fdb entry
 
-These commands create new neighbor records or update existing ones.
+This command creates a new fdb entry.
 
 .TP
 .BI "ADDRESS"
@@ -117,6 +116,14 @@ and is never forwarded.
 - the address is a dynamic entry, and will be removed if not used.
 .sp
 
+.B self
+- the address is associated with a software fdb (default)
+.sp
+
+.B embedded
+- the address is associated with an offloaded fdb
+.sp
+
 .in -8
 
 .SS bridge fdb delete - delete a forwarding database entry
