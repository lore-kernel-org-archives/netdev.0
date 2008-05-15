From: Jamie Lokier <jamie@shareable.org>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover, performance.
Date: Thu, 15 May 2008 02:10:09 +0100
Message-ID: <20080515011009.GA28687@shareable.org>
References: <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net> <20080514135156.GA23131@2ka.mipt.ru> <20080514143105.GB14987@shareable.org> <20080514150052.GA15826@2ka.mipt.ru> <20080514213251.GB23758@shareable.org> <20080514220252.GA14378@2ka.mipt.ru> <20080514222837.GF23758@shareable.org> <20080514224519.GA3739@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sage Weil <sage@newdream.net>, Jeff Garzik <jeff@garzik.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080514224519.GA3739@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> > It's possible that implementing server cloud protocol _and_ simple
> > client protocol may be more work than just server cloud protocol.  I'm
> > not sure.  Thoughts welcome.
> 
> Well, getting that client protocol is mostly ready, and its design
> allows infinite (blah!) extensions and extremely (blah!) flexible
> processing, we are close to just difficult server one :)

That's what I thought when I had my system working fine with just one
server.  The client was very simple. :-)

Since, I learned that my clients need to have parts of the complex
server protocol for fast, safe transactions (think ACID (or ACI)) over
relatively slow links, especially with multiple servers.

Also, efficiently recovering from a link/server failure, when clients
have large zero-latency caches (using leases), appears similar to the
synchronising protocol between recovering servers.

But, on the bright side, these things are only necessary for
performance in scenarios you might not encounter or care about :-)

I'm finding it's a really interesting but large problem.

-- Jamie
