From: Greg KH <greg@kroah.com>
Subject: Re: xen-netback stable backports request (regression fixes)
Date: Wed, 5 Jun 2013 14:08:07 -0700
Message-ID: <20130605210807.GA15455@kroah.com>
References: <1369734465.3469.52.camel@zakaz.uk.xensource.com>
 <20130605045532.GA10475@kroah.com>
 <1370422590.24512.135.camel@zakaz.uk.xensource.com>
 <20130605202502.GD13713@kroah.com>
 <1370465579.6652.14.camel@hastur.hellion.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	xen-devel <xen-devel@lists.xen.org>, netdev@vger.kernel.org,
	Wei Liu <wei.liu2@citrix.com>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1370465579.6652.14.camel@hastur.hellion.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 05, 2013 at 09:52:59PM +0100, Ian Campbell wrote:
> On Wed, 2013-06-05 at 13:25 -0700, Greg KH wrote: 
> > > For the first we thought that allocating a variable size array on the
> > > stack was bad practice which could lead to a stack overflow. The default
> > > is safe but can be overridden by a module parameter.
> > > 
> > > The other renames the module parameter which we thought was useful for
> > > consistency between newer kernels and the stable branches.
> > 
> > So you are doing a user/kernel api change in a stable branch?  Heck, you
> > did it in 3.10?  Why?  What did you just break by doing that?  I can't
> > do that to users of the stable kernels, sorry, and you shouldn't be
> > doing that to users of the 3.10 kernel either.  You should rename this
> > back so people's working systems don't break when they upgrade their
> > kernel.
> 
> The module parameter was introduce after 3.9 and then renamed before
> v3.10-rc1 happened, the original name was never part of an -rc let alone
> an actual release.

Ah, ok, my mistake then, I'll go apply this to keep things synced up.

sorry for the confusion, too many patches at once to handle in the
short-term memory...

greg k-h
