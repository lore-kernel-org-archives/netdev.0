From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [DEBUG]: sk_forward_alloc assertion failures
Date: Fri, 14 Jan 2005 12:37:37 +1100
Message-ID: <20050114013737.GB11619@gondor.apana.org.au>
References: <20050113171234.3fde0925.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050113171234.3fde0925.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jan 13, 2005 at 05:12:34PM -0800, David S. Miller wrote:
> 
> [ BTW, Herbert, it just occurred to me that these adjustments
>   are incorrect for the skb->data pulling case since we really
>   aren't liberating the data. ]

Yes but I thought the idea was to fake it so the application
can transmit more packets? Without TSO, the data would've been
freed at this point.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
