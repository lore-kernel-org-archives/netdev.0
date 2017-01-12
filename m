From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2 8/8] crypto/testmgr: Allocate only the required output
 size for hash tests
Date: Fri, 13 Jan 2017 00:44:11 +0800
Message-ID: <20170112164411.GA20313@gondor.apana.org.au>
References: <cover.1484090585.git.luto@kernel.org>
 <890f4bdb28a1cf72f6b802b220b35ebaf0f76bb9.1484090585.git.luto@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Ard Biesheuvel <ard.biesheuvel@linaro.org>
To: Andy Lutomirski <luto@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:43429 "EHLO
        helcar.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750818AbdALQog (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 11:44:36 -0500
Content-Disposition: inline
In-Reply-To: <890f4bdb28a1cf72f6b802b220b35ebaf0f76bb9.1484090585.git.luto@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 10, 2017 at 03:24:46PM -0800, Andy Lutomirski wrote:
> There are some hashes (e.g. sha224) that have some internal trickery
> to make sure that only the correct number of output bytes are
> generated.  If something goes wrong, they could potentially overrun
> the output buffer.
> 
> Make the test more robust by allocating only enough space for the
> correct output size so that memory debugging will catch the error if
> the output is overrun.
> 
> Tested by intentionally breaking sha224 to output all 256
> internally-generated bits while running on KASAN.
> 
> Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: Andy Lutomirski <luto@kernel.org>

Patch applied.  Thanks.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
