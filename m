From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPv6] Add option to copy DSCP in decap in ip6_tunnel
Date: Mon, 13 Sep 2004 13:21:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040913132105.02730b01.davem@davemloft.net>
References: <20040913111943.GA26179@gondor.apana.org.au>
	<20040913.205504.46820949.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040913.205504.46820949.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 13 Sep 2004 20:55:04 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> In article <20040913111943.GA26179@gondor.apana.org.au> (at Mon, 13 Sep 2004 21:19:43 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:
> 
> > Here is a patch that allows the copying of the DSCP during decapsulation
> > for ip6_tunnel.  I've made it a separate option from the one that
> > determines the copying during encapsulation since the DSCP processing
> > may be asymmetric.  It also means that we preserve compatibility should
> > anyone be relying on the current behaviour.
> 
> I agree.

Me too, patch applied.  Thanks Herbert.
