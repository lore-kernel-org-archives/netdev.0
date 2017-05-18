From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/7] crypto: aesni: provide generic gcm(aes)
Date: Thu, 18 May 2017 13:28:00 +0800
Message-ID: <20170518052800.GF32485@gondor.apana.org.au>
References: <cover.1493395785.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        "David S. Miller" <davem@davemloft.net>,
        Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@redhat.com>,
        "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
        linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1493395785.git.sd@queasysnail.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 28, 2017 at 06:11:55PM +0200, Sabrina Dubroca wrote:
> The current aesni AES-GCM implementation only offers support for
> rfc4106(gcm(aes)).  This makes some things a little bit simpler
> (handling of associated data and authentication tag), but it means
> that non-IPsec users of gcm(aes) have to rely on
> gcm_base(ctr-aes-aesni,ghash-clmulni), which is much slower.
> 
> This patchset adds handling of all valid authentication tag lengths
> and of any associated data length to the assembly code, and exposes a
> generic gcm(aes) AEAD algorithm to the crypto API.
> 
> With these patches, performance of MACsec on a single core increases
> by 40% (from 4.5Gbps to around 6.3Gbps).

All patches applied.  Thanks.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
