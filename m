From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [net-2.6.13 0/3] [IPSEC] Allow PMTU discovery to be turned off
Date: Mon, 20 Jun 2005 13:24:01 -0700 (PDT)
Message-ID: <20050620.132401.21595297.davem@davemloft.net>
References: <20050613073353.GA21454@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, kaber@trash.net, yoshfuji@linux-ipv6.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050613073353.GA21454@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 13 Jun 2005 17:33:53 +1000

> One of the problems that's been plaguing our IPsec stack is ICMP
> blackholes.  ICMP blackholes are particularly bad for tunnels because
> the most common remediy -- MSS clamping has no effect when applied
> outside the tunnel.  It is often impractical to apply it inside
> the tunnel since the point where the clamping is applied may be some
> way away from either IPsec endpoint.
> 
> The best solution so far has been to disable PMTU discovery when a
> blackhole is detected.  We already support that for IPIP/GRE tunnels.
> The following patchset adds support for a similar strategy to IPsec
> tunnels.
> 
> It is by no means ideal but it's something that you need to survive
> on today's Internet.

All 3 patches applied, thanks Herbert.

One thing needs clarification in your description.  When I first
read "blackhole is detected" I was under the wrong impression as
to _who_ does the detection.  Your patches allow the administrator
to do this, whereas I thought you were going to add some code which
dynamically figured out the presence of ICMP black holes and would
thus set the bit.
