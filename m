From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: 27 Sep 2004 08:59:05 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096289945.1074.53.camel@jzny.localdomain>
References: <4150E7E5.2000001@eurodev.net>
	 <20040922045239.GA19573@gondor.apana.org.au>
	 <1095854920.1047.64.camel@jzny.localdomain>
	 <20040922105221.59a67d4b.davem@davemloft.net>
	 <4152EE68.4030803@eurodev.net>
	 <20040923121651.51a58cf2.davem@davemloft.net>
	 <20040924032830.GC6384@gondor.apana.org.au>
	 <20040923223909.6f4da27f.davem@davemloft.net>
	 <20040924062604.GA7393@gondor.apana.org.au>
	 <20040924105855.0e1aecd0.davem@davemloft.net>
	 <20040924220651.GA6096@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, pablo@eurodev.net,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040924220651.GA6096@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-09-24 at 18:06, Herbert Xu wrote:

> I agree completely.  I'm just saying that the current NLM_GOODSIZE
> skb is the perfect scratch-pad so we don't need a new one.  All we
> need to do is to insert a helper call just before netlink_unicast
> to copy and trim the packet in the places that need it.

You are probably talking past each other - to me you seem to be saying
the same thing. A "manager" of some form is required.

cheers,
jamal
