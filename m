From: David Gibson <hermes@gibson.dropbear.id.au>
Subject: Re: [PATCH 2.6.10-rc1 1/15] wireless/orinoco: Use msleep() instead of hardcoded schedule_timeout()s
Date: Thu, 28 Oct 2004 11:42:25 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041028014225.GD2216@zax>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com> <1098815604.3663.35.camel@dcbw.boston.redhat.com> <20041026184749.GA16621@infradead.org> <1098819336.9874.11.camel@dcbw.boston.redhat.com> <20041026194219.GA17343@infradead.org> <1098820512.9874.13.camel@dcbw.boston.redhat.com> <20041027031305.GG7925@zax> <1098882671.13459.2.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, netdev@oss.sgi.com,
        jgarzik@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dan Williams <dcbw@redhat.com>
Content-Disposition: inline
In-Reply-To: <1098882671.13459.2.camel@dcbw.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Oct 27, 2004 at 09:11:11AM -0400, Dan Williams wrote:
> Ok, so in my zeal to get the kernel orinoco drivers to _not_ _suck_,
> what branch is the most up-to-date?  Have you been commiting the stuff
> here that you say is "committed to CVS" to _both_ HEAD and for_linus?

They are all equally up-to-date, more or less.  The difference between
the three branches is:
	HEAD - Has backwards compatibility code and experimental code
notready for merging (at preset, just USB support)
	standalone - Has backwards compatibility code, but not the
experimental code (so no USB support)
	for_linus - Has neither backwards compatibility code nor
experimental code.

Apart from the differences noted, the branches are kept merged.

I'm well aware that this merge with mainline is long, long overdue,
and frankly I've been a completely slack-arse maintainer.
Unfortunately, I really don't have the time or energy to spend on
this, and there doesn't seem to be anyone else eager to take over
maintainership.

> The things I care about (to bring orinoco drivers up to par with others
> like prism54 & aironet):
> 
> 1) Scanning support
> 2) monitor mode
> 3) the better firmware handling

All these are in all 3 branches.

-- 
David Gibson			| For every complex problem there is a
david AT gibson.dropbear.id.au	| solution which is simple, neat and
				| wrong.
http://www.ozlabs.org/people/dgibson
