From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC] MASQUERADE / policy routing ("Route send us somewhere
 else")
Date: Tue, 31 Aug 2004 12:41:35 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0408311208500.1773-100000@l>
References: <20040831082339.GA949@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, <laforge@netfilter.org>,
        <netfilter-devel@lists.netfilter.org>, <rusty@rustcorp.com.au>,
        <netdev@oss.sgi.com>, <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040831082339.GA949@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Tue, 31 Aug 2004, Herbert Xu wrote:

> On Tue, Aug 31, 2004 at 05:00:43PM +1000, herbert wrote:
> >
> > Here's a better idea.  Why don't we forget about the route lookup
> > and call inet_select_addr directly?
>
> Even better, why don't we use the skb->dst directly? It already
> contains the preferred source for the route that led us to the
> device.
>
> Here is an untested patch which does exactly that? Please do your
> best to break it :)

	No need for tests :) rt_spec_dst is your preferred src
to the sender (your local internal IP) and rt_src is the internal
IP of the sender (what we snat).

Regards

--
Julian Anastasov <ja@ssi.bg>
