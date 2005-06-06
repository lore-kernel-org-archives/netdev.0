From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fwd: [Bug 4615] Modem connection stalls out.
Date: Tue, 07 Jun 2005 09:19:53 +1000
Message-ID: <E1DfQsr-0001wK-00@gondolin.me.apana.org.au>
References: <20050606224729.B12034@flint.arm.linux.org.uk>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: rmk@arm.linux.org.uk (Russell King)
In-Reply-To: <20050606224729.B12034@flint.arm.linux.org.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Russell King <rmk@arm.linux.org.uk> wrote:
> 
> The "No buffer space available" looks like the system is running low on
> memory.  Would networking folk concur with that?

It's probably not running low of system memory.  However, it might
be running out of things such as routing cache entries.

Check the dmesg output, it might have a clue on what went wrong.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
