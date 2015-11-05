From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: NETIF_F_GSO_SOFTWARE vs NETIF_F_GSO
Date: Thu, 5 Nov 2015 20:15:01 +0800
Message-ID: <20151105121501.GA5776@gondor.apana.org.au>
References: <CAHmME9rGvViDN2iFa8xfXvUJpQThJnrCcZ1yHgQrdgEQRUWtfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAHmME9rGvViDN2iFa8xfXvUJpQThJnrCcZ1yHgQrdgEQRUWtfg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 04, 2015 at 12:24:47PM +0100, Jason A. Donenfeld wrote:
> 
> Strangely, the performance does not change at all regardless of
> whether or not NETIF_F_GSO is specified.

The NETIF_F_GSO flag turns on software GSO which should be on
anyway.  So that could be why it seems to make no difference.

> However, the performance becomes incredible when I use
> NETIF_F_GSO_SOFTWARE instead of NETIF_F_GSO. But, when using

NETIF_F_GSO_SOFTWARE is actually a collection of bits that lists
the protocols for which we support software GSO.  The bits themselves
are in fact an indication that the hardware supports GSO directly.
So by turning them on you're electing to receive GSO packets
directly.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
