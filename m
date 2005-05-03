From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: icmp_unreachable uses wrong ip
Date: Tue, 3 May 2005 12:38:06 +0200
Message-ID: <20050503103806.GB8864@xi.wantstofly.org>
References: <1115040079.5620.11.camel@jeroens.office.netland.nl> <20050503092244.GA8864@xi.wantstofly.org> <Pine.LNX.4.61.0505031239460.3205@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, "J. Simonetti" <jeroens@office.netland.nl>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0505031239460.3205@netcore.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 03, 2005 at 12:42:01PM +0300, Pekka Savola wrote:

> >(I know, "Every other router vendor out there does it this way."
> >is not a good reason for doing it the same way.)
> 
> There's no specification requiring or recommending either of these 
> approaches, either for v6 or v4 AFAICS so you can't depend on that 
> behaviour..
> 
> Do you have specific data to back up "every other router vendor..." ? 

Sorry, I wasn't claiming that every other router vendor out there
does it that way, just merely trying to state that that would not
be a good argument.

The ones I've worked with in the past do, and I just did some
simple tests (doing traceroute from a foreign IP in a different
network and looking at the ICMP time-exceededs arriving at that
foreign IP) to confirm that:
- Juniper M5 and M20 both running JUNOS 7.0R2.7
- Cisco 7206VXR and 12k(unsure which model) running unknown IOS versions
- Foundry FastIron 3 (the 15-slot chassis) running BIR06636.bin

do all behave opposite of the linux way, i.e. sending ICMPs with (one
of) the source address(es) of the interface where the original packet
(that we're sending an ICMP for) came in.

I did also find one router that behaves the linux way:
- Foundry TurboIron/8 running 07.800A

Any other vendors that we're interested in?


--L
