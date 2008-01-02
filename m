From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH] iproute2: add synonyms for ip rule options to ip(8)
	manpage.
Date: Thu, 03 Jan 2008 00:49:11 +0100
Message-ID: <1199317752.16358.57.camel@localhost.localdomain>
References: <1199317650.16358.54.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:53695 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753044AbYABXpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 18:45:50 -0500
In-Reply-To: <1199317650.16358.54.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 355e1438f73602fbac029d28891dfa889471b679
Author: Andreas Henriksson <andreas@fatal.se>
Date:   Wed Jan 2 23:21:59 2008 +0100

    Add synonyms for ip rule options to ip(8) manpage.
    
    See:
    http://bugs.debian.org/433507
    http://bugs.debian.org/213673

diff --git a/man/man8/ip.8 b/man/man8/ip.8
index c74440a..1a57a42 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -1568,10 +1568,12 @@ the priority of this rule.  Each rule should have an explicitly
 set
 .I unique
 priority value.
+The options preference and order are synonyms with priority.
 
 .TP
 .BI table " TABLEID"
 the routing table identifier to lookup if the rule selector matches.
+It is also possible to use lookup instead of table.
 
 .TP
 .BI realms " FROM/TO"
@@ -1589,6 +1591,7 @@ may be either the start of the block of NAT addresses (selected by NAT
 routes) or a local host address (or even zero).
 In the last case the router does not translate the packets, but
 masquerades them to this address.
+Using map-to instead of nat means the same thing.
 
 .B Warning:
 Changes to the RPDB made with these commands do not become active
@@ -1601,6 +1604,7 @@ This command has no arguments.
 
 .SS ip rule show - list rules
 This command has no arguments.
+The options list or lst are synonyms with show.
 
 .SH ip maddress - multicast addresses management
 


