From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] remove superfluous diverter printk'ing
Date: 16 Jan 2005 12:10:21 -0500
Message-ID: <1105895420.1090.708.camel@jzny.localdomain>
References: <20050114124700.GA4079@xi.wantstofly.org>
	 <20050114134642.4be4e2fc.davem@davemloft.net>
	 <20050115104750.GB14991@xi.wantstofly.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050115104750.GB14991@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Diverter could simply be killed now that tc actions exist if theres no
maintainer or user.
Should be able to divert any packet of choce to any interface.

cheers,
jamal


On Sat, 2005-01-15 at 05:47, Lennert Buytenhek wrote:
> On Fri, Jan 14, 2005 at 01:46:42PM -0800, David S. Miller wrote:
> 
> > > You're not listed as diverter maintainer but I'm sending this via
> > > you anyway.  This patch removes some printk'ing from the diverter
> > > driver (and cleans up the code a bit), because after a while it gets
> > > really annoying to have log messages like this one for every single
> > > tunnel you create or tear down.
> > > 
> > > 	divert: not allocating divert_blk for non-ethernet device tunl0
> > > 
> > > Please consider sending upstream.
> > 
> > Those diverter messages drive me crazy too, I think I'll
> > add your patch Lennert.
> 
> Benoit's email address bounces, and it's the latest address of his I
> could find, so if he doesn't read this list you might as well go ahead.
> 
> 
> cheers,
> Lennert
> 
> 
