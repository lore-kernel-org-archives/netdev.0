From: =?ISO-8859-1?Q?Einar_L=FCck?= <lkml@einar-lueck.de>
Subject: Re: [PATCH 2/2] ipv4 routing: multipath with cache support, 2.6.10-rc3
Date: Wed, 09 Feb 2005 14:28:49 +0100
Message-ID: <420A1011.1030602@einar-lueck.de>
References: <41C6B54F.2020604@einar-lueck.de> <20050202172333.4d0ad5f0.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050202172333.4d0ad5f0.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> Can you describe more precisely "the scenerios, that are relevant
> to us"?

The scenarios we have in mind are setups in which a set of collaborating 
servers steadly establish connections among each other with a very high rate. 
This high rate requirement drove us to consider the inclusion of all 
alternative routes into the routing cache because the corresponding delay 
for each connection establishment is low and the load is balanced over all
available routes. That's why we did not consider a slow lookup in the fib 
for each connection established.

Regards,
Einar.
