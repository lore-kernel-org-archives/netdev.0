From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH net-next] net: netdev_alloc_skb() use build_skb()
Date: Mon, 4 Jun 2012 14:44:55 +0200
Message-ID: <20120604124455.GA26420@1wt.eu>
References: <20120517121800.GA18052@1wt.eu> <20120517150157.GA19274@1wt.eu> <1337269380.3403.10.camel@edumazet-glaptop> <20120517155621.GK14498@1wt.eu> <1337272404.3403.18.camel@edumazet-glaptop> <20120517164016.GL14498@1wt.eu> <1337273387.3403.24.camel@edumazet-glaptop> <1337276056.3403.37.camel@edumazet-glaptop> <20120517174551.GN14498@1wt.eu> <20120604123912.GB28992@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:3095 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753531Ab2FDMpF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2012 08:45:05 -0400
Content-Disposition: inline
In-Reply-To: <20120604123912.GB28992@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 04, 2012 at 03:39:12PM +0300, Michael S. Tsirkin wrote:
> On Thu, May 17, 2012 at 07:45:51PM +0200, Willy Tarreau wrote:
> > Impressed !
> > 
> > For the first time I could proxy HTTP traffic at gigabit speed on this
> > little box powered by USB ! I've long believed that proper splicing
> > would make this possible and now I'm seeing it is. Congrats Eric !
> 
> which userspace do you use?

It's haproxy-1.5-dev with splicing enabled.

> anything I can try?

Yes, feel free to download -dev11, build it for kernels >= 2.6.28 and
make a small config to relay TCP/HTTP to another host. of course you
need gigabit-capable client and server.

Willy
