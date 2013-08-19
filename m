From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NAT stops forwarding ACKs after PMTU discovery
Date: Mon, 19 Aug 2013 06:58:05 -0700
Message-ID: <1376920685.4226.61.camel@edumazet-glaptop>
References: <521061B4.1030508@fatooh.org>
	 <1376839467.21329.36.camel@edumazet-glaptop>
	 <alpine.DEB.2.00.1308182314050.25515@blackhole.kfki.hu>
	 <1376870425.4226.25.camel@edumazet-glaptop>
	 <1376870592.4226.27.camel@edumazet-glaptop> <5211DAA6.1070302@fatooh.org>
	 <20130819123314.GC3583@cpaasch-mac>
	 <1376918657.4226.59.camel@edumazet-glaptop>
	 <20130819134919.GF3583@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Corey Hickey <bugfood-ml@fatooh.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130819134919.GF3583@cpaasch-mac>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-08-19 at 15:49 +0200, Christoph Paasch wrote:

> 
> It's a TCP-patch, that interprets duplicate-acks with invalid SACK-blocks as
> duplicate acks in tcp_sock->sacked_out.

Yeah, but here, this is conntrack who is blocking the thing.

TCP receiver has no chance to 'fix' it.

See conntrack is one of those buggy middle box as well.

So if you want to properly handle this mess, you'll also have to fix
conntrack.



