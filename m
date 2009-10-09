From: Michael Buesch <mb@bu3sch.de>
Subject: Re: pull request: wireless-2.6 2009-10-08
Date: Fri, 9 Oct 2009 10:57:19 +0200
Message-ID: <200910091057.21269.mb@bu3sch.de>
References: <20091008223454.GB2798@tuxdriver.com> <200910090108.08838.mb@bu3sch.de> <20091008.180119.242402327.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:49932 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753938AbZJII6D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Oct 2009 04:58:03 -0400
In-Reply-To: <20091008.180119.242402327.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 09 October 2009 03:01:19 David Miller wrote:
> From: Michael Buesch <mb@bu3sch.de>
> Date: Fri, 9 Oct 2009 01:08:06 +0200
> 
> > I was planning to do a better solution, but I didn't have the time, yet.
> 
> The change is harmless while we're twiddling our thumbs waiting
> for you to implement the fix "properly."
> 
> Not having the fix in is a developer burdon because people turn
> on the DMA API debugger and are going to keep reporting it's
> complaints here and elsewhere.
> 
> Get over your Napoleon complex, and let reasonable working fixes
> get into the tree even if you don't find them optimal.  You can
> always improve them later, "when you get around to it."
> 
> People put fixes in without my ACK in my areas of expertiece all
> the time.  I got over it a long time ago, it's OK, and not worth
> stressing out over.

Ok, that's enough. If you do not need a maintainer, then work without one.
What's a maintainer good for, if it's not for maintaining the code quality?

The patch needlessly moves huge chunks of crap, adds stupid comments, wastes memory.
If that's what you want just to remove a debugging message on devices that virtually
nobody owns, so be it.


---
 MAINTAINERS |    1 -
 1 file changed, 1 deletion(-)

--- wireless-testing.orig/MAINTAINERS
+++ wireless-testing/MAINTAINERS
@@ -1066,7 +1066,6 @@ F:	include/net/ax25.h
 F:	net/ax25/
 
 B43 WIRELESS DRIVER
-M:	Michael Buesch <mb@bu3sch.de>
 M:	Stefano Brivio <stefano.brivio@polimi.it>
 L:	linux-wireless@vger.kernel.org
 W:	http://linuxwireless.org/en/users/Drivers/b43


-- 
Greetings, Michael.
