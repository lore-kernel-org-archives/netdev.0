From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [XFRM] Make XFRM core subsystem af-independent
Date: Fri, 17 Sep 2004 23:11:27 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040917.231127.114842301.yoshfuji@linux-ipv6.org>
References: <20040917.205038.61628907.yoshfuji@linux-ipv6.org>
	<E1C8I2m-0005BS-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <E1C8I2m-0005BS-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <E1C8I2m-0005BS-00@gondolin.me.apana.org.au> (at Fri, 17 Sep 2004 22:40:52 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> Please provide ip_route_output_key() as an inline wrapper around
> ip_route_output_flow() so that its users don't have to change.

No.  Because I've succesfully changed all users (AFAIK),
there's no need to keep it.
And, I believe the name "ip_route_output_key()" itself was the bug.

--yoshfuji
