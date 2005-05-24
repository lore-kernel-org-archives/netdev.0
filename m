From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Super TSO v3
Date: Tue, 24 May 2005 10:32:08 +1000
Message-ID: <20050524003208.GA25778@gondor.apana.org.au>
References: <20050523.121943.78708600.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050523.121943.78708600.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, May 23, 2005 at 07:19:43PM +0000, David S. Miller wrote:
> 
> The guts of the logic is in tcp_tso_should_defer().  And
> when dealing with a TSO frame, tcp_write_xmit() calls
> this instead of tcp_nagle_test().  So you can view this
> deferral as a sort of "TSO Nagle".

Should we skip this step if the socket has Nagle turned off?

Also why are we doing this check in tcp_push_one? The only
way we can get there is if the TSO goal has been reached
or there is out-of-band stuff to send.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
