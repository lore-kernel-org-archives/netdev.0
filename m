From: "David S. Miller" <davem@redhat.com>
Subject: Re: sungem - ifconfig eth0 mtu 1300 -> oops
Date: Mon, 21 Jun 2004 14:11:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040621141144.119be627.davem@redhat.com>
References: <1087568322.4455.22.camel@localhost>
	<E1BcNzi-0000eh-00@gondolin.me.apana.org.au>
	<20040621130316.GA2661@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kernel@nn7.de, linux-kernel@vger.kernel.org, benh@kernel.crashing.org,
        netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040621130316.GA2661@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 21 Jun 2004 23:03:16 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Mon, Jun 21, 2004 at 10:33:50PM +1000, Herbert Xu wrote:
> > 
> > Does this patch fix your problems?
> 
> Oops, I had a thinko about min vs. max.  I've also decided to make the
> bigger MTU useful by adjusting the arguments to skb_put() as well.
> Please try this one instead.

Applied, thanks Herbert.
