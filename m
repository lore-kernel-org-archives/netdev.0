From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6]: Make packet scheduler clock source configurable
Date: Fri, 23 Jul 2004 13:54:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040723135459.2ee5c42c.davem@redhat.com>
References: <40F34740.5040100@trash.net>
	<1107.63.170.215.71.1089689716.squirrel@www.osdl.org>
	<20040712205037.573411c0.davem@redhat.com>
	<40F4862D.3070802@trash.net>
	<40F4AC8B.40706@trash.net>
	<20040721143110.4ab944bf.davem@redhat.com>
	<41004F76.1080807@trash.net>
	<20040722171752.341d2476.davem@redhat.com>
	<41006150.9000702@trash.net>
	<41014788.4070301@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com, devik@cdi.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41014788.4070301@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 23 Jul 2004 19:14:48 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Patrick McHardy wrote:
> > I'm pretty sure x86, x86_64, alpha, sparc64, ppc64 and ia64 can
> > be used. I'm not sure if the frequency of all ppcs is high enough,
> > so I won't add support for them.
> 
> This is the patch for configurable clock source. I've double-checked
> the arches, I think all mentioned above work fine. I've taken some text
> from Stephen's patch for the help text .. thanks ;)

We can't use this stuff on Alpha, it's cycle counter overflows after
just 10 minutes.  It works very strangely, something like only the
lower 32-bits are guarenteed to be continually incrementing.

I'm going to apply your patch and delete the Alpha parts.
Meanwhile, ping Richard Henderson (rth@redhat.com) or one
of the other Alpha experts for me to get confirmation on
this stuff.

Thanks.
