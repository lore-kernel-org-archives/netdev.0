From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 2.6.10-rc1 1/15] wireless/orinoco: Use msleep() instead
	of hardcoded schedule_timeout()s
Date: Wed, 27 Oct 2004 09:11:11 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098882671.13459.2.camel@dcbw.boston.redhat.com>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
	 <1098815604.3663.35.camel@dcbw.boston.redhat.com>
	 <20041026184749.GA16621@infradead.org>
	 <1098819336.9874.11.camel@dcbw.boston.redhat.com>
	 <20041026194219.GA17343@infradead.org>
	 <1098820512.9874.13.camel@dcbw.boston.redhat.com>
	 <20041027031305.GG7925@zax>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>, netdev@oss.sgi.com,
        jgarzik@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Gibson <hermes@gibson.dropbear.id.au>
In-Reply-To: <20041027031305.GG7925@zax>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ok, so in my zeal to get the kernel orinoco drivers to _not_ _suck_,
what branch is the most up-to-date?  Have you been commiting the stuff
here that you say is "committed to CVS" to _both_ HEAD and for_linus?

The things I care about (to bring orinoco drivers up to par with others
like prism54 & aironet):

1) Scanning support
2) monitor mode
3) the better firmware handling

Dan

On Wed, 2004-10-27 at 13:13 +1000, David Gibson wrote:
> On Tue, Oct 26, 2004 at 03:55:12PM -0400, Dan Williams wrote:
> > I will leave that do David/jgarzik since I didn't actually write any of
> > this code, I just broke the megadiff down.
> 
> What's happened is that the old explicit schedule_timeout() constructs
> were replaced in CVS with msleep() (ssleep() didn't exist at the
> time).  In the meantime, at least some of them were replaced with
> ssleep() in mainline.
> 
> I'm about to commit a patch to CVS replacing the msleep()s with
> ssleep()s.  In the for_linus branch, at least, HEAD will take longer
> because we'll need to come up with something to maintain compatibility
> with pre-ssleep() kernels.
> 
> > On Tue, 2004-10-26 at 20:42 +0100, Christoph Hellwig wrote:
> > > On Tue, Oct 26, 2004 at 03:35:36PM -0400, Dan Williams wrote:
> > > > New description:
> > > > 
> > > > o Use msleep() instead of hardcoded schedule_timeout()s
> > > > o Normalize sleep calls to use msleep() everywhere
> > > 
> > > care to explain what's the point of the latter?
> 
