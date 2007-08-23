From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] shaper: mark for removal
Date: Thu, 23 Aug 2007 09:44:30 -0700
Message-ID: <20070823094430.036f2d28@freepuppy.rosehill.hemminger.net>
References: <20070822165854.7a65f099@freepuppy.rosehill.hemminger.net>
	<20070822.170133.05603862.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	Adrian Bunk <bunk@stusta.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57898 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757755AbXHWQts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 12:49:48 -0400
In-Reply-To: <20070822.170133.05603862.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: shaper: mark for removal

This driver has been marked obsolete for a long time and
is superseded by traffic schedulers.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/Documentation/feature-removal-schedule.txt	2007-08-23 09:36:24.000000000 -0700
+++ b/Documentation/feature-removal-schedule.txt	2007-08-23 09:43:24.000000000 -0700
@@ -290,3 +290,12 @@ Why:	All mthca hardware also supports MS
 Who:	Roland Dreier <rolandd@cisco.com>
 
 ---------------------------
+
+What:	shaper network driver
+When:	January 2008
+Files:	drivers/net/shaper.c, include/linux/if_shaper.h
+Why:	This driver has been marked obsolete for many years.
+	It was only designed to work on lower speed links and has design
+	flaws that lead to machine crashes. The qdisc infrastructure in
+	2.4 or later kernels, provides richer features and is more robust.
+Who:	Stephen Hemminger <shemminger@linux-foundation.org>
