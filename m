From: =?ISO-8859-1?Q?Einar_L=FCck?= <lkml@einar-lueck.de>
Subject: Re: [PATCH 2/2] ipv4 routing: multipath with cache support, 2.6.10-rc3
Date: Wed, 09 Feb 2005 21:23:57 +0100
Message-ID: <420A715D.7050106@einar-lueck.de>
References: <41C6B54F.2020604@einar-lueck.de>	<20050202172333.4d0ad5f0.davem@davemloft.net>	<420A1011.1030602@einar-lueck.de> <20050209120157.18dc75c1.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: linux-kernel@vger.kernel.org
In-Reply-To: <20050209120157.18dc75c1.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

> So essentially you want per-flow multipathing.  Except that you're implementation
> is over-optimizing it to the point where it's only per-flow for your specific
> case where the connections are short lived and high rate.
>
> This hurts long lasting connections.
>
> So I'm pretty much against this change.  Do it right by making it occur
> per-connection attempt, it's not my problem to figure out how to do that
> efficiently, it's your's :-)


We do not want per-flow multipathing. We want per connection multipathing with fast route lookups (that's why we have all routes in the cache). That is exactly what we implemented. Our tests prove that a connection keeps its route as long as it lives (the dstentry remains associated with the socket). That's why I do not really
understand why our approach hurts long lasting connections in any way. Can you explain your point more precisely?

Regards,
Einar.
