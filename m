From: Alexander Sverdlin <alexander.sverdlin@nokia.com>
Subject: Re: [PATCH 4/4] crypto: api - Extend algorithm name limit to 128
 bytes
Date: Thu, 6 Apr 2017 17:11:28 +0200
Message-ID: <d3f0d05f-a06c-60f2-495e-b455f1e77404@nokia.com>
References: <20170406081509.GB30557@gondor.apana.org.au>
 <E1cw2aR-000868-VF@gondobar>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        <linux-crypto@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <E1cw2aR-000868-VF@gondobar>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/04/17 10:16, Herbert Xu wrote:
> With the new explicit IV generators, we may now exceed the 64-byte
> length limit on the algorithm name, e.g., with
> 
> 	echainiv(authencesn(hmac(sha256-generic),cbc(des3_ede-generic)))
> 
> This patch extends the length limit to 128 bytes.
> 
> Reported-by: Alexander Sverdlin <alexander.sverdlin@nokia.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Alexander Sverdlin <alexander.sverdlin@nokia.com>
Tested-by: Alexander Sverdlin <alexander.sverdlin@nokia.com>

> ---
> 
>  include/linux/crypto.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/crypto.h b/include/linux/crypto.h
> index c0b0cf3..84da997 100644
> --- a/include/linux/crypto.h
> +++ b/include/linux/crypto.h
> @@ -123,7 +123,7 @@
>  /*
>   * Miscellaneous stuff.
>   */
> -#define CRYPTO_MAX_ALG_NAME		64
> +#define CRYPTO_MAX_ALG_NAME		128
>  
>  /*
>   * The macro CRYPTO_MINALIGN_ATTR (along with the void * type in the actual
> 

-- 
Best regards,
Alexander Sverdlin.
