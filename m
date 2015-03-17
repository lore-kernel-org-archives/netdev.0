From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: [PATCH iproute2] bridge: drop reference to unused option embedded from manpage
Date: Tue, 17 Mar 2015 11:34:10 -0400
Message-ID: <1426606450-30133-1-git-send-email-gospo@cumulusnetworks.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:34855 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753530AbbCQPe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 11:34:59 -0400
Received: by qgez64 with SMTP id z64so11359265qge.2
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 08:34:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While looking at the manpage, I noticed a reference to 'embedded' that was
added by this commit:

	commit d611682a8c8f28205158e6d3a7d5e2d01db022cc
	Author: John Fastabend <john.r.fastabend@intel.com>
	Date:   Thu Sep 13 23:50:36 2012 -0700

	    iproute2: bridge: finish removing replace option in man pages

I no longer see any reference to the 'embedded' option in any c- or h-files, so
it seems worthwhile to remove.

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
CC: John Fastabend <john.r.fastabend@intel.com>
---
 man/man8/bridge.8 | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index 2005b9f..1855041 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -54,7 +54,7 @@ bridge \- show / manipulate bridge addresses and devices
 .B  dev
 .IR DEV " { "
 .BR local " | " temp " } { "
-.BR self " } { " embedded " } { " router " } [ "
+.BR self " } { " router " } [ "
 .B  dst
 .IR IPADDR " ] [ "
 .B vni
@@ -326,10 +326,6 @@ the interface to which this address is associated.
 - the address is associated with a software fdb (default)
 .sp
 
-.B embedded
-- the address is associated with an offloaded fdb
-.sp
-
 .B router
 - the destination address is associated with a router.
 Valid if the referenced device is a VXLAN type device and has
-- 
1.9.3
