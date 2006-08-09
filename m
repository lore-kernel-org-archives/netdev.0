From: Jan Kasprzak <kas@fi.muni.cz>
Subject: [PATCH] terminology in ip-sysctl.txt
Date: Wed, 9 Aug 2006 09:24:06 +0200
Message-ID: <20060809072406.GL29602@fi.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tirith.ics.muni.cz ([147.251.4.36]:36301 "EHLO
	tirith.ics.muni.cz") by vger.kernel.org with ESMTP id S1030577AbWHIHYl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 03:24:41 -0400
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Hello,

this minor patch fixes the description of net.ipv4.tcp_mem sysctl
in ip-sysctl.txt - the headline names the values "min, pressure, max",
while the description uses the "low, pressure, high" values.
Both tcp_rmem and tcp_wmem descriptions use the "min, pressure, max"
values, so I have changed the tcp_mem to match this and not vice versa.

Signed-Off-By: Jan "Yenya" Kasprzak <kas@fi.muni.cz>

--- a/Documentation/networking/ip-sysctl.txt.orig	2006-08-09 09:14:29.000000000 +0200
+++ b/Documentation/networking/ip-sysctl.txt	2006-08-09 09:21:01.000000000 +0200
@@ -294,15 +294,15 @@
 	Default: 87380*2 bytes.
 
 tcp_mem - vector of 3 INTEGERs: min, pressure, max
-	low: below this number of pages TCP is not bothered about its
+	min: below this number of pages TCP is not bothered about its
 	memory appetite.
 
 	pressure: when amount of memory allocated by TCP exceeds this number
 	of pages, TCP moderates its memory consumption and enters memory
 	pressure mode, which is exited when memory consumption falls
-	under "low".
+	under "min".
 
-	high: number of pages allowed for queueing by all TCP sockets.
+	max: number of pages allowed for queueing by all TCP sockets.
 
 	Defaults are calculated at boot time from amount of available
 	memory.

-Yenya

-- 
| Jan "Yenya" Kasprzak  <kas at {fi.muni.cz - work | yenya.net - private}> |
| GPG: ID 1024/D3498839      Fingerprint 0D99A7FB206605D7 8B35FCDE05B18A5E |
| http://www.fi.muni.cz/~kas/    Journal: http://www.fi.muni.cz/~kas/blog/ |
> I will never go to meetings again because I think  face to face meetings <
> are the biggest waste of time you can ever have.        --Linus Torvalds <
