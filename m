From: Andi Kleen <ak@muc.de>
Subject: Re: [PATCH] Increase snd/rcv buffers in pppoe
Date: 26 Feb 2004 20:49:00 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040226194900.GA8230@colin2.muc.de>
References: <20040223105359.GA91938@colin2.muc.de> <20040223.200101.39143636.yoshfuji@linux-ipv6.org> <20040223111659.GB10681@colin2.muc.de> <20040223.203843.04073965.yoshfuji@linux-ipv6.org> <20040223102613.33838132.davem@redhat.com> <20040225211526.74478066.ak@suse.de> <20040223133233.71eecc99.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, yoshfuji@linux-ipv6.org, ak@muc.de,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Date: Thu, 26 Feb 2004 20:49:00 +0100
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040223133233.71eecc99.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Sorry for the late answer.

On Mon, Feb 23, 2004 at 01:32:33PM -0800, David S. Miller wrote:
> > > 2) IPV6 icmp does the same as ipv4, except this value is even more wrong there
> > >    especially considering jumbograms.  With current code, sending a jumbogram
> > >    ipv6 icmp packet would simply fail, and I wonder if anyone has even tried
> > >    this.
> > 
> > Isn't even ICMPv6 limited to the minimum guaranteed MTU (1000 something) like ICMPv4 is to
> > 576 bytes?
> 
> What about ECHO?  I can't send an ICMPv6 jumbo sized ECHO and expect a fully quoted response
> back?

I don't think it should be only sized for big datagrams and other obscure cases.
Better is a reasonable default to fit at least 64K of data with a standard MTU like ~1.4K. 
Or may resize it on MTU change, but I'm not sure that's worth the effort. 

Are you working on this or should I prepare a new patch? 

-Andi
