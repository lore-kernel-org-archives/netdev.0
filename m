From: Andi Kleen <ak@muc.de>
Subject: Re: [PATCH] Increase snd/rcv buffers in pppoe
Date: 26 Feb 2004 21:52:20 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040226205220.GA29457@colin2.muc.de>
References: <20040223105359.GA91938@colin2.muc.de> <20040223.200101.39143636.yoshfuji@linux-ipv6.org> <20040223111659.GB10681@colin2.muc.de> <20040223.203843.04073965.yoshfuji@linux-ipv6.org> <20040223102613.33838132.davem@redhat.com> <20040225211526.74478066.ak@suse.de> <20040223133233.71eecc99.davem@redhat.com> <20040226194900.GA8230@colin2.muc.de> <20040226124245.5b3c77bf.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@muc.de>, ak@suse.de, yoshfuji@linux-ipv6.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Date: Thu, 26 Feb 2004 21:52:20 +0100
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040226124245.5b3c77bf.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Feb 26, 2004 at 12:42:45PM -0800, David S. Miller wrote:
> On 26 Feb 2004 20:49:00 +0100
> Andi Kleen <ak@muc.de> wrote:
> 
> > I don't think it should be only sized for big datagrams and other obscure cases.
> > Better is a reasonable default to fit at least 64K of data with a standard MTU like ~1.4K. 
> > Or may resize it on MTU change, but I'm not sure that's worth the effort. 
> > 
> > Are you working on this or should I prepare a new patch? 
> 
> Let's just leave things how we've changed them, and when people complain
> about jumbo MTU ipv6 icmp messages we'll address it.

Ah, I missed that you already checked it in.  Sorry for the noise.

I will test now if your change really fixes the DSL performance problem.

-Andi
