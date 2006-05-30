From: Pavel Machek <pavel@suse.cz>
Subject: zd1201 failure on sharp zaurus explained
Date: Tue, 30 May 2006 15:20:54 +0200
Message-ID: <20060530132054.GA9780@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from gprs189-60.eurotel.cz ([160.218.189.60]:20644 "EHLO amd.ucw.cz")
	by vger.kernel.org with ESMTP id S1751102AbWE3NVl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 May 2006 09:21:41 -0400
To: rpurdie@rpsys.net, lenz@cs.wisc.edu,
	kernel list <linux-kernel@vger.kernel.org>,
	Russell King <rmk@arm.linux.org.uk>,
	Netdev list <netdev@vger.kernel.org>,
	Jirka Lenost Benc <jbenc@suse.cz>, pe1rxq@amsat.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

Now I found out what went wrong with zd1201 on sharp zaurus (spitz)...

Card is detected and seems to work okay, except that you don't get any
results from iwlist eth1 scan, and card generally does not do anything
involving radio.

And now I have an explanation, too:

If you plug card directly to zaurus, above is what happens.

If you plug it into the hub, hub flashes the lights and shuts down, as
if not enough power is available from the zaurus.

...which is probably the case, because if I connect external 6V power
supply to the hub, it all starts to work.

So... it is

1) hw problem: spitz power supply is not strong enough to drive zd1201

2) usb problem, probably. Should not usb core detect that card
requires too much juice and refuse to power it up?

...and the morale is, always put hub between device and the host so
that you can see the flashy leds :-).
								Pavel 
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
