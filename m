From: bert hubert <ahu@ds9a.nl>
Subject: Re: off by one error in 3des cbc keying
Date: Tue, 12 Nov 2002 16:16:38 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021112151638.GA18488@outpost.ds9a.nl>
References: <20021111200321.GA30957@outpost.ds9a.nl> <200211121355.QAA00322@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200211121355.QAA00322@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Nov 12, 2002 at 04:55:57PM +0300, kuznet@ms2.inr.ac.ru wrote:

> 1. udp.c: silly bug, local input policy did not work on udp sockets.
> 2. ah.c,esp.c: even sillier bug: 0 was used as  tunnels protocol. Funny enough,
>    it worked between linuxes. :-) By <gem@asplinux.ru>

Thanks, will test tonight. Very very sadly, user mode linux does not compile
for me in 2.5.47 and furthermore does not appear to be aware of the crypto
subsystem.

I added this patch to the larc IPSEC pages.

> The problem with expiration remains unsolved. I still cannot reproduce this
> and cannot find a situation when kernel can create two larvals with one
> identity. :-( Searching.

Sure you saw that? I only saw the one larval in the output I sent you, with
everything set to zero. But perhaps I'm missing something. I'll have all my
computers together again tonight.

Regards,

bert

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
