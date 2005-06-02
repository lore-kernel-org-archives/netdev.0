From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/4] [NEIGH] neighbour table configuration and
	statistics via rtnetlink
Date: Thu, 02 Jun 2005 09:33:15 -0400
Message-ID: <1117719195.6050.54.camel@localhost.localdomain>
References: <20050527151608.GZ15391@postel.suug.ch>
	 <1117209411.6383.104.camel@localhost.localdomain>
	 <20050527163516.GB15391@postel.suug.ch>
	 <1117244567.6251.34.camel@localhost.localdomain>
	 <20050528120731.GP15391@postel.suug.ch>
	 <1117533847.6134.32.camel@localhost.localdomain>
	 <20050531114251.GC15391@postel.suug.ch>
	 <1117543711.6134.48.camel@localhost.localdomain>
	 <20050531131747.GF15391@postel.suug.ch>
	 <1117551561.6279.2.camel@localhost.localdomain>
	 <20050531161315.GH15391@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050531161315.GH15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-31-05 at 18:13 +0200, Thomas Graf wrote:

[..]
> So what I propose is to have the neighbour table parameters,
> e.g. everything in arp_tbl be distributed over RTM_NEIGHTBL
> and put the device specific parameters into devconfig,
> e.g. in_dev->arp_parms.
> 

Right, this is what i am saying a well.
The only caveat i was pointing out is that the devconfig piece is more
than just the neighbor stuff - and of course it hasnt been written,
yet;->
The major challenge will be events - some change via /proc, sysfs etc
should generate event.
I suggest something along usage of notifier_block with something like
NETDEV_CONFIG to transport these things around. Damn, if only i can find
my patch ....
I had already started doing events based on changes from /proc or sysctl
etc.

> Absolutely, more specific:
> 
> netdevice -> inet_device -> parameter set -> neighbour table
> or:
> neighbour table -> list of parameter sets -> netdevice
> 
> both ways are possible right now.

Sounds good to me.

cheers,
jamal
