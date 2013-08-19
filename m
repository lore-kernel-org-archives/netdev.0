From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: NAT stops forwarding ACKs after PMTU discovery
Date: Mon, 19 Aug 2013 22:13:59 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1308192207130.27869@blackhole.kfki.hu>
References: <521061B4.1030508@fatooh.org>  <1376839467.21329.36.camel@edumazet-glaptop>  <alpine.DEB.2.00.1308182314050.25515@blackhole.kfki.hu>  <1376870425.4226.25.camel@edumazet-glaptop>  <1376870592.4226.27.camel@edumazet-glaptop> <5211DAA6.1070302@fatooh.org>
  <20130819123314.GC3583@cpaasch-mac>  <1376918657.4226.59.camel@edumazet-glaptop>  <20130819134919.GF3583@cpaasch-mac> <1376920685.4226.61.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Christoph Paasch <christoph.paasch@uclouvain.be>,
	Corey Hickey <bugfood-ml@fatooh.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1376920685.4226.61.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 19 Aug 2013, Eric Dumazet wrote:

> On Mon, 2013-08-19 at 15:49 +0200, Christoph Paasch wrote:
>
> > It's a TCP-patch, that interprets duplicate-acks with invalid SACK-blocks as
> > duplicate acks in tcp_sock->sacked_out.
> 
> Yeah, but here, this is conntrack who is blocking the thing.
> 
> TCP receiver has no chance to 'fix' it.
> 
> See conntrack is one of those buggy middle box as well.
> 
> So if you want to properly handle this mess, you'll also have to fix
> conntrack.

I beg you pardon: why conntrack should be relaxed, when it is expected
to do more strict TCP checkings (RFC5961, Section 5.).

Also, it's clearly a broken middle box. Don't shoot the messenger.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
