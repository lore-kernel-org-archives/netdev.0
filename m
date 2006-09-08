From: Michael Buesch <mb@bu3sch.de>
Subject: Re: RFC/T: Possible fix for bcm43xx periodic work bug
Date: Fri, 8 Sep 2006 11:45:27 +0200
Message-ID: <200609081145.28095.mb@bu3sch.de>
References: <45006221.4090603@lwfinger.net> <20060908094204.GB26916@harddisk-recovery.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Bcm43xx-dev@lists.berlios.de,
	Stefano Brivio <st3@riseup.net>,
	Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:25252
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750756AbWIHJqd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Sep 2006 05:46:33 -0400
To: Erik Mouw <erik@harddisk-recovery.com>
In-Reply-To: <20060908094204.GB26916@harddisk-recovery.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 08 September 2006 11:42, Erik Mouw wrote:
> On Thu, Sep 07, 2006 at 01:17:05PM -0500, Larry Finger wrote:
> > I think I have a fix for the bcm43xx bug that leads to NETDEV WATCHDOG tx timeouts and would like it
> > to get as much testing as possible as this bug affects V2.6.18-rcX. If the problem is truly
> > fixed, I hope to get the fix into mainline before release of the bug into the stable series.
> 
> FWIW, I finally tracked down the bug that hangs my laptop to the
> bcm43xx driver. At first I got the impression it was the cpufreq code
> (which has been flaky in early 2.6.18-rc kernels), but after disabling
> that my laptop still crashed. After that I disabled preempt cause I got
> a couple of lockdep warnings when I had it enabled. That didn't make a
> difference, laptop still hangs after some time (runs a couple of hours
> at most). Right now I'm on wired network and my laptop finally doesn't
> hang anymore (up for two days).
> 
> The hang is very hard to trigger (i.e.: it happens at random, I see no
> pattern) and locks up the machine completely. I've tried to capture
> kernel messages through serial console, but that doesn't work (lock up
> before any messages are printed).
> 
> This is with any 2.6.18-rc kernel without additional patches or
> proprietary modules, 2.6.17 works ok.

The crash is fixed in wireless-2.6.
The actual cause of the controller restart not. So at least it
does not crash anymore.

-- 
Greetings Michael.
