From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: tunneling in linux (was: Re: [PATCH][RFC] etherip: Ethernet-in-IPv4 tunneling)
Date: Sun, 16 Jan 2005 20:57:50 +0100
Message-ID: <20050116195750.GB22165@xi.wantstofly.org>
References: <20050112222437.GC14280@xi.wantstofly.org> <Pine.LNX.4.61.0501130944270.19573@netcore.fi> <20050113092351.GA23170@xi.wantstofly.org> <1105897020.1091.736.camel@jzny.localdomain> <20050116185553.GA21739@xi.wantstofly.org> <Pine.LNX.4.61.0501162140460.10874@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0501162140460.10874@netcore.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jan 16, 2005 at 09:51:41PM +0200, Pekka Savola wrote:

> >If we do end up using GRE for ethernet tunneling, there's some work that
> >needs to be done.  For one, ip_gre in its current form would need a certain
> >amount of hacking for tunneling ethernet frames instead of IPv4/IPv6 as
> >it does now.  We might as rename it to plain 'gre' and move it out of
> >net/ipv4/ to net/core/ or something while we're at it.
> 
> Now that I think about this a bit more, there may be a potential 
> issue..
> 
> If the payload of GRE is an ethernet frame, which GRE 'Protocol Type' 
> (i.e., ethertype) would that be?

I assumed that "Transparent Ethernet Bridging" would be used for that.

>From ethernet-numbers:

	Ethernet          Exp. Ethernet    Description          References
	-------------     -------------   -----------           ----------
	decimal  Hex      decimal  octal
	[snip]
	 25944   6558        -      -     Trans Ethen Bridging   [RFC1701]

RFC1701 is the original GRE RFC, which mentions:

   The following are currently assigned protocol types for GRE.  Future
   protocol types must be taken from DIX ethernet encoding.  For
   historical reasons, a number of other values have been used for some
   protocols.  The following table of values MUST be used to identify
   the following protocols:

       Protocol Family                     PTYPE
       ---------------                     -----
	[snip]
       Transparent Ethernet Bridging       6558


--L
