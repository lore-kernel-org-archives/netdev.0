From: Pavel Machek <pavel@suse.cz>
Subject: Re: What should PCI core do during suspend-resume? (was: Re:
	2.6.29-rc3: tg3 dead after resume)
Date: Sat, 7 Feb 2009 10:21:31 +0100
Message-ID: <20090207092131.GG1411@ucw.cz>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <alpine.LFD.2.00.0901301714080.3150@localhost.localdomain> <200901312208.20850.rjw@sisk.pl> <200901312242.17273.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Parag Warudkar <parag.lkml@gmail.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:43837 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751978AbZBGJVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:21:48 -0500
Content-Disposition: inline
In-Reply-To: <200901312242.17273.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

> What about devices with no drivers and/or without suspend/resume support?
> Do you want them to be disabled during suspend and enabled during resume by
> the core?  [I guess you do, they have no interrupt handlers that may break
> after all.]

Device with driver but with no suspend/resume support can still use
interrupts. But I don't think there's much we can do in that
case... except perhaps failing the suspend.

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
