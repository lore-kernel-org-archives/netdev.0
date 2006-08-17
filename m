From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: proposal for new wireless configuration API
Date: Thu, 17 Aug 2006 12:39:38 -0700
Message-ID: <20060817193938.GA29676@bougret.hpl.hp.com>
References: <1155655728.17742.30.camel@ux156> <200608151838.58182.mb@bu3sch.de> <1155665688.8940.10.camel@localhost.localdomain> <200608152113.23697.mb@bu3sch.de>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:14806 "EHLO
	gundega.hpl.hp.com") by vger.kernel.org with ESMTP id S1751266AbWHQTla
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 15:41:30 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200608152113.23697.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 15, 2006 at 09:13:23PM +0200, Michael Buesch wrote:
> On Tuesday 15 August 2006 20:14, Dan Williams wrote:
> > On Tue, 2006-08-15 at 18:38 +0200, Michael Buesch wrote:
> > > On Tuesday 15 August 2006 18:29, Dan Williams wrote:
> > > > o Separate attributes for channel and frequency
> > > 
> > > No, channel and freq is the same. It's just another name
> > > for the same child. I would say we only want to deal with channel numbers
> > > in the API. That's much easier, as we don't have to deal with this
> > > fixed-point (or even floating point) mess. Look at WE for the
> > > fixed-point mess.
> > 
> > Right, I don't have a problem with only using one or the other; but we
> > _HAVE_ to provide a function in the driver that allows userspace
> > programs to convert channel <-> frequency both ways, like you suggest
> > below.  Obviously the channel/frequency mapping isn't the same
> > everywhere.
> > 
> > [ or is it?  I'd be very uncomfortable using the same channel #s
> > everywhere unless some IEEE spec states exactly what the channel #s are
> > for every frequency range that wireless stuff operates in ]
> 
> The channel<->freq mapping is stable.

	We may need to double check this...
	It is already clear that WiMax, ZigBee and pre-802.11 HW don't
use the same channel<->freq mapping as 802.11.
	Further, I remember somebody (was it Jouni) mentioning that
some variations of 802.11 have different channel mappings. But, we
would need to check that.

> > No argument here; as long as we provide the mapping function in the
> > driver for each card.
> 
> Hm, I don't know if I understand this correctly.
> You want to implement the mapping function in every driver
> or in the d80211 stack?

	A simple mapping table is probably enough, similar to what we
already have.

	Jean
