From: Greg KH <greg@kroah.com>
Subject: Re: Network drivers with direct io memory accesses
Date: Tue, 20 May 2008 11:33:45 -0700
Message-ID: <20080520183345.GA12937@kroah.com>
References: <20080515001044.GA2772@kroah.com> <20080514.171315.87012656.davem@davemloft.net> <20080515002824.GA3636@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:58522 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764368AbYETSeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 14:34:23 -0400
Content-Disposition: inline
In-Reply-To: <20080515002824.GA3636@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 14, 2008 at 05:28:24PM -0700, Greg KH wrote:
> On Wed, May 14, 2008 at 05:13:15PM -0700, David Miller wrote:
> > From: Greg KH <greg@kroah.com>
> > Date: Wed, 14 May 2008 17:10:44 -0700
> > 
> > > Both of these drivers are accessing memory on the devices directly,
> > > without using the proper kernel abstractions for it, making them usable
> > > only on x86-based boxes probably.
> > > 
> > > My question is, does this have to be fixed in order to get them
> > > accepted into the tree?
> > 
> > I'd say yes.
> 
> {sigh}
> 
> I figured that, but thought it would be worth it to at least ask. :)
> 
> > If that aspect isn't fixed I can't even build test them on my
> > computers.
> 
> Hm, why?  They should still build I would think, just not run properly,
> right?
> 
> Damm, I really gotta get that cross-build system set up here, I'll go
> start that right now...

Ok, I did this, and I don't see any build errors or warnings on sparc64.
Maybe the code isn't as bad as I imagined, I'll go through it all and
submit it for review.

thanks,

greg k-h
