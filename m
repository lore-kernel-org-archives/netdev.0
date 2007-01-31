From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [linux-pm] [RFC] Runtime power management =?iso-8859-1?q?on=09ipw2100?=
Date: Wed, 31 Jan 2007 14:12:05 +0100
Message-ID: <200701311412.06213.oneukum@suse.de>
References: <20070131075249.GA22115@srcf.ucam.org> <1170244400.6746.31.camel@amit-laptop> <20070131130447.GF19643@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Pavel Machek <pavel@suse.cz>,
	Amit Kucheria <amit.kucheria@nokia.com>,
	Matthew Garrett <mjg59@srcf.ucam.org>,
	ipw2100-devel@lists.sourceforge.net, ext Andi Kleen <ak@suse.de>,
	netdev@vger.kernel.org
To: linux-pm@lists.osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46862 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933226AbXAaNLy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 08:11:54 -0500
In-Reply-To: <20070131130447.GF19643@elf.ucw.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 31. Januar 2007 14:04 schrieb Pavel Machek:
> On Wed 2007-01-31 13:53:20, Amit Kucheria wrote:
> > On Wed, 2007-01-31 at 11:48 +0100, ext Andi Kleen wrote:
> > > On Wednesday 31 January 2007 11:27, Matthew Garrett wrote:
> > > > On Wed, Jan 31, 2007 at 12:13:04PM +0100, Andi Kleen wrote:
> > > > > Matthew Garrett <mjg59@srcf.ucam.org> writes:
> > > > > > 
> > > > > > PCI seems to require a delay of 10ms when sequencing from D3 to D0, 
> > > > > > which probably isn't acceptable latency for an "up" state.
> > > > > 
> > > > > It might be if the interface has been idle for some time
> > > > > (and the delay is not busy looping of course)
> > > > 
> > > > Hm. How would this interact with receiving packets?
> > > 
> > > The hardware will hopefully have support to wake itself up when that 
> > > happens.
> > 
> > Yes. Low power states without ability to respond to wakeup interrupts
> > would be broken behaviour generally.
> 
> Do you realy expect wifi to save significant ammount of power, while
> still listening for packets on wireless network?

It has a managed mode which gives each station a timeslot. Outside
those slots you could power down, if you can do it quickly.

	Regards
		Oliver
