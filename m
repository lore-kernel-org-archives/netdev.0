From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [DEBUG]: sk_forward_alloc assertion failures
Date: Thu, 13 Jan 2005 20:09:47 -0800
Message-ID: <20050113200947.09e53b01.davem@davemloft.net>
References: <20050113171234.3fde0925.davem@davemloft.net>
	<20050114013737.GB11619@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050114013737.GB11619@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 14 Jan 2005 12:37:37 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Thu, Jan 13, 2005 at 05:12:34PM -0800, David S. Miller wrote:
> > 
> > [ BTW, Herbert, it just occurred to me that these adjustments
> >   are incorrect for the skb->data pulling case since we really
> >   aren't liberating the data. ]
> 
> Yes but I thought the idea was to fake it so the application
> can transmit more packets? Without TSO, the data would've been
> freed at this point.

You're right.  At most we'll pseudo-free no more than 1 full
packet, so it's safe.
