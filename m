From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [IPv6] Add option to copy DSCP in decap in ip6_tunnel
Date: Mon, 13 Sep 2004 20:55:04 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040913.205504.46820949.yoshfuji@linux-ipv6.org>
References: <20040913111943.GA26179@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au, davem@davemloft.net
In-Reply-To: <20040913111943.GA26179@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040913111943.GA26179@gondor.apana.org.au> (at Mon, 13 Sep 2004 21:19:43 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> Here is a patch that allows the copying of the DSCP during decapsulation
> for ip6_tunnel.  I've made it a separate option from the one that
> determines the copying during encapsulation since the DSCP processing
> may be asymmetric.  It also means that we preserve compatibility should
> anyone be relying on the current behaviour.

I agree.

--yoshfuji
