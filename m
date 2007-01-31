From: Pavel Machek <pavel@suse.cz>
Subject: Re: [linux-pm] [RFC] Runtime power management on	ipw2100
Date: Wed, 31 Jan 2007 14:44:16 +0100
Message-ID: <20070131134416.GG19643@elf.ucw.cz>
References: <20070131075249.GA22115@srcf.ucam.org> <p731wlbphz3.fsf@bingen.suse.de> <20070131102744.GA24424@srcf.ucam.org> <200701311148.20777.ak@suse.de> <1170244400.6746.31.camel@amit-laptop> <20070131130447.GF19643@elf.ucw.cz> <1170249876.6746.43.camel@amit-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ext Andi Kleen <ak@suse.de>, Matthew Garrett <mjg59@srcf.ucam.org>,
	netdev@vger.kernel.org, linux-pm@lists.osdl.org,
	ipw2100-devel@lists.sourceforge.net
To: Amit Kucheria <amit.kucheria@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gprs189-60.eurotel.cz ([160.218.189.60]:40612 "EHLO amd.ucw.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933273AbXAaNo2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 08:44:28 -0500
Content-Disposition: inline
In-Reply-To: <1170249876.6746.43.camel@amit-laptop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> > > Yes. Low power states without ability to respond to wakeup interrupts
> > > would be broken behaviour generally.
> > 
> > Do you realy expect wifi to save significant ammount of power, while
> > still listening for packets on wireless network?
> 
> >From N800 specs (not meant as a shameless plug):
> 
> Continuous WLAN browsing:  upto 3.5 hrs
> Always Online WLAN (idle but respond to VoIP calls): upto 2 days
> Standby time(no WLAN):  upto 12 days
> 
> So with the right hardware, yes, you can listen and still save power.

Okay, but I'm somehow not sure if ipw2100 can do this kind of
tricks. Yes, n800 is likely very nice toy :-).
									Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
