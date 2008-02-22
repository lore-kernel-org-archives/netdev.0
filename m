From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH] iproute2: fix ip manpage typo (syntax error)
Date: Fri, 22 Feb 2008 14:11:49 +0100
Message-ID: <20080222131149.GA20938@scream.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:35309 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755437AbYBVOSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 09:18:49 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Stephen!

The patches branch of the debian packaging repo, at
git://git.debian.org/git/collab-maint/pkg-iproute, now has four patches still
pending. (Not resending, since they've all been posted multiple times before.
Pick them up from the repo if you're interested.)

Here's the latest addition:


commit 3c904bb5933257533f4afecf805ca5a548a8e885
Author: Andreas Henriksson <andreas@fatal.se>
Date:   Fri Feb 22 13:57:10 2008 +0100

    Fix typo (syntax error) in ip(8) manpage.
    
    Caught by lintian (debian package checker).

diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 1a57a42..c46a9f6 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -940,7 +940,7 @@ Linux-2.x can pack routes into several routing
 tables identified by a number in the range from 1 to 255 or by
 name from the file
 .B /etc/iproute2/rt_tables
-. By default all normal routes are inserted into the
+By default all normal routes are inserted into the
 .B main
 table (ID 254) and the kernel only uses this table when calculating routes.
 


-- 
Regards,
Andreas Henriksson
