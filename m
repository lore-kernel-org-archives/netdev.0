From: Soeren Sonnenburg <kernel@nn7.de>
Subject: Re: sungem - ifconfig eth0 mtu 1300 -> oops
Date: Mon, 21 Jun 2004 22:24:20 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1087849459.4146.3.camel@localhost>
References: <1087568322.4455.22.camel@localhost>
	 <E1BcNzi-0000eh-00@gondolin.me.apana.org.au>
	 <20040621130316.GA2661@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, davem@redhat.com,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>, netdev@oss.sgi.com,
        jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040621130316.GA2661@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-06-21 at 15:03, Herbert Xu wrote:
> On Mon, Jun 21, 2004 at 10:33:50PM +1000, Herbert Xu wrote:
> > 
> > Does this patch fix your problems?
> 
> Oops, I had a thinko about min vs. max.  I've also decided to make the
> bigger MTU useful by adjusting the arguments to skb_put() as well.
> Please try this one instead.
> 
> Cheers,

yes that one works nicely... I tested several mtu's ranging from 1000 to
1500 while the interface was up... no oops.

thanks,
Soeren.
