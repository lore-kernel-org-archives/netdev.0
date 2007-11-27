From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Wed, 28 Nov 2007 00:06:45 +0100
Message-ID: <20071127230645.GB31491@one.firstfloor.org>
References: <20071122343.446909000@suse.de> <200711261228.15155.rusty@rustcorp.com.au> <adahcj9sfan.fsf@cisco.com> <200711271549.37670.rusty@rustcorp.com.au> <1196202698.3415.119.camel@jcmlaptop> <20071127223743.GI24223@one.firstfloor.org> <20071127150022.61bdff7e@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Jon Masters <jonathan@jonmasters.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Roland Dreier <rdreier@cisco.com>, Andi Kleen <ak@suse.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760564AbXK0XHB@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071127150022.61bdff7e@freepuppy.rosehill>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 27, 2007 at 03:00:22PM -0800, Stephen Hemminger wrote:
> On Tue, 27 Nov 2007 23:37:43 +0100
> Andi Kleen <andi@firstfloor.org> wrote:
> 
> > > With my "Enterprise" hat on, I can see where Andi was coming from
> > > originally. 
> > 
> > For the record my original motivation was to fix the "TCP exports everything
> > for ipv6.ko" case cleanly. I later realized that it would be useful for the
> > ABI stability issues too, but it was really not my primary motivation.
> > This is why I didn't even mention that in the original patch description.
> 
> Since ipv6 can never be removed because it references itself, the whole concept

AFAIK that is obsolete anyways. It was done because it was feared it would
be broken, but at least the broken cases I knew about were all fixed
a long time ago. Most likely it could be safely removed.

> of a modular ipv6 is flawed. 

Modules that cannot be unloaded are still useful. Standard case: Distributions
like to offer an option to not use ipv6 because that is popular workaround
for the common "DNS server eats AAAA queries and causes delays" issue.
Forcing the user to rebuild the kernel for this wouldn't be practical.
If ipv6 wasn't modular that would be hard to do.

-Andi
