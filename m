From: =?ISO-8859-1?Q?Einar_L=FCck?= <lkml@einar-lueck.de>
Subject: Re: [PATCH 2/2] ipv4 routing: multipath with cache support, 2.6.10-rc3
Date: Wed, 09 Feb 2005 21:42:39 +0100
Message-ID: <420A75BF.1080106@einar-lueck.de>
References: <41C6B54F.2020604@einar-lueck.de>	<20050202172333.4d0ad5f0.davem@davemloft.net>	<420A1011.1030602@einar-lueck.de>	<20050209120157.18dc75c1.davem@davemloft.net>	<420A715D.7050106@einar-lueck.de> <20050209123004.2d65e1cf.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050209123004.2d65e1cf.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> This was brought up before.  It's the case where the system is acting
> as a router, you have to consider that case and not just the one where
> the local system is where the connections are originating from.
> 
> Your trick only works because of how routes are cached per-socket.
> Once you get into the realm of traffic going through the machine as
> a router, the trick stops to work.

We considered the routing case: in the routing case ip_route_input is called. 
In this case we just select the first route in the cache which is always the same 
(we ensure that). Consequently, the routing behaviour is not changed in this case and 
remains in the way you like it. 

Regards,
Einar.
