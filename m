From: "Ertman, DavidX M" <davidx.m.ertman@intel.com>
Subject: Re: i217-LM boot wreckage
Date: Fri, 21 Mar 2014 15:09:04 +0000
Message-ID: <2B0E3F215D1AB84DA946C8BEE234CCC9370CF4AB@ORSMSX101.amr.corp.intel.com>
References: <alpine.DEB.2.02.1403201332400.18573@ionos.tec.linutronix.de>
	<alpine.DEB.2.02.1403201431580.18573@ionos.tec.linutronix.de>
	<2B0E3F215D1AB84DA946C8BEE234CCC9370CEFE3@ORSMSX101.amr.corp.intel.com>
	<alpine.DEB.2.02.1403201724500.18573@ionos.tec.linutronix.de>
	<alpine.DEB.2.02.1403211534040.18573@ionos.tec.linutronix.de>
	<alpine.DEB.2.02.1403211551030.18573@ionos.tec.linutronix.de>
	<D38E8E86660E514AB505863C19C9287C73F87D2B@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Ronciak, John" <john.ronciak@intel.com>, Thomas Gleixner
	<tglx@linutronix.de>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <D38E8E86660E514AB505863C19C9287C73F87D2B@ORSMSX102.amr.corp.intel.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This has been reproduced here.  I am touching base with the person who reproduced it and will be addressing this as a high priority.

Thanks for finding this.

Dave Ertman

-----Original Message-----
From: Ronciak, John 
Sent: Friday, March 21, 2014 8:08 AM
To: Thomas Gleixner; Ertman, DavidX M
Cc: e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org
Subject: RE: [E1000-devel] i217-LM boot wreckage

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
> > > > From your lspci output it looks like you have a Management 
> > > > Engine enabled platform.  Do you know what version of ME is loaded?
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



------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
