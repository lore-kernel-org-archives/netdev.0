From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover, performance.
Date: Thu, 15 May 2008 11:34:44 +0400
Message-ID: <20080515073443.GA4082@2ka.mipt.ru>
References: <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net> <20080514135156.GA23131@2ka.mipt.ru> <20080514143105.GB14987@shareable.org> <20080514150052.GA15826@2ka.mipt.ru> <20080514213251.GB23758@shareable.org> <20080514220252.GA14378@2ka.mipt.ru> <20080514222837.GF23758@shareable.org> <20080514224519.GA3739@2ka.mipt.ru> <20080515011009.GA28687@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sage Weil <sage@newdream.net>, Jeff Garzik <jeff@garzik.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Jamie Lokier <jamie@shareable.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080515011009.GA28687@shareable.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 15, 2008 at 02:10:09AM +0100, Jamie Lokier (jamie@shareable.org) wrote:
> Since, I learned that my clients need to have parts of the complex
> server protocol for fast, safe transactions (think ACID (or ACI)) over
> relatively slow links, especially with multiple servers.
> 
> Also, efficiently recovering from a link/server failure, when clients
> have large zero-latency caches (using leases), appears similar to the
> synchronising protocol between recovering servers.

That's a part of the 'simple' client protocol already, there are
transactions, which are only committed completed, when server replies
that they are, there is also failover reconnection and timeout detection
features as long as switching to different servers in case of failure.

Yes, it is a bit more than 'simple' protocol, but I think that's what it
has to have, and hopefuly not more :)

> But, on the bright side, these things are only necessary for
> performance in scenarios you might not encounter or care about :-)
> 
> I'm finding it's a really interesting but large problem.

Yeah, it is far from 'small' problem :)
Really simple protocol was in the first version, and it was also fast,
but yes, it was rather miserable from failure point of view.

-- 
	Evgeniy Polyakov
