From: Ian Campbell <ian.campbell@citrix.com>
Subject: Re: xen-netback stable backports request (regression fixes)
Date: Wed, 5 Jun 2013 21:52:59 +0100
Message-ID: <1370465579.6652.14.camel@hastur.hellion.org.uk>
References: <1369734465.3469.52.camel@zakaz.uk.xensource.com>
	 <20130605045532.GA10475@kroah.com>
	 <1370422590.24512.135.camel@zakaz.uk.xensource.com>
	 <20130605202502.GD13713@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <stable@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	xen-devel <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>
To: Greg KH <greg@kroah.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20130605202502.GD13713@kroah.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-06-05 at 13:25 -0700, Greg KH wrote: 
> > For the first we thought that allocating a variable size array on the
> > stack was bad practice which could lead to a stack overflow. The default
> > is safe but can be overridden by a module parameter.
> > 
> > The other renames the module parameter which we thought was useful for
> > consistency between newer kernels and the stable branches.
> 
> So you are doing a user/kernel api change in a stable branch?  Heck, you
> did it in 3.10?  Why?  What did you just break by doing that?  I can't
> do that to users of the stable kernels, sorry, and you shouldn't be
> doing that to users of the 3.10 kernel either.  You should rename this
> back so people's working systems don't break when they upgrade their
> kernel.

The module parameter was introduce after 3.9 and then renamed before
v3.10-rc1 happened, the original name was never part of an -rc let alone
an actual release.

I hadn't considered the consequences of the introduction and renaming
getting backported to stable in separate stable releases, sorry.

I think in practise it is highly unlikely that anyone is using this
option but equally I'd rather change the name before people do to start
to use it.

If this is a problem for stable perhaps a patch to make it accept either
name would be useful? Seems to me like that is just deferring things a
bit further though.

> No worries, I've applied just the 9ecd1a75 patch.

Thanks,

Ian.
