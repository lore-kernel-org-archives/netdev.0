From: "Ronciak, John" <john.ronciak@intel.com>
Subject: RE: [E1000-devel] i217-LM boot wreckage
Date: Fri, 21 Mar 2014 15:07:32 +0000
Message-ID: <D38E8E86660E514AB505863C19C9287C73F87D2B@ORSMSX102.amr.corp.intel.com>
References: <alpine.DEB.2.02.1403201332400.18573@ionos.tec.linutronix.de>
	<alpine.DEB.2.02.1403201431580.18573@ionos.tec.linutronix.de>
	<2B0E3F215D1AB84DA946C8BEE234CCC9370CEFE3@ORSMSX101.amr.corp.intel.com>
	<alpine.DEB.2.02.1403201724500.18573@ionos.tec.linutronix.de>
	<alpine.DEB.2.02.1403211534040.18573@ionos.tec.linutronix.de>
 <alpine.DEB.2.02.1403211551030.18573@ionos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>,
	"Ertman, DavidX M" <davidx.m.ertman@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:21194 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752933AbaCUPHz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 11:07:55 -0400
In-Reply-To: <alpine.DEB.2.02.1403211551030.18573@ionos.tec.linutronix.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Thomas Gleixner [mailto:tglx@linutronix.de]
> Sent: Friday, March 21, 2014 7:52 AM
> To: Ertman, DavidX M
> Cc: e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org
> Subject: Re: [E1000-devel] i217-LM boot wreckage
> 
> On Fri, 21 Mar 2014, Thomas Gleixner wrote:
> > On Thu, 20 Mar 2014, Thomas Gleixner wrote:
> > > On Thu, 20 Mar 2014, Ertman, DavidX M wrote:
> > > > Hello Thomas,
> > > >
> > > > Could you provide the exact kernel version and kernel config you
> are using?
> > >
> > > 3.14-rc7. config attached
> > >
> > > > Do you have Runtime Power Management enabled?
> > >
> > > According to .config yes
> > >
> > > > Have you tried the latest driver from sourceforge.net (3.0.4.1)?
> > >
> > > Nope, why should I?
> >
> > Now I got desperate enough to do. Doesnt work either.
> >
> > > > From your lspci output it looks like you have a Management Engine
> > > > enabled platform.  Do you know what version of ME is loaded?
> Have
> > >
> > > 9.0.2.1345
> > >
> > > Disabling ME in the BIOS does not help.
> > >
> > > > you checked to see that you are on the latest BIOS/NVM image
> > > > (looks like a new one was released on March 11th for the M93z)?
> > >
> > > Yep. Latest BIOS does not help either.
> >
> > Just for extended fun: The Thinkpad L440 has the same issue.
> 
> Some more data. 3.12 does not work at all, 3.13 has the same behaviour
> as 3.14.-rc7
Thomas,

What does "does not work at all" mean? How is it broken?  Please supply some details.

Thanks.  We are looking into what's going on here but we don't have a lot of laptops around to test with.  That's slowing us down a bit.

Cheers,
John
