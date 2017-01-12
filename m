From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2 8/8] crypto/testmgr: Allocate only the required output
 size for hash tests
Date: Thu, 12 Jan 2017 15:47:52 +0800
Message-ID: <20170112074752.GA14230@gondor.apana.org.au>
References: <890f4bdb28a1cf72f6b802b220b35ebaf0f76bb9.1484090585.git.luto@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@iogearbox.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-crypto@vger.kernel.org,
        Jason@zx2c4.com, hannes@stressinduktion.org,
        alexei.starovoitov@gmail.com, edumazet@google.com,
        ebiggers3@gmail.com, tom@herbertland.com, davem@davemloft.net,
        luto@kernel.org, ard.biesheuvel@linaro.org
To: Andy Lutomirski <luto@kernel.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <890f4bdb28a1cf72f6b802b220b35ebaf0f76bb9.1484090585.git.luto@kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Lutomirski <luto@kernel.org> wrote:
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

This patch doesn't seem to depend on anything else in the series.
Do you want me to take it separately?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
