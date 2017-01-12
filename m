From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next 1/4] siphash: add cryptographically secure PRF
Date: Thu, 12 Jan 2017 23:04:17 +0800
Message-ID: <20170112150417.GA15951@gondor.apana.org.au>
References: <20170107040459.GA575@zzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason@zx2c4.com, davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, jeanphilippe.aumasson@gmail.com,
        torvalds@linux-foundation.org, David.Laight@aculab.com,
        eric.dumazet@gmail.com
To: Eric Biggers <ebiggers3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:59005 "EHLO
        helcar.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751318AbdALPa1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 10:30:27 -0500
Content-Disposition: inline
In-Reply-To: <20170107040459.GA575@zzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Biggers <ebiggers3@gmail.com> wrote:
> Hi Jason, just a few comments:
> 
> On Fri, Jan 06, 2017 at 09:10:52PM +0100, Jason A. Donenfeld wrote:
>> +#define SIPHASH_ALIGNMENT __alignof__(u64)
>> +typedef u64 siphash_key_t[2];
> 
> I was confused by all the functions passing siphash_key_t "by value" until I saw
> that it's actually typedefed to u64[2].  Have you considered making it a struct
> instead, something like this?
> 
> typedef struct {
>        u64 v[2];
> } siphash_key_t;

If it's just an 128-bit value then we have u128 in crypto/b128ops.h
that could be generalised for this.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
