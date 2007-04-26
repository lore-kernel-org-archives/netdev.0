From: Greg KH <greg@kroah.com>
Subject: Re: [Security] [PATCH] infinite recursion in netlink
Date: Wed, 25 Apr 2007 22:44:20 -0700
Message-ID: <20070426054420.GA18057@kroah.com>
References: <20070425183856.GA6028@ms2.inr.ac.ru> <alpine.LFD.0.98.0704251311270.9964@woody.linux-foundation.org> <20070426052912.GA17402@kroah.com> <20070425.223201.108808547.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, kuznet@ms2.inr.ac.ru,
	security@kernel.org, netdev@vger.kernel.org, jaco@kroon.co.za
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:35781 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754737AbXDZFoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 01:44:02 -0400
Content-Disposition: inline
In-Reply-To: <20070425.223201.108808547.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 25, 2007 at 10:32:01PM -0700, David Miller wrote:
> From: Greg KH <greg@kroah.com>
> Date: Wed, 25 Apr 2007 22:29:12 -0700
> 
> > On Wed, Apr 25, 2007 at 01:15:12PM -0700, Linus Torvalds wrote:
> > > 
> > > 
> > > On Wed, 25 Apr 2007, Alexey Kuznetsov wrote:
> > > > 
> > > > Reply to NETLINK_FIB_LOOKUP messages were misrouted back to kernel,
> > > > which resulted in infinite recursion and stack overflow.
> > 
> > Wait, I just had the bright idea of actually testing this before I
> > pushed out a 2.6.20.9 kernel with another fix in it, and nope, still
> > crashes, even with this patch  :(
> > 
> > Full stackdump in a picture (forgot to have netconsole running) at:
> > 	http://www.kroah.com/netlink_oops.jpg
> > 
> > Any thoughts?
> > 
> > I'll go try 2.6.21 now too...
> 
> Crap.  We should have let this one simmer for a day to get
> more eyes on it.
> 
> Thanks for catching this Greg.

Odd, 2.6.21 doesn't crash at all.

Can anyone verify that I made the 2.6.20.8 release correctly with the
proper patch?

thanks,

greg k-h
