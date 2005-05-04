From: Glen Turner <glen.turner@aarnet.edu.au>
Subject: Re: icmp_unreachable uses wrong ip
Date: Wed, 04 May 2005 10:45:45 +0930
Message-ID: <42782241.6080909@aarnet.edu.au>
References: <1115040079.5620.11.camel@jeroens.office.netland.nl> <20050503092244.GA8864@xi.wantstofly.org> <Pine.LNX.4.61.0505031239460.3205@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.61.0505031239460.3205@netcore.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pekka Savola wrote:
> 
> 
> There's no specification requiring or recommending either of these 
> approaches, either for v6 or v4 AFAICS so you can't depend on that 
> behaviour..

In the lack of a specification, doing what works best for
network operators would be nice :-)

And that behaviour is that addresses in a traceroute should
be ping-able.  That is, you're tracing the route and there's
loss at one point, so you want to determine how much loss.

The outgoing interface's address may not be reached down the
same path as used by the traceroute, whereis the incoming address
obviously is (or if it isn't, then that itself is interesting
diagnostic information).

Similarly, using the incoming interface gives more information
about asymetric routes.

In short, since using the incoming address gives more useful
output and the specification is silent as to which address
is allowable, using the incoming interface's address would
be the most useful choice.

Cheers,
Glen

-- 
  Glen Turner         Tel: (08) 8303 3936 or +61 8 8303 3936
  Australia's Academic & Research Network  www.aarnet.edu.au
