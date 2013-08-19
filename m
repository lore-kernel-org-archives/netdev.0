From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: NAT stops forwarding ACKs after PMTU discovery
Date: Mon, 19 Aug 2013 19:15:19 +0200
Message-ID: <20130819171519.GA4008@cpaasch-mac>
References: <1376870425.4226.25.camel@edumazet-glaptop>
 <1376870592.4226.27.camel@edumazet-glaptop>
 <5211DAA6.1070302@fatooh.org>
 <20130819123314.GC3583@cpaasch-mac>
 <1376918657.4226.59.camel@edumazet-glaptop>
 <20130819134919.GF3583@cpaasch-mac>
 <1376920685.4226.61.camel@edumazet-glaptop>
 <20130819143509.GA31320@linuxace.com>
 <20130819153328.GH3583@cpaasch-mac>
 <1376928031.4226.66.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Phil Oester <kernel@linuxace.com>,
	Corey Hickey <bugfood-ml@fatooh.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1376928031.4226.66.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19/08/13 - 09:00:31, Eric Dumazet wrote:
> On Mon, 2013-08-19 at 17:33 +0200, Christoph Paasch wrote:
> > Unfortunately, they will hardly go away in the near futur. Rather the
> > opposite is the case.
> > 
> > 
> > If you have a public server running, I would be interested in the count of
> > invalid SACK-blocks received (netstat -s | grep TCPSACKDiscard). This is an
> > indication for such kind of middlebox between your server and the client,
> > implying that these connections cannot benefit from TCP-FastRetransmission
> > and each packet-loss will require an RTO to recover.
> > 
> 
> If the (random) sequence offset is small rather than completely out of
> window, it's going to be hard to detect all problems.

Yes, it is not possible to make it 100% perfect. But considering the size of
the seq-space, the probability is rather low that the SACK-block falls
in-window.

> Show us your patch ;)

Will send it soon. Have to rebase on net-next,... :)
(it's several months ago that I did this)


Christoph
