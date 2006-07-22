From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] mark sk98lin driver for removal
Date: Sat, 22 Jul 2006 14:11:50 -0700
Message-ID: <20060722141150.5994fee1@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:148 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750760AbWGVVMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Jul 2006 17:12:06 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sk98lin driver is now superseded by the skge driver. I wanted to just
let the old driver wither and die from old age, but there are still bugs
that are too painful to fix.

See http://bugzilla.kernel.org/show_bug.cgi?id=6780
The board crashes repeatedly after 2 weeks. It probably is something
in the vendor MIB code. That code is a mess, and starting over was one
of the motivations for creating the skge driver.

So rather than add more bondo to the old beater to cover the rusty bits,
throw it in the dustbin.

Signed-off-by: Stephen Hemminger <shemminger@osdl.or

--- skge.orig/Documentation/feature-removal-schedule.txt
+++ skge/Documentation/feature-removal-schedule.txt
@@ -258,3 +258,10 @@ Why:	These drivers never compiled since 
 Who:	Jean Delvare <khali@linux-fr.org>
 
 ---------------------------
+
+What:   sk98lin network driver
+When:   January 2007
+Why:    replaced by the skge driver
+Who:    Stephen Hemminger <shemminger@osdl.org>
+
+---------------------------
--- skge.orig/MAINTAINERS
+++ skge/MAINTAINERS
@@ -2677,6 +2677,10 @@ L:	sdhci-devel@list.drzeus.cx
 W:	http://mmc.drzeus.cx/wiki/Linux/Drivers/sdhci
 S:	Maintained
 
+SK98LIN GIGABBIT ETHERNET DRIVER
+L:	netdev@vger.kernel.org
+S:	Obsolete
+
 SKGE, SKY2 10/100/1000 GIGABIT ETHERNET DRIVERS
 P:	Stephen Hemminger
 M:	shemminger@osdl.org
