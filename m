From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: Assertions when lowering tcp_tso_win_divisor
Date: Sat, 20 Nov 2004 15:19:54 -0800 (PST)
Message-ID: <Pine.LNX.4.58.0411201503510.6242@w-sridhar.beaverton.ibm.com>
References: <Pine.LNX.4.58.0411160931080.31882@w-sridhar.beaverton.ibm.com>
 <E1CUAQ2-0002jT-00@gondolin.me.apana.org.au> <20041116163106.3b62a39a.davem@davemloft.net>
 <Pine.LNX.4.58.0411191755160.2567@w-sridhar.beaverton.ibm.com>
 <20041119223527.1f243d6e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041119223527.1f243d6e.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 19 Nov 2004, David S. Miller wrote:

> On Fri, 19 Nov 2004 18:00:21 -0800 (PST)
> Sridhar Samudrala <sri@us.ibm.com> wrote:
>
> > Unfortunately as we cannot upgrade to 2.6.10-rc2
>
> This doesn't work.  You cannot expect upstream maintainers
> to work with you if you're not willing to or able to
> try things out with the latest kernels.
>
> I have an inkling as to the reason why you're restricted
> in this way, which is that you're limited to some vendor's
> kernel.  Am I right?

Yes. You are right. It is a vendor kernel based on 2.6.9 along
with some vendor specific kernel patches.
I agree that it is not always possible to support older kernels
and i was not expecting you to do that.
I tried to do this myself by identifying the tso related patches
that went in after 2.6.9 and just wanted to find out if i missed
any other patches that may have fixed the tso related assertions.

We will try to see if this problem can be reproduced with
2.6.10-rc2.

Thanks
Sridhar
